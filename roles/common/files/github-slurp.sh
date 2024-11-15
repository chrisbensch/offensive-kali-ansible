#!/bin/bash

# Check for required arguments
if [[ $# -lt 2 ]]; then
    exit 1
fi

# Variables
OWNER="$1"
REPO="$2"
GITHUB_API="https://api.github.com"
GITHUB_TOKEN="" # Optional: Add a GitHub token if rate limits are hit.
OUTPUT_DIR="/opt/${REPO}"

# Authorization header for GitHub API
AUTH_HEADER=""
if [[ -n "$GITHUB_TOKEN" ]]; then
    AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
fi

# Function to fetch release data
fetch_release_data() {
    local url="$1"
    curl -s -H "${AUTH_HEADER}" "$url"
}

# Try fetching the latest release
LATEST_RELEASE_URL="${GITHUB_API}/repos/${OWNER}/${REPO}/releases/latest"
RELEASE_DATA=$(fetch_release_data "$LATEST_RELEASE_URL")

# If the latest release fails, fall back to the first pre-release
if [[ -z "$RELEASE_DATA" || "$(echo "$RELEASE_DATA" | jq -r '.tag_name')" == "null" ]]; then
    echo "Latest release not found. Trying pre-releases..."
    ALL_RELEASES_URL="${GITHUB_API}/repos/${OWNER}/${REPO}/releases"
    RELEASE_DATA=$(fetch_release_data "$ALL_RELEASES_URL" | jq -c '[.[] | select(.prerelease)][0]')
fi

# Extract release tag
TAG=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
if [[ "$TAG" == "null" ]]; then
    exit 1
fi

# Extract asset URLs
ASSET_URLS=$(echo "$RELEASE_DATA" | jq -r '.assets[].browser_download_url')
if [[ -z "$ASSET_URLS" ]]; then
    echo "No assets found for release ${TAG}. Check repository and release settings."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Download all assets
for URL in $ASSET_URLS; do
    FILENAME=$(basename "$URL")
    curl -L -o "$OUTPUT_DIR/$FILENAME" "$URL"
done

# Uncompress compressed files
for FILE in "$OUTPUT_DIR"/*; do
    if [[ "$FILE" =~ \.zip$ ]]; then
        unzip -o "$FILE" -d "$OUTPUT_DIR"
    elif [[ "$FILE" =~ \.tar$ ]]; then
        tar -xf "$FILE" -C "$OUTPUT_DIR"
    elif [[ "$FILE" =~ \.tar\.gz$|\.tgz$ ]]; then
        tar -xzf "$FILE" -C "$OUTPUT_DIR"
    elif [[ "$FILE" =~ \.gz$ && ! "$FILE" =~ \.tar\.gz$ ]]; then
        gunzip -f "$FILE"
    fi
done

# Change permissions to 755
chmod 755 "$OUTPUT_DIR"/*

# Done
