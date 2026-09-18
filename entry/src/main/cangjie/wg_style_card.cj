package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import std.math.cos
import std.math.sin
import std.convert.*
import std.time.DateTime

// 拟物卡片渲染管线（对齐参考端 style_card.dart / editable_paper.dart）。
// 层序：PaperBase(纸纹+整版装饰) → Ornaments(under) → 正文块 → 贴纸 → Ornaments(over)。

func toneColor(a: AnimalSpec, tone: String): UInt32 {
    if (tone == "seal") {
        return a.seal
    }
    if (tone == "ink") {
        return a.ink
    }
    return a.accent
}

// ── 装饰层 ──────────────────────────────────────────────────────

@Component
class OrnamentLayer {
    var pAnimalId: String = "otter"
    var pOver: Bool = false
    var cardW: Float64 = 400.0
    var cardH: Float64 = 520.0
    var pMoodKey: String = ""

    private let settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    private var ctx: Option<CanvasRenderingContext2D> = Option<CanvasRenderingContext2D>.None

    func build() {
        Stack() {
            Canvas(getContext())
                .width(this.cardW)
                .height(this.cardH)
                .onReady({ => this.paint() })
        }
        .width(this.cardW)
        .height(this.cardH)
        .enabled(false)
    }

    func getContext(): CanvasRenderingContext2D {
        match (this.ctx) {
            case Some(c) => return c
            case None =>
                let c = CanvasRenderingContext2D(this.settings)
                this.ctx = Some(c)
                return c
        }
    }

    func paint(): Unit {
        let c = getContext()
        let a = AnimalSpec.byId(this.pAnimalId)
        let spec = TemplateSpec.specOf(a.style)
        let list = if (this.pOver) { spec.over } else { spec.under }
        let mood = Mood.tryParse(if (this.pMoodKey == "") { None<String> } else { Some(this.pMoodKey) })
        for (o in list) {
            drawOne(c, a, o, this.cardW, this.cardH, mood)
        }
    }
}

// 单个装饰分发绘制。
func drawOne(ctx: CanvasRenderingContext2D, a: AnimalSpec, o: OrnamentSpec,
    cardW: Float64, cardH: Float64, mood: ?Mood): Unit {
    let s = cardW * o.sizeFrac
    let cx = (cardW - s) * (o.ax + 1.0) / 2.0
    let cy = (cardH - s) * (o.ay + 1.0) / 2.0
    let tone = toneColor(a, o.tone)
    ctx.save()
    ctx.translate(cx, cy)
    match (o.kind) {
        case WashiTape =>
            // 上移出纸缘的半透明胶带。
            ctx.translate(0.0, -cardW * 0.09)
            fillRoundRect(ctx, 0.0, 0.0, s, cardW * 0.30 * (o.sizeFrac / 0.26), 3.0, withAlpha(tone, 0.30))
        case SealStamp =>
            drawSealStamp(ctx, s, tone, firstChar(a.name))
        case EmbossEmblem =>
            drawEmbossEmblem(ctx, s, tone, firstChar(a.name))
        case MoonSeal =>
            drawMoonSeal(ctx, s, tone)
        case AvatarCharm =>
            // 圆形白底小像：白底 + 描边 + 角色头像。
            let pad = s * 0.05
            drawCircleFill(ctx, s / 2.0, s / 2.0, s / 2.0, 0xFFFFFFFF)
            ctx.save()
            ctx.beginPath()
            ctx.arc(s / 2.0, s / 2.0, s / 2.0 - pad, 0.0, 2.0 * KPi)
            ctx.clip()
            ctx.restore()
            drawCircleStroke(ctx, s / 2.0, s / 2.0, s / 2.0 - 0.7, withAlpha(a.accent, 0.5), 1.4)
        case Footprints =>
            ctx.translate(0.0, (s - s * 0.22) / 2.0)
            drawFootprints(ctx, s, s * 0.22, withAlpha(tone, 0.55))
        case WaveRule =>
            ctx.translate(0.0, (s - s * 0.10) / 2.0)
            drawWaveRule(ctx, s, s * 0.10, withAlpha(tone, 0.8))
        case BubbleDots =>
            ctx.translate(0.0, (s - s * 0.9) / 2.0)
            drawBubbles(ctx, s, s * 0.9, withAlpha(tone, 0.6))
        case GlowHalo =>
            ctx.translate(0.0, (s - s * 1.2) / 2.0)
            drawGlowHalo(ctx, s, s * 1.2, tone)
        case TagHole =>
            drawTagHole(ctx, s, tone, a.bg)
        case CutDashed =>
            ctx.translate(s / 2.0 - 1.0, (s - s) / 2.0)
            drawCutDashed(ctx, 2.0, s, withAlpha(tone, 0.35))
        case CompassRose =>
            drawCompassRose(ctx, s, s, tone)
        case ChartRoute =>
            ctx.translate(0.0, (s - s * 0.5) / 2.0)
            drawChartRoute(ctx, s, s * 0.5, withAlpha(tone, 0.75))
        case StampCorner =>
            ctx.translate(0.0, (s - s * 1.18) / 2.0)
            let mi = match (mood) {
                case Some(m) => moodIndex(m)
                case None => 4
            }
            drawStampCorner(ctx, s, s * 1.18, tone, a.bg, mi)
        case WavePostmark =>
            ctx.translate(0.0, (s - s * 0.8) / 2.0)
            drawWavePostmark(ctx, s, s * 0.8, withAlpha(tone, 0.8))
        case SweepRing =>
            let bi = match (mood) {
                case Some(m) => 2 + moodIndex(m)
                case None => 5
            }
            drawSweepRing(ctx, s, s, withAlpha(tone, 0.5), bi)
        case DashedRules =>
            drawDashedRules(ctx, cardW, cardH, withAlpha(a.ink, 0.16))
        case DoubleFrame =>
            let isLp = match (a.style) {
                case Letterpress => true
                case _ => false
            }
            drawDoubleFrame(ctx, cardW, cardH, withAlpha(a.accent, if (isLp) { 0.7 } else { 1.0 }),
                withAlpha(a.accent, if (isLp) { 0.7 } else { 0.45 }),
                if (cardW * 0.004 > 1.0) { cardW * 0.004 } else { 1.0 })
        case SideBar =>
            fillRoundRect(ctx, 0.0, 0.0, s, cardH, 0.0, withAlpha(tone, 0.9))
        case CornerTape =>
            drawCornerTapes(ctx, cardW, cardH)
        case GridRules =>
            drawGridRules(ctx, cardW, cardH, withAlpha(a.accent, 0.28))
        case ChartGrid =>
            drawChartGrid(ctx, cardW, cardH, withAlpha(a.accent, 0.15))
    }
    ctx.restore()
}

func firstChar(s: String): String {
    for (r in s.runes()) {
        return r.toString()
    }
    return ""
}

func moodIndex(m: Mood): Int64 {
    match (m) {
        case Angry => 0
        case Sad => 1
        case Curious => 2
        case Happy => 3
        case Ecstatic => 4
    }
}

// ── 纸底（纸纹 + 整版装饰）──────────────────────────────────────

@Component
class PaperBase {
    var pAnimalId: String = "otter"
    var cardW: Float64 = 400.0
    var cardH: Float64 = 520.0

    private let settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    private var ctx: Option<CanvasRenderingContext2D> = Option<CanvasRenderingContext2D>.None

    func build() {
        Stack() {
            Stack() {
                Canvas(getContext())
                    .width(this.cardW)
                    .height(this.cardH)
                    .onReady({ => this.paintFallback() })
            }
            .width(this.cardW)
            .height(this.cardH)
            .enabled(false)
            this.texBranch(this.pAnimalId, this.cardW, this.cardH)
            Stack() {
                Canvas(getContext2())
                    .width(this.cardW)
                    .height(this.cardH)
                    .onReady({ => this.paintDeco() })
            }
            .width(this.cardW)
            .height(this.cardH)
            .enabled(false)
        }
        .width(this.cardW)
        .height(this.cardH)
        .enabled(false)
    }

    func getContext(): CanvasRenderingContext2D {
        match (this.ctx) {
            case Some(c) => return c
            case None =>
                let c = CanvasRenderingContext2D(this.settings)
                this.ctx = Some(c)
                return c
        }
    }

    func getContext2(): CanvasRenderingContext2D {
        match (this.ctx2) {
            case Some(c) => return c
            case None =>
                let c = CanvasRenderingContext2D(this.settings)
                this.ctx2 = Some(c)
                return c
        }
    }

    private var ctx2: Option<CanvasRenderingContext2D> = Option<CanvasRenderingContext2D>.None

    @Builder
    func texBranch(aid: String, tw: Float64, th: Float64) {
        if (aid == "otter") {
            Image(@rawfile("images/tex_otter.png")).width(tw).height(th)
        } else if (aid == "octo") {
            Image(@rawfile("images/tex_octo.png")).width(tw).height(th)
        } else if (aid == "penguin") {
            Image(@rawfile("images/tex_penguin.png")).width(tw).height(th)
        } else if (aid == "turtle") {
            Image(@rawfile("images/tex_turtle.png")).width(tw).height(th)
        } else if (aid == "bubble") {
            Image(@rawfile("images/tex_bubble.png")).width(tw).height(th)
        } else if (aid == "whale") {
            Image(@rawfile("images/tex_whale.png")).width(tw).height(th)
        } else if (aid == "jelly") {
            Image(@rawfile("images/tex_jelly.png")).width(tw).height(th)
        } else if (aid == "hermit") {
            Image(@rawfile("images/tex_hermit.png")).width(tw).height(th)
        } else if (aid == "crab") {
            Image(@rawfile("images/tex_crab.png")).width(tw).height(th)
        } else if (aid == "nautilus") {
            Image(@rawfile("images/tex_nautilus.png")).width(tw).height(th)
        } else if (aid == "albatross") {
            Image(@rawfile("images/tex_albatross.png")).width(tw).height(th)
        } else if (aid == "angler") {
            Image(@rawfile("images/tex_angler.png")).width(tw).height(th)
        } else if (aid == "ray") {
            Image(@rawfile("images/tex_ray.png")).width(tw).height(th)
        } else {
            Image(@rawfile("images/tex_gull.png")).width(tw).height(th)
        }
    }

    // 无纹理时的渐变兜底（暗底卡往深处压）。
    func paintFallback(): Unit {
        let c = getContext()
        let a = AnimalSpec.byId(this.pAnimalId)
        let dark = luminance(a.bg) < 0.5
        let lightC = if (dark) { mix(a.bg, 0xFF000000, 0.18) } else { mix(a.bg, 0xFFFFFFFF, 0.25) }
        let deep = if (dark) { mix(a.bg, 0xFF000000, 0.30) } else { mix(a.bg, a.accent, 0.06) }
        let grad = c.createLinearGradient(0.0, 0.0, this.cardW, this.cardH)
        grad.addColorStop(0.0, lightC)
        grad.addColorStop(0.55, a.bg)
        grad.addColorStop(1.0, deep)
        c.fillStyle = Some(grad)
        c.fillRect(0.0, 0.0, this.cardW, this.cardH)
    }

    // 按 CardStyle 画整版级装饰。
    func paintDeco(): Unit {
        let c = getContext2()
        let a = AnimalSpec.byId(this.pAnimalId)
        let w = this.cardW
        let h = this.cardH
        match (a.style) {
            case Washi => drawDashedRules(c, w, h, withAlpha(a.ink, 0.16))
            case Bookish => drawDoubleFrame(c, w, h, a.accent, withAlpha(a.accent, 0.45), if (w * 0.004 > 1.0) { w * 0.004 } else { 1.0 })
            case Letterpress => drawDoubleFrame(c, w, h, withAlpha(a.accent, 0.7), withAlpha(a.accent, 0.7), if (w * 0.003 > 1.0) { w * 0.003 } else { 1.0 })
            case Nordic => fillRoundRect(c, 0.0, 0.0, w * 0.016, h, 0.0, a.accent)
            case Grid => drawGridRules(c, w, h, withAlpha(a.accent, 0.28))
            case Chart => drawChartGrid(c, w, h, withAlpha(a.accent, 0.15))
            case Postcard => drawPostcardBase(c, w, h, withAlpha(a.ink, 0.30), withAlpha(a.accent, 0.75),
                mix(withAlpha(a.accent, 0.75), 0xFF14008C, 0.35))
            case Sonar =>
                drawCrtFrame(c, w, h, a.bg, a.ink)
                drawScanLines(c, w, h, withAlpha(0xFFFFFFFF, 0.05))
            case Telegram => drawTapeHoles(c, w, h, withAlpha(a.accent, 0.45), a.bg)
            case Chalk => drawChalkFrame(c, w, h, a.accent)
            case _ => ()
        }
    }
}

// ── 贴纸层 ──────────────────────────────────────────────────────

// 'id|x|y|rot' 解析；非法丢弃。
func decodeSticker(raw: String): ?(String, Float64, Float64, Float64) {
    let parts = raw.split("|", removeEmpty: false)
    if (parts.size != 4) {
        return None<(String, Float64, Float64, Float64)>
    }
    try {
        let x = Float64.parse(parts[1])
        let y = Float64.parse(parts[2])
        let rot = Float64.parse(parts[3])
        let cx = if (x < 0.0) { 0.0 } else if (x > 1.0) { 1.0 } else { x }
        let cy = if (y < 0.0) { 0.0 } else if (y > 1.0) { 1.0 } else { y }
        let t = (parts[0], cx, cy, rot)
        return Some(t)
    } catch (e: Exception) {
        return None<(String, Float64, Float64, Float64)>
    }
}

@Component
class StickerLayer {
    var rawSpecs: Array<String> = Array<String>()
    var cardW: Float64 = 400.0
    var cardH: Float64 = 520.0
    var tint: UInt32 = 0xFF3E6B5A

    func build() {
        Stack() {
            ForEach(this.rawSpecs, itemGeneratorFunc: {
                item: String, idx: Int64 =>
                StickerView(raw: item, cardW: this.cardW, cardH: this.cardH, tint: this.tint)
            }, keyGeneratorFunc: { item: String, idx: Int64 => "${idx}" })
        }
        .width(this.cardW)
        .height(this.cardH)
        .enabled(false)
    }
}

// 单枚贴纸（5 种程序化贴纸）。
@Component
class StickerView {
    var raw: String = ""
    var cardW: Float64 = 400.0
    var cardH: Float64 = 520.0
    var tint: UInt32 = 0xFF3E6B5A

    private let settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    private var ctx: Option<CanvasRenderingContext2D> = Option<CanvasRenderingContext2D>.None

    func info(): ?(String, Float64, Float64, Float64) {
        decodeSticker(this.raw)
    }

    func build() {
        Stack() {
            Canvas(this.getCtx())
                .width(this.stickerSize())
                .height(this.stickerSize())
                .onReady({ => this.paint() })
        }
        .width(this.stickerSize())
        .height(this.stickerSize())
        .translate(x: this.stickX(), y: this.stickY())
        .rotate(angle: Some(Float32(this.stickRot())))
        .enabled(false)
    }

    func stickerSize(): Float64 {
        this.cardW * 0.11
    }

    func stickX(): Float64 {
        match (this.info()) {
            case Some(v) => v[1] * this.cardW - this.stickerSize() / 2.0
            case None => 0.0
        }
    }

    func stickY(): Float64 {
        match (this.info()) {
            case Some(v) => v[2] * this.cardH - this.stickerSize() / 2.0
            case None => 0.0
        }
    }

    func stickRot(): Float64 {
        match (this.info()) {
            case Some(v) => v[3]
            case None => 0.0
        }
    }

    func getCtx(): CanvasRenderingContext2D {
        match (this.ctx) {
            case Some(c) => return c
            case None =>
                let c = CanvasRenderingContext2D(this.settings)
                this.ctx = Some(c)
                return c
        }
    }

    func paint(): Unit {
        let info = decodeSticker(this.raw)
        match (info) {
            case Some(v) =>
                let id = v[0]
                let s = this.stickerSize()
                let c = getCtx()
                if (id == "bubble") {
                    drawCircleFill(c, 0.55 * s, 0.5 * s, 0.32 * s, withAlpha(this.tint, 0.18))
                    drawCircleStroke(c, 0.55 * s, 0.5 * s, 0.32 * s, this.tint, s * 0.07)
                    drawCircleStroke(c, 0.28 * s, 0.74 * s, 0.10 * s, this.tint, s * 0.06)
                    c.beginPath()
                    c.arc(0.55 * s, 0.5 * s, 0.24 * s, -2.4, -1.4)
                    c.strokeStyle = strokeOf(this.tint)
                    c.lineWidth = Some(s * 0.05)
                    c.stroke()
                } else if (id == "shell") {
                    c.beginPath()
                    c.moveTo(0.14 * s, 0.78 * s)
                    c.quadraticCurveTo(0.10 * s, 0.34 * s, 0.5 * s, 0.16 * s)
                    c.quadraticCurveTo(0.90 * s, 0.34 * s, 0.86 * s, 0.78 * s)
                    c.closePath()
                    c.fillStyle = fillOf(withAlpha(this.tint, 0.22))
                    c.fill()
                    c.strokeStyle = strokeOf(this.tint)
                    c.lineWidth = Some(s * 0.06)
                    c.lineCap = Some("round")
                    c.stroke()
                    for (dx in [-0.22, -0.08, 0.08, 0.22]) {
                        drawLine(c, 0.5 * s, 0.16 * s, 0.5 * s + dx * s, 0.76 * s, this.tint, s * 0.045)
                    }
                    c.lineCap = Some("butt")
                } else if (id == "starfish") {
                    c.beginPath()
                    var i: Int64 = 0
                    while (i < 10) {
                        let ang = -KPi / 2.0 + Float64(i) * KPi / 5.0
                        let rr = if (i % 2 == 0) { 0.42 * s } else { 0.17 * s }
                        let px = 0.5 * s + cos(ang) * rr
                        let py = 0.5 * s + sin(ang) * rr
                        if (i == 0) {
                            c.moveTo(px, py)
                        } else {
                            c.lineTo(px, py)
                        }
                        i += 1
                    }
                    c.closePath()
                    c.fillStyle = fillOf(withAlpha(this.tint, 0.25))
                    c.fill()
                    c.strokeStyle = strokeOf(this.tint)
                    c.lineWidth = Some(s * 0.055)
                    c.stroke()
                } else if (id == "stamp") {
                    let hh = s * 0.82
                    fillRoundRect(c, 0.0, 0.0, s, hh, 2.0, withAlpha(this.tint, 0.30))
                    let rw = s / 8.0
                    var k: Int64 = 0
                    while (k < 8) {
                        drawCircleFill(c, rw * (Float64(k) + 0.5), rw * 0.35, rw * 0.3, 0x00000000)
                        k += 1
                    }
                    strokeRoundRect(c, rw * 0.6, rw * 0.6, s - 1.2 * rw, hh - 1.2 * rw, 1.0, this.tint, s * 0.045)
                } else if (id == "tape") {
                    c.save()
                    c.translate(s / 2.0, s / 2.0)
                    c.rotate(-0.35)
                    fillRoundRect(c, -s * 0.85, -s * 0.21, s * 1.7, s * 0.42, 2.5, withAlpha(this.tint, 0.38))
                    c.restore()
                }
            case None => ()
        }
    }
}

// ── 成品卡 ──────────────────────────────────────────────────────

func cardDateText(dateText: String): String {
    if (dateText != "") {
        return dateText
    }
    let d = DateTime.now()
    return T.dateFull(d.year, d.monthValue, d.dayOfMonth)
}

@Component
class StyleCard {
    var animalId: String = "otter"
    var text: String = ""
    var moodKey: String = ""
    var showMood: Bool = true
    var signature: String = ""
    var dateText: String = ""
    var fontScale: Float64 = 1.0
    var centered: Bool = false
    var rawStickers: Array<String> = Array<String>()
    var cardW: Float64 = 400.0

    func animal(): AnimalSpec {
        AnimalSpec.byId(this.animalId)
    }

    func spec(): TemplateSpec {
        TemplateSpec.specOf(this.animal().style)
    }

    func cardH(): Float64 {
        this.cardW * 1.28
    }

    func fs(): Float64 {
        fontSizeFor(this.text) * (this.cardW / 400.0) * this.fontScale * this.spec().fontScale
    }

    func k(): Float64 {
        this.cardW / 400.0
    }

    func bodyFontFamily(): String {
        let f = this.animal().fontFamily
        return if (f == "system") { "HarmonyOS Sans" } else { f }
    }

    func dateFull(): String {
        cardDateText(this.dateText)
    }

    func sigName(): String {
        if (this.signature != "") {
            return this.signature
        }
        return this.animal().name
    }

    func isHeaderCenter(): Bool {
        match (this.spec().header) {
            case HeaderCenterTitle => true
            case _ => false
        }
    }

    func isHeaderGrid(): Bool {
        match (this.spec().header) {
            case HeaderGridHeader => true
            case _ => false
        }
    }

    func moodLabel(): String {
        match (Mood.tryParse(if (this.moodKey == "") { None<String> } else { Some(this.moodKey) })) {
            case Some(m) => T.moodLine(m.label())
            case None => ""
        }
    }

    func build() {
        Stack() {
            PaperBase(pAnimalId: this.animalId, cardW: this.cardW, cardH: this.cardH())
            OrnamentLayer(pAnimalId: this.animalId, pOver: false, cardW: this.cardW,
                cardH: this.cardH(), pMoodKey: this.moodKey)
            Column(space: 0) {
                if (this.isHeaderCenter()) {
                    Text("· ${this.animal().species} ${this.animal().name} ·")
                        .fontSize(13.0 * this.k())
                        .fontColor(this.animal().accent)
                        .textAlign(TextAlign.Center)
                        .width(100.percent)
                    Blank().height(14.0 * this.k())
                }
                if (this.isHeaderGrid()) {
                    GridHeaderView(animalId: this.animalId, cardW: this.cardW,
                        signature: this.signature, dateStr: this.dateFull())
                    Blank().height(10.0 * this.k())
                }
                if (this.showMood && this.moodKey != "") {
                    Text(this.moodLabel())
                        .fontSize(this.fs() * 0.78)
                        .fontColor(this.animal().accent)
                    Blank().height(6.0 * this.k())
                }
                Text(this.text)
                    .fontSize(this.fs())
                    .fontColor(this.animal().ink)
                    .fontFamily(this.bodyFontFamily())
                    .textAlign(if (this.centered) { TextAlign.Center } else { TextAlign.Start })
                    .width(100.percent)
                Blank().height(20.0 * this.k())
                FooterView(animalId: this.animalId, cardW: this.cardW,
                    bodyText: this.text, signature: this.signature,
                    dateStr: this.dateFull(), accent: this.animal().accent,
                    ink: this.animal().ink, seal: this.animal().seal,
                    specFooter: footerKindIndex(this.spec().footer))
            }
            .alignItems(if (this.centered) { HorizontalAlign.Center } else { HorizontalAlign.Start })
            .padding(top: this.cardW * this.spec().safeT, right: this.cardW * this.spec().safeR,
                bottom: this.cardW * this.spec().safeB, left: this.cardW * this.spec().safeL)
            .width(this.cardW)
            .height(this.cardH())
            
            StickerLayer(rawSpecs: this.rawStickers, cardW: this.cardW, cardH: this.cardH(),
                tint: this.animal().accent)
            OrnamentLayer(pAnimalId: this.animalId, pOver: true, cardW: this.cardW,
                cardH: this.cardH(), pMoodKey: this.moodKey)
        }
        .width(this.cardW)
        .height(this.cardH())
        .borderRadius(this.spec().radius)
        .clip(true)
        .alignContent(Alignment.TopStart)
    }
}

func footerKindIndex(f: FooterKind): Int64 {
    match (f) {
        case FooterWashi => 0
        case FooterBookish => 1
        case FooterNordic => 2
        case FooterLetterpress => 3
        case FooterDoodle => 4
        case FooterPosterDate => 5
        case FooterGlowTrail => 6
        case FooterTagStub => 7
        case FooterGridCount => 8
        case FooterChartCoord => 9
        case FooterPostmark => 10
        case FooterDepth => 11
        case FooterRhyme => 12
        case FooterTide => 13
    }
}

// 稿纸页眉（姓名/日期栏）。
@Component
class GridHeaderView {
    var animalId: String = "otter"
    var cardW: Float64 = 400.0
    var signature: String = ""
    var dateStr: String = ""

    func k(): Float64 {
        this.cardW / 400.0
    }

    func build() {
        Row(space: 10.0 * this.k()) {
            Column(space: 2.0) {
                Text(T.gridHeaderName)
                    .fontSize(11.5 * this.k())
                    .fontColor(withAlpha(AnimalSpec.byId(this.animalId).ink, 0.65))
                Text(this.signature)
                    .fontSize(11.5 * this.k())
                    .fontColor(withAlpha(AnimalSpec.byId(this.animalId).ink, 0.85))
                    .padding(left: 4.0 * this.k())
                    .constraintSize(minWidth: 52.0 * this.k(), minHeight: 14.0 * this.k())
            }
            Column(space: 2.0) {
                Text(T.gridHeaderDate)
                    .fontSize(11.5 * this.k())
                    .fontColor(withAlpha(AnimalSpec.byId(this.animalId).ink, 0.65))
                Text(this.dateStr)
                    .fontSize(11.5 * this.k())
                    .fontColor(withAlpha(AnimalSpec.byId(this.animalId).ink, 0.85))
                    .padding(left: 4.0 * this.k())
            }
        }
        .width(100.percent)
        .justifyContent(FlexAlign.SpaceEvenly)
    }
}

// ── 14 种落款页脚 ───────────────────────────────────────────────

@Component
class FooterView {
    var animalId: String = "otter"
    var cardW: Float64 = 400.0
    var bodyText: String = ""
    var signature: String = ""
    var dateStr: String = ""
    var accent: UInt32 = 0xFFB4543E
    var ink: UInt32 = 0xFF4A3B2A
    var seal: UInt32 = 0xFFB4543E
    var specFooter: Int64 = 0

    func k(): Float64 {
        this.cardW / 400.0
    }

    func h(): Int64 {
        datumHash(this.dateStr)
    }

    func sigName(): String {
        if (this.signature != "") {
            return this.signature
        }
        return AnimalSpec.byId(this.animalId).name
    }

    // 日期 + 「 · 签名」尾缀。
    func dateSig(): String {
        if (this.signature != "") {
            return "${this.dateStr} · ${this.signature}"
        }
        return this.dateStr
    }

    func build() {
        Column {
            if (this.specFooter == 0) {
                // washi：日期居左 · 签名居右 · 尾部留白给印章
                Row() {
                    Text(this.dateStr).fontSize(12.0 * this.k()).fontColor(withAlpha(this.ink, 0.55))
                    Blank()
                    Text(this.signature).fontSize(12.0 * this.k()).fontColor(withAlpha(this.ink, 0.75))
                    Blank().width(64.0 * this.k())
                }.width(100.percent)
            } else if (this.specFooter == 1) {
                // bookish：右对齐 —— 签名
                Text("—— ${this.sigName()}")
                    .fontSize(13.5 * this.k()).fontColor(withAlpha(this.ink, 0.75))
                    .width(100.percent).textAlign(TextAlign.End)
            } else if (this.specFooter == 2) {
                // nordic：细分隔线 + 名字居左日期居右
                Column(space: 12.0 * this.k()) {
                    Column().height(1.0).width(100.percent).backgroundColor(withAlpha(this.accent, 0.5))
                    Row() {
                        Text(this.sigName()).fontSize(13.0 * this.k()).fontColor(this.seal)
                        Blank()
                        Text(this.dateStr).fontSize(11.5 * this.k()).fontColor(withAlpha(this.seal, 0.6))
                    }.width(100.percent)
                }
            } else if (this.specFooter == 3) {
                // letterpress：花饰行 + 居中日期 + 〔签名〕
                Column(space: 10.0 * this.k()) {
                    Row(space: 10.0 * this.k()) {
                        Column().height(1.0).layoutWeight(1).backgroundColor(withAlpha(this.accent, 0.5))
                        Text("❦").fontSize(13.0 * this.k()).fontColor(this.accent)
                        Column().height(1.0).layoutWeight(1).backgroundColor(withAlpha(this.accent, 0.5))
                    }.width(100.percent)
                    Text(this.dateStr).fontSize(12.0 * this.k()).fontColor(withAlpha(this.ink, 0.65))
                        .width(100.percent).textAlign(TextAlign.Center)
                    Text("〔 ${this.signature} 〕").fontSize(13.0 * this.k()).fontColor(this.seal)
                        .width(100.percent).textAlign(TextAlign.Center)
                }
            } else if (this.specFooter == 4) {
                // doodle：{name} 画于{date}
                Text(T.doodleFooter(this.sigName(), this.dateStr))
                    .fontSize(12.5 * this.k()).fontColor(withAlpha(this.ink, 0.7))
            } else if (this.specFooter == 5) {
                // posterDate：居中超小字
                Text(this.dateSig()).fontSize(10.5 * this.k()).fontColor(withAlpha(this.ink, 0.55))
                    .width(100.percent).textAlign(TextAlign.Center)
            } else if (this.specFooter == 6) {
                // glowTrail：光点行 + 居中小日期
                Column(space: 8.0 * this.k()) {
                    Row(space: 2.5 * this.k()) {
                        Circle().width(7.2).height(7.2).fill(withAlpha(this.accent, 0.95))
                        Circle().width(6.0).height(6.0).fill(withAlpha(this.accent, 0.85))
                        Circle().width(4.8).height(4.8).fill(withAlpha(this.accent, 0.75))
                        Circle().width(3.6).height(3.6).fill(withAlpha(this.accent, 0.65))
                        Circle().width(2.4).height(2.4).fill(withAlpha(this.accent, 0.55))
                        Circle().width(1.2).height(1.2).fill(withAlpha(this.accent, 0.45))
                    }
                    Text(this.dateStr).fontSize(10.0 * this.k()).fontColor(withAlpha(this.ink, 0.5))
                        .width(100.percent).textAlign(TextAlign.Center)
                }
            } else if (this.specFooter == 7) {
                // tagStub：条码 + 小字日期
                Column(space: 4.0 * this.k()) {
                    BarcodeCanvas(cardW: this.cardW, ink: withAlpha(this.ink, 0.7))
                    Text(this.dateStr).fontSize(10.0 * this.k()).fontColor(withAlpha(this.ink, 0.6))
                }
            } else if (this.specFooter == 8) {
                // gridCount：本页共 N 字
                Text(T.gridCountFooter(runeCount(this.bodyText), this.dateStr))
                    .fontSize(11.0 * this.k()).fontColor(withAlpha(this.ink, 0.6))
                    .width(100.percent).textAlign(TextAlign.Center)
            } else if (this.specFooter == 9) {
                // chartCoord：坐标
                Text(this.chartCoordText())
                    .fontSize(11.0 * this.k()).fontColor(withAlpha(this.ink, 0.65))
            } else if (this.specFooter == 10) {
                // postmark：SEA POST
                Text("${T.seaPost} · ${this.dateSig()}")
                    .fontSize(11.0 * this.k()).fontColor(withAlpha(this.ink, 0.65))
            } else if (this.specFooter == 11) {
                // depth：深度
                Text(this.depthText())
                    .fontSize(11.5 * this.k()).fontColor(withAlpha(this.ink, 0.75))
            } else if (this.specFooter == 12) {
                // rhyme：韵目代日 + 电码
                Column(space: 4.0 * this.k()) {
                    Text("${this.dateSig()} · ${rhymeChar()}日")
                        .fontSize(11.5 * this.k()).fontColor(withAlpha(this.ink, 0.75))
                    Text(this.telegramCode()).fontSize(9.0 * this.k()).fontColor(withAlpha(this.accent, 0.55))
                }
            } else {
                // tide：潮汐时刻
                Text(this.tideText())
                    .fontSize(11.0 * this.k()).fontColor(withAlpha(this.ink, 0.75))
            }
        }
        .width(100.percent)
    }

    func chartCoordText(): String {
        let hh = this.h()
        let lat = 5 + hh % 73
        let lon = 30 + (hh / 73) % 59
        let latM = hh % 60
        let lonM = (hh / 31) % 60
        return "N ${lat}°${pad2(latM)}′ · E ${lon}°${pad2(lonM)}′ · ${this.dateSig()}"
    }

    func depthText(): String {
        let depth = 200 + this.h() % 1800
        return "${T.depthLabel} -${depth} m · ${this.dateSig()}"
    }

    func tideText(): String {
        let hh = this.h()
        let hiH = 4 + hh % 8
        let hiM = hh % 60
        let loH = 15 + (hh / 7) % 6
        let loM = (hh / 13) % 60
        return "${T.tideHigh} ${pad2(hiH)}:${pad2(hiM)} · ${T.tideLow} ${pad2(loH)}:${pad2(loM)} · ${this.dateSig()}"
    }

    func rhymeChar(): String {
        let d = DateTime.now().dayOfMonth
        if (d >= 1 && d <= 31) {
            return rhymeByDay[d - 1]
        }
        return ""
    }

    func telegramCode(): String {
        var acc = ""
        var i: Int64 = 0
        while (i < 4) {
            let v = datumHash("${this.dateStr}#${i}") % 10000
            var s = "${v}"
            while (s.size < 4) {
                s = "0${s}"
            }
            if (acc == "") {
                acc = s
            } else {
                acc = "${acc} ${s}"
            }
            i += 1
        }
        return acc
    }
}

// 称重签条码（tagStub 用）。
@Component
class BarcodeCanvas {
    var cardW: Float64 = 400.0
    var ink: UInt32 = 0xFF4A3B2A

    private let settings: RenderingContextSettings = RenderingContextSettings(antialias: true)
    private var ctx: Option<CanvasRenderingContext2D> = Option<CanvasRenderingContext2D>.None

    func getCtx(): CanvasRenderingContext2D {
        match (this.ctx) {
            case Some(c) => return c
            case None =>
                let c = CanvasRenderingContext2D(this.settings)
                this.ctx = Some(c)
                return c
        }
    }

    func build() {
        Canvas(this.getCtx())
            .width(150.0 * (this.cardW / 400.0))
            .height(16.0 * (this.cardW / 400.0))
            
            .onReady({ => this.paint() })
    }

    func paint(): Unit {
        let c = this.getCtx()
        let w = 150.0 * (this.cardW / 400.0)
        let h = 16.0 * (this.cardW / 400.0)
        c.fillStyle = fillOf(this.ink)
        let widths: Array<Float64> = [2.0, 1.0, 3.0, 1.0, 2.0, 1.0, 1.0, 3.0, 2.0, 1.0]
        var x: Float64 = 0.0
        var i: Int64 = 0
        while (x < w) {
            let bw = widths[i % widths.size]
            c.fillRect(x, 0.0, bw, h)
            x += bw + (if (i % 2 == 0) { 2.0 } else { 3.0 })
            i += 1
        }
    }
}

// ── 纸面即编辑器 ────────────────────────────────────────────────

@Component
class EditablePaper {
    var animalId: String = "otter"
    var initialText: String = ""
    var moodKey: String = ""
    var showMood: Bool = true
    var signature: String = ""
    var dateText: String = ""
    var fontScale: Float64 = 1.0
    var centered: Bool = false
    var rawStickers: Array<String> = Array<String>()
    var cardW: Float64 = 400.0
    var onMoodTap: () -> Unit = { => }
    var onTextChange: (String) -> Unit = { _ => }

    @State var textValue: String = ""

    protected override func aboutToAppear() {
        this.textValue = this.initialText
    }

    func animal(): AnimalSpec {
        AnimalSpec.byId(this.animalId)
    }

    func spec(): TemplateSpec {
        TemplateSpec.specOf(this.animal().style)
    }

    func cardH(): Float64 {
        this.cardW * 1.28
    }

    // 编辑态字号：不乘 (w/400) 与 spec.fontScale。
    func fs(): Float64 {
        fontSizeFor(this.textValue) * this.fontScale
    }

    func isHeaderCenter(): Bool {
        match (this.spec().header) {
            case HeaderCenterTitle => true
            case _ => false
        }
    }

    func isHeaderGrid(): Bool {
        match (this.spec().header) {
            case HeaderGridHeader => true
            case _ => false
        }
    }

    func bodyFontFamily(): String {
        let f = this.animal().fontFamily
        return if (f == "system") { "HarmonyOS Sans" } else { f }
    }

    func dateFull(): String {
        cardDateText(this.dateText)
    }

    func build() {
        Stack() {
            PaperBase(pAnimalId: this.animalId, cardW: this.cardW, cardH: this.cardH())
            OrnamentLayer(pAnimalId: this.animalId, pOver: false, cardW: this.cardW, cardH: this.cardH())
            Column(space: 0) {
                if (this.isHeaderCenter()) {
                    Text("· ${this.animal().species} ${this.animal().name} ·")
                        .fontSize(13.0)
                        .fontColor(this.animal().accent)
                        .width(100.percent)
                        .textAlign(TextAlign.Center)
                    Blank().height(10.0)
                }
                if (this.isHeaderGrid()) {
                    GridHeaderView(animalId: this.animalId, cardW: this.cardW,
                        signature: this.signature, dateStr: this.dateFull())
                    Blank().height(10.0)
                }
                // 心情行（可点）
                Row() {
                    if (this.moodKey != "" && this.showMood) {
                        Text(T.moodLine(moodLabelOf(this.moodKey)))
                            .fontSize(this.fs() * 0.78)
                            .fontColor(this.animal().accent)
                    } else {
                        Text(T.markMoodInline)
                            .fontSize(14.0)
                            .fontColor(withAlpha(this.animal().accent, 0.65))
                    }
                }
                .width(100.percent)
                .padding(top: 2.0, bottom: 2.0)
                .onClick({ _ => this.onMoodTap() })
                Blank().height(6.0)
                TextArea(placeholder: Some(if (this.moodKey == "") { T.writeHint } else { T.keepWritingHint }), text: Some(this.textValue))
                    .placeholderColor(withAlpha(this.animal().ink, 0.28))
                    .fontColor(this.animal().ink)
                    .fontSize(this.fs())
                    .fontFamily(this.bodyFontFamily())
                    .textAlign(if (this.centered) { TextAlign.Center } else { TextAlign.Start })
                    .backgroundColor(Color.Transparent)
                    .border(width: 0)
                    .caretColor(this.animal().accent)
                    .width(100.percent)
                    .layoutWeight(1)
                    .constraintSize(minHeight: 60.0)
                    .onChange({ v: String =>
                        this.textValue = v
                        this.onTextChange(v)
                    })
                Blank().height(16.0 * (this.cardW / 400.0))
                FooterView(animalId: this.animalId, cardW: this.cardW,
                    bodyText: this.textValue, signature: this.signature,
                    dateStr: this.dateFull(), accent: this.animal().accent,
                    ink: this.animal().ink, seal: this.animal().seal,
                    specFooter: footerKindIndex(this.spec().footer))
            }
            .padding(top: this.cardH() * this.spec().safeT, right: this.cardW * this.spec().safeR,
                bottom: this.cardH() * this.spec().safeB, left: this.cardW * this.spec().safeL)
            .width(this.cardW)
            .height(this.cardH())
            StickerLayer(rawSpecs: this.rawStickers, cardW: this.cardW, cardH: this.cardH(),
                tint: this.animal().accent)
            OrnamentLayer(pAnimalId: this.animalId, pOver: true, cardW: this.cardW, cardH: this.cardH())
        }
        .width(this.cardW)
        .height(this.cardH())
        .borderRadius(this.spec().radius)
        .clip(true)
        .alignContent(Alignment.TopStart)
    }
}

// EditablePaper 的 header 判定（class 内无法跨类共享成员函数，这里以扩展式成员补齐）。

func moodLabelOf(key: String): String {
    match (Mood.tryParse(Some(key))) {
        case Some(m) => m.label()
        case None => ""
    }
}
