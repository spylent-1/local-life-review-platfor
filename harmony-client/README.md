# FlashPass HarmonyOS 客户端

课程演示客户端，基于 FlashPass 的资源与权益查询接口。项目源码和后端放在同一仓库中的独立目录；客户端不实现预约下单，避免将示例数据或未验证的交易结果当作真实结果。

## 运行前准备

使用支持 HarmonyOS NEXT / API 12 的 DevEco Studio 打开本目录并同步工程；首次打开时按 IDE 提示配置 SDK、签名及 Hvigor 环境。`AppScope/app.json5` 使用示例 bundleName，可在自己的开发环境中调整。Previewer 和设备的网络地址可能不同，请依据实际环境修改 `entry/src/main/ets/common/ApiClient.ets` 的地址常量。

默认使用本机网络 Mock（`http://127.0.0.1:18081`），在仓库根目录运行：

```powershell
python harmony-client/mock/server.py
```

首页可切换“Mock / 后端”；后端模式默认 `http://127.0.0.1:8081`，需预先配置并启动项目的 MySQL、Redis 与 Spring Boot。服务地址在客户端运行环境中必须可达。网络 Mock 仅是演示数据，不能证明后端真实联调。服务端接口为 `GET /shop/of/name`、`GET /shop/{id}`、`GET /voucher/list/{shopId}`，均采用后端的 `success`、`data`、`errorMsg` 响应结构。

## 验证范围

用 `python -m unittest discover -s harmony-client/mock -p 'test_*.py'` 验证 Mock HTTP 接口。DevEco 构建、Previewer 渲染及客户端网络联调必须在可用的 HarmonyOS 工具链中另行验证，不能由这些接口测试替代。
