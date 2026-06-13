#!/bin/bash
cd /tmp
echo "<h1>Hello world</h1>" > index.html
echo "<p>DB Address: ${db_address}</p>" >> index.html
echo "<p>DB Port: ${db_port}</p>" >> index.html
nohup python3 -m http.server 8080 &