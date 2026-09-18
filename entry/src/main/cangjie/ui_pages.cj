package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import std.collection.ArrayList
import std.collection.HashMap
import std.time.DateTime

// ── 收集册 / 详情 / 画廊 / 邮局 / 月刊 / 图鉴 / 搜索 / 统计 / 隐私 ──

// 页面脚手架：品牌绿顶栏 + NavDestination。
@Component
class DockSheetPage {
    func build() {
        NavDestination() {
            Column() {
                // 遮罩区（点击关闭）
                Column()
                    .width(100.percent)
                    .layoutWeight(1)
                    .onClick({ _ => stackPop() })
                // 底部浮卡
                Column() {
                    Row() {
                        Text("🗼").fontSize(20)
                        Blank().width(8)
                        Text(T.dockTitle).fontSize(15.5).fontWeight(FontWeight.W800).fontColor(pal.ink)
                            .layoutWeight(1)
                        Text(T.brandMotto).fontSize(9.5).fontColor(pal.inkSoft)
                            .maxLines(1)
                    }
                    .width(100.percent)
                    Blank().height(14)
                    Row(space: 10) {
                        this.ticket(T.ticketBox, this.boxCaption(), 0xFFFFD35C, 0xFF6B4A16, RN_COLLECTION)
                        this.ticket(T.ticketMonthly, this.monthlyCaption(), 0xFF3E6B5A, 0xFFDFF0E9, RN_MONTHLY)
                        this.ticket(T.ticketDex, T.dexUnlocked(AppState.instance.unlockedAnimalCount(), 14),
                            0xFF35604F, 0xFFDFF0E9, RN_DEX)
                    }
                    .width(100.percent)
                    Blank().height(10)
                    Row() {
                        Text("📊 投喂统计").fontSize(13).fontColor(pal.inkMid)
                            .onClick({ _ => stackPush(RN_STATS) })
                        Blank()
                        Text("🔍 搜索").fontSize(13).fontColor(pal.inkMid)
                            .onClick({ _ => stackPush(RN_SEARCH) })
                        Blank()
                        Text("📄 隐私政策").fontSize(13).fontColor(pal.inkMid)
                            .onClick({ _ => stackPush(RN_POLICY) })
                    }
                    .width(100.percent)
                    Blank().height(6)
                }
                .padding(18.0)
                .backgroundColor(pal.card)
                .borderRadius(26)
                .margin(12.0)
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(0x66000000)
        }
        .hideTitleBar(true)
    }

    func boxCaption(): String {
        T.bottlesOnShelf(AppState.instance.entries.size)
    }

    func monthlyCaption(): String {
        let now = DateTime.now()
        let n = AppState.instance.countInMonth(now.year, now.monthValue)
        if (n >= 8) {
            return T.monthlyReady
        }
        return T.monthlyProgress(n)
    }

    @Builder
    func ticket(label: String, caption: String, bg: UInt32, fg: UInt32, route: String) {
        Column(space: 4) {
            Blank().layoutWeight(1)
            Text(label).fontSize(12.5).fontWeight(FontWeight.W800).fontColor(fg)
            Text(caption).fontSize(10).fontColor(withAlpha(fg, 0.75)).maxLines(1)
        }
        .padding(10.0)
        .layoutWeight(1)
        .height(96)
        .backgroundColor(bg)
        .borderRadius(18)
        .alignItems(HorizontalAlign.Start)
        .onClick({ _ =>
            navParam = ""
            if (route == RN_COLLECTION) {
                // 收集册默认进木架 tab
                navParam = "shelf"
            }
            stackPush(route)
            stackPopIgnoreCurrent()
        })
    }
}

// 先推新页再关当前 sheet。
func stackPopIgnoreCurrent(): Unit {
    // push 已入栈；这里 pop 的是 dock 自身（在 push 之后执行则弹出 dock）。
    // 为避免误弹，直接保留 dock 在栈底，用户返回时自然关闭。
}

// ── 收集册：双 tab（时间线 / 按角色箱）──────────────────────────

@Component
class CollectionPage {
    @State
    var rev: Int64 = 0

    @State
    var entryIdList: Array<String> = Array<String>()

    @State
    var tabIndex: Int64 = 0

    func revOpacity(): Float64 {
        let _ = this.rev
        return 1.0
    }

    protected override func aboutToAppear() {
        if (navParam == "shelf") {
            this.tabIndex = 1
        }
        let self = this
        AppState.instance.addListener({ =>
            self.rev += 1
            self.entryIdList = self.computeSortedIds()
        })
        self.entryIdList = self.computeSortedIds()
    }

    func build() {
        NavDestination() {
            Column() {
                // 顶栏
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(pal.ink).onClick({ _ => stackPop() })
                    Text(T.shoreLabel).fontSize(17).fontWeight(FontWeight.W700).fontColor(pal.ink)
                        .layoutWeight(1)
                    Text("🔍").fontSize(17).onClick({ _ =>
                        navParam = ""
                        stackPush(RN_SEARCH)
                    })
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .backgroundColor(pal.header)
                .width(100.percent)
                // tabs
                Row() {
                    this.tabButton(T.tabTimeline, 0)
                    this.tabButton(T.tabShelfBox, 1)
                }
                .width(100.percent)
                .backgroundColor(pal.header)
                if (this.tabIndex == 0) {
                    if (AppState.instance.sorted().isEmpty()) {
                        EmptyShore(title: T.shelfEmptyTitle, hint: T.shelfEmptyHint)
                    }
                } else {
                    Scroll() {
                        Column() {
                            ForEach(this.allAnimalIds(), itemGeneratorFunc: {
                                id: String, idx: Int64 =>
                                ShelfCompartment(animalId: id)
                            }, keyGeneratorFunc: { id: String, idx: Int64 => id })
                        }
                        .padding(18.0)
                        .width(100.percent)
                    }
                    .layoutWeight(1)
                    .scrollBar(BarState.Off)
                }
            }
            .width(100.percent).opacity(this.revOpacity())
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }

    @Builder
    func tabButton(label: String, idx: Int64) {
        Text(label)
            .fontSize(13.5)
            .fontWeight(if (this.tabIndex == idx) { FontWeight.W700 } else { FontWeight.W400 })
            .fontColor(if (this.tabIndex == idx) { pal.ink } else { pal.inkMid })
            .padding(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0)
            .onClick({ _ => this.tabIndex = idx })
    }

    func computeSortedIds(): Array<String> {
        var ids = ArrayList<String>()
        for (e in AppState.instance.sorted()) {
            ids.add(e.id)
        }
        return ids.toArray()
    }

    func allAnimalIds(): Array<String> {
        var ids = ArrayList<String>()
        for (a in AnimalSpec.all) {
            ids.add(a.id)
        }
        return ids.toArray()
    }
}

// 木架格：一个角色的瓶子架。
@Component
class ShelfCompartment {
    var animalId: String = "otter"

    func animal(): AnimalSpec {
        AnimalSpec.byId(this.animalId)
    }

    func cards(): ArrayList<CardEntry> {
        let out = ArrayList<CardEntry>()
        for (e in AppState.instance.sorted()) {
            if (e.animalId == this.animalId) {
                out.add(e)
            }
        }
        return out
    }

    func count(): Int64 {
        this.cards().size
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

    func build() {
        Column(space: 6) {
            Row(space: 9) {
                this.imgBranch(this.animalId, 34.0)
                Text("${this.animal().species} · ${this.animal().name}")
                    .fontSize(14).fontWeight(FontWeight.W700).fontColor(this.animal().ink)
                    .layoutWeight(1)
                    .maxLines(1)
                Text(if (this.count() == 0) { T.emptyBottle } else { T.bottleCount(this.count()) })
                    .fontSize(10.5).fontColor(this.animal().accent)
                    .padding(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0)
                    .backgroundColor(withAlpha(this.animal().accent, 0.14))
                    .borderRadius(999)
            }
            .width(100.percent)
            // 木架
            Column() {
                Row() {
                    Blank().width(14)
                    ForEach(this.bottleLevels(this.count()), itemGeneratorFunc: {
                        lv: Float64, idx: Int64 =>
                        this.bottle(lv)
                    }, keyGeneratorFunc: { lv: Float64, idx: Int64 => "b${idx}" })
                    Blank()
                    Text(if (this.count() == 0) { T.writeFirstCard } else { T.openThisShore })
                        .fontSize(10.5).fontColor(withAlpha(0xFFFFFFFF, 0.85))
                        .padding(right: 14.0, bottom: 10.0)
                }
                .width(100.percent)
                .alignItems(VerticalAlign.Bottom)
            }
            .width(100.percent)
            .height(86)
            .linearGradient(angle: 90.0, colors: [(pal.woodTop, 0.0), (pal.woodBottom, 1.0)])
            .borderRadius(bottomLeft: 8.0, bottomRight: 8.0)
            .onClick({ _ =>
                if (this.count() > 0) {
                    navParam = this.animalId
                    stackPush(RN_GALLERY)
                }
            })
        }
        .margin(bottom: 20.0)
    }

    func bottleLevels(count: Int64): Array<Float64> {
        let n = if (count < 1) { 1 } else if (count > 6) { 6 } else { count }
        let lv = Float64(count) / 10.0
        var out = ArrayList<Float64>()
        var i: Int64 = 0
        while (i < n) {
            out.add(if (count == 0) { 0.0 } else { lv })
            i += 1
        }
        return out.toArray()
    }

    @Builder
    func bottle(level: Float64) {
        Column() {
            // 卷纸
            Column()
                .width(10).height(9)
                .backgroundColor(0xFFF7EFD8)
                .borderRadius(2.0)
                .margin(bottom: 2.0)
            // 墨水位
            Column()
                .width(18).height(20)
                .backgroundColor(withAlpha(this.animal().accent, 0.75))
                .borderRadius(3.0)
        }
        .width(26)
        .padding(right: 6.0, bottom: 8.0)
    }
}

// ── 详情页 ──────────────────────────────────────────────────────

@Component
class EntryDetailPage {
    @State
    var rev: Int64 = 0

    @State
    var revealed: Bool = false

    func revOpacity(): Float64 {
        let _ = this.rev
        return 1.0
    }

    func entry(): ?CardEntry {
        for (e in AppState.instance.entries) {
            if (e.id == navParam) {
                return Some(e)
            }
        }
        return None<CardEntry>
    }

    func entryOr(): CardEntry {
        match (this.entry()) {
            case Some(e) => return e
            case None => return CardEntry(id: "", animalId: "otter", text: "", dateText: "")
        }
    }

    func build() {
        NavDestination() {
            Column() {
                if (this.entry().isSome()) {
                    EntryBodyView(entryId: navParam)
                } else {
                    Column(space: 10) {
                        Text("🌊").fontSize(36)
                        Text(T.entryGone).fontSize(14).fontColor(pal.inkMid)
                        Button(T.backToShore)
                            .backgroundColor(pal.sea)
                            .fontColor(0xFFFFFFFF)
                            .onClick({ _ => stackPop() })
                    }
                    .width(100.percent)
                    .height(100.percent)
                    .justifyContent(FlexAlign.Center)
                }
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }
}

// 详情页正文（独立组件以便传齐全参）。
@Component
class EntryBodyView {
    var entryId: String = ""

    func entry(): ?CardEntry {
        for (e in AppState.instance.entries) {
            if (e.id == this.entryId) {
                return Some(e)
            }
        }
        return None<CardEntry>
    }

    func entryOr(): CardEntry {
        match (this.entry()) {
            case Some(e) => return e
            case None => return CardEntry(id: "", animalId: "otter", text: "", dateText: "")
        }
    }

    func cardW(): Float64 {
        330.0
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

    func build() {
        Column() {
            this.topBarOf()
            Scroll() {
                Column() {
                    StyleCard(animalId: this.entryOr().animalId, text: this.entryOr().text,
                        moodKey: this.moodKeyOf(), showMood: true,
                        signature: this.entryOr().signature, dateText: this.entryOr().dateText,
                        fontScale: 1.0, centered: this.entryOr().align == "center",
                        rawStickers: this.entryOr().imagePaths.toArray(),
                        cardW: this.cardW())
                }
                .width(100.percent)
                .alignItems(HorizontalAlign.Center)
                .padding(top: 10.0)
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .align(Alignment.Top)
            this.bottomBarOf()
        }
        .width(100.percent)
        .height(100.percent)
    }

    @Builder
    func topBarOf() {
        Row(space: 10) {
            Text("‹").fontSize(22).fontColor(this.entryAnimal().ink).onClick({ _ => stackPop() })
            Text(this.entryOr().dateText)
                .fontSize(16).fontWeight(FontWeight.W700).fontColor(this.entryAnimal().ink)
                .layoutWeight(1)
            Text("置顶").fontSize(12.5).fontColor(this.entryAnimal().ink)
                .padding(6.0)
                .onClick({ _ =>
                    this.entryOr().pinned = !this.entryOr().pinned
                    AppState.instance.persistEntry(this.entryOr())
                })
            Text("🗑").fontSize(15)
                .padding(6.0)
                .onClick({ _ => AppState.instance.deleteEntry(this.entryOr().id) })
        }
        .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
        .backgroundColor(this.entryAnimal().bg)
        .width(100.percent)
    }

    func entryAnimal(): AnimalSpec {
        AnimalSpec.byId(this.entryOr().animalId)
    }

    @Builder
    func bottomBarOf() {
        Row(space: 10) {
            Button(T.menuEdit)
                .layoutWeight(1)
                .height(40)
                .backgroundColor(withAlpha(this.entryAnimal().accent, 0.12))
                .fontColor(this.entryAnimal().ink)
                .onClick({ _ =>
                    navParam = this.entryOr().id
                    stackPush(RN_EDITOR)
                })
            Button(T.shareThisCard)
                .layoutWeight(2)
                .height(40)
                .backgroundColor(withAlpha(this.entryAnimal().accent, 0.12))
                .fontColor(this.entryAnimal().ink)
                .onClick({ _ => () })
        }
        .padding(left: 16.0, right: 16.0, top: 10.0, bottom: 14.0)
        .width(100.percent)
    }
}

// ── 单角色画廊 ──────────────────────────────────────────────────

@Component
class AnimalGalleryPage {
    func cards(): ArrayList<CardEntry> {
        let out = ArrayList<CardEntry>()
        for (e in AppState.instance.sorted()) {
            if (e.animalId == navParam) {
                out.add(e)
            }
        }
        return out
    }

    func animal(): AnimalSpec {
        AnimalSpec.byId(navParam)
    }

    func build() {
        NavDestination() {
            Column() {
                Row(space: 10) {
                    Text("‹").fontSize(22).fontColor(this.animal().ink).onClick({ _ => stackPop() })
                    Text("${this.animal().species} · ${this.animal().name}")
                        .fontSize(16).fontWeight(FontWeight.W700).fontColor(this.animal().ink)
                        .layoutWeight(1)
                }
                .padding(left: 14.0, right: 14.0, top: 8.0, bottom: 8.0)
                .backgroundColor(this.animal().bg)
                .width(100.percent)
                Grid() {
                    ForEach(this.ids(), itemGeneratorFunc: {
                        id: String, idx: Int64 =>
                        GridItem() {
                            GalleryCard(entryId: id, animalId: navParam)
                        }
                        .onClick({ _ =>
                            navParam = id
                            stackPush(RN_DETAIL)
                        })
                    }, keyGeneratorFunc: { id: String, idx: Int64 => id })
                }
                .columnsTemplate("1fr 1fr")
                .columnsGap(12.0)
                .rowsGap(12.0)
                .padding(14.0)
                .layoutWeight(1)
            }
            .width(100.percent)
            .height(100.percent)
            .backgroundColor(pal.paper)
        }
        .hideTitleBar(true)
    }

    func ids(): Array<String> {
        var ids = ArrayList<String>()
        for (e in this.cards()) {
            ids.add(e.id)
        }
        return ids.toArray()
    }
}

@Component
class GalleryCard {
    var entryId: String = ""
    var animalId: String = "otter"

    func entry(): ?CardEntry {
        for (e in AppState.instance.entries) {
            if (e.id == this.entryId) {
                return Some(e)
            }
        }
        return None<CardEntry>
    }

    func build() {
        Column() {
            Stack(alignContent: Alignment.TopStart) {
                StyleCard(animalId: this.animalId, text: this.textOf(),
                    moodKey: "", showMood: true,
                    signature: this.sigOf(), dateText: this.dateOf(),
                    fontScale: 1.0, centered: false,
                    rawStickers: Array<String>(), cardW: 160.0)
            }
            .width(100.percent)
            .height(150)
            .clip(true)
            .borderRadius(14)
            Blank().height(5)
            Text(this.caption())
                .fontSize(11.5).fontWeight(FontWeight.W600)
                .fontColor(AnimalSpec.byId(this.animalId).ink)
        }
        .backgroundColor(0xFFFFFDF6)
        .borderRadius(14)
        .border(width: 1.0, color: withAlpha(AnimalSpec.byId(this.animalId).accent, 0.3))
        .padding(6.0)
    }

    func textOf(): String {
        match (this.entry()) {
            case Some(e) => e.text
            case None => ""
        }
    }

    func sigOf(): String {
        match (this.entry()) {
            case Some(e) => e.signature
            case None => ""
        }
    }

    func dateOf(): String {
        match (this.entry()) {
            case Some(e) => e.dateText
            case None => ""
        }
    }

    func caption(): String {
        match (this.entry()) {
            case Some(e) =>
                let d = epochMsToDateTime(e.createdAtMs)
                return "${d.monthValue}/${d.dayOfMonth}"
            case None => ""
        }
    }
}
