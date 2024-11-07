#!/bin/bash

###
# Usage: output=$(./log-explorer.sh --profile localstack) && echo "$output" | nvim -
###

# Default endpoint
DEFAULT_ENDPOINT="http://localhost:4566"
AWS_ENDPOINT=$DEFAULT_ENDPOINT

# Function to list log groups
list_log_groups() {
    aws --endpoint-url $AWS_ENDPOINT logs describe-log-groups --query "logGroups[].logGroupName" --output text | tr '\t' '\n'
}

# Function to list log streams in a selected log group
list_log_streams() {
    local log_group_name="$1"
    aws --endpoint-url $AWS_ENDPOINT logs describe-log-streams --log-group-name "$log_group_name" --query "logStreams[].logStreamName" --output text | tr '\t' '\n'
}

# Function to get log stream contents as JSON (no additional messages)
get_log_stream_contents() {
    local log_group_name="$1"
    local log_stream_name="$2"
    aws --endpoint-url $AWS_ENDPOINT logs get-log-events --log-group-name "$log_group_name" --log-stream-name "$log_stream_name" --output json
}

# Function to display usage instructions
usage() {
    echo "Usage: $0 [--profile <profile>] [--endpoint <endpoint>]"
    echo "  --profile: AWS profile to use (from your AWS credentials)"
    echo "  --endpoint: AWS endpoint URL (default: http://localhost:4566)"
    exit 1
}

# Initialize AWS_PROFILE to "default"
AWS_PROFILE="default"
profile_set=false

# Parse optional flags
while [[ "$1" == --* || "$1" == -* ]]; do
    case "$1" in
        --profile)
            shift
            if [ -z "$1" ]; then
                echo "Error: --profile flag requires a profile name."
                usage
            fi
            export AWS_PROFILE="$1"
            profile_set=true
            shift
            ;;
        --endpoint)
            shift
            if [ -z "$1" ]; then
                echo "Error: --endpoint flag requires an endpoint URL."
                usage
            fi
            AWS_ENDPOINT="$1"
            shift
            ;;
        *)
            echo "Error: Unknown flag $1"
            usage
            ;;
    esac
done

# Output message if using default endpoint
if [ "$AWS_ENDPOINT" == "$DEFAULT_ENDPOINT" ]; then
    echo "Using default endpoint for localstack: $DEFAULT_ENDPOINT" > /dev/tty
fi

# Output message if using default profile
if [ "$profile_set" = false ]; then
    echo "Using default AWS profile: $AWS_PROFILE" > /dev/tty
fi

# Step 1: List log groups
log_groups=($(list_log_groups))
if [ ${#log_groups[@]} -eq 0 ]; then
    echo "No log groups found."
    exit 1
fi

# Display the log groups and let the user select one
echo "Select a log group:" > /dev/tty
select log_group in "${log_groups[@]}"; do
    if [ -n "$log_group" ]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Step 2: List log streams for the selected log group
log_streams=($(list_log_streams "$log_group"))
if [ ${#log_streams[@]} -eq 0 ]; then
    echo "No log streams found for log group: $log_group."
    exit 1
fi

# Display the log streams and let the user select one
echo "Select a log stream:" >> /dev/tty
select log_stream in "${log_streams[@]}"; do
    if [ -n "$log_stream" ]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Only output the JSON from the selected log stream
get_log_stream_contents "$log_group" "$log_stream"
