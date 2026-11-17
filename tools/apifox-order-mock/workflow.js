// 本地有状态 Mock：每次运行只创建并删除自己的测试订单。
var base = "http://127.0.0.1:18080/mock-order/v1";
var state = {};
var original = {title: "自动化测试订单", amount: 19900, quantity: 2, status: "draft", remark: "Apifox 自动化验证"};
var changed = {title: "已编辑订单", amount: 29900, quantity: 3, status: "confirmed", remark: "编辑结果需要可查询"};
var steps = [
  {name: "未登录禁止查询列表", method: "GET", path: "/orders", code: 401, auth: "none"},
  {name: "错误密码禁止登录", method: "POST", path: "/auth/login", code: 401, auth: "none", body: {username: "demo", password: "wrong"}},
  {name: "登录并提取 token", method: "POST", path: "/auth/login", code: 200, auth: "none", body: {username: "demo", password: "demo12345"}, save: "token"},
  {name: "携带 token 新增订单", method: "POST", path: "/orders", code: 201, body: original, save: "id"},
  {name: "携带 token 查询订单详情", method: "GET", path: "/orders/{id}", code: 200, check: "original"},
  {name: "携带 token 编辑订单", method: "PUT", path: "/orders/{id}", code: 200, body: changed, check: "changed"},
  {name: "再次查询验证编辑已保存", method: "GET", path: "/orders/{id}", code: 200, check: "changed"},
  {name: "订单列表包含本次订单", method: "GET", path: "/orders?page=1&size=100", code: 200, check: "list"},
  {name: "缺少 token 禁止新增", method: "POST", path: "/orders", code: 401, auth: "none", body: original},
  {name: "伪造 token 禁止编辑", method: "PUT", path: "/orders/{id}", code: 401, auth: "invalid", body: changed},
  {name: "非法金额拒绝新增", method: "POST", path: "/orders", code: 422, body: {title: "非法订单", amount: -1, quantity: 1}},
  {name: "携带 token 删除订单", method: "DELETE", path: "/orders/{id}", code: 200, check: "deleted"},
  {name: "删除后详情必须返回404", method: "GET", path: "/orders/{id}", code: 404},
  {name: "携带 token 退登", method: "POST", path: "/auth/logout", code: 200, body: {}, check: "logout"},
  {name: "退登后旧 token 禁止查询", method: "GET", path: "/orders", code: 401},
  {name: "退登后旧 token 禁止删除", method: "DELETE", path: "/orders/{id}", code: 401}
];
function run(index) {
  if (index === steps.length) {
    pm.variables.set("mockWorkflowDone", "true");
    console.log("登录与订单 Mock：16 个请求验证完成，token 未输出到日志。");
    return;
  }
  var step = steps[index];
  var headers = {"Content-Type": "application/json"};
  if (step.auth !== "none") headers.Authorization = "Bearer " + (step.auth === "invalid" ? "invalid-test-token" : state.token);
  var request = {url: base + step.path.replace("{id}", state.id), method: step.method, header: headers};
  if (step.body) request.body = {mode: "raw", raw: JSON.stringify(step.body)};
  pm.sendRequest(request, function (error, response) {
    pm.test((index + 1) + ". " + step.name + "｜HTTP " + step.code, function () {
      if (error) throw error;
      if (response.code !== step.code) throw new Error("预期 " + step.code + "，实际 " + response.code);
    });
    if (error || response.code !== step.code) return;
    var payload = response.json();
    pm.test((index + 1) + ". 统一结构与业务状态", function () {
      ["status", "code", "errmsg", "data", "timestamp"].forEach(function (key) {
        if (!Object.prototype.hasOwnProperty.call(payload, key)) throw new Error("缺少字段 " + key);
      });
      if (payload.status !== (step.code < 400 ? "1" : "0")) throw new Error("业务状态与 HTTP 状态不一致");
    });
    if (step.save === "token") {
      if (!payload.data.token) throw new Error("登录缺少 token");
      state.token = payload.data.token;
    }
    if (step.save === "id") state.id = payload.data.id;
    if (step.check) pm.test((index + 1) + ". 数据状态校验", function () {
      var data = payload.data;
      if (step.check === "original" && (data.id !== state.id || data.title !== original.title)) throw new Error("详情与新增订单不一致");
      if (step.check === "changed" && (data.title !== changed.title || data.amount !== changed.amount || data.quantity !== changed.quantity)) throw new Error("编辑结果未保存");
      if (step.check === "list" && !data.list.some(function (item) { return item.id === state.id; })) throw new Error("列表未包含新增订单");
      if (step.check === "deleted" && (data.deleted !== true || data.id !== state.id)) throw new Error("未成功删除本次订单");
      if (step.check === "logout" && data.loggedOut !== true) throw new Error("退登失败");
    });
    run(index + 1);
  });
}
pm.variables.set("mockWorkflowDone", "false");
run(0);
