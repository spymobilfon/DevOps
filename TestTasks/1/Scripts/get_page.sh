#!/usr/bin/python3

from atlassian import Confluence

confluence = Confluence(
    url='http://localhost:8090',
    username='admin',
    password='111111')

result = confluence.get_page_by_id(
    page_id='65610')

print(result)