#
# Install a K3s cluster
#

SHELL:=/bin/bash

K3S_INSTALL_OPTION	?= --write-kubeconfig-mode 644 --disable traefik
HOST_NAME			?= freemind.vn
NODE_NAME			?= k3s-01
USE_ETCD			?= 0
ETCD_CLUSTERS		?= http://localhost:2380
REGISTRY			?= registry.gitlab.com
REGISTRY_USER		?= gitlab+deploy-token-1165899
REGISTRY_PWD		?= deploy-token-pwd
CLOUDFLARE_EMAIL	?= thanh.vinh@hotmail.com
CLOUDFLARE_TOKEN	?= your-cloudfalre-token

clusterConfigPath 	:= /etc/rancher/k3s/k3s.yaml
k3sEnvPath 			:= /etc/systemd/system/k3s.service.env
k3sRegistryPath 	:= /etc/rancher/k3s/registries.yaml
etcdEnvPath 		:= /etc/default/etcd

branch				:= $(shell git rev-parse --abbrev-ref HEAD)

#: Lists all targets
help:
	@grep -B1 -E "^[a-zA-Z0-9_-]+\:([^\=]|$$)" Makefile \
		| grep -v -- -- \
		| sed 'N;s/\n/###/' \
		| sed -n 's/^#: \(.*\)###\(.*\):.*/\2###\1/p' \
		| column -t -s '###'

	@echo "Cluster config: $(clusterConfigPath)"
	@echo "K3s config: $(k3sEnvPath)"
	@echo "K3s private registry: $(k3sRegistryPath)"
	@echo 'K3s local-path storage: /var/lib/rancher/k3s/storage -> /mnt/k3s-storage'
	@echo "Etcd config: $(etcdEnvPath)"
	@echo
	@echo 'Add annotate "default kubed.appscode.com/sync" to sync across clusters/namespaces'
	@echo "Example: \"kubectl annotate secret registry-auth -n default kubed.appscode.com/sync=''\""
# help: ## help
# 	@grep -E '^#: .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#: Confirm your environments
confirm:
	@echo "K3S_INSTALL_OPTION = $(K3S_INSTALL_OPTION)"
	@echo "HOST_NAME = $(HOST_NAME)"
	@echo "NODE_NAME = $(NODE_NAME)"
	@echo "USE_ETCD = $(USE_ETCD)"
	@echo "ETCD_CLUSTERS = $(ETCD_CLUSTERS)"
	@echo "REGISTRY = $(REGISTRY)"
	@echo "REGISTRY_USER = $(REGISTRY_USER)"
	@echo "REGISTRY_PWD = $(REGISTRY_PWD)"
	@echo "CLOUDFLARE_EMAIL = $(CLOUDFLARE_EMAIL)"
	@echo "CLOUDFLARE_TOKEN = $(CLOUDFLARE_TOKEN)"
	@echo
	@read -p "Are you sure? [y/N]: " ans && \
	if [ $${ans:-N} = 'N' ]; then \
		exit 1; \
	fi

# -----------------------------------------------------------------------------
# K3s
# -----------------------------------------------------------------------------
#: Change hostname
hostname:
	@sudo hostnamectl set-hostname $(NODE_NAME)
	@echo '# Update hostname manualy' | sudo tee -a /etc/cloud/templates/hosts.debian.tmpl
	@echo "127.0.1.1 $(NODE_NAME)" | sudo tee -a /etc/cloud/templates/hosts.debian.tmpl
	@echo 'Set `preserve_hostname=true` in `/etc/cloud/cloud.cfg`'

#: Install etcd
etcd:
	@echo 'Install etcd'
	@sudo apt install -y etcd
	@echo 'Accept remote incoming requests'
	@echo '# Accept remote incoming requests' | sudo tee -a $(etcdEnvPath)
	@echo 'ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380' | sudo tee -a $(etcdEnvPath)
	@sudo systemctl restart etcd

#: Install k3s
k3s:
ifeq ($(USE_ETCD), 1)
	make -s etcd
endif

# K3s cluster
	@echo 'Create a K3s cluster'
	@curl -sfL https://get.k3s.io | sh -s - $(K3S_INSTALL_OPTION)

	@echo 'Create aliases'
	@echo 'alias k=kubectl' >> ~/.bash_aliases
	@echo 'alias h=helm' >> ~/.bash_aliases
	@source ~/.bash_aliases

	@echo 'Set K3s environments'
	@echo "K3S_NODE_NAME=$(NODE_NAME)" | sudo tee -a $(k3sEnvPath)

#	Datastorage
ifeq ($(USE_ETCD), 1)
	@echo "K3S_DATASTORE_ENDPOINT=$(ETCD_CLUSTERS)" | sudo tee -a $(k3sEnvPath)
endif

	@mkdir -p ~/.kube
	@cp $(clusterConfigPath) ~/.kube/config

#	Helm
	@echo 'Install Helm'
	@curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#	Storage
	-@sudo ln -s /var/lib/rancher/k3s/storage /mnt/k3s-storage

# -----------------------------------------------------------------------------
# Kubed (pronounced Cube-Dee) by AppsCode
# -----------------------------------------------------------------------------
#: Install kubed - Synchronize configuration across clusters/namespaces
kubed:
	@helm repo add appscode https://charts.appscode.com/stable/
	@helm install kubed appscode/kubed -n kube-system

# -----------------------------------------------------------------------------
# Cert manager
# -----------------------------------------------------------------------------
#: Cert manager
cert:
	@kubectl create ns cert-manager
#	@helm repo add jetstack https://charts.jetstack.io
	@helm install cert-manager cert-manager \
		-n cert-manager \
		--repo https://charts.jetstack.io \
		--set installCRDs=true

#	Create cloudflare api secrect
	@kubectl create secret generic \
		cloudflare-api-token \
		-n cert-manager \
		--from-literal api-token=$(CLOUDFLARE_TOKEN)

#	Create ClusterIssuer
	@curl https://raw.githubusercontent.com/ez-connect/scripts/$(branch)/make/k3s/cluster-issuer.yaml \
		| sed s/'<domain>'/"$(HOST_NAME)"/ \
		| sed s/'<email>'/"$(CLOUDFLARE_EMAIL)"/ \
		| kubectl apply -f -

#	Create Certificate & sync across clusters/namespaces used kubed
	@curl https://raw.githubusercontent.com/ez-connect/scripts/$(branch)/make/k3s/certificate.yaml \
		| sed s/'<domain>'/"$(HOST_NAME)"/ \
		| kubectl apply -n default -f -; \

# -----------------------------------------------------------------------------
# Ingress + Dashboard
# -----------------------------------------------------------------------------
#: Ingress
ingress:
	@kubectl create ns ingress
#	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	@helm install ingress-nginx ingress-nginx \
		-n ingress \
		--repo https://kubernetes.github.io/ingress-nginx

#: Dashboard
dashboard:
#	@helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard
	@helm install kubernetes-dashboard kubernetes-dashboard \
		-n kube-system \
		--repo https://kubernetes.github.io/dashboard \
		--set ingress.enabled=true \
		--set ingress.className=nginx \
		--set ingress.hosts={dash.${HOST_NAME}} \
		--set ingress.tls[0].secretName=${HOST_NAME} \
		--set ingress.tls[0].hosts={dash.${HOST_NAME}}
#	Create a service account for the dashboard
	@kubectl create serviceaccount admin-user -n kube-system
	@kubectl create clusterrolebinding admin-user \
		-n kube-system \
		--clusterrole=cluster-admin \
		--serviceaccount=kube-system:admin-user

# -----------------------------------------------------------------------------
# Secret
# -----------------------------------------------------------------------------
#: Private registry
secret:
#	@echo 'Private registry'
#	@curl https://raw.githubusercontent.com/ez-connect/scripts/$(branch)/make/k3s/registries.yaml \
# 		| sed s/'<registry>'/"$(REGISTRY)"/ \
#		| sed s/'<username>'/"$(REGISTRY_USER)"/ \
#		| sed s/'<password>'/"$(REGISTRY_PWD)"/ \
#		| sudo tee -a $(k3sRegistryPath)

#	registry-auth
	@echo 'Create a secret for registry'
	@kubectl create secret docker-registry registry-auth \
		-n default \
		--docker-server=$(REGISTRY) \
		--docker-username=$(REGISTRY_USER) \
		--docker-password=$(REGISTRY_PWD)

# 	Sync resource
	@kubectl annotate secret registry-auth -n default kubed.appscode.com/sync=''

#	SSH
ifneq ("$(wildcard ~/.ssh/id_ed25519)","")
	@echo 'Create secret for ssh keys'
	@kubectl create secret generic -n default ssh-auth \
		--from-file=private=$(HOME)/.ssh/id_ed25519 \
		--from-file=public=$(HOME)/.ssh/id_ed25519.pub
	@kubectl annotate secret ssh-auth -n default kubed.appscode.com/sync=''
else
	@echo 'ssh keys not found'
endif

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------
#: Install NFS
nfs:
	@echo 'Install NFS server'
	@sudo apt install -y nfs-kernel-server
	@echo 'Create a directory to be used for NFS'
	@sudo mkdir /nfs
	@sudo chown nobody:nogroup /nfs
	@sudo chmod 0777 /nfs
	@sudo ln -s /nfs /mnt/nfs
	@# echo '/nfs gss/krb5i(rw,fsid=0,insecure,no_subtree_check)' | sudo tee -a /etc/exports
	@echo '/nfs *(rw,sync,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports
	@echo 'Install csi-driver-nfs'
#	@helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
	@helm install csi-driver-nfs csi-driver-nfs \
		-n kube-system \
		--repo https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
	@echo 'Create a StorageClass for NFS'
	@curl https://raw.githubusercontent.com/ez-connect/scripts/$(branch)/make/k3s/sc-nfs.yaml \
		| sed s/'<server>'/"$(hostname -I | awk '{print $1}')"/ \
		| kubectl apply -f -

#: Install Longhorn - Cloud native distributed block storage for Kubernetes
longhorn:
	@sudo apt install -y open-iscsi
#	-@helm repo add longhorn https://charts.longhorn.io
	@kubectl create ns longhorn-system
	@helm install longhorn longhorn/longhorn \
		-n longhorn-system \
		--repo https://charts.longhorn.io \
		--set ingress.enabled=true \
		--set ingress.className=nginx \
		--set ingress.host=$(hostname) \
		--set ingress.tls=true \
		--set ingress.tlsSecret=$(hostname)
	@sudo chown -R nobody:nogroup /dev/longhorn
	@sudo ln -s /dev/longhorn /mnt/longhorn

#: Run 'confirm k3s cert ingress registry nfs config' targets
all: confirm k3s cert ingress config
