# HELM-ZABBIX

[WIP] Work in Progress

This HELM Chart will install (all|some) of the Zabbix components onto a Kubernetes environment.


## Installation

Create a secret

```
kubectl create secret generic db-secret -n zabbix --from-literal=db-zbx-user=zabbix-user --from-literal=db-zbx-pass=zabbix-pass --from-literal=db-root-pass=changeme
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
server.version|The version of the Zabbix Server.| `4.4-latest`
server.database.name|The name of the database| `zabbix`
server.database.host|The host of the database| `zabbix`
server.javagateway.enable| If the JavaGateway needs to be enabled.| `true`
server.javagateway.javapollers|The amount of pollers for the JavaGateway| `5`
server.externalIPs|A list with IPs of outside Kubernetes to access the server| `[]`
server.env|A dict for adding environment variables| `{}`



kubectl create secret generic db-secret -n zabbix --from-literal=db-zbx-user=zabbix-username --from-literal=db-zbx-pass=zabbix-password --from-literal=db-root-pass='Pass*w0rd!'