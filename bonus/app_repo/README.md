# 42_InceptionOfThings-rcutte_manifest

App repo of the manifests needed for InceptionOfThings CiCd project with ArgoCD

- Image: https://hub.docker.com/r/wil42/playground
- Port: `8888`

```bash
# Usage: ./update_version.sh <version> (allowed: 1 or 2)
./update_version.sh 1
```

```bash
# Check after sync
curl dev.localhost
# Output
# {"status":"ok", "message": "v1"}
```
