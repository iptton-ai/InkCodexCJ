package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import std.collection.ArrayList
import std.convert.*
import std.time.DateTime

// ── 邮局 / 月刊 / 图鉴 / 搜索 / 统计 / 隐私政策 ─────────────────

// 深海邮局：角色来信。
@Component
class MailboxPage {
    @State
    var rev: Int64 = 0

    func revOpacity(): Float64 {
        let _ = this.rev
        return 1.0
    }

    protected override func aboutToAppear() {
        let self = this
        AppState.instance.addListener({ =>
            self.rev += 1
        })
    }

    func build() {
        NavDestination() {
            Column() {
                this.topBar()
                List(space: 22) {
                    ForEach(this.mailIds(), itemGeneratorFunc: {
                        id: String, idx: Int64 =>
                        ListItem() {
                            MailCard(mailId: id)
                        }
                    }, keyGeneratorFunc: { id: String, idx: Int64 => id })
                }
                .padding(left: 20.0, right: 20.0, top: 8.0, bottom: 40.0)
                .width(100.percent)
                .layoutWeight(1)
                .scrollBar(BarState.Off)
                Text(T.moreMessengers)
                    .fontSize(11.5).fontColor(pal.seaDeep)
                    .padding(12.0)
            }
            .width(100.percent)
            .height(100.percent)
            .linearGradient(angle: 180.0, colors: [(0xFFBFDFD6, 0.0), (0xFF8FC0B2, 0.45), (0xFF5E9484, 1.0)])
        }
        .hideTitleBar(true)
    }

    @Builder
    func topBar() {
        Row(space: 10) {
            Text("‹").fontSize(22).fontColor(0xFFFFFFFF).onClick({ _ => stackPop() })
            Text(T.postTitle).fontSize(16).fontWeight(FontWeight.W700).fontColor(0xFFFFFFFF)
                .layoutWeight(1)
        }
        .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
        .backgroundColor(0xFF3E6B5A)
        .width(100.percent)
    }

    func mailIds(): Array<String> {
        var ids = ArrayList<String>()
        for (m in AppState.instance.mails) {
            ids.add(m.id)
        }
        return ids.toArray()
    }
}

// 单封来信明信片。
@Component
class MailCard {
    var mailId: String = ""

    func mail(): ?MailEntry {
        for (m in AppState.instance.mails) {
            if (m.id == this.mailId) {
                return Some(m)
            }
        }
        return None<MailEntry>
    }

    @Builder
    func imgBranch(aid: String, isz: Float64) {
        if (aid == "otter") {
            Image(@rawfile("images/otter.png")).width(isz).height(isz)
        }
        }         else if (aid == "octo") {
            Image(@rawfile("images/octo.png")).width(isz).height(isz)
        }
        }         else if (aid == "penguin") {
            Image(@rawfile("images/penguin.png")).width(isz).height(isz)
        }
        }         else if (aid == "turtle") {
            Image(@rawfile("images/turtle.png")).width(isz).height(isz)
        }
        }         else if (aid == "bubble") {
            Image(@rawfile("images/bubble.png")).width(isz).height(isz)
        }
        }         else if (aid == "whale") {
            Image(@rawfile("images/whale.png")).width(isz).height(isz)
        }
        }         else if (aid == "jelly") {
            Image(@rawfile("images/jelly.png")).width(isz).height(isz)
        }
        }         else if (aid == "hermit") {
            Image(@rawfile("images/hermit.png")).width(isz).height(isz)
        }
        }         else if (aid == "crab") {
            Image(@rawfile("images/crab.png")).width(isz).height(isz)
        }
        }         else if (aid == "nautilus") {
            Image(@rawfile("images/nautilus.png")).width(isz).height(isz)
        }
        }         else if (aid == "albatross") {
            Image(@rawfile("images/albatross.png")).width(isz).height(isz)
        }
        }         else if (aid == "angler") {
            Image(@rawfile("images/angler.png")).width(isz).height(isz)
        }
        }         else if (aid == "ray") {
            Image(@rawfile("images/ray.png")).width(isz).height(isz)
        }
        } else {
            Image(@rawfile("images/gull.png")).width(isz).height(isz)
        }
    }

    func mailOr(): MailEntry {
        match (this.mail()) {
            case Some(m) => return m
            case None => return MailEntry(id: "", animalId: "otter", title: "", body: "", dateText: "")
        }
    }

    func build() {
        if (this.mail().isSome()) {
            Column() {
                Row() {
                    Text("TO 亲爱的岛民")
                        .fontSize(12.5).fontColor(0xFF5D4037)
                        .layoutWeight(1)
                    this.imgBranch(this.mailOr().animalId, 34.0)
                        .objectFit(ImageFit.Cover)
                        .border(width: 1.0, color: withAlpha(AnimalSpec.byId(this.mailOr().animalId).accent, 0.6))
                }
                .width(100.percent)
                Blank().height(6)
                StyleCard(animalId: this.mailOr().animalId, text: this.mailOr().body,
                    moodKey: "", showMood: false,
                    signature: AnimalSpec.byId(this.mailOr().animalId).name,
                    dateText: this.mailOr().dateText,
                    fontScale: 1.0, centered: false,
                    rawStickers: Array<String>(), cardW: this.cardW())
                Blank().height(8)
                Text(this.mailOr().title).fontSize(11).fontColor(0xFF8D6E63)
            }
            .padding(12.0)
            .backgroundColor(0xFFFFFDF4)
            .borderRadius(8)
            .border(width: 1.0, color: withAlpha(AnimalSpec.byId(this.mailOr().animalId).accent, 0.4))
            .onClick({ _ =>
                if (!this.mailOr().read) {
                    AppState.instance.markMailRead(this.mailOr().id)
                }
            })
        }
    }

    func cardW(): Float64 {
        320.0
    }
}

// ── 潮汐月刊 ────────────────────────────────────────────────────

@Component
class MonthlyPage {
    protected override func aboutToAppear() {}

    func months(): Array<(Int64, Int64)> {
        let st = AppState.instance
        var seen: ArrayList<(Int64, Int64)> = ArrayList<(Int64, Int64)>()
        for (e in st.entries) {
            let d = epochMsToDateTime(e.createdAtMs)
            let ym = (d.year, d.monthValue)
            var found = false
            for (x in seen) {
                if (x[0] == ym[0] && x[1] == ym[1]) {
                    found = true
                }
            }
            if (!found) {
                seen.add(ym)
            }
        }
        // 年月倒序
        seen.sortBy(comparator: { a: (Int64, Int64), b: (Int64, Int64) =>
            if (a[0] != b[0]) {
                if (a[0] > b[0]) { Ordering.LT } else { Ordering.GT }
            } else if (a[1] > b[1]) {
                Ordering.LT
            }
            } else if (a[1] < b[1]) {
                Ordering.GT
            }
            } else {
                Ordering.EQ
            }
        })
        var out = ArrayList<(Int64, Int64)>()
        let now = DateTime.now()
        var hasCurrent = false
        for (x in seen) {
            out.add((x[0], x[1]))
            if (x[0] == now.year && x[1] == now.monthValue) {
                hasCurrent = true
            }
        }
        if (!hasCurrent) {
            var withCur = ArrayList<(Int64, Int64)>()
            withCur.add((now.year, now.monthValue))
            for (x in out) {
                withCur.add(x)
            }
            return withCur.toArray()
        }
        return out.toArray()
    }

    func build() {
        NavDestination() {
            Column() {
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(0xFFFFFFFF).onClick({ _ => stackPop() })
                    Text(T.monthlyTitle).fontSize(16).fontWeight(FontWeight.W700).fontColor(0xFFFFFFFF)
                        .layoutWeight(1)
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .backgroundColor(0xFF3E6B5A)
                .width(100.percent)
                if (this.months().isEmpty()) {
                    Column() {
                        Text(T.noMonths).fontSize(14).fontColor(pal.inkSoft)
                    }
                    .width(100.percent)
                    .layoutWeight(1)
                    .justifyContent(FlexAlign.Center)
                }
                } else {
                    List(space: 16) {
                        ForEach(this.months(), itemGeneratorFunc: {
                            ym: (Int64, Int64), idx: Int64 =>
                            ListItem() {
                                MonthTile(year: ym[0], month: ym[1])
                            }
                        }, keyGeneratorFunc: { ym: (Int64, Int64), idx: Int64 => "${ym[0]}-${ym[1]}" })
                    }
                    .padding(18.0)
                    .width(100.percent)
                    .layoutWeight(1)
                    .scrollBar(BarState.Off)
                }
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }
}

@Component
class MonthTile {
    var year: Int64 = 2026
    var month: Int64 = 1

    func count(): Int64 {
        AppState.instance.countInMonth(this.year, this.month)
    }

    func unlocked(): Bool {
        AppState.instance.monthUnlocked(this.year, this.month)
    }

    func hint(): String {
        let now = DateTime.now()
        let isCurrent = now.year == this.year && now.monthValue == this.month
        if (this.unlocked()) {
            return T.monthUnlockedHint(this.count())
        }
        if (isCurrent) {
            return T.monthCurrentHint(this.count())
        }
        return T.monthLockedHint(this.count())
    }

    func build() {
        Row() {
            Column()
                .width(10).height(64)
                .backgroundColor(withAlpha(pal.sea, if (this.unlocked()) { 0.8 } else { 0.3 }))
                .borderRadius(4.0)
            Blank().width(14)
            Column(space: 4) {
                Text(T.monthTile(this.year, this.month))
                    .fontSize(15).fontWeight(FontWeight.W700).fontColor(pal.ink)
                Text(this.hint()).fontSize(11.5).fontColor(pal.inkSoft)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text(if (this.unlocked()) { "📖" } else { "🔒" }).fontSize(18)
        }
        .padding(16.0)
        .width(100.percent)
        .backgroundColor(if (this.unlocked()) { pal.card } else { withAlpha(pal.line, 0.55) })
        .borderRadius(16)
        .onClick({ _ =>
            if (this.unlocked()) {
                navParam = "${this.year}-${this.month}"
                stackPush(RN_MONTHBOOK)
            }
        })
    }
}

// 某月整本内页。
@Component
class MonthBookPage {
    func year(): Int64 {
        let parts = navParam.split("-", removeEmpty: false)
        if (parts.size == 2) {
            return Int64.parse(parts[0])
        }
        return DateTime.now().year
    }

    func month(): Int64 {
        let parts = navParam.split("-", removeEmpty: false)
        if (parts.size == 2) {
            return Int64.parse(parts[1])
        }
        return DateTime.now().monthValue
    }

    func entries(): ArrayList<CardEntry> {
        let out = ArrayList<CardEntry>()
        for (e in AppState.instance.entries) {
            let d = epochMsToDateTime(e.createdAtMs)
            if (d.year == this.year() && d.monthValue == this.month()) {
                out.add(e)
            }
        }
        out.sortBy(comparator: { a: CardEntry, b: CardEntry =>
            if (a.createdAtMs < b.createdAtMs) { Ordering.LT } else if (a.createdAtMs > b.createdAtMs) { Ordering.GT } else { Ordering.EQ }
        })
        return out
    }

    func build() {
        NavDestination() {
            Column() {
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(0xFFFFFFFF).onClick({ _ => stackPop() })
                    Text(T.monthBookTitle(this.year(), this.month()))
                        .fontSize(16).fontWeight(FontWeight.W700).fontColor(0xFFFFFFFF)
                        .layoutWeight(1)
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .backgroundColor(0xFF3E6B5A)
                .width(100.percent)
                Scroll() {
                    Column() {
                        // 封面
                        Column() {
                            Text("TIDE MONTHLY")
                                .fontSize(11).fontColor(withAlpha(0xFFFFFFFF, 0.7))
                            Blank().height(6)
                            Text("${this.year()} 年 ${this.month()} 月 · ${this.entries().size} 篇")
                                .fontSize(20).fontWeight(FontWeight.W800).fontColor(0xFFFFFFFF)
                        }
                        .alignItems(HorizontalAlign.Start)
                        .width(100.percent)
                        .padding(20.0)
                        .backgroundColor(0xFF3E6B5A)
                        .borderRadius(14)
                        Blank().height(18)
                        ForEach(this.entryIds(), itemGeneratorFunc: {
                            id: String, idx: Int64 =>
                            this.bookEntry(id)
                        }, keyGeneratorFunc: { id: String, idx: Int64 => id })
                        Blank().height(16)
                        Text(T.brandMotto)
                            .fontSize(10.5).fontColor(0xFFA1887F)
                            .width(100.percent)
                            .textAlign(TextAlign.Center)
                    }
                    .padding(18.0)
                    .width(100.percent)
                    .backgroundColor(0xFFFBF6EC)
                }
                .layoutWeight(1)
                .scrollBar(BarState.Off)
                .align(Alignment.Top)
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(0xFFFBF6EC)
        }
        .hideTitleBar(true)
    }

    func entryIds(): Array<String> {
        var ids = ArrayList<String>()
        for (e in this.entries()) {
            ids.add(e.id)
        }
        return ids.toArray()
    }

    @Builder
    func bookEntry(id: String) {
        Column(space: 6) {
            Text(this.timeOf(id))
                .fontSize(11.5).fontColor(0xFF8D6E63)
            StyleCard(animalId: this.animalOf(id), text: this.textOf(id),
                moodKey: "", showMood: true,
                signature: this.sigOf(id), dateText: this.dateOf(id),
                fontScale: 1.0, centered: false,
                rawStickers: Array<String>(), cardW: 384.0)
        }
        .alignItems(HorizontalAlign.Start)
        .width(100.percent)
        .margin(bottom: 18.0)
    }

    func entryOf(id: String): ?CardEntry {
        for (e in AppState.instance.entries) {
            if (e.id == id) {
                return Some(e)
            }
        }
        return None<CardEntry>
    }

    func timeOf(id: String): String {
        match (this.entryOf(id)) {
            case Some(e) =>
                let d = epochMsToDateTime(e.createdAtMs)
                return "${d.monthValue}月${d.dayOfMonth}日 ${pad2(d.hour)}:${pad2(d.minute)}"
            case None => ""
        }
    }

    func animalOf(id: String): String {
        match (this.entryOf(id)) {
            case Some(e) => e.animalId
            case None => "otter"
        }
    }

    func textOf(id: String): String {
        match (this.entryOf(id)) {
            case Some(e) => e.text
            case None => ""
        }
    }

    func sigOf(id: String): String {
        match (this.entryOf(id)) {
            case Some(e) => e.signature
            case None => ""
        }
    }

    func dateOf(id: String): String {
        match (this.entryOf(id)) {
            case Some(e) => e.dateText
            case None => ""
        }
    }
}

// ── 居民图鉴 ────────────────────────────────────────────────────

@Component
class DexPage {
    func build() {
        NavDestination() {
            Column() {
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(0xFFFFFFFF).onClick({ _ => stackPop() })
                    Text(T.dexTitle).fontSize(16).fontWeight(FontWeight.W700).fontColor(0xFFFFFFFF)
                        .layoutWeight(1)
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .backgroundColor(0xFF35604F)
                .width(100.percent)
                Scroll() {
                    Column() {
                        Grid() {
                            ForEach(this.dexIds(), itemGeneratorFunc: {
                                id: String, idx: Int64 =>
                                GridItem() {
                                    DexCard(animalId: id)
                                }
                            }, keyGeneratorFunc: { id: String, idx: Int64 => id })
                        }
                        .columnsTemplate("1fr 1fr")
                        .columnsGap(14.0)
                        .rowsGap(14.0)
                        .height(720)
                    }
                    .padding(16.0)
                }
                .layoutWeight(1)
                .scrollBar(BarState.Off)
                .align(Alignment.Top)
                Column() {
                    Text(T.moreResidents).fontSize(12).fontColor(withAlpha(0xFFFFFFFF, 0.7))
                }
                .width(100.percent)
                .padding(12.0)
                .backgroundColor(0xFF35604F)
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }

    func dexIds(): Array<String> {
        var ids = ArrayList<String>()
        for (a in AnimalSpec.all) {
            ids.add(a.id)
        }
        return ids.toArray()
    }
}

@Component
class DexCard {
    var animalId: String = "otter"

    @Builder
    func imgBranch(aid: String, isz: Float64) {
        if (aid == "otter") {
            Image(@rawfile("images/otter.png")).width(isz).height(isz)
        }
        }         else if (aid == "octo") {
            Image(@rawfile("images/octo.png")).width(isz).height(isz)
        }
        }         else if (aid == "penguin") {
            Image(@rawfile("images/penguin.png")).width(isz).height(isz)
        }
        }         else if (aid == "turtle") {
            Image(@rawfile("images/turtle.png")).width(isz).height(isz)
        }
        }         else if (aid == "bubble") {
            Image(@rawfile("images/bubble.png")).width(isz).height(isz)
        }
        }         else if (aid == "whale") {
            Image(@rawfile("images/whale.png")).width(isz).height(isz)
        }
        }         else if (aid == "jelly") {
            Image(@rawfile("images/jelly.png")).width(isz).height(isz)
        }
        }         else if (aid == "hermit") {
            Image(@rawfile("images/hermit.png")).width(isz).height(isz)
        }
        }         else if (aid == "crab") {
            Image(@rawfile("images/crab.png")).width(isz).height(isz)
        }
        }         else if (aid == "nautilus") {
            Image(@rawfile("images/nautilus.png")).width(isz).height(isz)
        }
        }         else if (aid == "albatross") {
            Image(@rawfile("images/albatross.png")).width(isz).height(isz)
        }
        }         else if (aid == "angler") {
            Image(@rawfile("images/angler.png")).width(isz).height(isz)
        }
        }         else if (aid == "ray") {
            Image(@rawfile("images/ray.png")).width(isz).height(isz)
        }
        } else {
            Image(@rawfile("images/gull.png")).width(isz).height(isz)
        }
    }

    func animal(): AnimalSpec {
        AnimalSpec.byId(this.animalId)
    }

    func unlocked(): Bool {
        AppState.instance.isUnlocked(this.animal())
    }

    func hint(): String {
        match (this.animalId) {
            case "whale" => T.unlockFirstCard
            case "jelly" => T.unlockFeed7
            case "hermit" => T.dexHermitHint
            case "crab" => T.unlockChars400
            case "nautilus" => T.unlockBottles30
            case "albatross" => T.unlockFirstMail
            case "angler" => T.unlockNights3
            case "ray" => T.unlockDays15
            case "gull" => T.unlockMorning3
            case _ => T.dexBaseHint
        }
    }

    func progress(): String {
        let st = AppState.instance
        match (this.animalId) {
            case "jelly" => T.dexJellyProgress(st.bestHabitStreak())
            case "crab" => T.dexCrabProgress(st.totalWrittenChars())
            case "nautilus" => T.dexNautilusProgress(st.entries.size)
            case "angler" => T.dexAnglerProgress(st.nightCardsThisMonth())
            case "ray" => T.dexRayProgress(st.distinctDayCount())
            case "gull" => T.dexGullProgress(st.morningStreakDays())
            case _ => ""
        }
    }

    func build() {
        Column(space: 8) {
            if (this.unlocked()) {
                this.imgBranch(this.animalId, 74.0)
                    .borderRadius(37).objectFit(ImageFit.Cover)
            }
            } else {
                Text("❓")
                    .fontSize(30)
                    .width(74).height(74).borderRadius(37)
                    .backgroundColor(pal.sunken)
                    .textAlign(TextAlign.Center)
            }
            Text("${this.animal().species} · ${this.animal().name}")
                .fontSize(13.5).fontWeight(FontWeight.W700)
                .fontColor(if (this.unlocked()) { pal.ink } else { pal.inkSoft })
                .maxLines(1)
            Text(if (this.unlocked()) { this.animal().title } else { this.hint() })
                .fontSize(10.5)
                .fontColor(if (this.unlocked()) { pal.inkSoft } else { pal.inkFaint })
                .textAlign(TextAlign.Center)
                .maxLines(2)
            if (!this.unlocked() && this.progress() != "") {
                Text(this.progress()).fontSize(11).fontWeight(FontWeight.W700).fontColor(pal.seaInk)
            }
        }
        .width(100.percent)
        .padding(12.0)
        .backgroundColor(if (this.unlocked()) { pal.cardAlt } else { pal.sunken })
        .borderRadius(18)
        .border(width: 1.0,
            color: withAlpha(this.animal().accent, if (this.unlocked()) { 0.35 } else { 0.15 }))
    }
}

// ── 全文搜索 ────────────────────────────────────────────────────

@Component
class SearchPage {
    @State
    var q: String = ""

    func results(): Array<String> {
        let query = this.q
        var ids = ArrayList<String>()
        for (e in AppState.instance.sorted()) {
            if (query == "" || e.text.contains(query) || e.signature.contains(query)) {
                ids.add(e.id)
            }
        }
        return ids.toArray()
    }

    func build() {
        NavDestination() {
            Column() {
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(pal.ink).onClick({ _ => stackPop() })
                    TextInput(text: this.q, placeholder: T.searchHint)
                        .layoutWeight(1)
                        .height(38)
                        .backgroundColor(withAlpha(pal.headerCard, 0.8))
                        .borderRadius(12)
                        .onChange({ v: String => this.q = v })
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .backgroundColor(pal.header)
                .width(100.percent)
                if (this.q != "" && this.results().isEmpty()) {
                    Column() {
                        Text(T.searchEmpty).fontSize(13.5).fontColor(pal.inkSoft)
                    }
                    .width(100.percent)
                    .layoutWeight(1)
                    .justifyContent(FlexAlign.Center)
                }
                } else {
                    TimelineList(entryIds: this.results(), onTapEntry: { id: String =>
                        navParam = id
                        stackPush(RN_DETAIL)
                    })
                }
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }
}

// ── 投喂统计 ────────────────────────────────────────────────────

@Component
class StatsPage {
    @State
    var rev: Int64 = 0

    protected override func aboutToAppear() {
        let self = this
        AppState.instance.addListener({ =>
            self.rev += 1
        })
    }

    func build() {
        NavDestination() {
            Column() {
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(0xFFFFFFFF).onClick({ _ => stackPop() })
                    Text(T.statsTitle).fontSize(16).fontWeight(FontWeight.W700).fontColor(0xFFFFFFFF)
                        .layoutWeight(1)
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .backgroundColor(0xFF3E6B5A)
                .width(100.percent)
                Scroll() {
                    Column(space: 16) {
                        // 概览
                        Row() {
                            this.stat("${AppState.instance.entries.size}", T.totalBottles)
                            this.stat("${AppState.instance.computeStreak()}", T.writeStreakLabel)
                            this.stat("${AppState.instance.bestHabitStreak()}", T.bestHabitStreakLabel)
                        }
                        .width(100.percent)
                        .padding(top: 18.0, bottom: 18.0)
                        .backgroundColor(pal.cardAlt)
                        .borderRadius(18)
                        // 心情分布
                        Column(space: 10) {
                            Text(T.moodTideAll).fontSize(12.5).fontWeight(FontWeight.W700).fontColor(pal.inkMid)
                                .width(100.percent)
                            this.moodBars()
                        }
                        .alignItems(HorizontalAlign.Start)
                        .width(100.percent)
                        .padding(15.0)
                        .backgroundColor(pal.cardAlt)
                        .borderRadius(16)
                        // 习惯完成度
                        if (!AppState.instance.habits.isEmpty()) {
                            Column(space: 10) {
                                Text(T.habitProgressTitle).fontSize(12.5).fontWeight(FontWeight.W700).fontColor(pal.inkMid)
                                    .width(100.percent)
                                ForEach(this.habitNames(), itemGeneratorFunc: {
                                    hid: String, idx: Int64 =>
                                    this.habitRow(hid)
                                }, keyGeneratorFunc: { hid: String, idx: Int64 => hid })
                            }
                            .alignItems(HorizontalAlign.Start)
                            .width(100.percent)
                            .padding(15.0)
                            .backgroundColor(pal.cardAlt)
                            .borderRadius(16)
                        }
                        // 断签提醒
                        Column(space: 10) {
                            Row(space: 8) {
                                Text(if (AppState.instance.remindEnabled) { "🔔" } else { "🔕" }).fontSize(16)
                                Text(if (AppState.instance.remindEnabled) { T.remindOn(AppState.instance.remindHour) } else { T.remindOff })
                                    .fontSize(13).fontColor(pal.inkMid)
                                    .layoutWeight(1)
                                Toggle(ToggleType.Switch, isOn: AppState.instance.remindEnabled)
                                    .selectedColor(pal.sea)
                            }
                            .width(100.percent)
                            if (AppState.instance.remindEnabled) {
                                Row() {
                                    Text(T.remindHourLabel(AppState.instance.remindHour)).fontSize(12).fontColor(pal.inkSoft)
                                        .width(110)
                                    Slider(min: 6.0, max: 23.0, value: Float64(AppState.instance.remindHour), step: 1.0)
                                        .selectedColor(pal.sea)
                                        .layoutWeight(1)
                                }
                                .width(100.percent)
                            }
                        }
                        .alignItems(HorizontalAlign.Start)
                        .width(100.percent)
                        .padding(15.0)
                        .backgroundColor(pal.cardAlt)
                        .borderRadius(16)
                        Blank().height(20)
                    }
                    .padding(18.0)
                    .width(100.percent)
                }
                .layoutWeight(1)
                .scrollBar(BarState.Off)
                .align(Alignment.Top)
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }

    @Builder
    func stat(value: String, label: String) {
        Column(space: 3) {
            Text(value).fontSize(24).fontWeight(FontWeight.W800).fontColor(pal.ink)
            Text(label).fontSize(10.5).fontColor(pal.inkSoft)
        }
        .layoutWeight(1)
    }

    func habitNames(): Array<String> {
        var ids = ArrayList<String>()
        for (h in AppState.instance.habits) {
            ids.add(h.id)
        }
        return ids.toArray()
    }

    func habitOf(id: String): ?Habit {
        for (h in AppState.instance.habits) {
            if (h.id == id) {
                return Some(h)
            }
        }
        return None<Habit>
    }

    func habitGlyph(h: Habit): String {
        if (h.doneToday()) {
            return "🐟"
        }
        return "🐠"
    }

    func habitOfOr(hid: String): Habit {
        match (this.habitOf(hid)) {
            case Some(h) => return h
            case None => return Habit(id: hid, name: "")
        }
    }

    @Builder
    func habitRow(hid: String) {
        if (this.habitOf(hid).isSome()) {
            Row(space: 8) {
                Text(this.habitGlyph(this.habitOfOr(hid))).fontSize(15)
                Text(this.habitOfOr(hid).name).fontSize(13).fontColor(pal.inkMid).layoutWeight(1)
                Text(T.habitStatLine(this.habitOfOr(hid).streak(), this.habitOfOr(hid).targetDays,
                    this.habitOfOr(hid).doneDays.size))
                    .fontSize(10.5).fontColor(pal.inkSoft)
            }
            .width(100.percent)
        }
    }

    @Builder
    func moodBars() {
        Column(space: 5) {
            ForEach(this.moodKeys(), itemGeneratorFunc: {
                mk: String, idx: Int64 =>
                this.moodBar(mk)
            }, keyGeneratorFunc: { mk: String, idx: Int64 => mk })
        }
        .width(100.percent)
    }

    func moodKeys(): Array<String> {
        return ["angry", "sad", "curious", "happy", "ecstatic"]
    }

    func moodOf(mk: String): Mood {
        match (Mood.tryParse(Some(mk))) {
            case Some(v) => v
            case None => Happy
        }
    }

    func moodCount(mk: String): Int64 {
        var n: Int64 = 0
        for (e in AppState.instance.entries) {
            match (e.mood) {
                case Some(m) =>
                    if (m == mk) {
                        n += 1
                    }
                case None => ()
            }
        }
        return n
    }

    @Builder
    func moodBar(mk: String) {
        if (this.moodCount(mk) > 0 && AppState.instance.entries.size > 0) {
            Row() {
                Text(moodLabelOf(mk)).fontSize(11).fontColor(pal.inkSoft).width(46)
                Column() {
                    Column()
                        .height(9)
                        .borderRadius(5)
                        .backgroundColor(withAlpha(this.moodOf(mk).tint(), 0.8))
                        .width(this.barWidth(this.moodCount(mk), AppState.instance.entries.size))
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text("${this.moodCount(mk)}").fontSize(11).fontColor(pal.inkMid).width(26)
                    .textAlign(TextAlign.End)
            }
            .width(100.percent)
        }
    }

    func barWidth(cnt: Int64, total: Int64): Float64 {
        let frac = Float64(cnt) / Float64(total)
        return frac * 100.0
    }
}

// ── 隐私政策全文页 ──────────────────────────────────────────────

@Component
class PrivacyPolicyPage {
    @State
    var policyText: String = ""

    protected override func aboutToAppear() {
        this.policyText = this.loadPolicy()
    }

    func loadPolicy(): String {
        try {
            match (appContext) {
                case Some(c) =>
                    let bytes = c.resourceManager.getRawFileContent("privacy/privacy_zh.txt")
                    return String.fromUtf8(bytes)
                case None => return ""
            }
        } catch (e: Exception) {
            return ""
        }
    }

    func build() {
        NavDestination() {
            Column() {
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(pal.ink).onClick({ _ => stackPop() })
                    Text(T.privacyTitle).fontSize(16).fontWeight(FontWeight.W700).fontColor(pal.ink)
                        .layoutWeight(1)
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .width(100.percent)
                Scroll() {
                    Text(this.policyText)
                        .fontSize(13.5).fontColor(pal.ink).lineHeight(22.0)
                        .width(100.percent)
                        .padding(22.0)
                }
                .layoutWeight(1)
                .scrollBar(BarState.Off)
                .align(Alignment.Top)
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }
}
