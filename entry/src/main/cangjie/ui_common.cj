package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import std.collection.ArrayList
import std.collection.HashMap
import std.time.DateTime
import std.time.TimeZone

// ── 共享 UI 小件：时间线 / 空态 / 月历 ──────────────────────────

// 周日=0 的星期值。
func weekdaySun0(d: DateTime): Int64 {
    match (d.dayOfWeek) {
        case Sunday => 0
        case Monday => 1
        case Tuesday => 2
        case Wednesday => 3
        case Thursday => 4
        case Friday => 5
        case Saturday => 6
    }
}

// 时间线列表（首页 / 收集册 / 搜索共用）。
@Component
class TimelineList {
    var entryIds: Array<String> = Array<String>()
    var onTapEntry: (String) -> Unit = { _ => }

    func build() {
        List(space: 18) {
            ForEach(this.entryIds, itemGeneratorFunc: {
                id: String, idx: Int64 =>
                ListItem() {
                    TimelineEntryView(entryId: id, onTap: this.onTapEntry)
                }
            }, keyGeneratorFunc: { id: String, idx: Int64 => id })
        }
        .width(100.percent)
        .layoutWeight(1)
        .padding(left: 18.0, right: 18.0, top: 14.0, bottom: 132.0)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
    }
}

// 时间线单条：左圆点竖线 + 缩略卡。
@Component
class TimelineEntryView {
    var entryId: String = ""
    var onTap: (String) -> Unit = { _ => }

    func entry(): ?CardEntry {
        let st = AppState.instance
        for (e in st.entries) {
            if (e.id == this.entryId) {
                return Some(e)
            }
        }
        return None<CardEntry>
    }

    func timeLabel(): String {
        match (this.entry()) {
            case Some(e) =>
                let d = epochMsToDateTime(e.createdAtMs)
                return "${pad2(d.hour)}:${pad2(d.minute)}"
            case None => ""
        }
    }

    func moodText(): String {
        match (this.entry()) {
            case Some(e) =>
                match (Mood.tryParse(e.mood)) {
                    case Some(m) => " · ${m.label()}"
                    case None => ""
                }
            case None => ""
        }
    }

    func build() {
        Row(space: 12) {
            // 左侧时间线轨道
            Column() {
                Text(this.timeLabel())
                    .fontSize(10.5).fontColor(pal.inkSoft)
                    .margin(bottom: 6.0)
                Column().width(9).height(9).borderRadius(4.5)
                    .backgroundColor(withAlpha(AnimalSpec.byId(this.animalIdOf()).accent, 0.85))
                Column().width(1.6).layoutWeight(1).backgroundColor(pal.line)
            }
            .width(44)
            .alignItems(HorizontalAlign.Center)
            // 缩略成品卡（顶部裁切）
            Stack(alignContent: Alignment.TopStart) {
                StyleCard(animalId: this.animalIdOf(), text: this.textOf(),
                    moodKey: this.moodKeyOf(), showMood: true,
                    signature: this.signatureOf(), dateText: this.dateTextOf(),
                    fontScale: 1.0, centered: false,
                    rawStickers: Array<String>(), cardW: this.cardW())
            }
            .width(this.cardW())
            .height(128)
            .borderRadius(14)
            .clip(true)
            .border(width: 1.0, color: withAlpha(AnimalSpec.byId(this.animalIdOf()).accent, 0.25))
            .onClick({ _ => this.onTap(this.entryId) })
        }
        .width(100.percent)
        .alignItems(VerticalAlign.Top)
    }

    func cardW(): Float64 {
        250.0
    }

    func animalIdOf(): String {
        match (this.entry()) {
            case Some(e) => e.animalId
            case None => "otter"
        }
    }

    func textOf(): String {
        match (this.entry()) {
            case Some(e) => e.text
            case None => ""
        }
    }

    func moodKeyOf(): String {
        match (this.entry()) {
            case Some(e) =>
                match (e.mood) {
                    case Some(m) => m
                    case None => ""
                }
            case None => ""
        }
    }

    func signatureOf(): String {
        match (this.entry()) {
            case Some(e) => e.signature
            case None => ""
        }
    }

    func dateTextOf(): String {
        match (this.entry()) {
            case Some(e) => e.dateText
            case None => ""
        }
    }
}

// 空态海岸。
@Component
class EmptyShore {
    var title: String = T.emptyTitle
    var hint: String = T.emptyHint

    func build() {
        Column(space: 6) {
            Image(@rawfile("images/shore.png"))
                .width(230).height(150)
                .objectFit(ImageFit.Cover)
                .borderRadius(18)
            Text(this.title).fontSize(16).fontWeight(FontWeight.W600).fontColor(pal.inkMid)
            Text(this.hint).fontSize(12.5).fontColor(pal.inkSoft)
        }
        .width(100.percent)
        .padding(top: 60.0)
    }
}

// 潮汐月历。
@Component
class TideCalendar {
    var onEntryTap: (String) -> Unit = { _ => }
    @State
    var year: Int64 = DateTime.now().year
    @State
    var month: Int64 = DateTime.now().monthValue

    func build() {
        Column() {
            // 月导航
            Row() {
                Text("‹").fontSize(20).fontColor(pal.ink).padding(left: 6.0, right: 6.0)
                    .onClick({ _ => this.shift(-1) })
                Blank()
                Text(T.calendarTitle(this.year, this.month))
                    .fontSize(13.5).fontWeight(FontWeight.W700).fontColor(pal.ink)
                Blank()
                Text("›").fontSize(20).fontColor(pal.ink).padding(left: 6.0, right: 6.0)
                    .onClick({ _ => this.shift(1) })
            }
            .width(100.percent)
            Blank().height(6.0)
            // 星期表头
            Row() {
                ForEach(T.weekDays, itemGeneratorFunc: {
                    wd: String, idx: Int64 =>
                    Text(wd).fontSize(10).fontColor(pal.inkFaint).layoutWeight(1)
                        .textAlign(TextAlign.Center)
                }, keyGeneratorFunc: { wd: String, idx: Int64 => "${idx}" })
            }
            .width(100.percent)
            Blank().height(4.0)
            // 网格
            this.grid()
        }
        .padding(left: 14.0, right: 14.0, top: 10.0, bottom: 12.0)
        .backgroundColor(pal.headerPanel)
        .borderRadius(18)
        .width(100.percent)
    }

    func shift(delta: Int64): Unit {
        var m = this.month + delta
        var y = this.year
        if (m < 1) {
            m = 12
            y -= 1
        }
        if (m > 12) {
            m = 1
            y += 1
        }
        this.month = m
        this.year = y
    }

    @Builder
    func grid() {
        Column() {
            ForEach(this.rows(), itemGeneratorFunc: {
                row: Array<Int64>, rowIdx: Int64 =>
                Row() {
                    ForEach(row, itemGeneratorFunc: {
                        day: Int64, colIdx: Int64 =>
                        this.cell(day)
                    }, keyGeneratorFunc: { day: Int64, colIdx: Int64 => "${rowIdx}-${colIdx}-${day}" })
                }
                .width(100.percent)
            }, keyGeneratorFunc: { row: Array<Int64>, rowIdx: Int64 => "r${rowIdx}" })
        }
        .width(100.percent)
    }

    func rows(): Array<Array<Int64>> {
        let first = DateTime.of(year: this.year, month: this.month, dayOfMonth: 1, hour: 12, minute: 0, second: 0, nanosecond: 0, timeZone: TimeZone.Local)
        let leading = weekdaySun0(first)
        var daysInMonth: Int64 = 31
        if (this.month == 2) {
            daysInMonth = 28
        } else if (this.month == 4 || this.month == 6 || this.month == 9 || this.month == 11) {
            daysInMonth = 30
        }
        let cells = ArrayList<Int64>()
        var i: Int64 = 0
        while (i < leading) {
            cells.add(0)
            i += 1
        }
        var d: Int64 = 1
        while (d <= daysInMonth) {
            cells.add(d)
            d += 1
        }
        while (cells.size % 7 != 0) {
            cells.add(0)
        }
        var out = ArrayList<Array<Int64>>()
        var r: Int64 = 0
        while (r < cells.size / 7) {
            var row = ArrayList<Int64>()
            var c: Int64 = 0
            while (c < 7) {
                row.add(cells[r * 7 + c])
                c += 1
            }
            out.add(row.toArray())
            r += 1
        }
        return out.toArray()
    }

    func cellKey(y: Int64, m: Int64, day: Int64): String {
        "${y}-${pad2(m)}-${pad2(day)}"
    }

    @Builder
    func cell(day: Int64) {
        Column() {
            if (day > 0) {
                this.cellBody(day)
            } else {
                Column().height(40)
            }
        }
        .layoutWeight(1)
    }

    @Builder
    func imgBranch(aid: String, isz: Float64) {
        if (aid == "otter") {
            Image(@rawfile("images/otter.png")).width(isz).height(isz)
        } else if (aid == "octo") {
            Image(@rawfile("images/octo.png")).width(isz).height(isz)
        } else if (aid == "penguin") {
            Image(@rawfile("images/penguin.png")).width(isz).height(isz)
        } else if (aid == "turtle") {
            Image(@rawfile("images/turtle.png")).width(isz).height(isz)
        } else if (aid == "bubble") {
            Image(@rawfile("images/bubble.png")).width(isz).height(isz)
        } else if (aid == "whale") {
            Image(@rawfile("images/whale.png")).width(isz).height(isz)
        } else if (aid == "jelly") {
            Image(@rawfile("images/jelly.png")).width(isz).height(isz)
        } else if (aid == "hermit") {
            Image(@rawfile("images/hermit.png")).width(isz).height(isz)
        } else if (aid == "crab") {
            Image(@rawfile("images/crab.png")).width(isz).height(isz)
        } else if (aid == "nautilus") {
            Image(@rawfile("images/nautilus.png")).width(isz).height(isz)
        } else if (aid == "albatross") {
            Image(@rawfile("images/albatross.png")).width(isz).height(isz)
        } else if (aid == "angler") {
            Image(@rawfile("images/angler.png")).width(isz).height(isz)
        } else if (aid == "ray") {
            Image(@rawfile("images/ray.png")).width(isz).height(isz)
        } else {
            Image(@rawfile("images/gull.png")).width(isz).height(isz)
        }
    }

    @Builder
    func cellBody(day: Int64) {
        Column() {
            if (this.hasEntry(day)) {
                this.imgBranch(this.animalOf2(day), 28.0)
            } else if (this.habitDone(this.keyOf(day))) {
                Text("🌱").fontSize(15)
            } else {
                Text("${day}").fontSize(11).fontColor(pal.inkSoft)
            }
        }
        .width(30).height(30)
        .borderRadius(15)
        .backgroundColor(withAlpha(AnimalSpec.byId(this.animalOf2(day)).accent, 0.12))
        .onClick({ _ => this.tapCell(day) })
    }

    func keyOf(day: Int64): String {
        this.cellKey(this.year, this.month, day)
    }

    func hasEntry(day: Int64): Bool {
        this.entryFor(this.keyOf(day)).isSome()
    }

    func animalOf2(day: Int64): String {
        match (this.entryFor(this.keyOf(day))) {
            case Some(e) => e.animalId
            case None => "otter"
        }
    }

    func tapCell(day: Int64): Unit {
        match (this.entryFor(this.keyOf(day))) {
            case Some(e) => this.onEntryTap(e.id)
            case None => ()
        }
    }

    func entryFor(key: String): ?CardEntry {
        let map = AppState.instance.latestByDay()
        match (map.get(key)) {
            case Some(e) => Some(e)
            case None => None<CardEntry>
        }
    }

    func animalOf(key: String): String {
        match (this.entryFor(key)) {
            case Some(e) => e.animalId
            case None => "otter"
        }
    }

    func habitDone(key: String): Bool {
        for (h in AppState.instance.habits) {
            if (h.doneDays.contains(key)) {
                return true
            }
        }
        return false
    }
}
