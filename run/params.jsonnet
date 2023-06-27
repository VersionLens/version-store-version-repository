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
    tag: '729327234b330a9be46a6de41c7ada8a3ab332af',
  },
}
