import sys
import xmlrpc.client
import pandas as pd

# Launch format:
# python .\update-list-VM.py "XML-RPS URL" "Login" "Password" "Page ID" "Space" "Title" "Parent ID" "CSV"

confluence = xmlrpc.client.ServerProxy(sys.argv[1])
auth = confluence.confluence2.login(sys.argv[2], sys.argv[3])

# https://developer.atlassian.com/server/confluence/remote-confluence-methods/

# Get current page info
current_page = confluence.confluence2.getPage(auth, sys.argv[4])
# Get current page version
current_version = current_page['version']

# Read list virtual machine
csv_file = pd.read_csv(sys.argv[8], encoding="UTF-8")
# Convert CSV to HTML
html_content = csv_file.to_html()

# Create page content
page_content = { "id": sys.argv[4],
                 "space": sys.argv[5],
                 "title": sys.argv[6],
                 "parentId": sys.argv[7],
                 "content": html_content,
                 "version": current_version }

# Create page
create_page = confluence.confluence2.storePage(auth,page_content)