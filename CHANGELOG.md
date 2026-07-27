# 版本更新记录

用于记录 `Clock` 鸿蒙项目各版本的主要改动，便于后续回顾与排查。

## 维护说明

- 从 `v1.1.0` 开始维护。
- 按版本倒序记录，最新版本放在最前面。
- 每次发版时至少补充：核心功能、平台特性、配置或发版注意事项。

## 记录模板

```md
## v1.x.x - YYYY-MM-DD

### 功能与体验
- 

### 平台与配置
- 

### 备注
- 
```

## 未发布变更 - 2026-05-28

### 功能与体验

- 新增多套表盘主题：
  - 新增 `PosterClock` 整屏主题表盘类型，主页面、表盘选择页和表盘样式弹窗均支持渲染与预览。
  - 新增 11 个海报/全屏风格表盘：赛博朋克、复古翻页、可爱风格、极简 HUD、趣味提示、Orbitron 科幻 HUD、Exo 科技仪表、Audiowide 霓虹合成波、DSEG LED 电子钟、IBM Plex 极简高级、Space Mono 终端复古。
  - 圆形指针表盘从单一样式扩展为 6 个样式，新增冷色科技、赛博朋克、可爱、复古、Art Deco 等视觉变体。
  - `ClockType` 新增 `Poster`，`ClockStyle` 扩展到 `Style11`，用于承载新增表盘样式。
- 表盘选择体验优化：
  - 表盘选择页从单一网格改为分组列表，新增基础数字、圆形指针、机械旋转、日历时光、赛博 HUD、科技仪表、复古电子、终端复古、霓虹合成波、极简高级、可爱趣味等分组。
  - 表盘选择页和样式弹窗中的圆形表盘预览会传入对应 `style`，预览与实际展示保持一致。
- 字体和视觉资源增强：
  - 新增并注册 15 个字体资源：Erbos Draco 1st Open NBP、Jura、Iceland、Raleway Dots、Nova Square、Nova Mono、Geo、Megrim、Monofett、Orbitron、Exo 2、Audiowide、DSEG7 Classic、IBM Plex Mono、Space Mono。
  - 新增 12 张海报表盘背景图，按横屏和竖屏分别提供 Orbitron、Exo2、Audiowide、DSEG、Plex、Space Mono 背景。
  - 新增 `FontPreviewPage` 字体预览页，用于查看字体样式、商用状态、数字是否等宽和适用场景。
  - 设置页新增调试专用“字体预览”入口，仅在 `DEBUG` 为 `true` 时展示。
- 自定义设置新增“音效”开关，默认开启并持久化保存，可统一控制翻页钟和圆形指针钟音效。
- 新增桌面服务卡片能力：
  - 新增 HarmonyOS 服务卡片 `ClockWidgetAbility`，并在 `module.json5` 中注册 `form` 类型 `extensionAbility`。
  - 新增 `clock_widget` 服务卡片配置，默认尺寸为 `2*2`，支持 `2*2`、`2*4`、`4*4` 三种尺寸。
  - 新增桌面小组件选择页 `ClockWidgetsPage`，设置页新增“桌面小组件”入口。
  - 新增 5 类小组件样式：极简数字、小布丁翻页、电子数字、圆形指针、农历日期。
  - 圆形指针小组件扩展为 6 套表盘：经典指针、冷色科技、赛博霓虹、甜心圆盘、复古罗马、金色装饰，并支持 `2*2`、`2*4`、`4*4` 三种尺寸。
  - 小组件按尺寸过滤可选样式，并在选择页提供实时预览；圆形指针表盘在选择页支持左右切换并直接选中对应服务卡片样式。
  - 小组件时间显示统一到分钟级，不显示秒。
  - 新增 `ClockWidgetConfigManager`，支持保存默认小组件样式、记录已添加卡片 `formId`、记录卡片尺寸，并支持更新单个或全部服务卡片。

### 问题修复

- 修复服务卡片日期偶发显示 `NaN-NaN` 的问题：
  - `TextClock.onDateChange` 回调值会先按秒级/毫秒级时间戳兼容并校验。
  - 非法时间值会回退到当前时间，避免 `Invalid Date` 参与日期、农历、AM/PM 和指针角度计算。

### 平台与配置

- 签名与构建配置调整：
  - 签名配置从本机绝对路径调整为项目内相对路径，提升跨环境可构建性。
  - 调整 Debug 签名材料，`book_debug.*`、`clock_debug.p7b` 迁移为 `debug.*`，并更新 debug 证书、CSR、P12、P7B 和 material 文件。
  - `compatibleSdkVersion` 从 `5.0.0(12)` 调整为 `6.1.0(23)`。
  - 新增 `debug` product，使用 debug 签名配置。
  - `strictMode` 增加 `harLocalDependencyCheck: false`。
  - `oh-package-lock.json5` 和 `entry/oh-package-lock.json5` 增加 `enableUnifiedLockfile: false`。
  - `utils/BuildProfile.ets` 从 release 状态调整为 debug 状态。
- 路由与资源配置调整：
  - `main_pages.json` 新增 `pages/Settings/FontPreviewPage` 和 `pages/Settings/ClockWidgetsPage`。
  - 新增服务卡片相关中英文字符串资源。
  - `Index` 主页面新增 `PosterClock` 渲染分支，并为 `RoundClock` 传入样式配置。
- 本地调试脚本增强：
  - 新增 `run-harmony.sh`，支持通过命令行构建、安装和启动 HarmonyOS 应用。
  - 支持指定 hdc target、安装已有 HAP/APP 包、跳过构建/安装/启动，以及列出设备。

### 备注

- 本节依据当前分支 `v1.1.0` 与 `v1.0.5` 的 Git 差异整理，并额外纳入当前工作区未提交的服务卡片改动。
- 已提交差异包含 2 个提交：`298d528`、`3bd1fb2`。
- 已提交文件差异为 59 个文件变更，约 2948 行新增、165 行删除。
- 当前工作区仍有服务卡片相关文件未提交。
- `AppScope/app.json5` 中 `versionName` 仍为 `1.0.5`，`versionCode` 仍为 `1000050`，发布前需要确认是否升版。
- 已执行 HarmonyOS 构建：`assembleApp --mode project -p product=debug --no-daemon`，构建结果成功。
- 构建过程中仍存在若干既有 ArkTS warning，包括 deprecated API、可能抛异常但未显式处理、部分权限提示等；本次变更未处理这些历史 warning。
