# Deploy Loki to Kubernetes

See the [Tanka Installation Docs](../../docs/sources/installation/tanka.md)

Steps to perform on Linux 
_________

## Install jb 
- go get -u github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
or 
- sudo curl -Lo /usr/local/bin/jb https://github.com/jsonnet-bundler/jsonnet-bundler/releases/latest/download/jb-linux-amd64


### Install Tanka
- sudo curl -Lo /usr/local/bin/tk https://github.com/grafana/tanka/releases/latest/download/tk-linux-arm64
- GO111MODULE=on go get github.com/grafana/tanka/cmd/tk

OR 

- git clone https://github.com/grafana/tanka
- cd tanka
- make install
- make
- tk --version


###Setup to deploy loki using tank####

- mkdir loki
- cd loki
- tk init
- tk env add environments/loki --namespace=loki --server=https://35.238.153.150

#### 
- jb install github.com/pawanitzone/loki-1/production/ksonnet/loki
- jb install github.com/pawanitzone/loki-1/production/ksonnet/promtail
- jb install github.com/jsonnet-libs/k8s-alpha/1.16

##### If above any change in repo files you would need to update jb ######

- jb update github.com/pawanitzone/loki-1/production/ksonnet/loki
######

- vi lib/k.libsonnet
#Edit and Replace 
import 'github.com/jsonnet-libs/k8s-alpha/1.16/main.libsonnet'

####

- vi environments/loki/main.jsonnet
#Add these contents (If storage is bigtable & GCS):
-------
local gateway = import 'loki/gateway.libsonnet';
local loki = import 'loki/loki.libsonnet';
local promtail = import 'promtail/promtail.libsonnet';

loki + promtail + gateway {
  _config+:: {
    namespace: 'loki',
    htpasswd_contents: 'loki:$apr1$H4yGiGNg$ssl5/NymaGFRUvxIV1Nyr.',
    using_boltdb_shipper: false,

    // GCS variables remove if not using gcs
    storage_backend: 'bigtable,gcs',
    bigtable_instance: 'bigtableloki',
    bigtable_project: 'skilled-loader-305605',
    gcs_bucket_name: 'lokibucket',

    promtail_config+: {
      clients: [{
        scheme:: 'http',
        hostname:: 'gateway.%(namespace)s.svc' % $._config,
        username:: 'loki',
        password:: 'password',
        container_root_path:: '/var/lib/docker',
      }],
    },

    replication_factor: 3,
    consul_replicas: 1,
  },
}
-------
#Add these contents (If storage is dynamoDB & S3):  Note: Also change in "config.libsonnet" file for Storage_config: store: bigtable or dynamodb
------------
local gateway = import 'loki/gateway.libsonnet';
local loki = import 'loki/loki.libsonnet';
local promtail = import 'promtail/promtail.libsonnet';

loki + promtail + gateway {
  _config+:: {
    namespace: 'loki',
    htpasswd_contents: 'loki:$apr1$H4yGiGNg$ssl5/NymaGFRUvxIV1Nyr.',

    // S3 variables remove if not using aws
    storage_backend: 's3,dynamodb',
    s3_access_key: 'key',
    s3_secret_access_key: 'secret access key',
    s3_address: 'url',
    s3_bucket_name: 'loki-test',
    dynamodb_region: 'region',

    promtail_config+: {
      clients: [{
        scheme:: 'http',
        hostname:: 'gateway.%(namespace)s.svc' % $._config,
        username:: 'loki',
        password:: 'password',
        container_root_path:: '/var/lib/docker',
      }],
    },

    replication_factor: 3,
    consul_replicas: 1,
  },
}
------------
#### Deploy ksonnet for Loki HA

- tk show environments/loki
- tk apply environments/loki
