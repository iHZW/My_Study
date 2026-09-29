<p align="center"><a href="https://github.com/lyswhut/lx-music-mobile"><img width="200" src="https://github.com/lyswhut/lx-music-mobile/blob/master/doc/images/icon.png" alt="lx-music logo"></a></p>

<h1 align="center">LX Music 移动版</h1>

<p align="center">
  <a href="https://github.com/lyswhut/lx-music-mobile/releases"><img src="https://img.shields.io/github/release/lyswhut/lx-music-mobile" alt="Release version"></a>
  <a href="https://github.com/lyswhut/lx-music-mobile/actions/workflows/release.yml"><img src="https://github.com/lyswhut/lx-music-mobile/workflows/Build/badge.svg" alt="Build status"></a>
  <a href="https://github.com/lyswhut/lx-music-mobile/actions/workflows/beta-pack.yml"><img src="https://github.com/lyswhut/lx-music-mobile/workflows/Build%20Beta/badge.svg" alt="Build status"></a>
  <a href="https://github.com/facebook/react-native"><img src="https://img.shields.io/github/package-json/dependency-version/lyswhut/lx-music-mobile/react-native/master" alt="React native version"></a>
  <!-- <a href="https://github.com/lyswhut/lx-music-mobile/releases"><img src="https://img.shields.io/github/downloads/lyswhut/lx-music-mobile/latest/total" alt="Downloads"></a> -->
  <a href="https://github.com/lyswhut/lx-music-mobile/tree/dev"><img src="https://img.shields.io/github/package-json/v/lyswhut/lx-music-mobile/dev" alt="Dev branch version"></a>
  <!-- <a href="https://github.com/lyswhut/lx-music-mobile/blob/master/LICENSE"><img src="https://img.shields.io/github/license/lyswhut/lx-music-mobile" alt="License"></a> -->
</p>

<p align="center">一个基于 React Native 开发的音乐软件</p>

## 说明

所用技术栈：

- React Native
- Redux

已支持的平台：

- Android 5 及以上
- iOS 13.4 及以上（本仓库的 iOS 适配版本）

## iOS 源码运行指南

本仓库已经包含可运行的 iOS 工程、原生模块和 iPhone UI 适配。为避免依赖
版本或构建方式不同导致运行结果与当前工程不一致，请按照下面的固定流程操作。

### 已验证的开发环境

- macOS 与 Xcode（当前工程验证版本为 Xcode 26.3）
- Node.js 22（项目最低要求为 Node.js 18）
- npm 10
- CocoaPods 1.16.2
- iOS 13.4 或更高版本的模拟器、iPhone
- 真机运行时需要可用于自动签名的 Apple Developer 账号

不要求每台电脑与上述小版本完全相同，但应优先使用仓库中的
`package-lock.json` 和 `ios/Podfile.lock`，不要自行升级依赖。

### 全新克隆后的初始化步骤

以下命令均在仓库根目录执行：

```bash
git clone <仓库地址>
cd LXMusicMobile

# 严格按照 package-lock.json 安装 JS 与 React Native 依赖。
# npm ci 完成后会自动执行 postinstall，应用本项目所需的 iOS 兼容补丁。
npm ci

# 严格按照 Podfile.lock 安装 iOS 原生依赖并生成 xcworkspace。
cd ios
USE_HERMES=0 NO_FLIPPER=1 pod install --deployment
cd ..

# 必须打开 workspace，不能打开 xcodeproj。
open ios/LxMusicMobile.xcworkspace
```

如果本机 CocoaPods 的索引过旧，可以先执行 `pod repo update`，然后重新执行
上述 `pod install --deployment`。不要使用 `pod update`，因为它会主动升级原生
依赖并改变已验证的构建环境。

### Xcode 真机运行

1. 在 Xcode 中选择 `LxMusicMobile` Scheme。
2. 选择已连接并已开启“开发者模式”的 iPhone。
3. 打开 Target `LxMusicMobile` 的 `Signing & Capabilities`。
4. 勾选 `Automatically manage signing`，选择自己的开发团队。
5. 如果当前 Bundle Identifier 不属于该团队，改成自己账号下唯一的标识。
6. 点击 Xcode 的 Run 按钮安装并启动。

当前共享 Scheme 的 Run 配置是 **Release**。Xcode 构建时会通过
`Bundle React Native code and images` 阶段生成并打包 `main.jsbundle`，因此按
当前方式直接运行时不需要单独启动 Metro，也不需要手工执行“生成 iOS 代码”命令。

首次在真机启动时，如果系统提示开发者不受信任，请在 iPhone 的
“设置 → 通用 → VPN 与设备管理”中信任对应开发者证书。

### React Native 命令会不会改变当前 iOS 工程

下列命令不会重写仓库中的 iOS 业务代码：

- `npm ci`：重新创建 `node_modules`，并通过 `postinstall` 自动恢复本仓库的
  TrackPlayer、React Bridge 等 iOS 补丁；这是全新克隆后的推荐命令。
- `npm run start`：仅启动 Metro 开发服务器，不修改 iOS 工程。
- `npm run sc`：清理 Metro 缓存后启动服务，不修改 iOS 工程。
- `npm run ios`：调用 React Native CLI 执行 Xcode 构建，不会“重新生成”或覆盖
  已有 iOS 源码；但它默认偏向 Debug/模拟器工作流，与当前已经验证的
  Xcode Release 真机流程不同，因此本项目不建议将它作为日常运行方式。
- `pod install --deployment`：按照 `Podfile.lock` 恢复 Pods 和 workspace，生成物
  位于 Git 忽略目录，不会覆盖 `ios/LxMusicMobile` 与 `ios/LXMusicNative` 源码。

下列操作可能使依赖或工程状态与当前已验证版本不一致，不建议执行：

- `npm install` 后接受新的 lockfile 变化
- `npm update`、`npm audit fix`
- `pod update`
- `npx react-native upgrade`
- 手工修改 `node_modules` 后未同步更新
  `scripts/patchReactNativeTrackPlayer.js`
- 删除或绕过 `package-lock.json`、`ios/Podfile.lock`

如果只是修改了 `src` 下的 React Native JS/TS 代码，直接重新从 Xcode Run 即可；
如果修改了 `ios` 原生源码，同样直接重新编译即可；只有修改 `Podfile` 或原生依赖
时才需要重新执行 `pod install`。

### 依赖一致性检查

`npm ci` 执行的 `postinstall` 补丁脚本是幂等的，重复运行不会重复修改代码。
安装完成时终端应显示 TrackPlayer 时间单位、元数据参数、队列边界和 React Bridge
生命周期等补丁已经应用或已经存在。如果脚本提示“源码结构已变化”，说明依赖没有
命中仓库锁定版本，此时不要继续升级，应先恢复 `package-lock.json` 后重新执行
`npm ci`。

***注：上游官方版本目前没有 iOS 与 HarmonyOS NEXT 支持计划；本仓库维护的是独立的 iOS 适配版本。**<br>
*桌面版项目地址：<https://github.com/lyswhut/lx-music-desktop>*<br>
*LX Music 项目发展调整与新项目计划：https://github.com/lyswhut/lx-music-desktop/issues/1912*

软件变化请查看[更新日志](https://github.com/lyswhut/lx-music-mobile/blob/master/CHANGELOG.md)。

软件下载请查看 [GitHub Releases](https://github.com/lyswhut/lx-music-mobile/releases)。

使用常见问题请参阅[移动版常见问题](https://lyswhut.github.io/lx-music-doc/mobile/faq)。

目前本项目的原始发布地址只有 [**GitHub**](https://github.com/lyswhut/lx-music-mobile/releases)，其他渠道均为第三方转载发布，与本项目无关！

为了提高使用门槛，本软件内的默认设置、UI 操作不以新手友好为目标，所以使用前建议先根据你的喜好浏览调整一遍软件设置，阅读一遍[音乐播放列表机制](https://lyswhut.github.io/lx-music-doc/mobile/faq/playlist)。

### 数据同步服务

从 v1.0.0 起，我们发布了一个独立的[数据同步服务](https://github.com/lyswhut/lx-music-sync-server#readme)。如果你有服务器，可以将其部署到服务器上作为私人多端同步服务使用，详情看该项目说明。

## 贡献代码

本项目欢迎 PR，但为了 PR 能顺利合并，需要注意以下几点：

- 对于添加新功能的 PR，建议在提交 PR 前先创建 Issue 进行说明，以确认该功能是否确实需要；
- 对于修复 bug 的 PR，请提供修复前后的说明及重现方式；
- 对于其他类型的 PR，则适当附上说明。

贡献代码步骤：

1. 参照[源码使用方法](https://lyswhut.github.io/lx-music-doc/mobile/use-source-code)设置开发环境；
2. 克隆本仓库代码并切换至 `dev` 分支进行开发；
3. 提交 PR 至 `dev` 分支。

<!--
## 用户界面

<p><img width="100%" src="https://github.com/lyswhut/lx-music-mobile/blob/master/doc/images/app.png" alt="lx-music mobile UI"></p> -->

## 项目协议

本项目基于 [Apache License 2.0](https://github.com/lyswhut/lx-music-mobile/blob/master/LICENSE) 许可证发行，以下协议是对于 Apache License 2.0 的补充，如有冲突，以以下协议为准。

---

*词语约定：本协议中的“本项目”指 LX Music（洛雪音乐）移动版项目；“使用者”指签署本协议的使用者；“官方音乐平台”指对本项目内置的包括酷我、酷狗、咪咕等音乐源的官方平台统称；“版权数据”指包括但不限于图像、音频、名字等在内的他人拥有所属版权的数据。*

### 一、数据来源

1.1 本项目的各官方平台在线数据来源原理是从其公开服务器中拉取数据（与未登录状态在官方平台 APP 获取的数据相同），经过对数据简单地筛选与合并后进行展示，因此本项目不对数据的合法性、准确性负责。

1.2 本项目本身没有获取某个音频数据的能力，本项目使用的在线音频数据来源来自软件设置内“自定义源”设置所选择的“源”返回的在线链接。例如播放某首歌，本项目所做的只是将希望播放的歌曲名、艺术家等信息传递给“源”，若“源”返回了一个链接，则本项目将认为这就是该歌曲的音频数据而进行使用，至于这是不是正确的音频数据本项目无法校验其准确性，所以使用本项目的过程中可能会出现希望播放的音频与实际播放的音频不对应或者无法播放的问题。

1.3 本项目的非官方平台数据（例如“我的列表”内列表）来自使用者本地系统或者使用者连接的同步服务，本项目不对这些数据的合法性、准确性负责。

### 二、版权数据

2.1 使用本项目的过程中可能会产生版权数据。对于这些版权数据，本项目不拥有它们的所有权。为了避免侵权，使用者务必在 **24 小时内** 清除使用本项目的过程中所产生的版权数据。

### 三、音乐平台别名

3.1 本项目内的官方音乐平台别名为本项目内对官方音乐平台的一个称呼，不包含恶意。如果官方音乐平台觉得不妥，可联系本项目更改或移除。

### 四、资源使用

4.1 本项目内使用的部分包括但不限于字体、图片等资源来源于互联网。如果出现侵权可联系本项目移除。

### 五、免责声明

5.1 由于使用本项目产生的包括由于本协议或由于使用或无法使用本项目而引起的任何性质的任何直接、间接、特殊、偶然或结果性损害（包括但不限于因商誉损失、停工、计算机故障或故障引起的损害赔偿，或任何及所有其他商业损害或损失）由使用者负责。

### 六、使用限制

6.1 本项目完全免费，且开源发布于 GitHub 面向全世界人用作对技术的学习交流。本项目不对项目内的技术可能存在违反当地法律法规的行为作保证。

6.2 **禁止在违反当地法律法规的情况下使用本项目。** 对于使用者在明知或不知当地法律法规不允许的情况下使用本项目所造成的任何违法违规行为由使用者承担，本项目不承担由此造成的任何直接、间接、特殊、偶然或结果性责任。

### 七、版权保护

7.1 音乐平台不易，请尊重版权，支持正版。

### 八、非商业性质

8.1 本项目仅用于对技术可行性的探索及研究，不接受任何商业（包括但不限于广告等）合作及捐赠。

### 九、接受协议

9.1 若你使用了本项目，即代表你接受本协议。

---

若对此有疑问请 mail to: lyswhut+qq.com (请将 `+` 替换成 `@`)
