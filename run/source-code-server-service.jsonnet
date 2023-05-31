local params = import 'params.jsonnet';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: params.source_code_server.name,
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    ports: [
      {
        port: 80,
        targetPort: params.source_code_server.containerPort,
      },
    ],
    selector: {
      app: params.source_code_server.name,
    },
    type: 'NodePort',
  },
}