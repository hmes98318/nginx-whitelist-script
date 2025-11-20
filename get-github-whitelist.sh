#!/bin/bash
#
# Required commands:
# - curl
# - jq


OUTPUT_FILE="/etc/nginx/conf.d/whitelist/github-ip-list.whitelist"

API_ENDPOINT="https://api.github.com/meta"
IP_KEYS=".hooks[], .web[], .api[], .git[], .github_enterprise_importer[], .packages[], .pages[], .importer[], .actions[], .actions_macos[], .codespaces[], .copilot[]"


# Fetch IP addresses from GitHub's API directly and extract them
api_response=$(curl -s "$API_ENDPOINT")

# Check if the API response was successful
if [ $? -ne 0 ] || [ -z "$api_response" ]; then
    echo "Error: Failed to fetch data from GitHub's API" >&2
    exit 1
fi

# Extract IP addresses from the response and append to the configuration file
ip_list=$(jq -r "$IP_KEYS" <<< "$api_response" | sort -u)
ip_count=$(echo "$ip_list" | wc -l)

{
    echo "# GitHub services IP addresses"
    echo "$ip_list" | while read -r ip_address; do
        echo "$ip_address  1;"
    done
} > "$OUTPUT_FILE" || {
    echo "Error: Failed to write to $OUTPUT_FILE" >&2
    exit 1
}


echo "Total IP addresses: $ip_count"
echo "GitHub IP address list has been updated in $OUTPUT_FILE"


# Optional: Reload Nginx
# if nginx -t; then
#     nginx -s reload
#     echo "Nginx configuration is valid and has been reloaded."
# else
#     echo "Error: Nginx configuration test failed! Please check your Nginx configuration." >&2
#     exit 1
# fi
