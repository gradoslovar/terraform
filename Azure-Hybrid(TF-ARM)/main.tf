provider "azurerm" {
    client_id = "${var.azurerm_client_id}"
    client_secret = "${var.azurerm_client_secret}"
    subscription_id = "${var.azurerm_subscription_id}"
    tenant_id = "${var.azurerm_tenant_id}"
}

resource "azurerm_resource_group" "armtfdemo" {
    name = "ARM-TerraForm-Demo"
    location = "${var.azurerm_location}"
}

resource "azurerm_template_deployment" "arm_terraform" {
  name                = "encrypt"
  resource_group_name = "${azurerm_resource_group.armtfdemo.name}"
  deployment_mode     = "Incremental"

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "ServicePlanName": {
      "type": "string",
      "minLength": 1,
      "defaultValue": "TMServicePlan"
    },
    "ServicePlanSkuName": {
      "type": "string",
      "defaultValue": "S1",
      "allowedValues": [
        "S1",
        "S2",
        "S3"
      ],
      "metadata": {
        "description": "Describes plan's pricing tier and capacity. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/"
      }
    },
    "WebAppLocations": {
      "type": "array",
      "defaultValue": [ "West Europe", "Central US" ]
    }
  },
  "variables": {
  },
  "resources": [
    {
      "name": "[concat(parameters('ServicePlanName'),'-',copyIndex())]",
      "type": "Microsoft.Web/serverfarms",
      "location": "[parameters('WebAppLocations')[copyIndex()]]",
      "apiVersion": "2015-08-01",
      "copy": {
        "count": "[length(parameters('WebAppLocations'))]",
        "name": "ServicePlanCopy"
      },
      "sku": {
        "name": "[parameters('ServicePlanSkuName')]"
      },
      "dependsOn": [ ],
      "tags": {
        "displayName": "[concat(parameters('ServicePlanName'),'-',copyIndex())]"
      },
      "properties": {
        "name": "[concat(parameters('ServicePlanName'),'-',copyIndex())]",
        "numberOfWorkers": 1
      }
    },
    {
      "name": "[concat(parameters('ServicePlanName'),'-site-',copyIndex())]",
      "type": "Microsoft.Web/sites",
      "location": "[parameters('WebAppLocations')[copyIndex()]]",
      "apiVersion": "2015-08-01",
      "copy": {
        "count": "[length(parameters('WebAppLocations'))]",
        "name": "SiteCopy"
      },
      "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', concat(parameters('ServicePlanName'),'-',copyIndex()))]"
      ],
      "tags": {
        "[concat('hidden-related:', resourceId('Microsoft.Web/serverfarms', concat(parameters('ServicePlanName'),'-',copyIndex())))]": "Resource",
        "displayName": "[concat(parameters('ServicePlanName'),'-site-',copyIndex())]"
      },
      "properties": {
        "name": "[concat(parameters('ServicePlanName'),'-site-',copyIndex())]",
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', concat(parameters('ServicePlanName'),'-',copyIndex()))]"
      }
    },
    {
      "name": "[concat(parameters('ServicePlanName'),'-TM')]",
      "type": "Microsoft.Network/trafficManagerProfiles",
      "apiVersion": "2017-05-01",
      "location": "global",
      "dependsOn": [
        "SiteCopy"
      ],
      "properties": {
        "profileStatus": "Enabled",
        "trafficRoutingMethod": "Performance",
        "dnsConfig": {
          "relativeName": "[concat(parameters('ServicePlanName'),'-TM')]",
          "ttl": 300
        },
        "monitorConfig": {
          "protocol": "HTTP",
          "port": 80,
          "path": "/"
        },
        "endpoints": [
          {
            "name": "[concat(parameters('ServicePlanName'),'-site-','0')]",
            "type": "Microsoft.Network/trafficManagerProfiles/azureEndpoints",
            "properties": {
              "targetResourceId": "[resourceId('Microsoft.Web/sites/',concat(parameters('ServicePlanName'),'-site-','0'))]",
              "endpointStatus": "Enabled"
            }
          },
          {
            "name": "[concat(parameters('ServicePlanName'),'-site-','1')]",
            "type": "Microsoft.Network/trafficManagerProfiles/azureEndpoints",
            "properties": {
              "targetResourceId": "[resourceId('Microsoft.Web/sites/',concat(parameters('ServicePlanName'),'-site-','1'))]",
              "endpointStatus": "Enabled"
            }
          }

        ]
      }
    }
  ],
  "outputs": {}
}
  DEPLOY
}