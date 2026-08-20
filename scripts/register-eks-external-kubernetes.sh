#!/bin/bash
set -euo pipefail

export MORPHEUS_URL='<%=morpheus.applianceUrl%>'
export MORPHEUS_TOKEN='<%=morpheus.apiAccessToken%>'
export MORPHEUS_APP_ID='<%=app.id%>'

python3 - <<'PY'
import base64
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

base = os.environ["MORPHEUS_URL"].rstrip("/")
morpheus_token = os.environ["MORPHEUS_TOKEN"]
app_id = os.environ["MORPHEUS_APP_ID"]
morpheus_ssl = ssl._create_unverified_context()
morpheus_headers = {
    "Authorization": "BEARER " + morpheus_token,
    "Accept": "application/json",
    "Content-Type": "application/json",
}

def http_json(method, url, headers, payload=None, context=None, accepted=(200, 201)):
    data = None if payload is None else json.dumps(payload).encode()
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, context=context, timeout=60) as response:
            body = response.read().decode()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")
        if exc.code in accepted:
            return json.loads(detail) if detail else {}
        raise RuntimeError(f"{method} {url} failed with HTTP {exc.code}: {detail[:500]}")

def morpheus_request(method, path, payload=None):
    return http_json(method, base + path, morpheus_headers, payload, morpheus_ssl)

def decode_json_strings(value):
    if isinstance(value, str):
        stripped = value.strip()
        if stripped.startswith(("{", "[")):
            try:
                return decode_json_strings(json.loads(stripped))
            except Exception:
                return value
        return value
    if isinstance(value, list):
        return [decode_json_strings(item) for item in value]
    if isinstance(value, dict):
        return {key: decode_json_strings(item) for key, item in value.items()}
    return value

required = {
    "cluster_name",
    "cluster_endpoint_value",
    "cluster_certificate_authority_data",
    "morpheus_eks_bootstrap_token",
}

def find_outputs(value):
    if isinstance(value, dict):
        if required.issubset(value.keys()):
            return value
        for item in value.values():
            found = find_outputs(item)
            if found:
                return found
    elif isinstance(value, list):
        for item in value:
            found = find_outputs(item)
            if found:
                return found
    return None

def output_value(item):
    return item.get("value") if isinstance(item, dict) and "value" in item else item

state = decode_json_strings(morpheus_request("GET", f"/api/apps/{app_id}/state"))
outputs = find_outputs(state)
if not outputs:
    raise RuntimeError("Required Terraform outputs were not found in the Morpheus App state")

cluster_name = str(output_value(outputs["cluster_name"])).strip()
api_url = str(output_value(outputs["cluster_endpoint_value"])).strip().rstrip("/")
ca_data = str(output_value(outputs["cluster_certificate_authority_data"])).strip()
bootstrap_token = str(output_value(outputs["morpheus_eks_bootstrap_token"])).strip()
if not all((cluster_name, api_url, ca_data, bootstrap_token)):
    raise RuntimeError("Cluster name, API URL, CA data, or bootstrap token is empty")

existing = morpheus_request("GET", "/api/clusters?" + urllib.parse.urlencode({"name": cluster_name, "max": 100}))
matches = [item for item in existing.get("clusters", []) if item.get("name") == cluster_name]
if matches:
    print(f"External Kubernetes cluster already registered: {cluster_name} (id={matches[0]['id']})")
    sys.exit(0)

try:
    ca_pem = base64.b64decode(ca_data).decode()
except Exception as exc:
    raise RuntimeError("Terraform returned invalid EKS certificate-authority data") from exc
kube_ssl = ssl.create_default_context(cadata=ca_pem)
kube_headers = {
    "Authorization": "Bearer " + bootstrap_token,
    "Accept": "application/json",
    "Content-Type": "application/json",
}

def kube_request(method, path, payload=None, allow_conflict=False):
    accepted = (200, 201, 409) if allow_conflict else (200, 201)
    return http_json(method, api_url + path, kube_headers, payload, kube_ssl, accepted)

namespace = "kube-system"
service_account = "morpheus"
secret_name = "morpheus-token"
binding_name = "morpheus-cluster-admin"

kube_request("POST", f"/api/v1/namespaces/{namespace}/serviceaccounts", {
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {"name": service_account, "namespace": namespace},
}, allow_conflict=True)

kube_request("POST", "/apis/rbac.authorization.k8s.io/v1/clusterrolebindings", {
    "apiVersion": "rbac.authorization.k8s.io/v1",
    "kind": "ClusterRoleBinding",
    "metadata": {"name": binding_name},
    "roleRef": {
        "apiGroup": "rbac.authorization.k8s.io",
        "kind": "ClusterRole",
        "name": "cluster-admin",
    },
    "subjects": [{
        "kind": "ServiceAccount",
        "name": service_account,
        "namespace": namespace,
    }],
}, allow_conflict=True)

kube_request("POST", f"/api/v1/namespaces/{namespace}/secrets", {
    "apiVersion": "v1",
    "kind": "Secret",
    "metadata": {
        "name": secret_name,
        "namespace": namespace,
        "annotations": {"kubernetes.io/service-account.name": service_account},
    },
    "type": "kubernetes.io/service-account-token",
}, allow_conflict=True)

secret = {}
for _ in range(30):
    secret = kube_request("GET", f"/api/v1/namespaces/{namespace}/secrets/{secret_name}")
    if secret.get("data", {}).get("token"):
        break
    time.sleep(2)
else:
    raise RuntimeError("Kubernetes did not populate the Morpheus service-account token")

api_token = base64.b64decode(secret["data"]["token"]).decode()
kubeconfig = json.dumps({
    "apiVersion": "v1",
    "kind": "Config",
    "clusters": [{"name": cluster_name, "cluster": {
        "server": api_url,
        "certificate-authority-data": ca_data,
    }}],
    "contexts": [{"name": cluster_name, "context": {
        "cluster": cluster_name,
        "user": "morpheus",
    }}],
    "current-context": cluster_name,
    "users": [{"name": "morpheus", "user": {"token": api_token}}],
})

groups = morpheus_request("GET", "/api/groups?" + urllib.parse.urlencode({"name": "Dev", "max": 100})).get("groups", [])
clouds = morpheus_request("GET", "/api/zones?" + urllib.parse.urlencode({"name": "AWS-EKS", "max": 100})).get("zones", [])
layouts = morpheus_request("GET", "/api/library/cluster-layouts?" + urllib.parse.urlencode({"phrase": "External Kubernetes 1.34", "max": 100})).get("clusterLayouts", [])
group = next((item for item in groups if item.get("name") == "Dev"), None)
cloud = next((item for item in clouds if item.get("name") == "AWS-EKS"), None)
layout = next((item for item in layouts if item.get("name") == "External Kubernetes 1.34"), None)
if not group or not cloud or not layout:
    raise RuntimeError("Required Morpheus Group, Cloud, or External Kubernetes layout was not found")

payload = {"cluster": {
    "name": cluster_name,
    "type": {"code": "external-kubernetes-cluster"},
    "group": {"id": group["id"]},
    "cloud": {"id": cloud["id"]},
    "layout": {"id": layout["id"]},
    "plan": {"code": "external-default"},
    "server": {"config": {
        "apiUrl": api_url,
        "apiToken": api_token,
        "serviceAccess": kubeconfig,
    }},
}}
created = morpheus_request("POST", "/api/clusters", payload)
cluster = created.get("cluster", {})
if not cluster.get("id"):
    raise RuntimeError("Morpheus did not return a cluster ID after registration")
print(f"Registered External Kubernetes cluster: {cluster_name} (id={cluster['id']})")
PY
