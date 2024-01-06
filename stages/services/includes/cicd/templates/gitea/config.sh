#!/usr/bin/env bash

JWT_SECRET=$(vault-request-key JWT_SECRET 'gitea/oauth2')
INTERNAL_TOKEN=$(vault-request-key INTERNAL_TOKEN 'gitea/security')
SECRET_KEY=$(vault-request-key SECRET_KEY 'gitea/security')
LFS_JWT_SECRET=$(vault-request-key LFS_JWT_SECRET 'gitea/server')

cat <<EOF > /etc/gitea/app.ini
APP_NAME = RCMD Funkhaus
RUN_USER = git
RUN_MODE = prod

[oauth2]
JWT_SECRET = ${JWT_SECRET}

[security]
INTERNAL_TOKEN    = ${INTERNAL_TOKEN}
INSTALL_LOCK      = true
SECRET_KEY        = ${SECRET_KEY}
DISABLE_GIT_HOOKS = false

[server]
APP_DATA_PATH    = /var/lib/gitea/data
LOCAL_ROOT_URL   = http://localhost:25010/
SSH_DOMAIN       = git.rcmd.space
DOMAIN           = git.rcmd.space
HTTP_PORT        = 25010
ROOT_URL         = https://git.rcmd.space/
DISABLE_SSH      = false
SSH_PORT         = 22
LFS_START_SERVER = true
LFS_JWT_SECRET   = ${LFS_JWT_SECRET}
OFFLINE_MODE     = true

[lfs]
PATH = /var/lib/gitea/data/lfs

[database]
DB_TYPE  = sqlite3
HOST     = 127.0.0.1:3306
NAME     = gitea
USER     = gitea
PASSWD   =
SCHEMA   =
SSL_MODE = disable
CHARSET  = utf8
PATH     = /var/lib/gitea/data/gitea.db

[repository]
ROOT = /home/git

[ui]
DEFAULT_THEME = arc-green
THEMES = gitea,arc-green

[mailer]
ENABLED = false

[service]
REGISTER_EMAIL_CONFIRM            = false
ENABLE_NOTIFY_MAIL                = false
DISABLE_REGISTRATION              = true
ALLOW_ONLY_EXTERNAL_REGISTRATION  = false
ENABLE_CAPTCHA                    = false
REQUIRE_SIGNIN_VIEW               = false
DEFAULT_KEEP_EMAIL_PRIVATE        = false
DEFAULT_ALLOW_CREATE_ORGANIZATION = true
DEFAULT_ENABLE_TIMETRACKING       = true
NO_REPLY_ADDRESS                  = noreply.localhost

[picture]
DISABLE_GRAVATAR        = true
ENABLE_FEDERATED_AVATAR = false

[openid]
ENABLE_OPENID_SIGNIN = true
ENABLE_OPENID_SIGNUP = false

[session]
PROVIDER = file
SESSION_LIFE_TIME = 604800

[log]
MODE      = file
LEVEL     = info
ROOT_PATH = /var/lib/gitea/log
EOF

chown git:git /etc/gitea/app.ini
chmod 640 /etc/gitea/app.ini
