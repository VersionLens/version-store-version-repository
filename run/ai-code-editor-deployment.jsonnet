local params = import 'params.jsonnet';

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: params.ai_code_editor.name,
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: params.ai_code_editor.name,
      },
    },
    template: {
      metadata: {
        labels: {
          app: params.ai_code_editor.name,
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
          {
            name: 'version-store-frontend-deploy-key',
            secret: {
              secretName: 'version-store-frontend-deploy-key',
              defaultMode: 256,
            },
          },
        ],
        initContainers: [
          {
            name: 'wait-for-src',
            image: 'busybox:latest',
            command: ['sh', '-c', 'until [ -d /app/repos/version-store-frontend/src ] && [ "$(ls -A /app/repos/version-store-frontend/src)" ]; do echo "Waiting for /app/repos/version-store-frontend/src to exist and not be empty"; sleep 5; done'],
            volumeMounts: [
              {
                mountPath: '/app/repos/version-store-frontend',
                name: 'version-store-frontend-code-pv-claim',
              },
            ],
          },
        ],
        containers: [
          {
            name: params.ai_code_editor.name,
            image: params.ai_code_editor.registry + '/' + params.ai_code_editor.image + ':' + params.ai_code_editor.tag,
            imagePullPolicy: 'Always',
            ports: [
              {
                containerPort: 8000,
              },
            ],
            env: [
              {
                name: 'OPENAI_API_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: 'openai-api-key',
                    key: 'OPENAI_API_KEY',
                  },
                },
              },
              {
                name: 'AI_MODEL',
                value: 'gpt-4-0314',
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
                mountPath: '/app/repos/version-store-frontend',
                name: 'version-store-frontend-code-pv-claim',
              },
              {
                mountPath: '/root/.ssh',
                name: 'version-store-frontend-deploy-key',
              },
            ],
            resources: {
              requests: {
                memory: '7168Mi', # For fuzzy find and replace
              },
              limits: {
                memory: '7168Mi',
              },
            },
            // livenessProbe: {
            //   httpGet: {
            //     path: '/docs',
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
