#!/usr/bin/bash

while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; sh page;} | nc -l -p 4321; done

