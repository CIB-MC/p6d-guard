#!/bin/sh
export HOME=/home/p6d-guard
export USER=p6d-guard

exec ~/P6dGuard/script/env start_server --port=5000 --interval=5 -- plackup -a ~/P6dGuard/script/p6dguard-server -E production -s Starlet --max_workers=5 --max-reqs-per-child=50