# Deploy Loki to Kubernetes

See the [Tanka Installation Docs](../../docs/sources/installation/tanka.md)

Steps to perform on Linux 
_________

## Install jb 
go get -u github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
or 
sudo curl -Lo /usr/local/bin/jb https://github.com/jsonnet-bundler/jsonnet-bundler/releases/latest/download/jb-linux-amd64


### Install Tanka
sudo curl -Lo /usr/local/bin/tk https://github.com/grafana/tanka/releases/latest/download/tk-linux-arm64
GO111MODULE=on go get github.com/grafana/tanka/cmd/tk
git clone https://github.com/grafana/tanka
cd tanka
make install
make
tk --version


###Setup to deploy loki using tank####

mkdir loki
cd loki
tk init
tk env add environments/loki --namespace=loki --server=https://35.238.153.150

#### 
jb install github.com/pawanitzone/loki-1/production/ksonnet/loki
jb install github.com/pawanitzone/loki-1/production/ksonnet/promtail
jb install github.com/jsonnet-libs/k8s-alpha/1.16

##### If above any change in repo files you would need to update jb ######

jb update github.com/pawanitzone/loki-1/production/ksonnet/loki
######


#### Deploy ksonnet for Loki HA

tk show environments/loki
tk apply environments/loki
