local params = import 'params.jsonnet';

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: params.source_code_server.name,
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: params.source_code_server.name,
      },
    },
    template: {
      metadata: {
        labels: {
          app: params.source_code_server.name,
          'versionlens.com/version': std.extVar('VERSION_NAME'),
        },
      },
      spec: {
        imagePullSecrets: [
          {
            name: 'versionlens-regcred',
          },
        ],
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
            name: 'version-store-frontend-code-pv-claim',
            persistentVolumeClaim: {
              claimName: 'version-store-frontend-code-pv-claim',
            },
          },
        ],
        initContainers: [
          {
            name: 'rm-rf-lost-found-frontend',
            image: 'busybox:latest',
            command: ['rm', '-rf', '/code/lost+found'],
            volumeMounts: [
              {
                mountPath: '/code',
                name: 'version-store-frontend-code-pv-claim',
              },
            ],
          },
          {
            name: 'rm-rf-lost-found-backend',
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
            name: params.source_code_server.name,
            image: params.source_code_server.registry + '/' + params.source_code_server.image + ':' + params.source_code_server.tag,
            imagePullPolicy: 'Always',
            ports: [
              {
                containerPort: params.source_code_server.containerPort,
              },
            ],
            env: [
              {
                name: 'CODE_PATH',
                value: '/code',
              },
              {
                name: 'VERSION_NAME',
                value: std.extVar('VERSION_NAME'),
              },
              {
                name: 'SET_UP_GIT',
                value: 'true',
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
