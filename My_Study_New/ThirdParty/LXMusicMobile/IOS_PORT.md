# LX Music iOS 移植说明

本目录从 [LX Music 移动版](https://github.com/lyswhut/lx-music-mobile) 的
`master` 源码快照移入（获取日期：2026-09-23，提交：
`fb8480728d875fa5e0da25eebd3a26bb71723aae`）。保留上游 `LICENSE`、
`README.md` 和锁文件。上游仅正式支持 Android，本目录是独立的 iOS 移植工程，
暂不接入 `My_Study` 主 App 的启动流程，以免影响现有功能。

## 构建

需要 Xcode、Node.js、CocoaPods。进入本目录执行：

```sh
npm ci
cd ios
pod install
open LxMusicMobile.xcworkspace
```

在 Xcode 中选择 `LxMusicMobile` Scheme 和自己的签名团队，再选择 iOS 13.4
及以上的设备。Debug 模式需要同时运行 `npm start`；Release 模式会在编译时
打包 JavaScript。所有第三方依赖由 `package-lock.json` 和 CocoaPods 管理，
不要提交 `node_modules`、`Pods` 或编译产物。

## iOS 适配

- `ios/LXMusicNative` 提供设备、缓存、加密、自定义音源脚本以及文件导入的
  React Native 桥接。自定义音源脚本在独立的 JavaScriptCore 上下文执行，
  对外只开放预载脚本所需的函数。
- `src/utils/fs.ios.js` 使用应用的 Documents 目录实现本地文件管理，
  系统文件选择器会将选中的文件导入沙箱。可在 iOS“文件”中访问该目录。
- iOS 没有 Android 的系统悬浮窗。移植版隐藏桌面歌词入口，保留应用内歌词，
  并复用应用内歌词解析结果更新锁屏播放信息。
- `src/utils/localMediaMetadata.ios.ts` 使用 AVFoundation 读取音频标签。
  iOS 的标签、封面、歌词编辑结果暂存为音频旁的 `.lxmeta.json`、
  `.lxcover.*`、`.lrc` 伴随文件；尚不写入原音频的 ID3/FLAC 标签。
- 为兼容用户配置的 HTTP 自定义源，隔离 App 启用了 ATS 任意加载。请只导入
  自己信任的音源脚本，优先使用 HTTPS。项目本身不提供音频源或音频内容。

## 当前状态

TypeScript、改动文件的 ESLint、Metro iOS 资源打包、`LXMusicNative` Pod
单独编译、关闭签名的 Debug 真机架构整包构建，以及 Release 模拟器整包构建均已
通过。Release 包已在 iOS 18.3 的 iPhone 16 Pro 模拟器上成功安装和启动，React
Native 首屏与“谨防被骗提示”可正常渲染。工程使用传统 `RCTBridge`，因此保持
Fabric 与 React Native 新架构关闭，避免旧架构三方组件产生无法解析的 Fabric
注册符号。

已确认一台 iOS 16.5 的 iPhone 12 Pro Max 通过 USB 在线，配对有效、开发者模式
已开启且开发者镜像已挂载，Xcode 可通过设备 UDID 读取其构建设置。项目尚未选择
开发团队，因此还未执行自动签名和真机安装；真机上的启动、播放、音源、搜索、
下载和本地文件流程仍需继续验证，模拟器也尚未覆盖首屏之后的完整交互。因此，
**不能将本目录视为已经完整可用的 iOS App**。现有 `My_Study` 主工程未修改，最终
接入应在上述隔离工程功能验证通过后进行。
