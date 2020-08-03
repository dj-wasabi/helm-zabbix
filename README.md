# HELM-ZABBIX

[WIP] Work in Progress (I've started a puppet module (owned by vox-populi now), have created several Ansible roles (Now part of the collection.zabbix) so why not starting a HELM Chart.)

This HELM Chart will install (all|some) of the Zabbix components onto a Kubernetes environment. This is based on this https://github.com/zabbix/zabbix-docker/blob/5.0/kubernetes.yaml file.

## Dependencies

This HELM Chart will only install the Zabbix specific components and it will not install any database instance. Before deploying this HELM Chart, please make sure you have either MySQL or PgSQL installed and running.

There is no need for running MySQL or PgSQL in the same Kubernetes environment, this can be a (Physical) host or some cloud related instance like AWS RDS.

## Installation

Create a secret, containing some credentials needed for a Zabbix Server to connect to an database.

```
kubectl create secret generic server-db-secret -n zabbix --from-literal=db-zbx-user=zabbix-user --from-literal=db-zbx-pass=zabbix-pass --from-literal=db-root-pass=changeme
```

Parameter | Description
--------- | -----------
db-zbx-user|The username that Zabbix can use to authenticate against a (MySQL or PgSQL) database.
db-zbx-pass|The password that Zabbix can use to authenticate against a (MySQL or PgSQL) database.
db-root-pass|The (MySQL or PgSQL) ROOT password.

## Configuration

The following table lists the configurable parameters of the Zabbix chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
server.enabled |If the Zabbix Server needs to be deployed or not. | `true`
server.type| The database type to use.| `mysql`
server.version|The version of the Zabbix Server.| `5.0-latest`
server.database.name|The name of the database| `zabbix`
server.database.host|The host of the database| `zabbix`
server.javagateway.enable| If the JavaGateway needs to be enabled.| `true`
server.javagateway.javapollers|The amount of pollers for the JavaGateway| `5`
server.externalIPs|A list with IPs of outside Kubernetes to access the server| `[]`
server.env|A dict for adding environment variables| `{}`
agent.enabled|If the Zabbix Agent needs to be deployed or not.|`true`
agent.version|The version of the Zabbix Agent.| `5.0-latest`
agent.server.host|.The FQDN on which the Zabbix Server is available.|`zabbix-server.zabbix.svc`
agent.timeout|The timeout of the Zabbix Agent.|`10`
agent.startagents|The amount of agents to start.|`3`
agent.passiveagent: |If we need to allow passive checks.|`true`

