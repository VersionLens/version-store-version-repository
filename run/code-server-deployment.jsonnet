local params = import 'params.jsonnet';

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'code-server',
    labels: {
      'versionlens.com/version': std.extVar('VERSION_NAME'),
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'code-server',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'code-server',
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
        volumes: [
          {
            name: 'version-store-frontend-code-pv-claim',
            persistentVolumeClaim: {
              claimName: 'version-store-frontend-code-pv-claim',
            },
          },
          {
            name: 'version-store-backend-code-pv-claim',
            persistentVolumeClaim: {
              claimName: 'version-store-backend-code-pv-claim',
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
                name: 'version-store-backend-code-pv-claim',
              },
            ],
          },
        ],
        containers: [
          {
            name: 'code-server',
            image: 'linuxserver/code-server:latest',
            imagePullPolicy: 'Always',
            ports: [
              {
                containerPort: 8443,
              },
            ],
            env: [
              {
                name: 'PUID',
                value: '0',
              },
              {
                name: 'PGID',
                value: '0',
              },
              {
                name: 'DEFAULT_WORKSPACE',
                value: '/code',
              },
            ],
            volumeMounts: [
              {
                mountPath: '/code/version-store-frontend',
                name: 'version-store-frontend-code-pv-claim',
              },
              {
                mountPath: '/code/version-store-backend',
                name: 'version-store-backend-code-pv-claim',
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
