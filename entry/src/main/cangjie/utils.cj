package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.time.DateTime
import kit.LocalizationKit.*
import kit.ArkUI.NavPathStack
import kit.ArkUI.NavPathInfo

// dayKey：本地时区的 yyyy-MM-dd。
func dayKey(d: DateTime): String {
    let m = d.monthValue
    let day = d.dayOfMonth
    let ms = if (m < 10) { "0${m}" } else { "${m}" }
    let ds = if (day < 10) { "0${day}" } else { "${day}" }
    return "${d.year}-${ms}-${ds}"
}

// 两位数补零。
func pad2(n: Int64): String {
    if (n < 10) {
        return "0${n}"
    }
    return "${n}"
}


// 全局导航栈（EntryView aboutToAppear 注入）。
var globalStack: Option<NavPathStack> = Option<NavPathStack>.None

// 页面跳转。
func stackPush(name: String): Unit {
    match (globalStack) {
        case Some(st) => st.pushPath(NavPathInfo(name: name, param: navParam))
        case None => ()
    }
}

func stackPop(): Unit {
    match (globalStack) {
        case Some(st) => st.pop()
        case None => ()
    }
}

// @State rev 的消费钩子：build 内读取以建立刷新依赖。
func revHook(rev: Int64): Float64 {
    let _ = rev
    return 1.0
}

// 动态 rawfile 资源（@rawfile 宏不支持插值，这里手工构造 AppResource）。
// RAWFILE 资源类型值为 20002（ArkTS ResourceType.RAWFILE）。
func rawfileRes(path: String): AppResource {
    AppResource("", "entry", 0, params: Some(Array<Any>(1, { _ => path })), resType: Some(20002))
}

// 动物头像（14 选 1）：emoji 徽章（@rawfile 需字面量且深层上下文不可注入，用 emoji 兜底）。
@Component
class AnimalImg {
    @Prop var id: String
    @Prop var imgSize: Float64

    func emoji(): String {
        match (id) {
            case "otter" => "🦦"
            case "octo" => "🐙"
            case "penguin" => "🐧"
            case "turtle" => "🐢"
            case "bubble" => "🐡"
            case "whale" => "🐋"
            case "jelly" => "🪼"
            case "hermit" => "🐚"
            case "crab" => "🦀"
            case "nautilus" => "🐚"
            case "albatross" => "🪶"
            case "angler" => "🎣"
            case "ray" => "⚡"
            case _ => "🕊️"
        }
    }

    func build() {
        Text(this.emoji())
            .fontSize(this.imgSize * 0.66)
            .width(this.imgSize)
            .height(this.imgSize)
            .textAlign(TextAlign.Center)
    }
}

// 纸纹底板（14 选 1）。
@Component
class TexImg {
    var id: String = "otter"
    var w: Float64 = 400.0
    var h: Float64 = 520.0

    func build() {
        if (id == "otter") {
            Image(@rawfile("images/tex_otter.png")).width(w).height(h)
        } else if (id == "octo") {
            Image(@rawfile("images/tex_octo.png")).width(w).height(h)
        } else if (id == "penguin") {
            Image(@rawfile("images/tex_penguin.png")).width(w).height(h)
        } else if (id == "turtle") {
            Image(@rawfile("images/tex_turtle.png")).width(w).height(h)
        } else if (id == "bubble") {
            Image(@rawfile("images/tex_bubble.png")).width(w).height(h)
        } else if (id == "whale") {
            Image(@rawfile("images/tex_whale.png")).width(w).height(h)
        } else if (id == "jelly") {
            Image(@rawfile("images/tex_jelly.png")).width(w).height(h)
        } else if (id == "hermit") {
            Image(@rawfile("images/tex_hermit.png")).width(w).height(h)
        } else if (id == "crab") {
            Image(@rawfile("images/tex_crab.png")).width(w).height(h)
        } else if (id == "nautilus") {
            Image(@rawfile("images/tex_nautilus.png")).width(w).height(h)
        } else if (id == "albatross") {
            Image(@rawfile("images/tex_albatross.png")).width(w).height(h)
        } else if (id == "angler") {
            Image(@rawfile("images/tex_angler.png")).width(w).height(h)
        } else if (id == "ray") {
            Image(@rawfile("images/tex_ray.png")).width(w).height(h)
        } else {
            Image(@rawfile("images/tex_gull.png")).width(w).height(h)
        }
    }
}
