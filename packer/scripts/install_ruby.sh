#!/bin/bash
apt update
sleep 10
systemctl stop unnatended-upgrades.service
apt install -y ruby-full ruby-bundler build-essential
