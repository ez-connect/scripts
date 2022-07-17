# !/bin/sh

###############################################################################
# A simple script to help to install packages for Alpine/Debian OCIs
#
# Usage: ./install.sh [packages...]
###############################################################################

distro=$(grep -oE '^ID=\w+' /etc/os-release | sed 's/ID=//')
install_cmd='apt install -y'
bin_path='/usr/local/bin'

if [ "$distro" = "alpine" ]; then
  install_cmd='apk add --no-cache'
fi

echo "distro=${distro}"
echo "Install command=${install_cmd}"

###############################################################################
# The latest tag on GitHub
###############################################################################
function get_github_latest_tag() {
    # curl -s "https://api.github.com/repos/$1/tags" | grep -oP '"name": "\K[\w.]+' | head -n 1
	curl -s "https://api.github.com/repos/$1/tags" | grep -oE '"name": ".*"' | head -n 1 | sed -e 's/[name :|"]//g'
}

###############################################################################
# Kubernetes
###############################################################################
# kubectl
function install_kubectl() {
    curl -Lo ${bin_path}/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ${bin_path}/kubectl
}

function install_helm() {
	curl -s 'https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3' | sh
}

###############################################################################
# Web
###############################################################################
# gohugo
function install_hugo() {
	tag=$(get_github_latest_tag gohugoio/hugo)
	version=$(echo ${tag} | sed 's/v//')
	echo "Version=${tag}"

    curl -Lo hugo.tar.gz "https://github.com/gohugoio/hugo/releases/download/${tag}/hugo_extended_${version}_Linux-64bit.tar.gz"
    mkdir -p hugo
    tar -xf hugo.tar.gz -C hugo
    chmod +x hugo/hugo
    mv hugo/hugo ${bin_path}/
    rm -rf hugo.tar.gz hugo/
}

###############################################################################
# Postgres
###############################################################################
function install_pg_jobmon() {
	tag=$(get_github_latest_tag omniti-labs/pg_jobmon)
	version=$(echo ${tag} | sed 's/v//')

	curl -Lo pg_jobmon.tar.gz "https://github.com/omniti-labs/pg_jobmon/archive/refs/tags/${tag}.tar.gz"
	tar -xf pg_jobmon.tar.gz
	rm pg_jobmon.tar.gz
	cd "pg_jobmon-${version}"
	make && make install
	cd ..
	rm -rf "pg_jobmon-${version}"
}

function install_pg_partman() {
	tag=$(get_github_latest_tag pgpartman/pg_partman)
	version=$(echo ${tag} | sed 's/v//')

    curl -Lo pg_partman.tar.gz "https://github.com/pgpartman/pg_partman/archive/refs/tags/${tag}.tar.gz"
    tar -x -f pg_partman.tar.gz
    rm pg_partman.tar.gz
    cd "pg_partman-${version}"
    make && make install
    cd ..
    rm -rf "pg_partman-${version}"
}

function install_pg_cron() {
	package=postgresql-13-cron
	if [ "$distro" = "alpine" ]; then
    	package=postgresql-pg_cron
	fi

	${install_cmd} ${package}
}

###############################################################################
# Text search
###############################################################################
function install_typesense() {
	tag=$(get_github_latest_tag typesense/typesense)
	version=$(echo ${tag} | sed 's/v//')

	echo "Version=${tag}"

    curl -Lo typesense-server.tar.gz "https://dl.typesense.org/releases/${version}/typesense-server-${version}-linux-amd64.tar.gz"
    tar -xf typesense-server.tar.gz
    rm typesense-server.tar.gz
	chmod +x typesense-server
	mv typesense-server ${bin_path}/
}

function install() {
    if [ -z "$@" ]; then
        echo "No packages specified"
        exit 1
    fi

    for package in "$@"
    do
        echo "Installing ${package}"
        case "${package}" in
            kubectl)    install_kubectl;;
			helm)		install_helm;;
            hugo)       install_hugo;;
			pg_jobmon)	install_pg_jobmon;;
			pg_partman)	install_pg_partman;;
			pg_cron)	install_pg_cron;;
			typesense) 	install_typesense;;
            *)
                # "Use the distro install command"
                ${install_cmd} ${package}
                ;;
        esac
    done
}

install "$@"
