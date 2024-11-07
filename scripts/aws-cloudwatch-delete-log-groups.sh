#!/bin/bash

# Default profile and endpoint
PROFILE="default"
ENDPOINT="http://localhost:4566"

# Flags to check if profile and endpoint are provided
PROFILE_PROVIDED=false
ENDPOINT_PROVIDED=false

# Check if profile and endpoint are provided as arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --profile) PROFILE="$2"; PROFILE_PROVIDED=true; shift ;;
        --endpoint) ENDPOINT="$2"; ENDPOINT_PROVIDED=true; shift ;;
    esac
    shift
done

# Notify if default profile or endpoint are used
if ! $PROFILE_PROVIDED; then
    echo "No profile provided. Using default profile: $PROFILE"
else
    echo "Using profile: $PROFILE"
fi

if ! $ENDPOINT_PROVIDED; then
    echo "No endpoint provided. Using default endpoint: $ENDPOINT"
else
    echo "Using endpoint: $ENDPOINT"
fi

# List all log groups
log_groups=$(aws --profile "$PROFILE" --endpoint-url="$ENDPOINT" logs describe-log-groups --query 'logGroups[*].logGroupName' --output text)

# Iterate over each log group and delete it
for log_group in $log_groups; do
  echo "Deleting log group: $log_group"
  aws --profile "$PROFILE" --endpoint-url="$ENDPOINT" logs delete-log-group --log-group-name "$log_group"
done

echo "All log groups deleted."

