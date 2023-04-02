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
        affinity: {
          nodeAffinity: {
            requiredDuringSchedulingIgnoredDuringExecution: {
              nodeSelectorTerms: [
                {
                  matchExpressions: [
                    {
                      key: 'alpha.eksctl.io/nodegroup-name',
                      operator: 'NotIn',
                      values: [
                        'managed-ng-1',
                      ],
                    },
                  ],
                },
              ],
            },
          },
        },
        volumes: [
          {
            name: 'version-store-frontend-code-pv-claim',
            persistentVolumeClaim: {
              claimName: 'version-store-frontend-code-pv-claim',
            },
          },
        ],
        initContainers: [
          {
            name: 'rm-rf-lost-found',
            image: 'busybox:latest',
            command: ['rm', '-rf', '/code/lost+found'],
            volumeMounts: [
              {
                mountPath: '/code',
                name: 'version-store-frontend-code-pv-claim',
              },
            ],
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
            volumeMounts: [
              {
                mountPath: '/code',
                name: 'version-store-frontend-code-pv-claim',
              },
            ],
            resources: {
              limits: {
                memory: '512Mi',
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
