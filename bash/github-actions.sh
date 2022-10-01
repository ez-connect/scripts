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

# -----------------------------------------------------------------------------
# Download
# -----------------------------------------------------------------------------
# Create a folder
sudo mkdir -p /opt/actions-runner
sudo chmod a+rw /opt/actions-runner
cd /opt/actions-runner

# Download the latest runner package
tag=$(get_github_latest_tag actions/runner)
version=$(echo ${tag} | sed 's/v//')

read -p 'Which runner image (linux-x64, osx-x64, osx-arm64, win-x64) [linux-x64]: ' image

curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/${tag}/actions-runner-${image}-${version}.tar.gz"

# Optional: Validate the hash
# echo "eb4e2fa6567d2222686be95ee23210e83fb6356dd0195149f96fd91398323d7f  actions-runner-linux-x64-2.297.0.tar.gz" | shasum -a 256 -c

# Extract the installer
tar xzf actions-runner.tar.gz
rm actions-runner-.tar.gz

# -----------------------------------------------------------------------------
# Configure
# -----------------------------------------------------------------------------
read -p 'Enter the org/repository [ez-connect]: ' input
repo=${input:-ez-connect}
read -p 'Enter the token: ' token

# Create the runner and start the configuration experience
./config.sh --url "https://github.com/${repo}" --token ${token}
# Last step, run it!
# ./run.sh

# -----------------------------------------------------------------------------
# systemd
# -----------------------------------------------------------------------------
mkdir -p ~/.config/systemd/user/

# Create a simple service
echo '[Unit]' > ~/.config/systemd/actions-runner.service
echo 'Description=GitHub runner' >>~/.config/systemd/actions-runner.service

echo '[Service]' >> ~/.config/systemd/actions-runner.service
echo 'Type=simple' >> ~/.config/systemd/actions-runner.service
echo 'Restart=always' >> ~/.config/systemd/actions-runner.service
echo 'RestartSec=5s' >> ~/.config/systemd/actions-runner.service
echo 'WorkingDirectory=/opt/actions-runner' >> ~/.config/systemd/actions-runner.service
echo 'ExecStart=/opt/actions-runner/run.sh' >> ~/.config/systemd/actions-runner.service
echo 'StandardOutput=syslog' >> ~/.config/systemd/actions-runner.service
echo 'StandardError=syslog' >> ~/.config/systemd/actions-runner.service
echo 'SyslogIdentifier=runner' >> ~/.config/systemd/actions-runner.service

echo '[Install]' >> ~/.config/systemd/actions-runner.service
echo 'WantedBy=multi-user.target' >> ~/.config/systemd/actions-runner.service

# Register
systemctl --user daemon-reload
systemctl --user list-unit-files actions-runner.service
systemctl --user enable --now actions-runner.service
systemctl --user status actions-runner
# journalctl -f -u actions-runner
