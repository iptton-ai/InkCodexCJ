package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.math.pow

// ── 颜色工具（ARGB UInt32）───────────────────────────────────────

// 取 alpha 通道（0-255）。
func alphaOf(c: UInt32): UInt32 {
    return (c >> 24) & 0xFF
}

// 同 RGB 改 alpha（a: 0..1），等价 Flutter withValues(alpha:)。
func withAlpha(c: UInt32, a: Float64): UInt32 {
    let base = c & 0x00FFFFFF
    let al = Float64((c >> 24) & 0xFF) * a
    let ai = UInt32(al)
    return (ai << 24) | base
}

// 两色线性插值（等价 Color.lerp）。
func mix(a: UInt32, b: UInt32, t: Float64): UInt32 {
    let at = Float64((a >> 24) & 0xFF)
    let ar = Float64((a >> 16) & 0xFF)
    let ag = Float64((a >> 8) & 0xFF)
    let ab = Float64(a & 0xFF)
    let bt = Float64((b >> 24) & 0xFF)
    let br = Float64((b >> 16) & 0xFF)
    let bg = Float64((b >> 8) & 0xFF)
    let bb = Float64(b & 0xFF)
    let f = { x: Float64, y: Float64 => x + (y - x) * t }
    let nt = UInt32(f(at, bt))
    let nr = UInt32(f(ar, br))
    let ng = UInt32(f(ag, bg))
    let nb = UInt32(f(ab, bb))
    return (nt << 24) | (nr << 16) | (ng << 8) | nb
}

// WCAG 相对亮度（等价 computeLuminance）。
func luminance(c: UInt32): Float64 {
    let f = { v: UInt32 => Float64(v) / 255.0 }
    let lr = f((c >> 16) & 0xFF)
    let lg = f((c >> 8) & 0xFF)
    let lb = f(c & 0xFF)
    let g = { ch: Float64 =>
        if (ch <= 0.03928) { ch / 12.92 } else { pow((ch + 0.055) / 1.055, 2.4) }
    }
    return 0.2126 * g(lr) + 0.7152 * g(lg) + 0.0722 * g(lb)
}

// Canvas fillStyle / strokeStyle 赋值辅助。
func fillOf(c: UInt32): Option<FillStyle> {
    return Some(c)
}

func strokeOf(c: UInt32): Option<StrokeStyle> {
    return Some(c)
}

// ── Canvas 绘制小件 ─────────────────────────────────────────────

// 实心圆。
func drawCircleFill(ctx: CanvasRenderingContext2D, cx: Float64, cy: Float64, r: Float64, color: UInt32): Unit {
    ctx.beginPath()
    ctx.arc(cx, cy, r, 0.0, 6.283185307179586)
    ctx.fillStyle = fillOf(color)
    ctx.fill()
}

// 描边圆。
func drawCircleStroke(ctx: CanvasRenderingContext2D, cx: Float64, cy: Float64, r: Float64, color: UInt32, w: Float64): Unit {
    ctx.beginPath()
    ctx.arc(cx, cy, r, 0.0, 6.283185307179586)
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(w)
    ctx.stroke()
}

// 直线段。
func drawLine(ctx: CanvasRenderingContext2D, x1: Float64, y1: Float64, x2: Float64, y2: Float64, color: UInt32, w: Float64): Unit {
    ctx.beginPath()
    ctx.moveTo(x1, y1)
    ctx.lineTo(x2, y2)
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(w)
    ctx.stroke()
}

// 圆角矩形路径。
func pathRoundRect(ctx: CanvasRenderingContext2D, x: Float64, y: Float64, w: Float64, h: Float64, r: Float64): Unit {
    let rr = if (r > w / 2.0) { w / 2.0 } else if (r > h / 2.0) { h / 2.0 } else { r }
    ctx.beginPath()
    ctx.moveTo(x + rr, y)
    ctx.lineTo(x + w - rr, y)
    ctx.quadraticCurveTo(x + w, y, x + w, y + rr)
    ctx.lineTo(x + w, y + h - rr)
    ctx.quadraticCurveTo(x + w, y + h, x + w - rr, y + h)
    ctx.lineTo(x + rr, y + h)
    ctx.quadraticCurveTo(x, y + h, x, y + h - rr)
    ctx.lineTo(x, y + rr)
    ctx.quadraticCurveTo(x, y, x + rr, y)
    ctx.closePath()
}

// 实心圆角矩形。
func fillRoundRect(ctx: CanvasRenderingContext2D, x: Float64, y: Float64, w: Float64, h: Float64, r: Float64, color: UInt32): Unit {
    pathRoundRect(ctx, x, y, w, h, r)
    ctx.fillStyle = fillOf(color)
    ctx.fill()
}

// 描边圆角矩形。
func strokeRoundRect(ctx: CanvasRenderingContext2D, x: Float64, y: Float64, w: Float64, h: Float64, r: Float64, color: UInt32, lw: Float64): Unit {
    pathRoundRect(ctx, x, y, w, h, r)
    ctx.strokeStyle = strokeOf(color)
    ctx.lineWidth = Some(lw)
    ctx.stroke()
}
