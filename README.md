# HELM-ZABBIX

![CI](https://github.com/dj-wasabi/helm-zabbix/workflows/CI/badge.svg)
![GitHub Release Date](https://img.shields.io/github/release-date/dj-wasabi/helm-zabbix)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/dj-wasabi/helm-zabbix)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/dj-wasabi/pre-commit-hooks)


Table of content:
<!--TOC-->

- [HELM-ZABBIX](#helm-zabbix)
- [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Dependencies](#dependencies)
- [Installation](#installation)
  - [server-db-secret](#server-db-secret)
  - [www.example.com](#wwwexamplecom)
  - [proxy-db-secret](#proxy-db-secret)
  - [Install the HELM Chart](#install-the-helm-chart)
- [Configuration](#configuration)
  - [Zabbix overal](#zabbix-overal)
  - [Zabbix Server](#zabbix-server)
  - [Zabbix Web](#zabbix-web)
  - [Zabbix Agent](#zabbix-agent)
    - [`agent.volumes_host`](#agentvolumes_host)
    - [`agent.volumes`](#agentvolumes)
  - [Zabbix Proxy](#zabbix-proxy)
  - [Zabbix JavaGateway](#zabbix-javagateway)
  - [Network Policies](#network-policies)

<!--TOC-->

# Introduction

[WIP] Work in Progress (I've started a puppet module (owned by vox-populi now), have created several Ansible roles (Now part of the collection.zabbix) so why not starting a HELM Chart for Zabbix.)

This HELM Chart will install (all|some) of the Zabbix components onto a Kubernetes environment. This HELM Chart is based on the work Zabbix already did and can be found https://github.com/zabbix/zabbix-docker/blob/5.0/kubernetes.yaml .

## Prerequisites

* Kubernetes 1.10+;
* Helm 3.0;
* The need for deploying Zabbix.

## Dependencies

This HELM Chart will only install the Zabbix specific components and it will not install any database instance. Before deploying this HELM Chart, please make sure you have either `MySQL` or `PgSQL` installed and running.

There is no need for running `MySQL` or `PgSQL` in the same Kubernetes environment that you want to use for running the Zabbix components. This can also be a (Physical) host or some cloud related instance like AWS RDS.

# Installation

Before we can install 1 or more Zabbix components, we need to create some "secrets". We need to create the following:

1. `server-db-secret`
2. `www.example.com`
3. `proxy-db-secret`

Once we have done that, we can install the HELM Chart.

## server-db-secret

This secret `server-db-secret` contains the username/passwords for accessing the database used by the `Zabbix Server`. Please check [dependencies](#dependencies) and make sure you have either a `MySQL` or a `PgSQL` running.

Once you have that running, please create the following secret:
```
kubectl create namespace zabbix
kubectl create secret generic server-db-secret -n zabbix --from-literal=db-zbx-user=zabbix-user --from-literal=db-zbx-pass=zabbix-pass --from-literal=db-root-pass=changeme
```

The following tables provides an overview of the meaning for the values.

Parameter | Description
--------- | -----------
`db-zbx-user`|The username that Zabbix can use to authenticate against a (MySQL or PgSQL) database.
`db-zbx-pass`|The password that Zabbix can use to authenticate against a (MySQL or PgSQL) database.
`db-root-pass`|The (MySQL or PgSQL) password for the `ROOT` or `postgres` user.

## www.example.com

When you set `ingress.enabled` to `true`, you will have access to the Zabbix Web interface via the Ingress Controller. But if you want to use TLS certificates, we need to create a 2nd secret which contains the TLS information.

This secret contains the `key` and `crt` that we need to provide to the Ingress Controller. But first, we need to make sure we have a `crt` and `key` file. The following provides an example command to generate an self signed TLS certificate. Please do not do this in production, use properly signed certificates for this. For demonstration purposes, this would be fine.

```bash
openssl req -x509 \
  -newkey rsa:2048 \
  -keyout www.example.com.key \
  -out www.example.com.crt \
  -days 365 \
  -nodes \
  -subj "/C=NL/ST=Utrecht/L=Utrecht/O=MyAwesomeCompany/CN=www.example.com"
```

The above will create 2 files named `www.example.com.key` and `www.example.com.crt` and will be working for the `www.example.com` domain. Please change this to your FQDN.

Once that is done, we have to create a secret containing these 2 files.

```bash
kubectl create secret tls -n zabbix www.example.com \
  --key="www.example.com.key" \
  --cert="www.example.com.crt"
```

In the above command, we create a secret named `www.example.com` in the `zabbix` namespace. Please change the name and/or files as well to either your FQDN or something that you know that it is related to the earlier mentioned FQDN.

We need to create an `zabbix-override.yaml` file containing the following ingress configuration.
```yaml
---
ingress:
  enabled: true
  hosts:
    - host: www.example.com
      secretName: www.example.com
      paths:
        - "/"
  tls:
    - hosts:
      - www.example.com
      secretName: www.example.com
```

We need to update the `www.example.com` with the actual FQDN or name you have for the secret name that you created in the previous command.

## proxy-db-secret

This secret `server-db-secret` contains the username/passwords for accessing the database used by the `Zabbix Proxy`. If you don't need to deploy the Proxy (Zabbix Proxy is disabled default), you can skip this step. Please check [dependencies](#dependencies) and make sure you have either a `MySQL` or a `PgSQL` running.

Once you have that running, please create the following secret:
```
kubectl create secret generic proxy-db-secret -n zabbix --from-literal=db-zbx-user=zabbix-user --from-literal=db-zbx-pass=zabbix-pass --from-literal=db-root-pass=changeme
```

The following tables provides an overview of the meaning for the values.

Parameter | Description
--------- | -----------
`db-zbx-user`|The username that Zabbix can use to authenticate against a (MySQL or PgSQL) database.
`db-zbx-pass`|The password that Zabbix can use to authenticate against a (MySQL or PgSQL) database.
`db-root-pass`|The (MySQL or PgSQL) password for the `ROOT` or `postgres` user.

## Install the HELM Chart

We are now ready to deploy the HELM Chart. We have to execute the following commands to make it work.

```
git clone https://github.com/dj-wasabi/helm-zabbix.git
helm install -n zabbix zabbix ./helm-zabbix -f zabbix-override.yaml
```

# Configuration

The next few paragraphs provides an overview of all available options you can configure per Zabbix component. First it mentions the properties that are set generally

## Zabbix overal

The following provides an overview of the settings that can be used for all components. When setting these, you won't have to set them specifically for each component.

Parameter | Description | Default
--------- | ----------- | -------
`zabbix.version`|The version to be deployed.| `5.2-latest`
`zabbix.database.type`|The type of database to be used.|`mysql`
`zabbix.database.name`|The name of the database.| `zabbix`
`zabbix.database.host`|The host of the database.| `zabbix`
`zabbix.namespace`|The namespace on which Zabbix is running.| `zabbix`
`zabbix.networkPolicy.enabled`|If the network policies are enabled.| `true`

## Zabbix Server

Parameter | Description | Default
--------- | ----------- | -------
`server.image` |If you want to override the default official Zabbix image. This should also contain the appropriate tag. | `None`
`server.enabled` |If the Zabbix Server needs to be deployed or not. | `true`
`server.version`|The version of the Zabbix Server.| `5.2-latest`
`server.database.type`|The type of database to be used (Is overriding the `zabbix.database.type`).|`mysql`
`server.database.name`|The name of the database (Is overriding the `zabbix.database.name`).| `zabbix`
`server.database.host`|The host of the database (Is overriding the `zabbix.database.host`).| `zabbix`
`server.externalIPs`|A list with IPs of outside Kubernetes to access the server| `[]`
`server.env`|A dict for adding environment variables| `{}`
`server.securityContext.privileged`|If you need to run the agent as a privileged Docker container.|`false`
`server.securityContext.runAsUser` |The UID of the user inside the Docker image.|`1997`
`server.volumes`|Add additional volumes to be mounted.| `[]`
`server.volumeMounts`|Add additional volumes to be mounted.| `[]`

## Zabbix Web

Parameter | Description | Default
--------- | ----------- | -------
`web.image` |If you want to override the default official Zabbix image. This should also contain the appropriate tag. | `None`
`web.webserver`|What kind of webserver do you want to use: `nginx` or `apache`.| `nginx`
`ingress.enabed`|If Ingress needs to be enabled.| `false`
`ingress.annotations`| Add additional annotations to configure the Ingress.| `{}`
`ingress.hosts`|Add FQDN/path configuration to te Ingress.| `{}`

## Zabbix Agent

Parameter | Description | Default
--------- | ----------- | -------
`image.image` |If you want to override the default official Zabbix image. This should also contain the appropriate tag. | `None`
`agent.enabled`|If the Zabbix Agent needs to be deployed or not.|`true`
`agent.version`|The version of the Zabbix Agent.| `5.2-latest`
`agent.server.host`|.The FQDN on which the Zabbix Server is available.|`zabbix-server.zabbix.svc`
`agent.timeout`|The timeout of the Zabbix Agent.|`10`
`agent.startagents`|The amount of agents to start.|`3`
`agent.passiveagent`|If we need to allow passive checks.|`true`
`agent.securityContext.privileged`|If you need to run the agent as a privileged Docker container.|`true`
`agent.securityContext.runAsUser` |The UID of the user inside the Docker image.|`1997`
`agent.volumes_host`|If a preconfigured set of volumes to be mounted (`/`, `/etc`, `/sys`, `/proc`, `/var/run`).|`true`
`agent.volumes`|Add additional volumes to be mounted.| `[]`
`agent.volumeMounts`|Add additional volumes to be mounted.| `[]`

### `agent.volumes_host`

The following directories will be mounted from the host, inside the pod:

Host | Pod |
---- | ----
`/` | `/hostfs`
`/etc` | `/hostfs/etc`
`/sys` | `/hostfs/sys`
`/proc` | `/hostfs/proc`
`/var/run` | `/var/run`

### `agent.volumes`

The following will provide an overview on how to add additional volumes.

## Zabbix Proxy

Parameter | Description | Default
--------- | ----------- | -------
`proxy.enabled`|If the Zabbix Proxy needs to be deployed or not.|`false`
`proxy.database.type`|The type of database to be used (Is overriding the `zabbix.database.type`).| `mysql`
`proxy.database.name`|The name of the database (Is overriding the `zabbix.database.name`).| `zabbix`
`proxy.database.host`|The host of the database (Is overriding the `zabbix.database.host`).| `zabbix`

## Zabbix JavaGateway

Parameter | Description | Default
--------- | ----------- | -------
`javagateway.enabled`|If the Zabbix Java Gateway needs to be deployed or not.|`false`

## Network Policies

When `zabbix.networkPolicy.enabled` is set to `true` (Which is default), 3 networkpolicies are installed:

```sh
$ kubectl -n zabbix get networkpolicies
NAME            POD-SELECTOR        AGE
zabbix-agent    app=zabbix-agent    32m
zabbix-server   app=zabbix-server   32m
zabbix-web      app=zabbix-web      32m
```

The Zabbix Server only allows connections from and to both the Zabbix Web on port 10051 and the Zabbix Agent. The Zabbix Server also allows connections to be made to either port 3306 (MySQL) or 5432 (PostGreSQL), depending on the database type.

The Zabbix Agent only allows connections from and to the Zabbix Server on port 10050. Both the Zabbix Server and Agent will allow DNS request made to `kube-dns`.
