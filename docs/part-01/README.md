# Create k8s cluster

Before starting with the main content, it's necessary to provision
the Kubernetes in Azure.

Use the `MY_DOMAIN` variable containing domain and `LETSENCRYPT_ENVIRONMENT`
variable.
The `LETSENCRYPT_ENVIRONMENT` variable should be one of:

* `staging` - Let’s Encrypt will create testing certificate (not valid)

* `production` - Let’s Encrypt will create valid certificate (use with care)

```bash
export MY_DOMAIN=${MY_DOMAIN:-myexample.dev}
export LETSENCRYPT_ENVIRONMENT=${LETSENCRYPT_ENVIRONMENT:-staging}
export AZURE_RESOURCE_GROUP_NAME="pruzicka-k8s-test"
export AZURE_LOCATION="westeurope"
echo "*** ${MY_DOMAIN} | ${LETSENCRYPT_ENVIRONMENT} | ${AZURE_RESOURCE_GROUP_NAME} | ${AZURE_LOCATION} ***"
```

## Prepare the local working environment

::: tip
You can skip these steps if you have all the required software already
installed.
:::

Install necessary software:

```bash
if [ -x /usr/bin/apt ]; then
  apt update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl gettext-base git jq openssh-client sudo wget > /dev/null
fi
```

Install [kubectl](https://github.com/kubernetes/kubectl) binary:

```bash
if [ ! -x /usr/local/bin/kubectl ]; then
  sudo curl -s -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  sudo chmod a+x /usr/local/bin/kubectl
fi
```

Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt):

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
```

## Prepare the Azure environment

Create Service Principal and authenticate to Azure - this should be done only
once for the new Azure accounts:

* [Azure Provider: Authenticating using a Service Principal with a Client Secret](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html)

* [Install and configure Terraform to provision VMs and other infrastructure into Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

Login to the Azure CLI:

```shell
az login
```

Get Subscription ID for Default Subscription:

```shell
SUBSCRIPTION_ID=$(az account list | jq -r '.[] | select (.isDefault == true).id')
```

Create the Service Principal which will have permissions to manage resources
in the specified Subscription:

```shell
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" | jq
```

Output:

```json
{
  "appId": "axxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx8",
  "displayName": "azure-cli-2019-08-30-12-31-54",
  "name": "http://azure-cli-2019-08-30-12-31-54",
  "password": "dxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx0",
  "tenant": "5xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx8"
}
```

Login to Azure using Service Principal:

```shell
az login --service-principal -u axxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -p dxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --tenant 5xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | jq
```

Output:

```json
[
  {
    "cloudName": "AzureCloud",
    "id": "exxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxb",
    "isDefault": true,
    "name": "Pay-As-You-Go",
    "state": "Enabled",
    "tenantId": "5xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx8",
    "user": {
      "name": "axxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx8",
      "type": "servicePrincipal"
    }
  }
]
```

### Create DNS zone

See the details: [https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns](https://docs.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns)

Create DNS resource group:

```shell
az group create --name ${AZURE_RESOURCE_GROUP_NAME}-dns --location ${AZURE_LOCATION}
```

Output:

```json
{
  "id": "/subscriptions/exxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxb/resourceGroups/pruzicka-k8s-test-dns",
  "location": "westeurope",
  "managedBy": null,
  "name": "pruzicka-k8s-test-dns",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": null
}
```

Create DNS zone:

```shell
az network dns zone create -g ${AZURE_RESOURCE_GROUP_NAME}-dns -n ${MY_DOMAIN} | jq
```

Output

```json
{
  "etag": "0xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx1",
  "id": "/subscriptions/exxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxb/resourceGroups/pruzicka-k8s-test-dns/providers/Microsoft.Network/dnszones/myexample.dev",
  "location": "global",
  "maxNumberOfRecordSets": 10000,
  "name": "myexample.dev",
  "nameServers": [
    "ns1-06.azure-dns.com.",
    "ns2-06.azure-dns.net.",
    "ns3-06.azure-dns.org.",
    "ns4-06.azure-dns.info."
  ],
  "numberOfRecordSets": 2,
  "registrationVirtualNetworks": null,
  "resolutionVirtualNetworks": null,
  "resourceGroup": "pruzicka-k8s-test-dns",
  "tags": {},
  "type": "Microsoft.Network/dnszones",
  "zoneType": "Public"
}
```

List DNS nameservers for zone `myexample.dev` in Azure. You need to ask the
domain owner to delegate the zone `myexample.dev` to the Azure nameservers.

```shell
az network dns zone show -g ${AZURE_RESOURCE_GROUP_NAME}-dns -n ${MY_DOMAIN} -o json | jq
```

Output:

```json
{
  "etag": "00000002-0000-0000-7907-d16f315fd501",
  "id": "/subscriptions/ef241c56-6f94-4aee-8861-9cd4ae74436b/resourceGroups/pruzicka-k8s-test-dns/providers/Microsoft.Network/dnszones/myexample.dev",
  "location": "global",
  "maxNumberOfRecordSets": 10000,
  "name": "myexample.dev",
  "nameServers": [
    "ns1-06.azure-dns.com.",
    "ns2-06.azure-dns.net.",
    "ns3-06.azure-dns.org.",
    "ns4-06.azure-dns.info."
  ],
  "numberOfRecordSets": 2,
  "registrationVirtualNetworks": null,
  "resolutionVirtualNetworks": null,
  "resourceGroup": "pruzicka-k8s-test-dns",
  "tags": {},
  "type": "Microsoft.Network/dnszones",
  "zoneType": "Public"
}
```

Check if DNS servers are forwarding queries to Azure DNS server:

```shell
dig +short -t SOA ${MY_DOMAIN}
```

Output:

```text
ns1-06.azure-dns.com. azuredns-hostmaster.microsoft.com. 1 3600 300 2419200 300
```

## Create K8s in Azure

Generate SSH keys if not exists:

```bash
test -f $HOME/.ssh/id_rsa || ( install -m 0700 -d $HOME/.ssh && ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N "" )
```

Clone the `k8s-postgresql` Git repository if it wasn't done already:

```bash
if [ ! -d .git ]; then
  git clone --quiet https://github.com/ruzickap/k8s-postgresql && cd k8s-postgresql
fi
```

Check if the new Kubernetes cluster is available:

```bash
export KUBECONFIG=$PWD/kubeconfig.conf
kubectl get nodes -o wide
```

Output:

```text
```
