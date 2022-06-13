# Install Python modules
# pip install --upgrade pip --user
# pip install azure-identity
# pip install azure-mgmt-containerservice
# pip install kubernetes
# pip install json2html
# pip install atlassian-python-api

# Set environment variables
# AZURE_TENANT_ID
# AZURE_CLIENT_ID
# AZURE_CLIENT_SECRET
# AZURE_SUBSCRIPTION_ID
# CONFLUENCE_TOKEN
# W_HTTP_PROXY

import os
import json
import html
from azure.identity import DefaultAzureCredential
from azure.mgmt.containerservice import ContainerServiceClient
from kubernetes import client, config
from json2html import *
from atlassian import Confluence

subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID", "")
kl_proxy = os.environ.get("W_HTTP_PROXY", "")
kl_no_proxy = "localhost, 127.0.0.*, 10.*, 192.168.*"
confluence_token = os.environ.get("CONFLUENCE_TOKEN", "")
confluence_url = "https://confluence.example.com"
confluence_parent_id = "762165596" # Whitelist ingress traffic for services
confluence_title_main = "AKS whitelist ingress traffic for services at runtime"
if subscription_id == "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx":
    confluence_title_env = "DEV"
elif subscription_id == "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx":
    confluence_title_env = "PROD"
else:
    confluence_title_env = "Unknown"
confluence_title = confluence_title_main + " (" + confluence_title_env + ")"
temp_kubeconfig_path = "./kubeconfig.tmp"
html_path = "./aks_whitelist.html"
data_list = []
aks = [
    {
        "aks_name": "aks-name",
        "resource_group": "aks-resource-group-name"
    }
]
networks = [
    {
        "network": "ip-or-network",
        "description": "ip-or-network-description"
    },
    {
        "network": "127.0.0.1",
        "description": "localhost"
    },
    {
        "network": "0.0.0.0/0",
        "description": "All networks"
    }
]

def get_kubeconfig(subscription_id, resource_group, aks_name):
    credential = DefaultAzureCredential(exclude_environment_credential=False,
                                        exclude_managed_identity_credential=True,
                                        exclude_powershell_credential=True,
                                        exclude_visual_studio_code_credential=True,
                                        exclude_shared_token_cache_credential=True)
    container_service_client = ContainerServiceClient(credential, subscription_id)
    kubeconfig = container_service_client.managed_clusters.list_cluster_user_credentials(resource_group, aks_name).kubeconfigs[0].value
    return kubeconfig

def load_kubeconfig(subscription_id, resource_group, aks_name, kubeconfig_path):
    with open(kubeconfig_path, "wb") as kubeconfig:
        kubeconfig.write(get_kubeconfig(subscription_id, resource_group, aks_name))

    config.load_config(config_file=kubeconfig_path, context=aks_name)

    if os.path.exists(kubeconfig_path):
        os.remove(kubeconfig_path)
    else:
        print("The file with temp kubeconfig does not exist")

def get_whitelist(aks_name):
    cluster = aks_name
    cluster_data_list = []

    api_client = client.NetworkingV1Api()
    api_responce = api_client.list_ingress_for_all_namespaces(watch=False)

    for item in api_responce.items:
        try:
            host = item.spec.rules[0].host
        except:
            host = "-"
        try:
            ip = item.status.load_balancer.ingress[0].ip
        except:
            ip = "-"
        try:
            namespace = item.metadata.namespace
        except:
            namespace = "-"
        try:
            network_with_description = []
            whitelist_list = (item.metadata.annotations["nginx.ingress.kubernetes.io/whitelist-source-range"]).split(",")
            for whitelist_item in whitelist_list:
                for net in networks:
                    if whitelist_item == net["network"]:
                        network_with_description.append(net["network"] + " (" + net["description"] + ")<br/>")
            whitelist = "".join(network_with_description)
        except:
            whitelist = "0.0.0.0/0 (All networks)"
        data = {
            "host": host,
            "ip": ip,
            "cluster": cluster,
            "namespace": namespace,
            "whitelist": whitelist
        }
        cluster_data_list.append(data)

    return cluster_data_list

def json_html(data_json):
    data_table = json2html.convert(json = data_json, escape=False, table_attributes="border=\"1\" style=\"border: 1px solid black; border-collapse: collapse;\"")
    # with open(html_path, "w") as html:
    #     html.write(data_table)
    return data_table

def push_confluence(confluence_url, confluence_token, confluence_parent_id, confluence_title, confluence_body):
    confluence = Confluence(url = confluence_url, token = confluence_token, verify_ssl=False)
    body = html.unescape(confluence_body)
    confluence.update_or_create(parent_id = confluence_parent_id, title = confluence_title, body = body)

# os.environ["http_proxy"] = kl_proxy
# os.environ["https_proxy"] = kl_proxy
# os.environ["no_proxy"] = kl_no_proxy

for item in aks:
    aks_name = item["aks_name"]
    resource_group = item["resource_group"]

    load_kubeconfig(subscription_id, resource_group, aks_name, temp_kubeconfig_path)

    data_list.extend(get_whitelist(aks_name))

data_json = json.dumps(data_list)
push_confluence(confluence_url, confluence_token, confluence_parent_id, confluence_title, json_html(data_json))
