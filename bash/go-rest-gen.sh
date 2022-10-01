#!/bin/bash
#
# Generate sources use `go-rest-gen`
# Usage: ./go-gen.sh
#

# Install go-watcher if not exists
if [ ! -x "$(command -v go-rest-gen)" ]; then
  echo 'Warn: `go-rest-gen` is not installed, install it.'
  go install github.com/ez-connect/go-rest/cmd/go-rest-gen
fi

# Generate
go-rest-gen
