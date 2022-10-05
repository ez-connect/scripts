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
# Required packages
# -----------------------------------------------------------------------------
function install_linux_packages() {
	sudo apt install make jq unzip
}

function install_osx_packages() {
	brew make install jq
}

# -----------------------------------------------------------------------------
# systemd
# -----------------------------------------------------------------------------
function create_systemd_service() {
	mkdir -p ~/.config/systemd/user/
	pushd ~/.config/systemd/user/

	# Create a simple service
	echo '[Unit]' > actions-runner.service
	echo 'Description=GitHub runner' >> actions-runner.service
	echo >> actions-runner.service

	echo '[Service]' >> actions-runner.service
	echo 'Type=simple' >> actions-runner.service
	echo 'Restart=always' >> actions-runner.service
	echo 'RestartSec=5s' >> actions-runner.service
	echo 'WorkingDirectory=/opt/actions-runner' >> actions-runner.service
	echo 'ExecStart=/opt/actions-runner/run.sh' >> actions-runner.service
	echo 'StandardOutput=syslog' >> actions-runner.service
	echo 'StandardError=syslog' >> actions-runner.service
	echo 'SyslogIdentifier=runner' >> actions-runner.service
	echo >> actions-runner.service

	echo '[Install]' >> actions-runner.service
	echo 'WantedBy=multi-user.target' >> actions-runner.service

	popd

	# Register
	systemctl --user daemon-reload
	systemctl --user list-unit-files actions-runner.service
	systemctl --user enable --now actions-runner.service
	systemctl --user status actions-runner
	# journalctl --user -f -u actions-runner
}

# -----------------------------------------------------------------------------
# launchd
# -----------------------------------------------------------------------------
function create_launchd_daemon() {
	pushd /Library/LaunchDaemons/

	echo '<?xml version="1.0" encoding="UTF-8"?>' | sudo tee com.github.actions-runner.plist
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' | sudo tee -a com.github.actions-runner.plist
	echo '<plist version="1.0">' | sudo tee -a com.github.actions-runner.plist
	echo '<dict>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<key>Label</key>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<string>com.github.actions.runner</string>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<key>ProgramArguments</key>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<array>' | sudo tee -a com.github.actions-runner.plist
	echo '\t\t<string>/opt/actions-runner/run.sh</string>' | sudo tee -a com.github.actions-runner.plist
	echo '\t</array>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<key>StandardOutPath</key>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<string>/tmp/actions-runner.stdout</string>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<key>StandardErrorPath</key>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<string>/tmp/actions-runner.stderr</string>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<key>RunAtLoad</key>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<true/>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<key>KeepAlive</key>' | sudo tee -a com.github.actions-runner.plist
	echo '\t<true/>' | sudo tee -a com.github.actions-runner.plist
	echo '</dict>' | sudo tee -a com.github.actions-runner.plist
	echo '</plist>' | sudo tee -a com.github.actions-runner.plist

	popd

	sudo launchctl load -w /Library/LaunchDaemons/com.github.actions-runner.plist
	sudo launchctl start com.github.actions.runner
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
if [ "${os}" == "linux" ]; then
	install_linux_packages
	create_systemd_service
elif [ "${os}" == "osx" ]; then
	install_osx_packages
	create_launchd_daemon
elif [ "${os}" == "win" ]; then
	echo 'Will be support windows services in the future'
fi
