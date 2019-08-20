#!/usr/bin/python3

import requests
from bs4 import BeautifulSoup

request_url=requests.get("http://localhost:8090/confluence/rest/api/content/", auth=("admin", "111111"))

if request_url.status_code==200:
    text=BeautifulSoup(request_url.text, 'html.parser')
    check=text.find("meta",{"content":"admin"}).get("content")
    if check=="admin":
        print("Confluence is OK")
    else:
        print("Problem with Confluence")
else:
    print("Problem with Confluence")