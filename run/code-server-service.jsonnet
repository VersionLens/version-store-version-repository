local params = import 'params.jsonnet';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'code-server',
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    ports: [
      {
        port: 80,
        targetPort: 8443,
      },
    ],
    selector: {
      app: 'code-server',
    },
    type: 'NodePort',
  },
}
