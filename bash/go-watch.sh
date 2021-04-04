#!/bin/bash
#
# Watch use `go-watcher`
# Usage: ./go-watcher.sh
#

# Install go-watcher if not exists
if [ ! -x "$(command -v watcher)" ]; then
  echo 'Warn: `watcher` is not installed, install it.'
  go install github.com/canthefason/go-watcher/cmd/watcher
fi

# Remove all watcher xecutes
for e in "$GOPATH/bin/watcher-.*"; do
  if [ -f "${e}" ]; then
    rm ${e}
  fi
done

# Watch
watcher
