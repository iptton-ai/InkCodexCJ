# InkCodexCJ

> 把你写下的字，交给海里最懂排版的十四位海洋居民。
> **每个字，都值得被海浪排好。**

InkCodex 的 **HarmonyOS 原生版**——使用华为 **仓颉语言（Cangjie）+ ArkUI** 从零重写，不是 Flutter 跨端移植。

- 应用市场：鸿蒙设备搜 **InkCodex**
- Flutter 版（Android / iOS / macOS / Web）：见姊妹仓库 `inkzoo`
- 背景故事：《我让 AI 把一个 1.2 万行的 Flutter 应用，用华为的仓颉语言重写了一遍》（`article-cangjie-rewrite.md`）

## 功能

- 14 位海洋排版师（海獭阿浮 / 章鱼墨教授 / 企鹅波波 / 海龟老墨先生 / 河豚泡泡 + 三波解锁角色），每人一套拟物纸面模板
- 纸面即编辑器：心情标记 → 直接在纸上书写 → 「好了」收进漂流瓶海岸
- 漂流条 / 潮汐月历 / 时间线 / 单角色画廊
- 每日投喂（自定义习惯打卡）、图鉴解锁引擎、深海邮局角色来信、潮汐月刊
- 全部程序化自绘装饰（朱红方印、罗盘、齿孔邮票、声呐圈、CRT 外框……）+ 纸纹底图 + 霞鹜文楷 / Noto Serif SC

## 构建

要求：DevEco Studio 6.1+（含仓颉 SDK 6.1）、HarmonyOS 模拟器或真机。

```bash
export DEVECO_HOME=/Applications/DevEco-Studio.app/Contents
export CANGJIE_SDK_HOME=<你的仓颉 SDK 根目录>
python3 ~/.config/deveco/skills/cangjie-arkts-interop/arkts-invoke-cangjie/build/build.py --project-root ./
# 产物: entry/build/default/outputs/default/entry-default-signed.hap
```

签名：仓库里的 `build-profile.json5` **不含签名密码**（storePassword/keyPassword 为空占位，证书路径指向本仓库外的本地目录）。克隆后请打开 DevEco Studio → File → Project Structure → Signing Configs，勾选 **Automatically generate signature** 完成自动签名，即可构建出已签名的 HAP。

## 目录速览

```
entry/src/main/cangjie/
  model_*.cj          # AnimalSpec(14角色) / TemplateSpec(14套模板) / CardEntry / Habit / Mood
  svc_*.cj            # AppState(解锁引擎+连投) / CardStore(preferences) / Palette / 文案
  wg_*.cj             # StyleCard 拟物渲染管线 / Canvas 程序化装饰 / 编辑器纸面
  ui_*.cj             # 首页 / 编辑器 / 收集册 / 邮局 / 月刊 / 图鉴 / 搜索 / 统计
  index.cj            # Navigation 骨架 + 隐私门 + PIN 锁
entry/src/main/resources/rawfile/
  images/             # 14 角色立绘 + 14 纸纹（复用自 Flutter 版）
  fonts/              # LXGW WenKai Lite / Noto Serif SC
```

## License

代码 MIT；素材与产品设定 © yltech；字体分别遵循其开源许可证（SIL OFL）。
