#!/usr/bin/env bash
# 备份 SQLite 数据库到 backups/ 目录，保留最近 30 份
set -e
cd "$(dirname "$0")"

DB="server/data/member.db"
DIR="backups"
mkdir -p "$DIR"

if [ ! -f "$DB" ]; then
  echo "数据库不存在：$DB（请先启动过一次服务）"
  exit 1
fi

TARGET="$DIR/member-$(date +%Y%m%d-%H%M%S).db"
if command -v sqlite3 >/dev/null 2>&1; then
  # 在线热备份，服务运行中也可安全执行
  sqlite3 "$DB" ".backup '$TARGET'"
else
  cp "$DB" "$TARGET"
fi

echo "备份完成：$TARGET"

# 仅保留最近 30 份
ls -1t "$DIR"/member-*.db 2>/dev/null | tail -n +31 | while read -r old; do
  rm -f "$old"
done
