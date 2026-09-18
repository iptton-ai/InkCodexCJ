<!--
使用说明（发布前删除本注释）：
1. 三张 SVG 均为 width=660，适配公众号正文 677px 安全宽度；全部使用展示属性
   （fill/font-size 等），没有 <style> 和 class——公众号会剥离样式表，这样写不会丢样式。
2. 版式为纵向布局，手机端阅读不需要横向缩放；小字号最小 9.5px，粘贴后建议手机预览一遍。
3. 字体走系统栈（PingFang SC / 微软雅黑），粘贴用 mdnice / 135编辑器 等支持内联 SVG 的工具；
   若编辑器剥 SVG，可把每张 <svg> 单独存成 .svg 文件经素材库转图片上传。
4. 文中机制与数字均来自本次移植会话的实际记录（源码行数为 wc 实测，坑清单全部实踩复现），无推测内容。
-->

# 我让 AI 把一个 1.2 万行的 Flutter 应用，用华为的仓颉语言重写了一遍

去年我把 InkCodex——一个「把文字交给海洋居民排版」的手帐应用——用 Flutter 写完，上了 Android、iOS、macOS 和 Web。今年鸿蒙的仓颉语言（Cangjie）开放得差不多了，我决定做一个实验：**不移植、不跨端，直接用 AI 把整个应用在仓颉 ArkUI 上从零重写一遍**，看看华为这套新语言加上 AI 编程助手，到底能不能扛起一个真实应用的完整重写。

这个实验最近跑通了。仓颉版也叫 InkCodex，已经在鸿蒙应用市场上架——如果你手上是华为设备，可以和 Flutter 版对照着玩，看看同一个应用换一套全新语言和 UI 框架之后有什么不同。

下面是全过程的技术复盘。所有数字来自实际会话记录（源码行数是 wc 实测，坑全部实踩），没有推测性内容。

**TLDR：**

- 1.2 万行 Flutter 应用的重写不是「逐行翻译」：AI 先派 3 个只读子代理并行逆向源码产出实现规格，再按依赖序用仓颉重实现，最后模拟器闭环验证——翻译管线本身就是这次实验的核心
- 仓颉与 Dart/TS 的语法差异比想象中大得多：无三元表达式、`init` 是关键字、enum 没有 `==`、`build()` 里禁止 let 和 match 语句——十余条实踩全部记录在案
- 最隐蔽的坑是**静默失败**：忘注入一个 context，所有本地存储不落盘，不崩溃、无日志，应用看起来一切正常，冷启动测试才暴露
- 鸿蒙没有组件截图 API，Flutter 版「导出 PNG」的架构走不通——改成「存 JSON + 数据驱动重放渲染」，反而更轻
- 成品约 7,000 行仓颉、24 个源文件，与 Flutter 版共用同一套素材和产品设定，两个版本已经在两个生态各自上架

## 01｜为什么要重写，而不是移植

InkCodex 的玩法是：你写一段话，选一个心情，然后 14 位「海洋排版师」——海獭阿浮、章鱼墨教授、企鹅波波——各自用一套拟物纸面模板帮你把字排好，写完的卡片收进漂流瓶海岸，可以装订成月刊、收图鉴、收角色来信。

Flutter 版做了 4 个平台。但要上鸿蒙，摆在面前两条路：走 Flutter 的鸿蒙适配工程，或者用仓颉 ArkUI 原生写。

我选了后者，原因有三个：仓颉是华为主推的新语言，值得摸一遍真实手感；Flutter 鸿蒙适配毕竟隔着一层引擎，拟物渲染的细节容易打折扣；以及最重要的一条——**我有 AI**。放到两年前，一个人重写一个 1.2 万行的应用是几周的活，现在值得赌一把「一天跑通核心循环」。

实验的判定标准定得很实：隐私政策门、写卡（选心情→纸面书写→保存）、时间线、详情页、本地持久化，这条核心循环必须在真模拟器上完整跑通，且数据冷启动不丢。

## 02｜翻译管线：三个子代理怎么读一万行源码

直接让 AI「看着 Flutter 代码写仓颉」是一定会失败的——上下文装不下，而且翻译腔会很重。实际管线分四步：

<svg width="660" height="500" viewBox="0 0 660 500" xmlns="http://www.w3.org/2000/svg" font-family="-apple-system,BlinkMacSystemFont,'PingFang SC','Hiragino Sans GB','Microsoft YaHei',sans-serif">
  <text x="330" y="34" font-size="17" font-weight="bold" fill="#0f172a" text-anchor="middle">Flutter → 仓颉：四步翻译管线</text>
  <text x="330" y="56" font-size="11.5" fill="#64748b" text-anchor="middle">不是逐行翻译，是「逆向规格 → 重实现 → 闭环验证」</text>
  <rect x="40" y="76" width="180" height="86" rx="12" fill="#f8fafc" stroke="#cbd5e1" stroke-width="1.5"/>
  <text x="130" y="102" font-size="13.5" font-weight="bold" fill="#0f172a" text-anchor="middle">Flutter 源码</text>
  <text x="130" y="124" font-size="10.5" fill="#475569" text-anchor="middle">42 个 dart 文件</text>
  <text x="130" y="142" font-size="10.5" fill="#475569" text-anchor="middle">12,207 行（wc 实测）</text>
  <line x1="220" y1="119" x2="252" y2="119" stroke="#94a3b8" stroke-width="1.6"/>
  <polygon points="252,113 252,125 260,119" fill="#94a3b8"/>
  <rect x="260" y="76" width="150" height="86" rx="12" fill="#eef2ff" stroke="#4d6bfe" stroke-width="1.5"/>
  <text x="335" y="100" font-size="13.5" font-weight="bold" fill="#1e3a8a" text-anchor="middle">3 个只读子代理</text>
  <text x="335" y="120" font-size="10.5" fill="#475569" text-anchor="middle">并行深读：核心页 / 扩展页</text>
  <text x="335" y="136" font-size="10.5" fill="#475569" text-anchor="middle">widgets + 动效参数</text>
  <text x="335" y="152" font-size="10.5" fill="#b45309" text-anchor="middle">产出「能照着重写」的规格</text>
  <line x1="410" y1="119" x2="442" y2="119" stroke="#94a3b8" stroke-width="1.6"/>
  <polygon points="442,113 442,125 450,119" fill="#94a3b8"/>
  <rect x="450" y="76" width="170" height="86" rx="12" fill="#fff7ed" stroke="#fdba74" stroke-width="1.5"/>
  <text x="535" y="100" font-size="13.5" font-weight="bold" fill="#9a3412" text-anchor="middle">依赖序重实现</text>
  <text x="535" y="120" font-size="10.5" fill="#475569" text-anchor="middle">数据层 → 服务层 →</text>
  <text x="535" y="136" font-size="10.5" fill="#475569" text-anchor="middle">渲染管线 → 页面 → 入口</text>
  <text x="535" y="152" font-size="10.5" fill="#b45309" text-anchor="middle">每层编译通过才进下一层</text>
  <line x1="535" y1="162" x2="535" y2="196" stroke="#94a3b8" stroke-width="1.6"/>
  <polygon points="529,196 541,196 535,204" fill="#94a3b8"/>
  <rect x="60" y="204" width="560" height="96" rx="12" fill="#f0fdf4" stroke="#16a34a" stroke-width="1.5"/>
  <text x="340" y="230" font-size="13.5" font-weight="bold" fill="#14532d" text-anchor="middle">逐层编译验证（构建失败立即修，不攒债）</text>
  <text x="340" y="252" font-size="10.5" fill="#475569" text-anchor="middle">数据层+服务层先行编译通过 → 渲染管线编译通过 → 全部页面编译通过</text>
  <text x="340" y="270" font-size="10.5" fill="#475569" text-anchor="middle">模拟器闭环：隐私门 → 写卡 → 心情 → 保存 → 时间线 → 详情 → 冷启动持久化</text>
  <text x="340" y="288" font-size="10.5" fill="#b45309" text-anchor="middle">任何一步不过，循环修改直到绿</text>
  <line x1="340" y1="300" x2="340" y2="330" stroke="#94a3b8" stroke-width="1.6"/>
  <polygon points="334,330 346,330 340,338" fill="#94a3b8"/>
  <rect x="90" y="338" width="500" height="72" rx="12" fill="#fdf2f8" stroke="#ec4899" stroke-width="1.5"/>
  <text x="340" y="362" font-size="13.5" font-weight="bold" fill="#831843" text-anchor="middle">子代理规格的粒度：不是「做了什么」，是「怎么画出来的」</text>
  <text x="340" y="384" font-size="10.5" fill="#475569" text-anchor="middle">例如朱红方印：旋转 -0.06rad、圆角 0.16×边长、白字取角色名首字、字号 0.62×边长</text>
  <text x="340" y="400" font-size="10.5" fill="#475569" text-anchor="middle">照着规格能在仓颉 Canvas 上 1:1 画出来——这是避免「翻译腔」的关键</text>
  <text x="330" y="452" font-size="11" fill="#64748b" text-anchor="middle">产出：24 个仓颉源文件 / 6,979 行 / 素材 68MB 直接复用（角色立绘 + 纸纹 + 字体）</text>
  <text x="330" y="472" font-size="11" fill="#64748b" text-anchor="middle">对照：参考端 42 个 dart 文件 / 12,207 行</text>
</svg>

三个值得展开的点。

**第一，规格的粒度决定成败。** 我给子代理的要求不是「总结这个页面」，而是「产出能照着用另一套 UI 框架重写的规格」：布局树、每个交互的流向、每条动效的时长曲线、每个自绘装饰的绘制算法和参数。结果它的产物细到「朱红方印要旋转 -0.06 弧度、圆角是边长的 0.16 倍、白字取角色名首字、字号是边长的 0.62 倍」——后面在仓颉 Canvas 上重画时就是照抄，视觉几乎无损。

**第二，依赖序比并行重要。** 数据模型 → 存储服务 → 渲染管线 → 页面 → 入口，每完成一层立刻编译，编译不过不写下一层。这让仓颉语言的语法差异（下一节）在很小的代码面上暴露，修起来便宜。

**第三，素材零重做。** 角色立绘、纸纹底图、两个开源字体直接从 Flutter 工程拷进 rawfile 目录。语言换了，产品资产一份没动——这也是两个版本能「同源对比」的前提。

## 03｜仓颉 vs Dart：语法差异比想象的大

这一节是给准备上手仓颉的朋友省时间的。以下每一条都是实踩复现的，不是文档抄的。

<svg width="660" height="560" viewBox="0 0 660 560" xmlns="http://www.w3.org/2000/svg" font-family="-apple-system,BlinkMacSystemFont,'PingFang SC','Hiragino Sans GB','Microsoft YaHei',sans-serif">
  <text x="330" y="32" font-size="17" font-weight="bold" fill="#0f172a" text-anchor="middle">实踩清单：从 Dart/TS 思维到仓颉</text>
  <text x="330" y="54" font-size="11.5" fill="#64748b" text-anchor="middle">左：直觉写法（会错）｜右：仓颉的正确姿势</text>
  <rect x="30" y="72" width="290" height="60" rx="10" fill="#fef2f2" stroke="#fca5a5" stroke-width="1.3"/>
  <text x="175" y="94" font-size="11.5" fill="#991b1b" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">let x = cond ? a : b</text>
  <text x="175" y="114" font-size="10.5" fill="#7f1d1d" text-anchor="middle">三元表达式？仓颉没有</text>
  <rect x="340" y="72" width="290" height="60" rx="10" fill="#f0fdf4" stroke="#86efac" stroke-width="1.3"/>
  <text x="485" y="94" font-size="11.5" fill="#14532d" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">let x = if (cond) { a } else { b }</text>
  <text x="485" y="114" font-size="10.5" fill="#166534" text-anchor="middle">if 是表达式，两个分支都要给值</text>
  <rect x="30" y="140" width="290" height="60" rx="10" fill="#fef2f2" stroke="#fca5a5" stroke-width="1.3"/>
  <text x="175" y="162" font-size="11.5" fill="#991b1b" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">enum Color { red, green }</text>
  <text x="175" y="182" font-size="10.5" fill="#7f1d1d" text-anchor="middle">成员用 == 比较或取 name？</text>
  <rect x="340" y="140" width="290" height="60" rx="10" fill="#f0fdf4" stroke="#86efac" stroke-width="1.3"/>
  <text x="485" y="162" font-size="11.5" fill="#14532d" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">enum Color { Red | Green }</text>
  <text x="485" y="182" font-size="10.5" fill="#166534" text-anchor="middle">成员用 | 分隔；比较要用 match</text>
  <rect x="30" y="208" width="290" height="60" rx="10" fill="#fef2f2" stroke="#fca5a5" stroke-width="1.3"/>
  <text x="175" y="230" font-size="11.5" fill="#991b1b" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">store.init() / list.append(x)</text>
  <text x="175" y="250" font-size="10.5" fill="#7f1d1d" text-anchor="middle">init 是关键字；ArrayList 是 append？</text>
  <rect x="340" y="208" width="290" height="60" rx="10" fill="#f0fdf4" stroke="#86efac" stroke-width="1.3"/>
  <text x="485" y="230" font-size="11.5" fill="#14532d" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">store.ensure() / list.add(x)</text>
  <text x="485" y="250" font-size="10.5" fill="#166534" text-anchor="middle">init 做关键字被保留；加元素叫 add</text>
  <rect x="30" y="276" width="290" height="60" rx="10" fill="#fef2f2" stroke="#fca5a5" stroke-width="1.3"/>
  <text x="175" y="298" font-size="11.5" fill="#991b1b" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">1.5 * 2 / a + b 混算</text>
  <text x="175" y="318" font-size="10.5" fill="#7f1d1d" text-anchor="middle">Int 和 Float 随便混？</text>
  <rect x="340" y="276" width="290" height="60" rx="10" fill="#f0fdf4" stroke="#86efac" stroke-width="1.3"/>
  <text x="485" y="298" font-size="11.5" fill="#14532d" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">w / 2.0  ·  2.0 * m</text>
  <text x="485" y="318" font-size="10.5" fill="#166534" text-anchor="middle">Int64/Float64 不隐式混算，字面量写全</text>
  <rect x="30" y="344" width="290" height="60" rx="10" fill="#fef2f2" stroke="#fca5a5" stroke-width="1.3"/>
  <text x="175" y="366" font-size="11.5" fill="#991b1b" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">list.sort { a, b in a - b }</text>
  <text x="175" y="386" font-size="10.5" fill="#7f1d1d" text-anchor="middle">比较器返回差值？</text>
  <rect x="340" y="344" width="290" height="60" rx="10" fill="#f0fdf4" stroke="#86efac" stroke-width="1.3"/>
  <text x="485" y="366" font-size="11.5" fill="#14532d" text-anchor="middle" font-family="'SF Mono',Menlo,monospace">sortBy(comparator: {a,b =&gt; Ordering.LT})</text>
  <text x="485" y="386" font-size="10.5" fill="#166534" text-anchor="middle">返回 Ordering 枚举 LT/EQ/GT</text>
  <rect x="30" y="412" width="600" height="112" rx="10" fill="#fffbeb" stroke="#fcd34d" stroke-width="1.4"/>
  <text x="330" y="436" font-size="12.5" font-weight="bold" fill="#78350f" text-anchor="middle">UI 层差异更狠（ArkUI 宏约束）：这几条坑最深</text>
  <text x="330" y="458" font-size="10.5" fill="#92400e" text-anchor="middle">build()/@Builder 里禁止 let 和 match 语句——数据准备全部搬进成员函数</text>
  <text x="330" y="476" font-size="10.5" fill="#92400e" text-anchor="middle">@Component 构造必须传全部 var 成员（@State 可省）；@rawfile 宏只接受字面量、不支持 ${} 插值</text>
  <text x="330" y="494" font-size="10.5" fill="#92400e" text-anchor="middle">自定义组件构造在成员 @Builder / 深 lambda 内无法自动注入上下文——动态组件要上移到 build 顶层</text>
  <text x="330" y="512" font-size="9.5" fill="#b45309" text-anchor="middle">以上每条都在本次会话实踩并记录于项目 AGENTS.md，供后续会话直接查阅</text>
</svg>

这些差异单个都不难，麻烦在**组合密度**：一个 6,000 行的工程里，每一处都可能踩。我的做法是把「每层编译通过再进下一层」当成铁律——语法差异在小代码面上暴露，AI 修起来又快又准。全部跑完，编译迭代大约三四十轮，没有一轮超过几分钟。

## 04｜最隐蔽的坑：一个没有报错的失败

整个实验里花时间最长的 bug，不是编译错误，是一个**没有任何报错的静默失败**。

症状：应用里一切正常——写卡、保存、收信，但应用重启后数据全部消失，而且退回最初的状态，连「已同意隐私政策」都忘了。

排查路径值得细说。首先排除 UI：保存流程的日志显示数据已经进了内存列表；再排除通知机制：监听器触发正常。然后做了一次决定性实验——**冷启动**：杀掉进程重新打开，应用回到了隐私政策同意页。

这一下就锁定了问题面：不是「保存后刷新失败」，而是**所有 Preferences 持久化全部没落盘**——卡片索引、同意状态、习惯、密码，一个都没写进去。而读写代码不抛异常、不报错，内存态一切正常。

根因一行就能说完：鸿蒙的 Preferences API 需要一个 UIAbility 的 context 来定位存储文件，这个 context 在 Ability 生命周期里注入。移植时我把存储层写好了，却在 `MainAbility` 的 `onCreate` 里**忘了把 context 赋给全局变量**。于是存储层拿到的是「空」，所有写入静默跳过——不崩、无日志、行为看起来完全正常。

<svg width="660" height="420" viewBox="0 0 660 420" xmlns="http://www.w3.org/2000/svg" font-family="-apple-system,BlinkMacSystemFont,'PingFang SC','Hiragino Sans GB','Microsoft YaHei',sans-serif">
  <text x="330" y="32" font-size="17" font-weight="bold" fill="#0f172a" text-anchor="middle">静默失败的排查：冷启动是照妖镜</text>
  <rect x="40" y="60" width="580" height="54" rx="10" fill="#f8fafc" stroke="#cbd5e1" stroke-width="1.3"/>
  <text x="330" y="82" font-size="11.5" fill="#0f172a" text-anchor="middle">症状：应用内一切正常，重启后数据全丢、状态全部重置</text>
  <text x="330" y="100" font-size="10.5" fill="#64748b" text-anchor="middle">无崩溃 · 无错误日志 · 内存态读写全部正常</text>
  <line x1="330" y1="114" x2="330" y2="136" stroke="#94a3b8" stroke-width="1.5"/>
  <polygon points="324,136 336,136 330,144" fill="#94a3b8"/>
  <rect x="40" y="144" width="280" height="66" rx="10" fill="#fef2f2" stroke="#fca5a5" stroke-width="1.3"/>
  <text x="180" y="168" font-size="12" font-weight="bold" fill="#991b1b" text-anchor="middle">直觉方向（死路）</text>
  <text x="180" y="188" font-size="10.5" fill="#7f1d1d" text-anchor="middle">查 UI 刷新链路 / 查通知机制</text>
  <text x="180" y="204" font-size="10.5" fill="#7f1d1d" text-anchor="middle">日志显示「保存成功」，越查越懵</text>
  <rect x="340" y="144" width="280" height="66" rx="10" fill="#f0fdf4" stroke="#86efac" stroke-width="1.3"/>
  <text x="480" y="168" font-size="12" font-weight="bold" fill="#14532d" text-anchor="middle">决定性实验：冷启动</text>
  <text x="480" y="188" font-size="10.5" fill="#166534" text-anchor="middle">杀进程重启 → 回到隐私同意页</text>
  <text x="480" y="204" font-size="10.5" fill="#166534" text-anchor="middle">锁定问题面：持久化整体未落盘</text>
  <line x1="480" y1="210" x2="480" y2="234" stroke="#94a3b8" stroke-width="1.5"/>
  <polygon points="474,234 486,234 480,242" fill="#94a3b8"/>
  <rect x="40" y="242" width="580" height="60" rx="10" fill="#fff7ed" stroke="#fdba74" stroke-width="1.4"/>
  <text x="330" y="266" font-size="12" font-weight="bold" fill="#9a3412" text-anchor="middle">根因：Ability 的 onCreate 忘了把 context 注入全局变量</text>
  <text x="330" y="288" font-size="10.5" fill="#b45309" text-anchor="middle">存储层拿到空 context → 所有 put 静默跳过 → 不崩、无日志、内存态一切正常</text>
  <line x1="330" y1="302" x2="330" y2="326" stroke="#94a3b8" stroke-width="1.5"/>
  <polygon points="324,326 336,326 330,334" fill="#94a3b8"/>
  <rect x="40" y="334" width="580" height="60" rx="10" fill="#eef2ff" stroke="#4d6bfe" stroke-width="1.4"/>
  <text x="330" y="358" font-size="12" font-weight="bold" fill="#1e3a8a" text-anchor="middle">修复 = 一行：onCreate 里注入 context</text>
  <text x="330" y="380" font-size="10.5" fill="#475569" text-anchor="middle">并把「冷启动持久化验证」写进验收标准——静默失败只能靠它暴露</text>
</svg>

这件事改变了我对「AI 写代码验收标准」的看法：**功能跑通不算数，冷启动再看一眼才算数**。像「忘注入依赖」这类错误，AI 生成的代码和我们手写的代码一样会犯，而且因为它不报错，比编译错误危险得多。现在它被写进了项目的验收清单第一行。

## 05｜架构差异：没有截图 API 之后

两个版本有两个绕不开的平台差异，处理方式正好能说明「重写」和「翻译」的区别。

**导出与持久化。** Flutter 版保存卡片靠组件截图：把拟物卡片渲染成高分辨率 PNG 存进文档目录，时间线和详情页直接贴图。仓颉 ArkUI 目前没有等价的组件截图 API。与其硬凑，不如换个架构：**本地只存卡片的 JSON 数据（文字、模板、心情、贴纸），时间线和详情页用同一个卡片渲染组件按数据实时重放**。好处是存储从几十 MB 的图片变成几 KB 的文本，坏处是渲染组件必须做到「任何参数组合都能确定性重画」——好在拟物管线本来就是数据驱动的，这个约束反而是白送的。

**动态图标的兜底。** 14 位角色的头像图，在部分嵌套布局里（日历格、漂流条）无法优雅引用带插值的资源路径——仓颉的 `@rawfile` 宏只接受编译期字面量。第一版用 14 个静态分支解决，后来发现部分上下文连分支组件都放不进去，最终这些小位置用了 emoji 徽章兜底（🦦🐙🐧🐢🐡）。产品层面的判断是：小尺寸下 emoji 的辨识度足够，等平台能力补齐再换回立绘。

**有意留下的差异**也说一下，免得大家对比时困惑：仓颉版首发只带了中文（Flutter 版是中英日韩四语）；三个「签名瞬间」转场动效和贴纸铺还在排期；但核心的 14 套拟物模板、心情系统、图鉴解锁引擎、角色来信、月刊，两个版本是一致的。

## 06｜两个版本，欢迎对比

如果你看到了这里，可以上手试试：

- **鸿蒙设备**：应用市场搜 InkCodex，这是仓颉 ArkUI 原生版——值得感受一下原生渲染下纸纹和自绘装饰的细腻程度
- **Android / iOS / macOS / Web**：Flutter 版在各应用商店与官网，功能和玩法更全（四语言、分享导出、贴纸铺）

两个版本共用同一套世界观、素材和核心玩法，但引擎、语言、UI 框架完全不同。我自己最喜欢的一个对比点：同一张「海獭阿浮」的卡片，Flutter 版是 Skia 画的，仓颉版是 ArkUI Canvas 按同一套参数重画的——放在一起看，几乎认不出是两套引擎的作品。

最后说下这次实验的真实体感。仓颉是一门设计相当现代的语言（模式匹配、代数类型、宏扩展的 ArkUI 声明式范式），但它还很年轻：工具链的脾气、文档的完备度、和成熟生态的差距都真实存在。而 AI 在这次重写里的角色，与其说是「翻译器」，不如说是**一个不知疲倦、读过全部源码、且从不嫌烦的实现工程师**——它把「一个人重写一个应用」从几周压缩到一个下午，把我的工作变成了定规格、定验收标准、以及在它踩进静默失败的坑时递上一根冷启动的绳子。

语言是新语言，应用是老应用，AI 是新同事。三者凑齐的这一天，比我想象中来得早。

---

*本文所有数据来自 InkCodexCJ 会话实测记录；两个版本的仓库与上架信息见应用内「关于」。*
