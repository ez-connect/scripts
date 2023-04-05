#!/bin/sh

# GitHub self-hosted runner
# https://github.com/organizations/<name>/settings/actions/runners/new

# ---------------------------------------------------------
# The latest tag on GitHub
# ---------------------------------------------------------
get_github_latest_tag() {
    # curl -s "https://api.github.com/repos/$1/tags" | grep -oP '"name": "\K[\w.]+' | head -n 1
	curl -s "https://api.github.com/repos/$1/tags" | grep -oE '"name": ".*"' | head -n 1 | sed -e 's/[name :|"]//g'
}

github_tag_to_version() {
	echo $1 | sed 's/v//'
}

# ---------------------------------------------------------
# Download
# ---------------------------------------------------------
# Create a folder
sudo mkdir -p ~/actions-runner
cd ~/actions-runner

# Download the latest runner packagecreate_systemd_service
read -p 'Which os (linux, osx, win) [linux]: ' input
os=${input:-linux}

read -p 'Which architect (x64, arm64) [x64]: ' input
architect=${input:-x64}
tag=$(get_github_latest_tag actions/runner)
version=$(github_tag_to_version ${tag})

curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/${tag}/actions-runner-${os}-${architect}-${version}.tar.gz"

# Extract the installer
tar xzf actions-runner.tar.gz
rm actions-runner.tar.gz

# ---------------------------------------------------------
# Configure
# ---------------------------------------------------------
# Create the runner and start the configuration experience
./config.sh
# Last step, run it!
# ./run.sh

# ---------------------------------------------------------
# Install required packages
# ---------------------------------------------------------
package_management=apt
if [ "${os}" == "osx" ]; then
	package_management=brew
elif [ "${os}" == "win" ]; then
	package_management=scoop
fi

read -p "Which is your package management [${package_management}]: " input
package_management=${input:-${package_management}}

"${package_management} install make jq podman"

# ---------------------------------------------------------
# Startup
# ---------------------------------------------------------
# Service
./svc.sh install
./svc.sh start
