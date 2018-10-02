#!/bin/bash

set -e

dockerize -template /etc/railgun/railgun-nat.tmpl:/etc/railgun/railgun-nat.conf \
	-template /etc/railgun/railgun.tmpl:/etc/railgun/railgun.conf

exec "$@"