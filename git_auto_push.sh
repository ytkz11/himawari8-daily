#!/bin/bash

# 设置工作目录为你的 git 仓库路径
REPO_PATH="/home/ubuntu/code/himawari8-daily"
cd "$REPO_PATH" || exit

# 添加所有更改的文件
git add .

# 获取当前时间作为提交信息
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "Auto commit: $TIMESTAMP"

# 推送更改到 GitHub
# 假设远程仓库名为 origin，分支名为 main（根据实际情况修改）
git push origin master

# 可选：添加日志记录
echo "Pushed to GitHub at $TIMESTAMP" >> auto_push.log
