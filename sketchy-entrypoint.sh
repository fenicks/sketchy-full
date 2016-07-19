#!/usr/bin/env bash

set -e

sysctl -w net.core.somaxconn=1024

exec "$@"