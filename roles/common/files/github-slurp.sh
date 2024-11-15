#!/bin/bash

# Check for required arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <owner> <repo>"
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

# Fetch all releases and select the most recent one
ALL_RELEASES_URL="${GITHUB_API}/repos/${OWNER}/${REPO}/releases"
RELEASE_DATA=$(fetch_release_data "$ALL_RELEASES_URL" | jq -c '.[0]')

# Extract release tag
TAG=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
if [[ "$TAG" == "null" ]]; then
    echo "Error: Unable to fetch release tag. Ensure the repository exists and has releases."
    exit 1
fi
echo "Selected release tag: $TAG"

# Extract asset URLs
ASSET_URLS=$(echo "$RELEASE_DATA" | jq -r '.assets[].browser_download_url')
if [[ -z "$ASSET_URLS" ]]; then
    echo "No assets found for release ${TAG}. Check repository and release settings."
    exit 1
fi

# Create output directory
echo "Creating output directory at ${OUTPUT_DIR}..."
mkdir -p "$OUTPUT_DIR"

# Download all assets
echo "Downloading assets to ${OUTPUT_DIR}..."
for URL in $ASSET_URLS; do
    FILENAME=$(basename "$URL")
    echo "Downloading $URL..."
    curl -L -o "$OUTPUT_DIR/$FILENAME" "$URL"
done

# Uncompress compressed files
echo "Uncompressing any compressed files..."
for FILE in "$OUTPUT_DIR"/*; do
    if [[ "$FILE" =~ \.zip$ ]]; then
        echo "Unzipping $FILE..."
        unzip -o "$FILE" -d "$OUTPUT_DIR"
    elif [[ "$FILE" =~ \.tar$ ]]; then
        echo "Extracting $FILE..."
        tar -xf "$FILE" -C "$OUTPUT_DIR"
    elif [[ "$FILE" =~ \.tar\.gz$|\.tgz$ ]]; then
        echo "Extracting $FILE..."
        tar -xzf "$FILE" -C "$OUTPUT_DIR"
    elif [[ "$FILE" =~ \.gz$ && ! "$FILE" =~ \.tar\.gz$ ]]; then
        echo "Decompressing $FILE..."
        gunzip -f "$FILE"
    fi
done

# Change permissions to 755
echo "Changing permissions of downloaded files to 755..."
chmod 755 "$OUTPUT_DIR"/*

echo "All assets downloaded to ${OUTPUT_DIR}, permissions set to 755, and compressed files uncompressed."
