#!/bin/bash
#
# Trigger a GitLab piple
#

# Help
function help() {
  echo 'Usage: ./gitlab-trigger-pipeline.sh PROJECT REF TOKEN'
  echo 'Trigger a GitLab piple'
  echo
  echo 'Example:'
  echo './gitlab-trigger-pipeline.sh 25187774 main 44Qbvvu2ETJzEAq9'
}

# Required args
if [ ! $# -eq 3 ]; then
  help
  exit 1
fi

# Args
projectID="$1"
ref="$2"
token="$3"

url="https://gitlab.com/api/v4/projects/${projectID}/trigger/pipeline"

curl -X POST -F token=${token} -F ref=${ref} ${url}
