#!/bin/sh
set -e

git add .
git commit -m "update" || echo "No changes to commit"
git branch -M main
git remote set-url origin https://github.com/cklam12345/npu.git
git push -u origin main
