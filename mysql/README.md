
## environment variables

`DEFAULT_MYSQL_IMAGE`=mysql:5
`DEFAULT_INIT_DIR`=/docker-entrypoint-initdb.d

## usages

```sh
run.sh -p project -t latest-tag
spawn.sh -p project -o /path/to/backups -t tag
```

