{
  version_store_backend: {
    containerPort: 8000,
    image: 'versionlens/version-store-backend-arm64',
    name: 'version-store-backend',
    registry: 'docker.io',
    replicas: 1,
    tag: std.extVar('VERSION_STORE_BACKEND_SHA'),
  },
  version_store_frontend: {
    containerPort: 5173,
    image: 'versionlens/version-store-frontend-arm64',
    name: 'version-store-frontend',
    registry: 'docker.io',
    replicas: 1,
    tag: std.extVar('VERSION_STORE_FRONTEND_SHA'),
  },
  source_code_server: {
    containerPort: 8000,
    image: 'versionlens/source-code-server',
    name: 'source-code-server',
    registry: 'docker.io',
    replicas: 1,
    tag: '9e32ad0153ff1203b24ba08e2712dca2bcd6d795',
  },
}
