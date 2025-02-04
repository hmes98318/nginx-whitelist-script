#!/bin/bash
#
# Required commands:
# - curl
# - jq


OUTPUT_FILE="/etc/nginx/conf.d/github-ip-list.whitelist"

API_ENDPOINT="https://api.github.com/meta"
IP_KEYS=".hooks[], .web[], .api[], .git[], .github_enterprise_importer[], .packages[], .pages[], .importer[], .actions[], .actions_macos[], .codespaces[], .dependabot[], .copilot[]"


# Fetch IP addresses from GitHub's API directly and extract them
api_response=$(curl -s "$API_ENDPOINT")

# Check if the API response was successful
if [ $? -ne 0 ] || [ -z "$api_response" ]; then
    echo "Error: Failed to fetch data from GitHub's API" >&2
    exit 1
fi

# Extract IP addresses from the response and append to the configuration file
if ! echo "# GitHub services IP addresses" > "$OUTPUT_FILE"; then
    echo "Error: Failed to write to $OUTPUT_FILE" >&2
    exit 1
fi

jq -r "$IP_KEYS" <<< "$api_response" | while read -r ip_address; do
    if ! echo "allow $ip_address;" >> "$OUTPUT_FILE"; then
        echo "Error: Failed to write IP to $OUTPUT_FILE" >&2
        exit 1
    fi
done


echo "GitHub IP address list has been updated in $OUTPUT_FILE"


# Optional: Reload Nginx
# if nginx -t; then
#     nginx -s reload
#     echo "Nginx configuration is valid and has been reloaded."
# else
#     echo "Error: Nginx configuration test failed! Please check your Nginx configuration." >&2
#     exit 1
# fi
