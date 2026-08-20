#!/bin/bash
set -euo pipefail

export MORPHEUS_URL='<%=morpheus.applianceUrl%>'
export MORPHEUS_TOKEN='<%=morpheus.apiAccessToken%>'
export MORPHEUS_APP_ID='<%=app.id%>'

python3 - <<'PY'
import json
import os
import ssl
import sys
import urllib.parse
import urllib.request
import urllib.error

base = os.environ["MORPHEUS_URL"].rstrip("/")
token = os.environ["MORPHEUS_TOKEN"]
app_id = os.environ["MORPHEUS_APP_ID"]
ssl_context = ssl._create_unverified_context()
headers = {
    "Authorization": "BEARER " + token,
    "Accept": "application/json",
    "Content-Type": "application/json",
}

def request(method, path, payload=None):
    data = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request(base + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, context=ssl_context, timeout=60) as response:
            body = response.read().decode()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")
        raise RuntimeError(f"{method} {path} failed with HTTP {exc.code}: {detail[:500]}")

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
    "morpheus_service_account_token",
    "morpheus_kubeconfig",
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

state = decode_json_strings(request("GET", f"/api/apps/{app_id}/state"))
outputs = find_outputs(state)
if not outputs:
    raise RuntimeError("Terraform outputs were not found in the Morpheus App state")

cluster_name = str(output_value(outputs["cluster_name"])).strip()
api_url = str(output_value(outputs["cluster_endpoint_value"])).strip()
api_token = str(output_value(outputs["morpheus_service_account_token"])).strip()
kubeconfig = str(output_value(outputs["morpheus_kubeconfig"]))

if not all((cluster_name, api_url, api_token, kubeconfig)):
    raise RuntimeError("One or more required Terraform outputs are empty")

existing = request("GET", "/api/clusters?" + urllib.parse.urlencode({"name": cluster_name, "max": 100}))
matches = [item for item in existing.get("clusters", []) if item.get("name") == cluster_name]
if matches:
    print(f"External Kubernetes cluster already registered: {cluster_name} (id={matches[0]['id']})")
    sys.exit(0)

groups = request("GET", "/api/groups?" + urllib.parse.urlencode({"name": "Dev", "max": 100})).get("groups", [])
clouds = request("GET", "/api/zones?" + urllib.parse.urlencode({"name": "AWS-EKS", "max": 100})).get("zones", [])
layouts = request("GET", "/api/library/cluster-layouts?" + urllib.parse.urlencode({"phrase": "External Kubernetes 1.34", "max": 100})).get("clusterLayouts", [])

group = next((item for item in groups if item.get("name") == "Dev"), None)
cloud = next((item for item in clouds if item.get("name") == "AWS-EKS"), None)
layout = next((item for item in layouts if item.get("name") == "External Kubernetes 1.34"), None)

if not group or not cloud or not layout:
    raise RuntimeError("Required Morpheus Group, Cloud, or External Kubernetes layout was not found")

payload = {
    "cluster": {
        "name": cluster_name,
        "type": {"code": "external-kubernetes-cluster"},
        "group": {"id": group["id"]},
        "cloud": {"id": cloud["id"]},
        "layout": {"id": layout["id"]},
        "plan": {"code": "external-default"},
        "server": {
            "config": {
                "apiUrl": api_url,
                "apiToken": api_token,
                "serviceAccess": kubeconfig,
            }
        },
    }
}

created = request("POST", "/api/clusters", payload)
cluster = created.get("cluster", {})
if not cluster.get("id"):
    raise RuntimeError("Morpheus did not return a cluster ID after registration")

print(f"Registered External Kubernetes cluster: {cluster_name} (id={cluster['id']})")
PY
