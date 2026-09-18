# InkCodexCJ 构建与踩坑速查（2026-09-18）

## 构建（必须用这个流程）
```bash
export DEVECO_HOME=/Applications/DevEco-Studio.app/Contents
export CANGJIE_SDK_HOME=~/.cangjie-sdk/6.1/cangjie
python3 ~/.config/deveco/skills/cangjie-arkts-interop/arkts-invoke-cangjie/build/build.py --project-root ./
# 产物: entry/build/default/outputs/default/entry-default-signed.hap
# 安装: hdc -t 127.0.0.1:5555 install -r <hap>
```
- 仓颉工程必须设 `CANGJIE_SDK_HOME`/`DEVECO_HOME`，否则 hvigor 报 00303038 schema 不认 cangjieOptions
- 6.1 SDK 无 compiler/，已 symlink: `~/.cangjie-sdk/6.1/cangjie/compiler -> build-tools`
- stdx 已配置: `cjnative/stdx-*/.../dynamic/stdx`（cjpm.toml path-option）
- 签名复用 `../inkzoo/ohos/signing/`（bundleName=store.yltech.inkcodex 与 Flutter 版相同）；仓库内 build-profile.json5 密码为空串占位，本机出包前需在 DevEco Studio 里重新配置签名
- 模拟器: Pura 90 (127.0.0.1:5555)

## 仓颉 ArkUI 高频坑（新会话必读）
1. `build()`/`@Builder` 内**禁止 let/match 语句**——数据准备全部放成员函数
2. 无三元 `?:`；Int64/Float64 不隐式混算；`init` 是关键字（成员方法改名）
3. enum 无 `==`（用 match）；ArrayList 是 `add` 不是 append；`sortBy(comparator:)` 返回 `Ordering.LT/EQ/GT`
4. `@Component` 构造必须传**全部 var 成员**（@State 可省）→ 动态子组件尽量少 var
5. `@rawfile` 宏只接受**字面量**，不支持 `${}` 插值 → 动态路径用 14 分支成员 @Builder（imgBranch/texBranch 模式已在 utils.cj/各组件）
6. 自定义组件构造在成员 @Builder/深层 lambda 内**无法注入 CustomView** → 用系统组件(Image)或上移到 build 顶层
7. @Builder 调用不能链式 `.属性()`（返回 void）
8. Canvas 不支持 hitTestBehavior/enabled → 触摸穿透用外层 Stack 包裹 + Stack.hitTestBehavior(HitTestMode.None)
9. 无组件截图 API → 卡片持久化=存 JSON + StyleCard 数据驱动重放渲染
10. **MainAbility.onCreate 必须注入 `appContext = Some(this.context)`**——否则 preferences 全部静默失败（无崩溃无日志，冷启动才暴露）
