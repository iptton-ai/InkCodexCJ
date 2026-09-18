package ohos_app_cangjie_entry

// 拟物模板数据层。
// 渲染顺序：bgTexture → ornaments(under) → 正文块 → ornaments(over)。
// 一切带图形语义的装饰都是程序化自绘的 OrnamentKind；AI 只出纸纹底板。
//
// wave2/wave3 增补 datum 通道：模板消化卡片元数据
// （日期→邮戳/深度/韵目/坐标/潮时，心情→邮票/回波点/海况，字数→格数页脚）。

enum OrnamentKind {
    | WashiTape
    | SealStamp
    | AvatarCharm
    | DashedRules
    | DoubleFrame
    | SideBar
    | Footprints
    | EmbossEmblem
    | WaveRule
    | CornerTape
    | BubbleDots
    | MoonSeal
    | GlowHalo
    | TagHole
    | CutDashed
    | CompassRose
    | ChartRoute
    | StampCorner
    | WavePostmark
    | SweepRing
}

// 签名/日期的落款排布方式。
enum FooterKind {
    | FooterWashi
    | FooterBookish
    | FooterNordic
    | FooterLetterpress
    | FooterDoodle
    | FooterPosterDate
    | FooterGlowTrail
    | FooterTagStub
    | FooterGridCount
    | FooterChartCoord
    | FooterPostmark
    | FooterDepth
    | FooterRhyme
    | FooterTide
}

enum HeaderKind {
    | HeaderNone
    | HeaderCenterTitle
    | HeaderGridHeader
}

class OrnamentSpec {
    let kind: OrnamentKind

    // 锚点：相对整卡的中心偏移（-1..1，x 向右 y 向下）。
    let ax: Float64
    let ay: Float64

    // 占比尺寸（相对卡宽）。
    let sizeFrac: Float64

    // 是否绘制在正文上层。
    let over: Bool

    // 颜色 token：accent / seal / ink。
    let tone: String

    init(kind: OrnamentKind, ax!: Float64 = 0.0, ay!: Float64 = 0.0,
        sizeFrac!: Float64 = 0.2, over!: Bool = false, tone!: String = "accent") {
        this.kind = kind
        this.ax = ax
        this.ay = ay
        this.sizeFrac = sizeFrac
        this.over = over
        this.tone = tone
    }
}

class TemplateSpec {
    let animal: AnimalSpec

    // AI 纸质底板；缺失时回退纯色。
    let textureAsset: ?String

    let header: HeaderKind
    let footer: FooterKind

    // 正文安全区（比例坐标：四边均相对卡宽）。
    let safeL: Float64
    let safeT: Float64
    let safeR: Float64
    let safeB: Float64

    let lineHeight: Float64

    // 卡片圆角。
    let radius: Float64

    // 字号整体增益（长风 1.35：短文海报大字）。
    let fontScale: Float64

    // 正文字距（伏特 2.0：电报体拉开）。
    let letterSpacing: Float64

    // 右上斜切角 + 卡底撕线（小安·行李吊牌造型）。
    let tagNotch: Bool

    // 正文发光（夜光=霓虹 / 提灯=磷光）。
    let glowText: Bool

    // 粉笔字质感（柔和白晕，粉笔姐）。
    let chalkText: Bool

    let under: Array<OrnamentSpec>
    let over: Array<OrnamentSpec>

    init(animal!: AnimalSpec, textureAsset!: ?String = None<String>,
        header!: HeaderKind = HeaderNone, footer!: FooterKind = FooterWashi,
        safeL!: Float64 = 0.08, safeT!: Float64 = 0.07, safeR!: Float64 = 0.08,
        safeB!: Float64 = 0.06, lineHeight!: Float64 = 1.85, radius!: Float64 = 12.0,
        fontScale!: Float64 = 1.0, letterSpacing!: Float64 = 0.0,
        tagNotch!: Bool = false, glowText!: Bool = false, chalkText!: Bool = false,
        under!: Array<OrnamentSpec> = Array<OrnamentSpec>(),
        over!: Array<OrnamentSpec> = Array<OrnamentSpec>()) {
        this.animal = animal
        this.textureAsset = textureAsset
        this.header = header
        this.footer = footer
        this.safeL = safeL
        this.safeT = safeT
        this.safeR = safeR
        this.safeB = safeB
        this.lineHeight = lineHeight
        this.radius = radius
        this.fontScale = fontScale
        this.letterSpacing = letterSpacing
        this.tagNotch = tagNotch
        this.glowText = glowText
        this.chalkText = chalkText
        this.under = under
        this.over = over
    }

    // 十四套模板：首波五位 + wave2 五位 + wave3 四位。
    static func specOf(style: CardStyle): TemplateSpec {
        match (style) {
            // 阿浮·漂流手帖：米白纸 + 虚线行线 + 朱红「漂」字印章 + 右下海獭小像
            case Washi => TemplateSpec(
                animal: AnimalSpec.all[0],
                textureAsset: Some("images/tex_otter.png"),
                header: HeaderNone, footer: FooterWashi,
                safeL: 0.075, safeT: 0.055, safeR: 0.075, safeB: 0.05,
                lineHeight: 1.85, radius: 18.0,
                under: [OrnamentSpec(DashedRules, tone: "ink")],
                over: [
                    OrnamentSpec(WashiTape, ax: 0.0, ay: -1.0, sizeFrac: 0.26, over: true),
                    OrnamentSpec(SealStamp, ax: 0.82, ay: 0.86, sizeFrac: 0.115, over: true),
                    OrnamentSpec(AvatarCharm, ax: 0.55, ay: 0.9, sizeFrac: 0.15, over: true),
                ])
            // 墨教授·深海藏书页：双细线框 + 居中题头 + 海绿书脊条
            case Bookish => TemplateSpec(
                animal: AnimalSpec.all[1],
                textureAsset: Some("images/tex_octo.png"),
                header: HeaderCenterTitle, footer: FooterBookish,
                safeL: 0.09, safeT: 0.075, safeR: 0.09, safeB: 0.06,
                lineHeight: 1.8, radius: 0.0,
                under: [
                    OrnamentSpec(DoubleFrame, tone: "accent"),
                    OrnamentSpec(SideBar, ax: -1.0, ay: 0.0, sizeFrac: 0.028, tone: "accent"),
                ])
            // 波波·冰原便签：大留白 + 左侧冰蓝竖条 + 微型企鹅脚印页脚
            case Nordic => TemplateSpec(
                animal: AnimalSpec.all[2],
                textureAsset: Some("images/tex_penguin.png"),
                header: HeaderNone, footer: FooterNordic,
                safeL: 0.11, safeT: 0.09, safeR: 0.085, safeB: 0.06,
                lineHeight: 1.95, radius: 0.0,
                under: [
                    OrnamentSpec(SideBar, ax: -1.0, ay: 0.0, sizeFrac: 0.016, tone: "accent"),
                ],
                over: [
                    OrnamentSpec(Footprints, ax: 0.55, ay: 0.94, sizeFrac: 0.3, over: true, tone: "accent"),
                ])
            // 老墨先生·铅字潮痕卡：做旧牛皮纸底 + 花饰分隔线 + 钢印
            case Letterpress => TemplateSpec(
                animal: AnimalSpec.all[3],
                textureAsset: Some("images/tex_turtle.png"),
                header: HeaderNone, footer: FooterLetterpress,
                safeL: 0.09, safeT: 0.06, safeR: 0.09, safeB: 0.05,
                lineHeight: 1.9, radius: 6.0,
                under: [
                    OrnamentSpec(DoubleFrame, tone: "accent"),
                ],
                over: [
                    OrnamentSpec(EmbossEmblem, ax: 0.8, ay: -0.72, sizeFrac: 0.16, over: true, tone: "seal"),
                ])
            // 泡泡·气泡涂鸦纸：明黄底 + 手绘波浪下划线 + 贴角胶带 + 气泡点缀
            case Doodle => TemplateSpec(
                animal: AnimalSpec.all[4],
                textureAsset: Some("images/tex_bubble.png"),
                header: HeaderNone, footer: FooterDoodle,
                safeL: 0.08, safeT: 0.07, safeR: 0.08, safeB: 0.06,
                lineHeight: 1.9, radius: 4.0,
                under: [
                    OrnamentSpec(WaveRule, ax: 0.0, ay: 0.62, sizeFrac: 0.62, tone: "accent"),
                ],
                over: [
                    OrnamentSpec(CornerTape, over: true),
                    OrnamentSpec(BubbleDots, ax: 0.72, ay: -0.62, sizeFrac: 0.3, over: true, tone: "accent"),
                ])
            // 长风·深海大字笺：短册式极端留白 + 字放大 + 底部浪线 + 圆月浅印
            case Poster => TemplateSpec(
                animal: AnimalSpec.all[5],
                textureAsset: Some("images/tex_whale.png"),
                header: HeaderNone, footer: FooterPosterDate,
                safeL: 0.14, safeT: 0.14, safeR: 0.14, safeB: 0.16,
                lineHeight: 1.9, radius: 16.0, fontScale: 1.35,
                under: [
                    OrnamentSpec(WaveRule, ax: 0.0, ay: 0.92, sizeFrac: 0.46, tone: "accent"),
                ],
                over: [
                    OrnamentSpec(MoonSeal, ax: 0.82, ay: 0.85, sizeFrac: 0.13, over: true, tone: "seal"),
                ])
            // 夜光·荧光诗签：深夜底 + 光晕 + 发光字 + 光点页脚
            case Glow => TemplateSpec(
                animal: AnimalSpec.all[6],
                textureAsset: Some("images/tex_jelly.png"),
                header: HeaderNone, footer: FooterGlowTrail,
                safeL: 0.12, safeT: 0.12, safeR: 0.12, safeB: 0.1,
                lineHeight: 2.0, radius: 18.0, glowText: true,
                under: [
                    OrnamentSpec(GlowHalo, sizeFrac: 0.92, tone: "accent"),
                ])
            // 小安·换壳行李签：斜切角 + 打孔穿绳 + 撕线 + 条码页脚 + 「安」章
            case Tag => TemplateSpec(
                animal: AnimalSpec.all[7],
                textureAsset: Some("images/tex_hermit.png"),
                header: HeaderNone, footer: FooterTagStub,
                safeL: 0.09, safeT: 0.085, safeR: 0.14, safeB: 0.07,
                lineHeight: 1.85, radius: 10.0, tagNotch: true,
                under: [
                    OrnamentSpec(CutDashed, ax: 0.94, ay: 0.5, sizeFrac: 0.36, tone: "ink"),
                ],
                over: [
                    OrnamentSpec(TagHole, ax: -0.8, ay: -0.85, sizeFrac: 0.17, over: true, tone: "ink"),
                    OrnamentSpec(SealStamp, ax: 0.78, ay: 0.88, sizeFrac: 0.1, over: true, tone: "seal"),
                ])
            // 阿横·方格稿纸：整版格线 + 页眉 + 「共 N 字」页脚 + 「横」章
            case Grid => TemplateSpec(
                animal: AnimalSpec.all[8],
                textureAsset: Some("images/tex_crab.png"),
                header: HeaderGridHeader, footer: FooterGridCount,
                safeL: 0.065, safeT: 0.15, safeR: 0.065, safeB: 0.08,
                lineHeight: 1.9, radius: 6.0,
                over: [
                    OrnamentSpec(SealStamp, ax: 0.8, ay: 0.9, sizeFrac: 0.1, over: true, tone: "seal"),
                ])
            // 老罗·航海图志：经纬网 + 罗盘角章 + 虚线航线 + 坐标页脚
            case Chart => TemplateSpec(
                animal: AnimalSpec.all[9],
                textureAsset: Some("images/tex_nautilus.png"),
                header: HeaderNone, footer: FooterChartCoord,
                safeL: 0.08, safeT: 0.06, safeR: 0.08, safeB: 0.06,
                lineHeight: 1.85, radius: 4.0,
                over: [
                    OrnamentSpec(CompassRose, ax: 0.76, ay: 0.8, sizeFrac: 0.24, over: true, tone: "seal"),
                    OrnamentSpec(ChartRoute, ax: -0.66, ay: -0.76, sizeFrac: 0.34, over: true, tone: "accent"),
                ])
            // 航邮·海运明信片：对分中缝 + 地址区 + 心情邮票 + 波浪邮戳 + 航空边条
            case Postcard => TemplateSpec(
                animal: AnimalSpec.all[10],
                textureAsset: Some("images/tex_albatross.png"),
                header: HeaderNone, footer: FooterPostmark,
                safeL: 0.07, safeT: 0.07, safeR: 0.44, safeB: 0.07,
                lineHeight: 1.9, radius: 8.0,
                over: [
                    OrnamentSpec(StampCorner, ax: 0.74, ay: -0.78, sizeFrac: 0.2, over: true, tone: "accent"),
                    OrnamentSpec(WavePostmark, ax: 0.36, ay: -0.72, sizeFrac: 0.17, over: true, tone: "accent"),
                ])
            // 提灯·声呐深潜屏：CRT 外框 + 扫描线 + 同心圈回波 + 深度页脚 + 磷光字
            case Sonar => TemplateSpec(
                animal: AnimalSpec.all[11],
                textureAsset: Some("images/tex_angler.png"),
                header: HeaderNone, footer: FooterDepth,
                safeL: 0.13, safeT: 0.14, safeR: 0.13, safeB: 0.13,
                lineHeight: 1.8, radius: 20.0, glowText: true,
                over: [
                    OrnamentSpec(SweepRing, ax: -0.6, ay: -0.68, sizeFrac: 0.36, over: true, tone: "accent"),
                ])
            // 伏特·电报纸带：上下齿孔 + 电报体字距 + 韵目代日页脚
            case Telegram => TemplateSpec(
                animal: AnimalSpec.all[12],
                textureAsset: Some("images/tex_ray.png"),
                header: HeaderNone, footer: FooterRhyme,
                safeL: 0.1, safeT: 0.115, safeR: 0.1, safeB: 0.115,
                lineHeight: 2.0, radius: 4.0, letterSpacing: 2.0)
            // 粉笔姐·港口潮汐黑板：木框 + 粉笔质感字 + 海况页眉 + 潮时页脚
            case Chalk => TemplateSpec(
                animal: AnimalSpec.all[13],
                textureAsset: Some("images/tex_gull.png"),
                header: HeaderNone, footer: FooterTide,
                safeL: 0.1, safeT: 0.09, safeR: 0.1, safeB: 0.07,
                lineHeight: 1.95, radius: 14.0, chalkText: true)
        }
    }
}
