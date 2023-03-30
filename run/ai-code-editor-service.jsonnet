local params = import 'params.jsonnet';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: params.ai_code_editor.name,
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    ports: [
      {
        port: 80,
        targetPort: params.ai_code_editor.containerPort,
      },
    ],
    selector: {
      app: params.ai_code_editor.name,
    },
    type: 'NodePort',
  },
}
