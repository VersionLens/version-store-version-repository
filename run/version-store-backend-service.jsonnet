local params = import 'params.jsonnet';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: params.version_store_backend.name,
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    ports: [
      {
        port: 80,
        targetPort: params.version_store_backend.containerPort,
      },
    ],
    selector: {
      app: params.version_store_backend.name,
    },
    type: 'NodePort',
  },
}
