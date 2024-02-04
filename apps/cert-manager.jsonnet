local secretName = 'cloudflare-api-token-secret';

[
  {
    apiVersion: 'onepassword.com/v1',
    kind: 'OnePasswordItem',
    metadata: {
      name: secretName      
    },
    spec: {
      itemPath: 'vaults/Homeserver/items/Cloudflare'
    }
  },
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Issuer',
    metadata: {
      name: 'acme-issuer'
    },
    spec: {
      acme: {
        solvers: [{
          dns01:{
            cloudflare: {
              apiTokenSecretRef: {
                name: secretName,
                key: 'password'
              }
            }    
          }         
        }]
      }
    }
  }  
]
