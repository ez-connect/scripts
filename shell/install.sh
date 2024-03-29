#!/bin/sh

# -----------------------------------------------------------------------------
# A simple script to help to install packages for Alpine/Debian OCIs
#
# Usage: ./install.sh [packages...]
# -----------------------------------------------------------------------------

os_id=$(grep -oE '^ID=\w+' /etc/os-release | sed 's/ID=//')
install_cmd=''
bin_path='/usr/local/bin'

if [ "$os_id" = "alpine" ]; then
	install_cmd='apt install -y'
elif [ "$os_id" = "alpine" ]; then
  	install_cmd='apk add --no-cache'
else
	install_cmd='pacman -S'
fi

echo "OS ID: ${os_id}"
echo "Install command: ${install_cmd}"

# -----------------------------------------------------------------------------
# The latest tag on GitHub
# -----------------------------------------------------------------------------
get_github_latest_tag() {
	curl -s "https://api.github.com/repos/$1/tags" | grep -oE '"name": ".*"' | head -n 1 | sed -e 's/[name :|"]//g'
}

github_tag_to_version() {
	echo $1 | sed 's/v//'
}

# -----------------------------------------------------------------------------
# Kubernetes
# -----------------------------------------------------------------------------
# Kubectl
install_kubectl() {
  curl -Lo ${bin_path}/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ${bin_path}/kubectl
}

# Helm
install_helm() {
	curl -s 'https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3' | sh
}

# -----------------------------------------------------------------------------
# Web
# -----------------------------------------------------------------------------
# gohugo
install_hugo() {
	tag=$(get_github_latest_tag gohugoio/hugo)
	version=$(get_github_version ${tag})
	echo "Version=${tag}"

  curl -Lo hugo.tar.gz "https://github.com/gohugoio/hugo/releases/download/${tag}/hugo_extended_${version}_Linux-64bit.tar.gz"
  mkdir -p hugo
  tar -xf hugo.tar.gz -C hugo
  chmod +x hugo/hugo
  mv hugo/hugo ${bin_path}/
  rm -rf hugo.tar.gz hugo/
}

# -----------------------------------------------------------------------------
# Postgres
# -----------------------------------------------------------------------------
install_pg_jobmon {
	tag=$(get_github_latest_tag omniti-labs/pg_jobmon)
	version=$(github_tag_to_version ${tag})

	curl -Lo pg_jobmon.tar.gz "https://github.com/omniti-labs/pg_jobmon/archive/refs/tags/${tag}.tar.gz"
	tar -xf pg_jobmon.tar.gz
	rm pg_jobmon.tar.gz
	cd "pg_jobmon-${version}"
	make && make install
	cd ..
	rm -rf "pg_jobmon-${version}"
}

install_pg_partman() {
	tag=$(get_github_latest_tag pgpartman/pg_partman)
	version=$(github_tag_to_version ${tag})

  curl -Lo pg_partman.tar.gz "https://github.com/pgpartman/pg_partman/archive/refs/tags/${tag}.tar.gz"
  tar -x -f pg_partman.tar.gz
  rm pg_partman.tar.gz
  cd "pg_partman-${version}"
  make && make install
  cd ..
  rm -rf "pg_partman-${version}"
}

install_pg_cron() {
	package=postgresql-13-cron
	if [ "$distro" = "alpine" ]; then
    	package=postgresql-pg_cron
	fi

	${install_cmd} ${package}
}

# -----------------------------------------------------------------------------
# Text search
# -----------------------------------------------------------------------------
install_typesense() {
	tag=$(get_github_latest_tag typesense/typesense)
	version=$(github_tag_to_version ${tag})

	echo "Version=${tag}"

  curl -Lo typesense-server.tar.gz "https://dl.typesense.org/releases/${version}/typesense-server-${version}-linux-amd64.tar.gz"
  tar -xf typesense-server.tar.gz
  rm typesense-server.tar.gz
	chmod +x typesense-server
	mv typesense-server ${bin_path}/
}

# -----------------------------------------------------------------------------
# ERP
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
install {
  if [ -z "$@" ]; then
    echo "No packages specified"
    exit 1
  fi

  for package in "$@"
  do
    echo "Installing ${package}"
    case "${package}" in
    kubectl)    install_kubectl;;
    helm)		    install_helm;;
    hugo)       install_hugo;;
    pg_jobmon)	install_pg_jobmon;;
    pg_partman)	install_pg_partman;;
    pg_cron)	  install_pg_cron;;
    typesense) 	install_typesense;;
    *)
      # "Use the distro install command"
      ${install_cmd} ${package}
      ;;
    esac
  done
}

install "$@"
