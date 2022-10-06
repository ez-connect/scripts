# !/bin/bash

# GitHub self-hosted runner
# https://github.com/organizations/<name>/settings/actions/runners/new

# -----------------------------------------------------------------------------
# The latest tag on GitHub
# -----------------------------------------------------------------------------
function get_github_latest_tag() {
    # curl -s "https://api.github.com/repos/$1/tags" | grep -oP '"name": "\K[\w.]+' | head -n 1
	curl -s "https://api.github.com/repos/$1/tags" | grep -oE '"name": ".*"' | head -n 1 | sed -e 's/[name :|"]//g'
}

function github_tag_to_version() {
	echo $1 | sed 's/v//'
}

# -----------------------------------------------------------------------------
# Download
# -----------------------------------------------------------------------------
# Create a folder
sudo mkdir -p /opt/actions-runner
sudo chmod a+rw /opt/actions-runner
cd /opt/actions-runner

# Download the latest runner packagecreate_systemd_service
read -p 'Which os (linux, osx, win) [linux]: ' input
os=${input:-linux}

read -p 'Which architect (x64, arm64) [x64]: ' input
architect=${input:-x64}
tag=$(get_github_latest_tag actions/runner)
version=$(github_tag_to_version ${tag})

curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/${tag}/actions-runner-${os}-${architect}-${version}.tar.gz"

# Optional: Validate the hash
# echo "eb4e2fa6567d2222686be95ee23210e83fb6356dd0195149f96fd91398323d7f  actions-runner-linux-x64-2.297.0.tar.gz" | shasum -a 256 -c

# Extract the installer
tar xzf actions-runner.tar.gz
rm actions-runner.tar.gz

# -----------------------------------------------------------------------------
# Configure
# -----------------------------------------------------------------------------
# Create the runner and start the configuration experience
./config.sh
# Last step, run it!
# ./run.sh

# -----------------------------------------------------------------------------
# Startup
# -----------------------------------------------------------------------------
# Service
./svc.sh install
./svc.sh start
