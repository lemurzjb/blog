#!/bin/sh

# start hexo server
hexo server -s &

hexo generate --watch
