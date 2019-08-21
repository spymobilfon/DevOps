#!/usr/bin/python3

from atlassian import Confluence

confluence = Confluence(
    url='http://localhost:8090',
    username='admin',
    password='111111')

result = confluence.create_page(
    space='TEST',
    title='Created title',
    body='Created body')

print(result)