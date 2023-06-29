{
  version_store_backend: {
    containerPort: 8000,
    image: 'versionlens/version-store-backend',
    name: 'version-store-backend',
    registry: 'docker.io',
    replicas: 1,
    tag: std.extVar('VERSION_STORE_BACKEND_SHA'),
  },
  version_store_frontend: {
    containerPort: 5173,
    image: 'versionlens/version-store-frontend',
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
    tag: '4fd7438531f10716e707bcf8e5bff07f815b5f62',
  },
}
