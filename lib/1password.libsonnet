local item = function(item, secretName, namespace='default') {
    apiVersion: 'onepassword.com/v1',
    kind: 'OnePasswordItem',
    metadata: {
      name: secretName,
      namespace: namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '-1',
      },
    },
    spec: {
      itemPath: 'vaults/Homeserver/items/%s' % item,
    }
};

{
	item: item
}

