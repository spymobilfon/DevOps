from pyzabbix import ZabbixAPI
import os
import sys
import csv

csv_path = 'C:/path_to_file/zabbix_hosts.csv'
header = ['name', 'dns', 'ip']
rows = []

zabbix_api = ZabbixAPI('https://fqdn_of_zabbix', user='user1', password='password1')
hosts = zabbix_api.host.get(sortfield='name', output=['hostid','name'])
for host in hosts:
    host_name = host['name']
    host_interface = zabbix_api.hostinterface.get(hostids=host['hostid'], output=['interfacesid','dns','ip'])
    host_dns = host_interface[0]["dns"]
    host_ip = host_interface[0]['ip']
    rows.append([host_name, host_dns, host_ip])

with open(csv_path, 'wt', newline='') as csv_file:
    write_file = csv.writer(csv_file)
    write_file.writerow(header)
    write_file.writerows(rows)
csv_file.close()