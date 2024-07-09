#!/bin/sh

server_app=$(cd ../terraform/stage || exit; terraform output | grep app | awk  '{print $3}')
server_db=$(cd ../terraform/stage || exit; terraform output | grep db | awk  '{print $3}')


cat << EOF
{
  "app": {
    "hosts": ["appserver"]
  },
  "db" : {
    "hosts": ["dbserver"]
  },
  "_meta": {
    "hostvars": {
      "appserver": {
        "ansible_host": $server_app
      },
      "dbserver": {
        "ansible_host": $server_db
      }
    }
  }
}
EOF
