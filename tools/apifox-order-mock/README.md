# Apifox 登录与订单 Mock

已在 Apifox 的「测试开发」项目创建独立模块及同名目录：**登录与订单 Mock**。

包含登录、退登、新增订单、编辑订单、删除订单、订单详情和订单列表，共 7 个接口。登录之外的接口均校验 `Authorization: Bearer <token>`，退登后旧 token 立即失效。

## 启动服务

在仓库根目录执行：

```bash
python3 -u "tools/apifox-order-mock/server.py"
```

服务只监听本机 `127.0.0.1:18080`，不会公开到局域网或互联网。数据保存在本目录 `.runtime/mock.sqlite3`，该目录不提交 Git。

测试账号：`demo`，密码：`demo12345`。这些是公开的虚构 Mock 账号，不是真实用户凭据。token 有效期 1 小时，只保存散列值。

## 在 Apifox 使用

选择环境 **订单Mock-本机**，模块前置 URL 为 `http://127.0.0.1:18080`。

按编号调试：

1. 登录：后置脚本提取 `data.token` 到环境变量 `mockToken`。
2. 新增：请求头自动使用 `Bearer {{mockToken}}`，提取 `data.id` 到 `orderId`。
3. 详情：路径 `/mock-order/v1/orders/{{orderId}}`。
4. 编辑：更新同一个订单。
5. 列表：查看刚新增或编辑的数据。
6. 删除：删除本次订单。
7. 退登：撤销当前 token。

金额 `amount` 使用整数分，数量 `quantity` 使用正整数，状态支持 `draft`、`confirmed`、`cancelled`。

## 自动化场景

Apifox → 自动化测试 → **登录与订单 Mock｜完整闭环与鉴权验证**。

场景包含一个脚本步骤，内部顺序执行 16 个真实 HTTP 请求，累计 38 条断言。已在应用内运行通过，0 条失败。脚本使用自己提取的 token 和订单 ID，不依赖手动调试遗留变量，不修改既有 CND 环境变量。

验证包括无 token、错误密码、登录提取、新增、详情、编辑持久化、列表、缺 token 新增、伪造 token 编辑、非法金额、删除、删除后 404、退登、退登后旧 token 查询／删除均返回 401。

由于请求由脚本调用，Apifox 报告显示 **1 个脚本步骤**；38 条断言及控制台可以查看内部 16 个请求，不能将“1 步骤”理解成只测了一个接口。

场景使用固定本机 Mock URL，因此报告所选环境不会把请求发往现有生产或测试服务器。

## 交付文件

- `server.py`：有状态 Mock 服务，仅使用 Python 标准库，无需安装依赖。
- `workflow.js`：完整测试流程脚本的可读版本。
- `登录与订单Mock.postman_collection.json`：7 个接口、请求示例、token／ID 提取和断言脚本。
- `登录订单自动化.postman_collection.json`：16 请求流程的通用导入备份。
- `openapi.json`：OpenAPI 3.1 接口契约。
- `test_mock.py`：独立回归验证。

独立验证：

```bash
python3 "tools/apifox-order-mock/test_mock.py"
```

## Mock 的区别

本方案用 Apifox 管理接口和自动化，以本地有状态 Mock 提供真实 token 校验和订单状态。它不是将 Apifox 内置随机响应伪装成真实 CRUD。

内置 Mock 可以展示固定或随机响应，但 Mock 脚本不能使用客户端环境变量，不能据此证明删除状态或 token 撤销已被服务端保存。后续需要云端共享时，应部署此 Mock 服务并单独配置联调地址，而不是直接复用生产地址。

本次未提交或推送这些新增文件。

## 分步骤场景与变量关联

另建场景：**登录与订单 Mock｜分步骤与变量关联**，场景 ID `8983792`。

这是 7 个独立 HTTP 请求步骤，已在 Apifox 运行通过：7/7 步骤、21 条断言、0 失败。每步都有各自的响应、耗时、后置操作和实际请求。

1. 登录 → 后置操作：`var data = pm.response.json(); pm.environment.set("mockToken", data.data.token);`。
2. 新增订单 → Headers：`Authorization: Bearer {{mockToken}}`。
3. 新增订单 → 后置操作：从 `data.id` 保存到环境变量 `orderId`。
4. 详情／编辑／删除 → 路径：`/mock-order/v1/orders/{{orderId}}`，Headers 同样引用 `mockToken`。
5. 退登 → Headers 携带同一 token，服务端将该 token 撤销。

变量提取位于步骤的「后置操作」脚本，变量使用位于「Headers」及路径输入框。报告中的「实际请求」可查看替换后的路径和请求头。运行环境为「订单Mock-本机」，使用单线程顺序执行；每次运行都重新登录并创建自己的测试订单。
