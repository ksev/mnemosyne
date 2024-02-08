local item(item, secretName, namespace='default') = {
    apiVersion: 'onepassword.com/v1',
    kind: 'OnePasswordItem',
    metadata: {
      name: secretName,
      namespace: namespace,
    },
    spec: {
      itemPath: 'vaults/Homeserver/items/%s' % item,
    }
};

{
	item: item
}

