#!/bin/bash

# GitHub自动上传脚本
# 配置说明：使用前需配置好SSH密钥或Personal Access Token

# --------------------------
# 用户配置区域（按需修改）
# --------------------------
REPO_DIR="/home/ubuntu/code/himawari8-daily"  # 本地仓库绝对路径
BRANCH="master"                        # 默认推送分支
REMOTE="origin"                      # 远程仓库名称
LOG_FILE="/tmp/git_auto_push.log"    # 日志文件路径
MAX_RETRIES=3                        # 网络错误重试次数
# --------------------------

# 初始化日志
echo "===== 执行时间: $(date) =====" > $LOG_FILE

# 函数：记录日志并显示彩色状态
log() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "\033[32m[SUCCESS]\033[0m $message" | tee -a $LOG_FILE
            ;;
        "ERROR")
            echo -e "\033[31m[ERROR]\033[0m $message" | tee -a $LOG_FILE
            exit 1
            ;;
        "WARNING")
            echo -e "\033[33m[WARNING]\033[0m $message" | tee -a $LOG_FILE
            ;;
        *)
            echo "$message" | tee -a $LOG_FILE
            ;;
    esac
}

# 检查是否在Git仓库
check_git_repo() {
    cd $REPO_DIR || log "ERROR" "目录不存在: $REPO_DIR"
    if [ ! -d .git ]; then
        log "ERROR" "当前目录不是Git仓库"
    fi
}

# 执行Git命令（带重试）
git_command() {
    local cmd=$1
    local retry=0
    while [ $retry -lt $MAX_RETRIES ]; do
        if git $cmd 2>>$LOG_FILE; then
            return 0
        else
            log "WARNING" "命令执行失败: git $cmd (尝试 $((retry+1))/$MAX_RETRIES)"
            ((retry++))
            sleep 5
        fi
    done
    log "ERROR" "操作失败: git $cmd"
}
# 在main函数中修复的代码段
main() {
    check_git_repo

    # 配置用户信息（如果未设置）
    if [ -z "$(git config user.name)" ]; then
        git config user.name "Auto Committer"
        git config user.email "auto@example.com"
    fi

    git_command "pull $REMOTE $BRANCH"

    # 增强变更检测
    if [ -z "$(git status --porcelain)" ]; then
        log "WARNING" "没有检测到文件变更"
        exit 0
    fi

    git_command "add ."

    # 提交信息使用单引号
    COMMIT_MSG="Auto commit: $(date '+%Y-%m-%d %H:%M:%S')"
    git_command "commit -m '$COMMIT_MSG'"

    git_command "push $REMOTE $BRANCH"
    log "SUCCESS" "操作成功完成"
}

# 执行主程序
main

