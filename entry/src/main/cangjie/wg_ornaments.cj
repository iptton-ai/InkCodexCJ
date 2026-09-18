package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.math.sin
import std.math.cos

// 圆周率。
const KPi: Float64 = 3.141592653589793

// 程序化自绘装饰（对齐参考端 paper_ornaments.dart）。
// 全部 Canvas 绘制，规格逐参数对齐。

// Rune 数（近似字素数，中文场景一致）。
func runeCount(s: String): Int64 {
    var n: Int64 = 0
    for (r in s.runes()) {
        n += 1
    }
    return n
}

// 自适应字号分档：≤24→26；≤60→22；≤120→19；≤220→16.5；否则 14.5。
func fontSizeFor(text: String): Float64 {
    let n = runeCount(text)
    if (n <= 24) {
        return 26.0
    }
    if (n <= 60) {
        return 22.0
    }
    if (n <= 120) {
        return 19.0
    }
    if (n <= 220) {
        return 16.5
    }
    return 14.5
}

// datum 哈希（FNV-1a 变体，逐位复刻含 31 位截断）。
func datumHash(s: String): Int64 {
    var h: Int64 = 0x811c9dc5
    for (b in s.toArray()) {
        let c = Int64(b)
        h = h ^ c
        h = (h * 0x01000193) & 0x7fffffff
    }
    return h
}

// 31 日韵目。
let rhymeByDay: Array<String> = ["东", "冬", "江", "支", "微", "鱼", "虞", "齐", "佳",
    "灰", "真", "文", "元", "寒", "删", "铣", "篠", "巧", "皓", "哿", "马", "养",
    "梗", "迥", "有", "寝", "感", "俭", "艳", "陷", "世"]

// ── 整版级装饰 ──────────────────────────────────────────────────

// 打字纸行线（washi）。
func drawDashedRules(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(1.0)
    ctx.setLineDash(Some([5.0, 4.0]))
    let left = w * 0.075
    let right = w * 0.075
    let gap = w * 0.085
    var y = h * 0.09
    let yEnd = h * 0.93
    while (y < yEnd) {
        ctx.beginPath()
        ctx.moveTo(left, y)
        ctx.lineTo(w - right, y)
        ctx.stroke()
        y += gap
    }
    ctx.setLineDash(None<Array<Float64>>)
}

// 双细线框（bookish/letterpress）。
func drawDoubleFrame(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, outer: UInt32, inner: UInt32, bw: Float64): Unit {
    let m = w * 0.018
    strokeRoundRect(ctx, m, m, w - 2.0 * m, h - 2.0 * m, 2.0, outer, bw * 1.6)
    let m2 = m + w * 0.014
    strokeRoundRect(ctx, m2, m2, w - 2.0 * m2, h - 2.0 * m2, 2.0, inner, bw)
}

// 方格稿纸（grid）。
func drawGridRules(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    let cell = w / 20.0
    let m = cell * 0.6
    strokeRoundRect(ctx, m, m, w - 2.0 * m, h - 2.0 * m, 1.0, color, 1.4)
    ctx.strokeStyle = strokeOf(withAlpha(color, 0.55))
    ctx.lineWidth = Some(0.8)
    var x = m + cell
    while (x < w - m - 1.0) {
        ctx.beginPath()
        ctx.moveTo(x, m)
        ctx.lineTo(x, h - m)
        ctx.stroke()
        x += cell
    }
    var y = m + cell
    while (y < h - m - 1.0) {
        ctx.beginPath()
        ctx.moveTo(m, y)
        ctx.lineTo(w - m, y)
        ctx.stroke()
        y += cell
    }
}

// 经纬网（chart）。
func drawChartGrid(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(0.9)
    var x = w / 7.0
    while (x < w) {
        ctx.beginPath()
        ctx.moveTo(x, 0.0)
        ctx.lineTo(x, h)
        ctx.stroke()
        x += w / 7.0
    }
    var y = h / 9.0
    while (y < h) {
        ctx.beginPath()
        ctx.moveTo(0.0, y)
        ctx.lineTo(w, y)
        ctx.stroke()
        y += h / 9.0
    }
}

// 明信片整版（postcard）：航空斜纹 + 中缝 + 地址区横线。
func drawPostcardBase(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, ink: UInt32, red: UInt32, blue: UInt32): Unit {
    let band = h * 0.016
    let seg = 16.0
    let skew = 5.0
    var i: Float64 = 0.0
    var k: Int64 = 0
    while (i < w) {
        let c = if (k % 2 == 0) { red } else { blue }
        // 上条
        ctx.beginPath()
        ctx.moveTo(i, 0.0)
        ctx.lineTo(i + seg, 0.0)
        ctx.lineTo(i + seg - skew, band)
        ctx.lineTo(i - skew, band)
        ctx.closePath()
        ctx.fillStyle = fillOf(c)
        ctx.fill()
        // 下条
        ctx.beginPath()
        ctx.moveTo(i + skew, h - band)
        ctx.lineTo(i + seg + skew, h - band)
        ctx.lineTo(i + seg, h)
        ctx.lineTo(i, h)
        ctx.closePath()
        ctx.fillStyle = fillOf(c)
        ctx.fill()
        i += seg
        k += 1
    }
    drawLine(ctx, w * 0.58, h * 0.06, w * 0.58, h * 0.88, ink, 1.2)
    var j: Int64 = 0
    while (j < 4) {
        let y = h * (0.30 + Float64(j) * 0.085)
        drawLine(ctx, w * 0.63, y, w * 0.93, y, withAlpha(ink, 0.6), 1.0)
        j += 1
    }
}

// CRT 外框 + 旋钮（sonar）。
func drawCrtFrame(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32, frame: UInt32): Unit {
    let bezel = mix(color, 0xFF000000, 0.35)
    strokeRoundRect(ctx, w * 0.028, w * 0.028, w - 2.0 * w * 0.028, h - 2.0 * w * 0.028, w * 0.06, bezel, w * 0.045)
    var ky = h * 0.18
    while (ky <= h * 0.28) {
        drawCircleFill(ctx, w - w * 0.045, ky, w * 0.022, mix(color, 0xFF000000, 0.45))
        drawCircleStroke(ctx, w - w * 0.045, ky, w * 0.022, withAlpha(frame, 0.5), 1.2)
        drawLine(ctx, w - w * 0.045 - w * 0.012, ky, w - w * 0.045 + w * 0.012, ky, withAlpha(frame, 0.7), 1.4)
        ky += h * 0.10
    }
}

// 扫描线（sonar）。
func drawScanLines(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(1.0)
    var y = 0.0
    while (y < h) {
        ctx.beginPath()
        ctx.moveTo(0.0, y)
        ctx.lineTo(w, y)
        ctx.stroke()
        y += 4.0
    }
}

// 电报纸带齿孔（telegram）。
func drawTapeHoles(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, ring: UInt32, paper: UInt32): Unit {
    let step = 30.0
    let y1 = h * 0.035
    let y2 = h - h * 0.035
    let r = h * 0.014
    var x = 21.0
    while (x < w) {
        drawCircleFill(ctx, x, y1, r, paper)
        drawCircleStroke(ctx, x, y1, r, ring, 1.2)
        drawCircleFill(ctx, x, y2, r, paper)
        drawCircleStroke(ctx, x, y2, r, ring, 1.2)
        x += step
    }
}

// 黑板木框（chalk）。
func drawChalkFrame(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, accent: UInt32): Unit {
    let bw = w * 0.032
    let wood = withAlpha(0xFF8A6B41, 0.90)
    fillRoundRect(ctx, 0.0, 0.0, w, bw, 0.0, wood)
    fillRoundRect(ctx, 0.0, h - bw, w, bw, 0.0, wood)
    fillRoundRect(ctx, 0.0, 0.0, bw, h, 0.0, wood)
    fillRoundRect(ctx, w - bw, 0.0, bw, h, 0.0, wood)
    strokeRoundRect(ctx, bw + 3.0, bw + 3.0, w - 2.0 * (bw + 3.0), h - 2.0 * (bw + 3.0), 2.0, withAlpha(accent, 0.5), 1.2)
    fillRoundRect(ctx, 0.0, 0.0, w, bw * 0.4, 0.0, withAlpha(0xFF6B4F2E, 0.80))
}

// doodle 四角胶带。
func drawCornerTapes(ctx: CanvasRenderingContext2D, w: Float64, h: Float64): Unit {
    let tw = 74.0
    let th = 20.0
    let tapes: Array<(Float64, Float64, UInt32, Float64)> = [
        (-10.0, -10.0, 0xFFE57373, 0.35),
        (0.0, -10.0, 0xFF64B5F6, -0.25),
        (-10.0, 10.0, 0xFF81C784, -0.3),
        (0.0, 10.0, 0xFFE1BEE7, 0.28),
    ]
    for (t in tapes) {
        let (dx, dy, c, rot) = t
        let cx = if (dx < 0.0) { -dx + tw / 2.0 } else { w - dx - tw / 2.0 }
        let cy = if (dy < 0.0) { -dy + th / 2.0 } else { h - dy - th / 2.0 }
        ctx.save()
        ctx.translate(cx, cy)
        ctx.rotate(rot)
        fillRoundRect(ctx, -tw / 2.0, -th / 2.0, tw, th, 2.5, withAlpha(c, 0.55))
        ctx.restore()
    }
}

// ── 独立装饰（OrnamentKind 分发）──────────────────────────────

// 手绘波浪线（waveRule）。
func drawWaveRule(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(h * 0.28)
    ctx.lineCap = Some("round")
    let step = w / 14.0
    ctx.beginPath()
    ctx.moveTo(0.0, h * 0.5)
    var x = 0.0
    var i: Int64 = 0
    while (x < w) {
        let cy = if (i % 2 == 0) { 0.0 } else { h }
        ctx.quadraticCurveTo(x + step / 2.0, cy, x + step, h * 0.5)
        x += step
        i += 1
    }
    ctx.stroke()
    ctx.lineCap = Some("butt")
}

// 气泡点缀（bubbleDots）。
func drawBubbles(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    let specs: Array<(Float64, Float64, Float64)> = [
        (0.16, 0.18, 0.16), (0.52, 0.06, 0.10), (0.80, 0.38, 0.20),
        (0.30, 0.62, 0.09), (0.62, 0.84, 0.13),
    ]
    let minDim = if (w < h) { w } else { h }
    for (s in specs) {
        let (dx, dy, r) = s
        drawCircleFill(ctx, dx * w, dy * h, r * w, withAlpha(color, 0.25))
        drawCircleStroke(ctx, dx * w, dy * h, r * w, color, minDim * 0.045)
    }
}

// 企鹅脚印（footprints）。
func drawFootprints(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    let n: Int64 = 4
    let unit = w / Float64(n * 2 - 1)
    var i: Int64 = 0
    while (i < n) {
        let cx = unit * (Float64(i) * 2.0 + 0.5)
        let cy = h * (if (i % 2 == 0) { 0.32 } else { 0.68 })
        drawCircleFill(ctx, cx, cy, unit * 0.30, color)
        for (a in [-0.7, 0.0, 0.7]) {
            drawCircleFill(ctx, cx + sin(a) * unit * 0.34, cy - cos(a) * unit * 0.34, unit * 0.12, color)
        }
        i += 1
    }
}

// 朱红方印（sealStamp）。
func drawSealStamp(ctx: CanvasRenderingContext2D, s: Float64, color: UInt32, ch: String): Unit {
    ctx.save()
    ctx.translate(s / 2.0, s / 2.0)
    ctx.rotate(-0.06)
    fillRoundRect(ctx, -s / 2.0, -s / 2.0, s, s, s * 0.16, color)
    ctx.fillStyle = fillOf(0xFFFFFFFF)
    ctx.font = Some("600 ${s * 0.62}px LXGWenKai")
    ctx.textAlign = Some("center")
    ctx.textBaseline = Some("middle")
    ctx.fillText(ch, 0.0, s * 0.04)
    ctx.restore()
}

// 钢印双圈章（embossEmblem）。
func drawEmbossEmblem(ctx: CanvasRenderingContext2D, s: Float64, color: UInt32, ch: String): Unit {
    let c = withAlpha(color, 0.32)
    ctx.save()
    ctx.translate(s / 2.0, s / 2.0)
    ctx.rotate(0.12)
    drawCircleStroke(ctx, 0.0, 0.0, s / 2.0, c, s * 0.035)
    drawCircleStroke(ctx, 0.0, 0.0, s / 2.0 - s * 0.09, withAlpha(c, 0.7), 1.0)
    ctx.fillStyle = fillOf(c)
    ctx.font = Some("600 ${s * 0.42}px NotoSerifSC")
    ctx.textAlign = Some("center")
    ctx.textBaseline = Some("middle")
    ctx.fillText(ch, 0.0, s * 0.02)
    ctx.restore()
}

// 圆月印「风」（moonSeal）。
func drawMoonSeal(ctx: CanvasRenderingContext2D, s: Float64, color: UInt32): Unit {
    let c = withAlpha(color, 0.45)
    ctx.save()
    ctx.translate(s / 2.0, s / 2.0)
    ctx.rotate(0.1)
    drawCircleStroke(ctx, 0.0, 0.0, s / 2.0, c, if (s * 0.03 > 1.0) { s * 0.03 } else { 1.0 })
    drawCircleStroke(ctx, 0.0, 0.0, s / 2.0 - s * 0.08, withAlpha(c, 0.6), 1.0)
    ctx.fillStyle = fillOf(c)
    ctx.font = Some("500 ${s * 0.40}px LXGWenKai")
    ctx.textAlign = Some("center")
    ctx.textBaseline = Some("middle")
    ctx.fillText("风", 0.0, s * 0.02)
    ctx.restore()
}

// 打孔穿绳（tagHole）：孔 + 弧线绳。
func drawTagHole(ctx: CanvasRenderingContext2D, s: Float64, color: UInt32, paper: UInt32): Unit {
    let hole = s * 0.30
    let hx = s * 0.30 + hole / 2.0
    let hy = s * 0.26 + hole / 2.0
    drawCircleFill(ctx, hx, hy, hole / 2.0, paper)
    drawCircleStroke(ctx, hx, hy, hole / 2.0, withAlpha(color, 0.55), if (s * 0.035 > 1.2) { s * 0.035 } else { 1.2 })
    ctx.strokeStyle = strokeOf(withAlpha(color, 0.6))
    ctx.lineWidth = Some(if (s * 0.045 > 1.4) { s * 0.045 } else { 1.4 })
    ctx.lineCap = Some("round")
    ctx.beginPath()
    ctx.moveTo(hx, hy)
    ctx.quadraticCurveTo(s * 0.2, -s * 0.1, s * 0.85, -s * 0.28)
    ctx.stroke()
    ctx.lineCap = Some("butt")
}

// 沿虚线撕下（cutDashed）：竖向虚线。
func drawCutDashed(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(1.6)
    var y = 0.0
    while (y < h) {
        let yEnd = if (y + 6.0 > h) { h } else { y + 6.0 }
        ctx.beginPath()
        ctx.moveTo(w / 2.0, y)
        ctx.lineTo(w / 2.0, yEnd)
        ctx.stroke()
        y += 11.0
    }
}

// 八芒罗盘（compassRose）。
func drawCompassRose(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    let cx = w / 2.0
    let cy = h / 2.0
    let r = w / 2.0
    drawCircleFill(ctx, cx, cy, r * 0.92, withAlpha(color, 0.16))
    drawCircleStroke(ctx, cx, cy, r * 0.92, withAlpha(color, 0.85), if (r * 0.06 > 1.0) { r * 0.06 } else { 1.0 })
    drawCircleStroke(ctx, cx, cy, r * 0.55, withAlpha(color, 0.85), 1.0)
    var i: Int64 = 0
    while (i < 8) {
        let ang = Float64(i) * KPi / 4.0
        let r2 = if (i % 2 == 0) { r * 0.88 } else { r * 0.62 }
        let tipX = cx + cos(ang) * r2
        let tipY = cy + sin(ang) * r2
        let lx = cx + cos(ang + 0.35) * r * 0.16
        let ly = cy + sin(ang + 0.35) * r * 0.16
        let rx = cx + cos(ang - 0.35) * r * 0.16
        let ry = cy + sin(ang - 0.35) * r * 0.16
        ctx.beginPath()
        ctx.moveTo(tipX, tipY)
        ctx.lineTo(lx, ly)
        ctx.lineTo(cx, cy)
        ctx.lineTo(rx, ry)
        ctx.closePath()
        ctx.fillStyle = fillOf(withAlpha(color, 0.85))
        ctx.fill()
        ctx.strokeStyle = strokeOf(color)
        ctx.lineWidth = Some(1.0)
        ctx.stroke()
        i += 1
    }
}

// 虚线航线 + 锚点（chartRoute）。
func drawChartRoute(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(1.4)
    let n = 40
    var prevX = 0.0
    var prevY = h * 0.15
    var i: Int64 = 1
    while (i <= n) {
        let t = Float64(i) / Float64(n)
        let mt = 1.0 - t
        let x = mt * mt * 0.0 + 2.0 * mt * t * (w * 0.45) + t * t * (w * 0.95)
        let y = mt * mt * (h * 0.15) + 2.0 * mt * t * (h * 1.1) + t * t * (h * 0.45)
        if (i % 2 == 1) {
            drawLine(ctx, prevX, prevY, x, y, color, 1.4)
        }
        prevX = x
        prevY = y
        i += 1
    }
    drawCircleFill(ctx, w * 0.95, h * 0.45, w * 0.035, color)
}

// 波浪邮戳（wavePostmark）：双圈 + 三道波纹。
func drawWavePostmark(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    let cx = w / 2.0
    let cy = h / 2.0
    let r = if (w < h) { w / 2.0 } else { h / 2.0 }
    drawCircleStroke(ctx, cx, cy, r * 0.95, color, if (r * 0.08 > 1.2) { r * 0.08 } else { 1.2 })
    drawCircleStroke(ctx, cx, cy, r * 0.72, color, 1.0)
    ctx.lineCap = Some("round")
    for (dy in [-0.22, 0.0, 0.22]) {
        let y = cy + dy * r
        ctx.strokeStyle = strokeOf(color)
        ctx.lineWidth = Some(if (r * 0.06 > 1.0) { r * 0.06 } else { 1.0 })
        ctx.beginPath()
        ctx.moveTo(cx - 0.85 * r, y)
        ctx.quadraticCurveTo(cx - 0.45 * r, y - 0.28 * r, cx - 0.05 * r, y)
        ctx.quadraticCurveTo(cx + 0.35 * r, y + 0.28 * r, cx + 0.85 * r, y)
        ctx.stroke()
    }
    ctx.lineCap = Some("butt")
}

// 声呐同心圈 + 回波点（sweepRing）：圆心在画布左上角。
func drawSweepRing(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32, blips: Int64): Unit {
    let r = w
    drawCircleStroke(ctx, 0.0, 0.0, r * 0.28, color, 1.2)
    drawCircleStroke(ctx, 0.0, 0.0, r * 0.56, color, 1.2)
    drawCircleStroke(ctx, 0.0, 0.0, r * 0.84, color, 1.2)
    var i: Int64 = 0
    while (i < blips) {
        let ang = -0.5 + Float64(i) * (KPi / 2.6)
        let bx = cos(ang) * r * 0.82
        let by = sin(ang) * r * 0.82
        drawCircleFill(ctx, bx, by, r * 0.035, withAlpha(color, 0.9))
        i += 1
    }
}

// 径向光晕（glowHalo）。
func drawGlowHalo(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32): Unit {
    let grad = ctx.createRadialGradient(w / 2.0, h / 2.0, 0.0, w / 2.0, h / 2.0, w / 2.0)
    // CanvasGradient 用 UInt32 色阶添加：两端 color 与透明。
    ctx.fillStyle = fillOf(color)
    ctx.globalAlpha = Some(0.10)
    drawCircleFill(ctx, w / 2.0, h / 2.0, w / 2.0, color)
    ctx.globalAlpha = Some(1.0)
}

// 齿孔邮票（stampCorner）：票面图案随心情五换。
func drawStampCorner(ctx: CanvasRenderingContext2D, w: Float64, h: Float64, color: UInt32, paper: UInt32, moodIdx: Int64): Unit {
    fillRoundRect(ctx, 0.0, 0.0, w, h, w * 0.04, 0xFFFFFFFF)
    let step = 9.0
    var x = 4.5
    while (x < w) {
        drawCircleFill(ctx, x, 0.0, 2.6, paper)
        drawCircleFill(ctx, x, h, 2.6, paper)
        x += step
    }
    var y = 4.5
    while (y < h) {
        drawCircleFill(ctx, 0.0, y, 2.6, paper)
        drawCircleFill(ctx, w, y, 2.6, paper)
        y += step
    }
    strokeRoundRect(ctx, w * 0.1, h * 0.07, w * 0.8, h * 0.72, w * 0.02, withAlpha(color, 0.8), 1.2)
    // 票面图案
    let cx = w * 0.5
    let cy = h * 0.42
    let r = w * 0.28
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(if (r * 0.12 > 1.2) { r * 0.12 } else { 1.2 })
    ctx.lineCap = Some("round")
    if (moodIdx == 0) {
        // angry → wave（两道风暴浪）
        for (dy in [-0.25, 0.25]) {
            ctx.beginPath()
            ctx.moveTo(cx - 0.8 * r, cy + dy * r)
            ctx.quadraticCurveTo(cx - 0.4 * r, cy + (dy - 0.5) * r, cx, cy + dy * r)
            ctx.quadraticCurveTo(cx + 0.4 * r, cy + (dy + 0.5) * r, cx + 0.8 * r, cy + dy * r)
            ctx.stroke()
        }
    } else if (moodIdx == 1) {
        // sad → jelly（水母）
        ctx.beginPath()
        ctx.arc(cx, cy - 0.2 * r, 0.55 * r, KPi, 0.0)
        ctx.stroke()
        drawLine(ctx, cx - 0.3 * r, cy - 0.2 * r, cx - 0.35 * r, cy + 0.7 * r, color, 1.4)
        drawLine(ctx, cx, cy - 0.18 * r, cx, cy + 0.8 * r, color, 1.4)
        drawLine(ctx, cx + 0.3 * r, cy - 0.2 * r, cx + 0.35 * r, cy + 0.7 * r, color, 1.4)
    } else if (moodIdx == 2) {
        // curious → shell（贝壳）
        ctx.beginPath()
        ctx.arc(cx, cy, 0.8 * r, KPi, 0.0)
        ctx.stroke()
        for (k in [-0.3, 0.0, 0.3]) {
            drawLine(ctx, cx + k * 0.7 * r, cy + 0.05 * r, cx + k * 0.9 * r, cy + 0.75 * r, color, 1.4)
        }
    } else if (moodIdx == 3) {
        // happy → anchor（船锚）
        drawCircleStroke(ctx, cx, cy - 0.7 * r, 0.14 * r, color, 1.4)
        drawLine(ctx, cx, cy - 0.56 * r, cx, cy + 0.8 * r, color, 1.4)
        drawLine(ctx, cx - 0.4 * r, cy - 0.2 * r, cx + 0.4 * r, cy - 0.2 * r, color, 1.4)
        ctx.beginPath()
        ctx.arc(cx, cy + 0.3 * r, 0.45 * r, 0.0, KPi)
        ctx.stroke()
    } else {
        // ecstatic/null → lighthouse（灯塔）
        drawLine(ctx, cx - 0.25 * r, cy + r, cx - 0.25 * r, cy - 0.2 * r, color, 1.4)
        drawLine(ctx, cx + 0.25 * r, cy + r, cx + 0.25 * r, cy - 0.2 * r, color, 1.4)
        drawLine(ctx, cx - 0.4 * r, cy + r, cx + 0.4 * r, cy + r, color, 1.4)
        drawLine(ctx, cx - 0.35 * r, cy - 0.2 * r, cx + 0.35 * r, cy - 0.2 * r, color, 1.4)
        drawLine(ctx, cx - 0.5 * r, cy - 0.45 * r, cx + 0.5 * r, cy - 0.45 * r, color, 1.4)
        drawCircleStroke(ctx, cx, cy - 0.32 * r, 0.1 * r, color, 1.4)
    }
    // 面值
    ctx.fillStyle = fillOf(color)
    ctx.font = Some("700 ${w * 0.17}px sans-serif")
    ctx.textAlign = Some("center")
    ctx.textBaseline = Some("alphabetic")
    ctx.fillText("80", cx, h * 0.95)
    ctx.lineCap = Some("butt")
}
