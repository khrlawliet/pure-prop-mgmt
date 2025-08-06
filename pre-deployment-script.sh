#!/bin/bash

# Service Pre-Deployment Check Script
# 
# PURPOSE:
# This script validates service deployments by checking if artifacts are available
# in the artifactory before deployment. It reads a manifest file containing service
# paths, extracts version information from each service directory, and verifies
# artifact availability via API calls.
#
# USAGE:
# ./check-deployment.sh <manifest_file>
#
# MANIFEST FILE FORMAT:
# The manifest file should contain one service directory path per line:
# /path/to/service1
# /path/to/service2
# /path/to/service3
#
# VERSION DETECTION:
# The script looks for version information in the following order:
# 1. version.txt file in the service directory
# 2. version field in package.json file
# 3. Defaults to "unknown" if neither is found
#
# OUTPUT:
# Generates a report showing each service's name, version, and artifact status

set -euo pipefail # Exit on error, undefined vars, and pipe failures

ARTIFACTORY_URL="https://mock-check-artifact.vercel.app/check-artifact"

# Display usage information and exit
usage() {
    echo -e "\033[0;31mUsage: $0 <manifest_file>\033[0m"
    exit 1
}

# Extract version from service directory
get_version() {
    local dir="$1"
    
    # Check for version.txt file first
    [[ -f "$dir/version.txt" ]] && {
        cat "$dir/version.txt"
        return
    }

    # Check for package.json with version field
    [[ -f "$dir/package.json" ]] && {
        jq -r '.version // empty' "$dir/package.json" 2>/dev/null || echo "unknown"
        return
    }
    
    # Default to unknown if no version source found
    echo "unknown"
}

# Check artifact availability in artifactory
check_artifact() {
    local service="$1" version="$2"
    
    # Skip check for unknown versions
    [[ "$version" == "unknown" ]] && { echo "n/a"; return; }
    
    # Make API call to check artifact status
    local response
    response=$(curl -s "$ARTIFACTORY_URL/$service/$version" 2>/dev/null) || {
        echo "error_checking_artifact"
        return
    }
    
    # Parse JSON response to get status
    local status
    status=$(jq -r '.status' <<< "$response" 2>/dev/null) || {
        echo "error_checking_artifact"
        return
    }
    
    # Return normalized status
    case "$status" in
        available|unavailable) echo "$status" ;;
        *) echo "error_checking_artifact" ;;
    esac
}

# Process individual service and generate report entry
process_service() {
    local path="$1"
    local service version artifact
    
    service=$(basename "$path") # Extract service name from path

    # Validate service directory exists
    [[ -d "$path" ]] || { echo -e "\033[0;31mDirectory does not exist: $path\033[0m"; return 1; }
    
    # Get version and check artifact availability
    version=$(get_version "$path")
    artifact=$(check_artifact "$service" "$version")
    
    # Output service information
    echo "Service: $service"
    echo "Version: $version"
    echo "Artifact: $artifact"
    echo "------------------------------------"
}

# Main execution function
main() {
    # Validate command line arguments
    [[ $# -eq 1 ]] || usage
    
    local manifest="$1"
    # Check if manifest file exists
    [[ -f "$manifest" ]] || { echo -e "\033[0;31mManifest file not found: $manifest\033[0m"; exit 1; }

    echo "Service Pre-Deployment Check Report:"
    echo "===================================="
    
    # Process each service listed in manifest
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -n "$line" ]] && process_service "$line" # Skip empty lines
    done < "$manifest"
    
    echo "===================================="
}

main "$@"