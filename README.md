# Introduction to Kubernetes Secrets and ConfigMaps

## Table of contents:
1. [Overview](#overview)
2. [Secrets](#secrets)
3. [Creating Secrets directly from the CLI](#creating-secrets-directly-from-the-cli) 

### Overview:
This repository shows the usage of Secrets and ConfigMap objects in Kubernetes by using example database Pod

Kubernetes has two objects that can inject configuration data into a container on startup:
    - Secrets
    - ConfigMaps

### Secrets:
1. Secrets are used to store a small amount of sensitive data.
2. Secrets are stored in base64 format
3. Use RBAC to protect access to secrets
4. Better solution to protect Kubernetes secrets is to use [Vault](https://www.vaultproject.io/)
5. To create secret use:
```shell
kubectl apply -f [path_to_the_yaml_file]
```
6. To view created Secret use:
```shell
kubectl describe secret [secret_name]
```
7. To view and edit Secret in-place use:
```shell
kubectl edit secret [secret_name]
```
8. To view secret in plain text use:
```shell
kubectl get secret [secret_name] -o jsonpath='{.data.password}'
```
9. To delete secret use:
```shell
kubectl delete secret [secret_name]
```
10. Secret can hold more than one key/value pair

### Creating Secrets directly from the CLI:
1. To create Secrets directly use:
```shell
kubectl create secret [secret_type] [secret_name]
```
For example:
```shell
kubectl create secret generic database-creds \
--from-literal=MYSQL_USER=admin\
--from-literal=MYSQL_PASSWORD=P@ssw0rd!
```
2. The `--from-literal` - sets the key name and value all in one. You can pass as many `--from-literal` arguments as you need
3. To get the username use:
```shell
kubectl get secret database-creds -o jsonpath='{.data.MYSQL_USER}' | base64 --decode -
```
4. To get the password use:
```shell
kubectl get secret database-creds -o jsonpath='{.data.MYSQL_PASSWORD}' | base64 --decode -
```

### ConfigMaps
1. ConfigMaps are intended for non-sensitive data—configuration data—like config files and environment variables and are a great way to create customized running services from generic container images
2. There are two ways to create ConfigMaps as with Secrets:
    - write and deploy YAML file
    - use `kubectl create configmap` command to create from the CLI

### Reference:
1. [Bash Scripting Tutorial - 3. User Input](https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php)