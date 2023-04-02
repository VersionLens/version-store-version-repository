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
  ai_code_editor: {
    containerPort: 8000,
    image: 'versionlens/ai-code-editor-arm64',
    name: 'ai-code-editor',
    registry: 'docker.io',
    replicas: 1,
    tag: std.extVar('AI_CODE_EDITOR_SHA'),
  },
}
