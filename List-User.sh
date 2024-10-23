#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    
    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to check if a user has read access
function user_has_read_access {
    local user="$1"
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators/${user}/permission"
    
    # Fetch permissions for the user
    response="$(github_api_get "$endpoint")"
    
    # Check if the user has read access
    echo "$response" | jq -r '.permission == "read"'
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    
    # Fetch the list of collaborators on the repository
    collaborators="$(github_api_get "$endpoint" | jq -r '.[].login')"

    # Check each collaborator for read access
    read_users=()
    while IFS= read -r collaborator; do
        if user_has_read_access "$collaborator"; then
            read_users+=("$collaborator")
        fi
    done <<< "$collaborators"

    # Display the list of collaborators with read access
    if [[ ${#read_users[@]} -eq 0 ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        printf '%s\n' "${read_users[@]}"
    fi
}

# Main script

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
