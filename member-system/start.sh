#!/usr/bin/env bash
# 会员管理系统一键启动：安装依赖（按需）→ 构建 → 启动生产服务
set -e
cd "$(dirname "$0")"

echo "==> 检查运行环境"
command -v node >/dev/null 2>&1 || { echo "未找到 Node.js，请先安装 Node 20+"; exit 1; }
command -v pnpm >/dev/null 2>&1 || { echo "未找到 pnpm，请执行 npm i -g pnpm"; exit 1; }

if [ ! -d "node_modules" ] || [ ! -d "server/node_modules" ] || [ ! -d "admin/node_modules" ]; then
  echo "==> 安装依赖"
  pnpm install
fi

if [ ! -f "admin/dist/index.html" ] || [ ! -f "server/dist/main.js" ]; then
  echo "==> 构建前后端"
  pnpm build
fi

echo "==> 清理占用 3000 端口的旧进程"
OLD_PIDS=$(lsof -ti:3000 2>/dev/null || true)
if [ -n "$OLD_PIDS" ]; then
  echo "$OLD_PIDS" | while read -r pid; do kill "$pid" 2>/dev/null || true; done
  sleep 1
  # 强杀未退出的进程
  lsof -ti:3000 2>/dev/null | while read -r pid; do kill -9 "$pid" 2>/dev/null || true; done
fi

echo "==> 启动服务（数据库：server/data/member.db，首次启动自动初始化演示数据）"
pnpm start
