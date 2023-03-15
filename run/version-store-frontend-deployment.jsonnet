local params = import 'params.jsonnet';

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: params.version_store_frontend.name,
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    replicas: params.version_store_frontend.replicas,
    selector: {
      matchLabels: {
        app: params.version_store_frontend.name,
      },
    },
    template: {
      metadata: {
        labels: {
          app: params.version_store_frontend.name,
          'versionlens.com/version': std.extVar('VERSION_NAME'),
        },
      },
      spec: {
        tolerations: [
          {
            key: 'versionlens.com/free-tier',
            operator: 'Exists',
            effect: 'NoSchedule',
          },
        ],
        containers: [
          {
            name: params.version_store_frontend.name,
            image: params.version_store_frontend.registry + '/' + params.version_store_frontend.image + ':' + params.version_store_frontend.tag,
            imagePullPolicy: 'Always',
            ports: [
              {
                containerPort: params.version_store_frontend.containerPort,
              },
            ],
            env: [
              {
                name: 'VITE_GRAPHQL_HTTP_HOST',
                value: 'https://version-store-backend--' + std.extVar('VERSION_URL'),
              },
            ],
            resources: {
              limits: {
                memory: '256Mi',
              },
            },
            // livenessProbe: {
            //   httpGet: {
            //     path: '/_alive',
            //     port: 8000,
            //   },
            //   initialDelaySeconds: 20,
            // },
          },
        ],
      },
    },
  },
}
