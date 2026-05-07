#!/usr/bin/env bash

vault-request-unlock

JWT_SECRET=$(vault-request-key JWT_SECRET 'gitea/oauth2')
INTERNAL_TOKEN=$(vault-request-key INTERNAL_TOKEN 'gitea/security')
SECRET_KEY=$(vault-request-key SECRET_KEY 'gitea/security')
LFS_JWT_SECRET=$(vault-request-key LFS_JWT_SECRET 'gitea/server')

cat <<EOF > /etc/gitea/secrets.json
{
    "jwt_secret": "${JWT_SECRET}",
    "internal_token": "${INTERNAL_TOKEN}",
    "secret_key": "${SECRET_KEY}",
    "lfs_jwt_secret": "${LFS_JWT_SECRET}"
}
EOF
