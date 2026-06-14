#!/bin/bash
cd /tmp
echo "<h1>Hello world</h1>" > index.html
nohup python3 -m http.server 8080 &