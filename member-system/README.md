# 会员管理系统（本地部署）

餐饮 / 零售门店的会员运营系统：**NestJS + SQLite 后端**、**Vue3 + Element Plus 管理后台**、**iOS App 内会员入口**。
无需购买服务器，数据全部保存在本机 SQLite 文件中，支持局域网内手机访问。

## 功能清单

| 模块 | 能力 |
| --- | --- |
| 数据看板 | 会员总数 / 今日新增 / 今日营业额 / 累计消费，新增会员趋势、消费趋势、等级分布、标签 Top10、订单类型分布、消费排行 |
| 会员管理 | 增删改查（软删除）、关键词/等级/标签/状态/注册时间筛选、标签分组、积分调整、储值充值、批量打标签 |
| Excel | 导入模板下载、批量导入（重复手机号跳过或覆盖）、按筛选条件导出 |
| 消费订单 | 录入订单自动执行：等级折扣 → 优惠券核销 → 积分抵扣（100 分 = 1 元）→ 储值扣款 → 赠送积分 → 累计消费自动升级 |
| 优惠券 | 满减 / 折扣 / 代金券模板，限量发放、有效期、核销记录、会员持券查询 |
| 标签 / 等级 | 标签颜色管理；等级升级门槛、折扣率、积分倍率配置 |
| 账号权限 | JWT 登录，默认 admin（管理员）/ staff（店员） |
| iOS 端 | 个人中心「会员管理」入口，会员列表（搜索/分页）、会员详情（档案 + 最近订单） |

## 快速开始

环境要求：Node.js 20+、pnpm 10+。

```bash
cd member-system
./start.sh          # 一键：装依赖（按需）→ 构建 → 启动
```

启动后访问：

- 管理后台：http://localhost:3000
- 接口地址：http://localhost:3000/api
- 局域网访问：启动日志会打印 `手机/局域网访问: http://<本机IP>:3000`

默认账号：`admin / admin123`（管理员）、`staff / staff123`（店员）。
首次启动自动建表并写入演示数据：4 个等级、8 个标签、3 个券模板、48 位会员、220 笔订单。
**不需要演示数据时，删除 `server/data/member.db` 并清空 `server/src/seed/seed.service.ts` 中对应演示数据方法后重启即可。**

## 开发模式

```bash
pnpm install
pnpm dev            # 同时启动后端(3000) 与前端 Vite(5173)，前端代理 /api
pnpm dev:server     # 仅后端，Nest watch 模式
pnpm dev:admin      # 仅前端，http://localhost:5173
```

## 各端调试指南

### 1. 后端（NestJS）

代码目录：`server/src`

```bash
# 1) 停止当前生产服务
lsof -ti:3000 | xargs kill

# 2) 启动开发模式（保存代码自动重启）
pnpm dev:server
```

- 接口地址：`http://localhost:3000/api`
- 主要调试位置：
  - 会员：`server/src/members`
  - 订单：`server/src/orders`
  - 优惠券：`server/src/coupons`
  - 数据看板：`server/src/stats`
  - 数据库实体：`server/src/database/entities`
- 生产服务日志：`tail -f /tmp/member-server.log`
- 接口冒烟（获取 token）：

```bash
curl -s -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}'
```

### 2. Web 后台（Vue3）

代码目录：`admin/src`

保持后端运行，另开终端：

```bash
pnpm dev:admin     # http://localhost:5173，/api 自动代理到 3000
```

- 修改 `.vue` / 样式后浏览器自动热更新
- 浏览器按 `F12`，用 **Console / Network** 排查报错与接口
- 前后端一起热更新：`lsof -ti:3000 | xargs kill && pnpm dev`

### 3. iOS 端（My_Study_New）

```bash
open /Users/boge/hzw/git/My_Study/My_Study_New/My_Study.xcworkspace
```

> 注意打开 `.xcworkspace`，不是 `.xcodeproj`。

1. Scheme 选择 `My_Study`，选择模拟器，`Command + R` 运行
2. 进入 **个人中心 → 会员管理**
3. 右上角「服务器」配置：
   - 模拟器：`http://127.0.0.1:3000`
   - 真机：`http://<电脑局域网IP>:3000`（查看 IP：`ipconfig getifaddr en0`）
4. 使用 `admin / admin123` 登录
5. 断点调试位置：`My_Study/Business/MemberManage/`
   - `ZWMemberApi`（网络层）、`ZWMemberListViewController`（列表）、`ZWMemberDetailViewController`（详情）

命令行编译验证：

```bash
cd /Users/boge/hzw/git/My_Study/My_Study_New
xcodebuild -workspace My_Study.xcworkspace -scheme My_Study \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

### 4. 常用运维命令

```bash
# 停止服务
lsof -ti:3000 | xargs kill

# 生产模式重启（重新构建后端 + 前端）
cd /Users/boge/hzw/git/My_Study/member-system && ./start.sh

# 数据库备份
./backup.sh

# 查看本机局域网 IP（手机连同一 Wi-Fi 时访问用）
ipconfig getifaddr en0
```

## 数据与备份

- 数据库文件：`server/data/member.db`（SQLite 单文件，拷走即完成迁移）。
- 备份：执行 `./backup.sh`，热备份到 `backups/`（自动保留最近 30 份）。
- 建议用 crontab 每日备份：`0 3 * * * /path/to/member-system/backup.sh`。

## iOS 端接入（My_Study_New）

代码位置：`My_Study_New/My_Study/Business/MemberManage/`

- `ZWMemberApi`：独立 NSURLSession 网络层，token 存 NSUserDefaults，不影响 App 现有网络层。
- `ZWMemberListViewController`：会员列表（搜索 / 下拉刷新 / 自动分页）。
- `ZWMemberDetailViewController`：会员档案 + 最近 10 笔订单。
- `ZWMemberManageModule`：个人中心入口（`PersonalCenterConfig` 已注册），点击经 Router `member/manage/list` 打开列表。
- 8 个源文件已写入 `project.pbxproj` 并加入 My_Study / My_Study_Sit / My_Study_Uat 三个 Target，直接用 Xcode 打开编译即可（原文件备份为 `project.pbxproj.bak-member`）。

手机端配置：

1. 电脑启动 `./start.sh`，手机与电脑连同一 Wi-Fi。
2. App 个人中心 → 会员管理 → 右上角「服务器」：
   - 模拟器：`http://127.0.0.1:3000`
   - 真机：`http://<电脑局域网IP>:3000`（启动日志中有打印）
3. 使用 `admin / admin123` 登录即可查看会员数据。

注意：真机通过 HTTP 访问需在 target 的 ATS 配置中允许局域网 HTTP（`NSAllowsArbitraryLoads` 或对局域网地址配置例外域名）。

## 目录结构

```
member-system/
├── server/                 # NestJS + TypeORM + better-sqlite3
│   ├── src/
│   │   ├── common/         # 统一响应、异常过滤、JWT 守卫、分页
│   │   ├── database/entities/  # 7 张表实体
│   │   ├── auth/           # 登录 / JWT
│   │   ├── members/        # 会员 CRUD + Excel 导入导出
│   │   ├── orders/         # 下单事务（折扣/券/积分/升级）
│   │   ├── coupons/        # 券模板 / 发券 / 持券
│   │   ├── tags/ levels/   # 标签与等级
│   │   ├── stats/          # 看板统计
│   │   └── seed/           # 首次启动自动初始化
│   └── data/member.db      # SQLite 数据库
├── admin/                  # Vue3 + Element Plus + ECharts
│   └── src/views/          # 看板 / 会员 / 订单 / 优惠券 / 标签 / 等级 / 登录
├── start.sh                # 一键启动
└── backup.sh               # 数据库备份
```

## 接口约定

- 统一响应：`{ status: "1"|"0", errmsg, code, data, timestamp }`，`status="1"` 为成功。
- 鉴权：除 `POST /api/auth/login` 外均需 `Authorization: Bearer <token>`，token 有效期 7 天。
- 分页：`page`（默认 1）、`size`（默认 20），返回 `{ list, total, page, size }`。
