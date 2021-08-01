#!/usr/bin/env bash

kubectl -n consul port-forward ptzo-server-0 8500:8500
