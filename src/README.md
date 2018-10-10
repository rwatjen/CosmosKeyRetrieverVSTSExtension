# Retrieve Cosmos DB keys

This extension can retrieve the primary master key from a Cosmos DB Account.

You must pass in an Azure Resource Manager Subscription, the Cosmos DB Account Name, and the resource group where the account is located.
It will return the Primary Master Key in a variable called `CosmosKey`.

You can select which key type you want returned from the Cosmos DB account and also set the variable name to get the key.