local params = import 'params.jsonnet';

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: params.version_store_backend.name,
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    replicas: params.version_store_backend.replicas,
    selector: {
      matchLabels: {
        app: params.version_store_backend.name,
      },
    },
    template: {
      metadata: {
        labels: {
          app: params.version_store_backend.name,
          'versionlens.com/version': std.extVar('VERSION_NAME'),
        },
      },
      spec: {
        tolerations: [
          {
            key: 'versionlens.com/paying-customer',
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
            name: 'version-store-backend-code-pv-claim',
            persistentVolumeClaim: {
              claimName: 'version-store-backend-code-pv-claim',
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
                name: 'version-store-backend-code-pv-claim',
              },
            ],
          },
        ],
        containers: [
          {
            name: params.version_store_backend.name,
            image: params.version_store_backend.registry + '/' + params.version_store_backend.image + ':' + params.version_store_backend.tag,
            imagePullPolicy: 'Always',
            ports: [
              {
                containerPort: params.version_store_backend.containerPort,
              },
            ],
            env: [
              {
                name: 'VERSION_URL',
                value: std.extVar('VERSION_URL'),
              },
            ],
            volumeMounts: [
              {
                mountPath: '/code',
                name: 'version-store-backend-code-pv-claim',
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
