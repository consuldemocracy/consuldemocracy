# Deploying a Consul instance

__TODO: explain about creating and applying tenants__


Make sure the ssh certificates are loaded:

```bash
eval "$(ssh-agent -s)"

ssh-add ~/.ssh/{key_name}
```

Deploy the consul instance using the deploy.sh script:

```bash
sh deploy.sh [-p] {tenant_name}
```

where the `-p` flag denotes that the deployment is for production.


