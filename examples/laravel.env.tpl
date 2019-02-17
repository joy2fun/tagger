# don't edit this file directly
# update consul key "env/{PROJECT}/{TAG}" instead

{{ keyOrDefault "env/{PROJECT}/{TAG}" ""}}

APP_NAME=
APP_ENV=local
APP_KEY={APP_KEY}
APP_DEBUG=true
APP_URL=http://localhost

{{ range service "{TAG}.mysql_{PROJECT}" }}
DB_HOST={{ .Address }}
DB_PORT={{ .Port }}
{{ end }}

DB_DATABASE=
DB_USERNAME=root
DB_PASSWORD=${MYSQL_ROOT_PASSWORD}

