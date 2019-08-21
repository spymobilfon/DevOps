#!/usr/bin/python3

from atlassian import Confluence

confluence = Confluence(
    url='http://localhost:8090',
    username='admin',
    password='111111')

result = confluence.update_page(
    page_id='65610',
    title='Created title',
    body='New body')

print(result)