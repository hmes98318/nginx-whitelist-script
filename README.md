# nginx-whitelist-script

This repository contains scripts for converting IP addresses of specific services into Nginx configuration files, allowing only those IPs to access the services.  


* [`get-github-whitelist.sh`](./get-github-whitelist.sh)  
This script fetches the list of IP addresses used by GitHub services (such as GitHub Actions, web, API, etc.) and generates an Nginx whitelist configuration file.
