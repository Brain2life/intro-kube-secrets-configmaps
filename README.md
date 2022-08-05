# Introduction to Kubernetes Secrets and ConfigMaps

## Table of contents:
1. [Overview](#overview)
2. [Secrets](#secrets)
3. [Creating Secrets directly from the CLI](#creating-secrets-directly-from-the-cli) 
4. [ConfigMaps](#configmaps)
5. [Using Secrets and ConfigMaps](#using-secrets-and-configmaps)
6. [Verification of Secrets and ConfigMap usage](#verification-of-secrets-and-configmap-usage)

### Overview:
This repository shows the usage of Secrets and ConfigMap objects in Kubernetes by using example database deployment.
It explains how to create Kubernetes Secrets and ConfigMaps, how to use them and add as environment variables or files into a running container instance. This allows to keep the configuration of containers separate from the container image. 

The main idea: reduce overhead by maintaining only a single image, while keeping the flexibility to create container instances with various configurations

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
kubectl create secret generic mariadb-user-creds \
--from-literal=MYSQL_USER=admin \
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
3. To use config from file use `--from-file=[filename]` parameter:
```shell
kubectl create configmap [configmap_name] --from-file=[file]
```
4. To get info about created ConfigMap use:
```shell
kubectl get configmap [configmap_name]
```
5. To view the contents of the ConfigMap use:
```shell
kubectl describe cm [configmap_name]
```
6. You can edit ConfigMap live in-place with the `kubectl edit` command. It's not best practice, but can be useful for testing purposes in dev environment. For example:
```shell
kubectl edit configmap [configmap_name]
```
7. To verify that data in ConfigMap has been updated use (example):
```shell
kubectl get configmap mariadb-config -o "jsonpath={.data['max_allowed_packet\.cnf']}"
```

### Using Secrets and ConfigMaps
1. Secrets and ConfigMaps can be mounted as *environment variables* or as *files* within a container. For example for the Database container you can mount the Secrets as environment variables and the ConfigMap as a file
2. To specify env variables with Secret root password, in spec container definition you need to psecify env array list and set  the environment variable value to the value of the key in your Secret:
```yaml
env:
   - name: MYSQL_ROOT_PASSWORD
     valueFrom:
       secretKeyRef:
         name: mariadb-root-password
         key: password
```
The **valueFrom** field defines **secretKeyRef** as the source from which the environment variable will be set; i.e., it will use the value from the **password** key in the **mariadb-root-password** Secret you set
3. This method can also be used with **ConfigMaps** by using **configMapRef** instead of **secretKeyRef**.
4. **envFrom** is a list of sources for Kubernetes to take environment variables. Use secretRef again, this time to specify mariadb-user-creds as the source of the environment variables. All the keys and values in the Secret will be added as environment variables in the container:
```yaml
    envFrom:
    - secretRef:
        name: mariadb-user-creds
```
Remember! There is no way to manually specify the environment variable name with **envFrom** as with **env**.
5. You can add your ConfigMap as a source by adding it to the volume list and then adding a volumeMount for it to the container definition:
```yaml
  volumeMounts:
  - mountPath: /var/lib/mysql
    name: mariadb-volume-1
  - mountPath: /etc/mysql/conf.d
    name: mariadb-config

<...>

volumes:
- emptyDir: {}
  name: mariadb-volume-1
- configMap:
    name: mariadb-config
    items:
      - key: max_allowed_packet.cnf
        path: max_allowed_packet.cnf
  name: mariadb-config-volume
```
6. To apply the deployment use:
```shell
kubectl create -f mariadb-deployment.yaml
```

### Verification of Secrets and ConfigMap usage
1. To get pods list use:
```shell
kubectl get pods
```
2. To validate the usage of environment variables use:
```shell
kubectl exec -it [pod_name] env | grep
```
3. To checl the config file modification use:
```shell
kubectl exec -it [pod_name] cat /etc/mysql/conf.d/max_allowed_packet.cnf
```
4. To validate the database use:
```shell
kubectl exec -it [pod_name] /bin/sh
```
To show databases:
```shell
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'show databases;'
```
To check that config was parsed use:
```shell
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW VARIABLES LIKE 'max_allowed_packet';"
```

### Reference:
1. [Bash Scripting Tutorial - 3. User Input](https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php)
2. [An Introduction to Kubernetes Secrets and ConfigMaps](https://opensource.com/article/19/6/introduction-kubernetes-secrets-and-configmaps)
3. [Minikube installation on Ubuntu system](https://github.com/Brain2life/minikube-ubuntu-install)