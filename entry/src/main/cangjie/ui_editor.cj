package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.Hilog
import std.collection.ArrayList
import std.collection.HashMap
import std.time.DateTime

// ── 纸面编辑器 ──────────────────────────────────────────────────

@Component
class EditorPage {
    @State
    var rev: Int64 = 0

    @State
    var animalId: String = "otter"

    @State
    var text: String = ""

    @State
    var signature: String = ""

    @State
    var moodKey: String = ""

    @State
    var centered: Bool = false

    @State
    var fontStep: Int64 = 1

    @State
    var showMood: Bool = true

    @State
    var inviteOpen: Bool = false

    @State
    var saving: Bool = false

    // 编辑模式：待替换的卡片 id。
    var existingId: String = ""

    protected override func aboutToAppear() {
        if (navParam != "") {
            this.existingId = navParam
            for (e in AppState.instance.entries) {
                if (e.id == this.existingId) {
                    this.animalId = e.animalId
                    this.text = e.text
                    this.signature = e.signature
                    this.centered = e.align == "center"
                    match (e.mood) {
                        case Some(m) => this.moodKey = m
                        case None => ()
                    }
                }
            }
        }
        this.text = this.text
    }

    func paperW(): Float64 {
        330.0
    }

    func fontScale(): Float64 {
        let steps: Array<Float64> = [0.85, 1.0, 1.15]
        return steps[this.fontStep]
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

    func animal(): AnimalSpec {
        AnimalSpec.byId(this.animalId)
    }

    func unlockedIds(): Array<String> {
        var ids = ArrayList<String>()
        for (a in AnimalSpec.all) {
            if (AnimalSpec.baseIds.contains(a.id) || AppState.instance.isUnlocked(a)) {
                ids.add(a.id)
            }
        }
        return ids.toArray()
    }




    func spec(): TemplateSpec {
        TemplateSpec.specOf(this.animal().style)
    }

    func paperH(): Float64 {
        this.paperW() * 1.28
    }


    func bodyFontFamily(): String {
        let f = this.animal().fontFamily
        return if (f == "system") { "HarmonyOS Sans" } else { f }
    }

    func fs(): Float64 {
        fontSizeFor(this.text) * this.fontScale()
    }

    // 纸面即编辑器（内联：纸底+装饰+输入+页脚）。
    @Builder
    func paperBlock() {
        Stack() {
            PaperBase(pAnimalId: this.animalId, cardW: this.paperW(), cardH: this.paperH())
            OrnamentLayer(pAnimalId: this.animalId, pOver: false, cardW: this.paperW(), cardH: this.paperH())
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
                    GridHeaderView(animalId: this.animalId, cardW: this.paperW(),
                        signature: this.signature, dateStr: this.dateText())
                    Blank().height(10.0)
                }
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
                .onClick({ _ => this.inviteOpen = true })
                Blank().height(6.0)
                TextArea(placeholder: Some(if (this.moodKey == "") { T.writeHint } else { T.keepWritingHint }),
                    text: Some(this.text))
                    .placeholderColor(withAlpha(this.animal().ink, 0.28))
                    .fontColor(this.animal().ink)
                    .fontSize(this.fs())
                    .fontFamily(this.bodyFontFamily())
                    .textAlign(if (this.centered) { TextAlign.Center } else { TextAlign.Start })
                    .backgroundColor(Color.Transparent)
                    .caretColor(this.animal().accent)
                    .width(100.percent)
                    .layoutWeight(1)
                    .constraintSize(minHeight: 60.0)
                    .onChange({ v: String => this.text = v })
                Blank().height(16.0 * (this.paperW() / 400.0))
                FooterView(animalId: this.animalId, cardW: this.paperW(),
                    bodyText: this.text, signature: this.signature,
                    dateStr: this.dateText(), accent: this.animal().accent,
                    ink: this.animal().ink, seal: this.animal().seal,
                    specFooter: footerKindIndex(this.spec().footer))
            }
            .padding(top: this.paperH() * this.spec().safeT, right: this.paperW() * this.spec().safeR,
                bottom: this.paperH() * this.spec().safeB, left: this.paperW() * this.spec().safeL)
            .width(this.paperW())
            .height(this.paperH())
            StickerLayer(rawSpecs: Array<String>(), cardW: this.paperW(), cardH: this.paperH(),
                tint: this.animal().accent)
            OrnamentLayer(pAnimalId: this.animalId, pOver: true, cardW: this.paperW(), cardH: this.paperH())
        }
        .width(this.paperW())
        .height(this.paperH())
        .borderRadius(this.spec().radius)
        .clip(true)
        .alignContent(Alignment.TopStart)
        .margin(top: 10.0)
    }

    func build() {
        NavDestination() {
            Stack(alignContent: Alignment.TopStart) {
                Column() {
                    this.topBar()
                    Scroll() {
                        Column() {
                            this.paperBlock()
                        }
                        .width(100.percent)
                        .alignItems(HorizontalAlign.Center)
                    }
                    .layoutWeight(1)
                    .align(Alignment.Top)
                    .scrollBar(BarState.Off)
                    this.animalBar()
                }
                .width(100.percent)
                .height(100.percent)
                .backgroundColor(pal.paperSunken)
                if (this.inviteOpen) {
                    this.moodInvite()
                }
            }
            .width(100.percent)
            .height(100.percent)
        }
        .hideTitleBar(true)
    }

    func dateText(): String {
        let now = DateTime.now()
        return T.dateFull(now.year, now.monthValue, now.dayOfMonth)
    }

    // 顶栏：关闭 | 标题 | 好了
    @Builder
    func topBar() {
        Row() {
            Text("✕").fontSize(18).fontColor(pal.inkMid).padding(10.0)
                .onClick({ _ => this.tryClose() })
            Blank()
            Text("${this.animal().species} · ${this.animal().name}")
                .fontSize(15).fontWeight(FontWeight.W600).fontColor(pal.inkMid)
            Blank()
            Text(T.doneBtn)
                .fontSize(14.5).fontWeight(FontWeight.W600)
                .fontColor(0xFFFFFDF6)
                .padding(left: 18.0, right: 18.0, top: 9.0, bottom: 9.0)
                .backgroundColor(pal.ink)
                .borderRadius(999)
                .margin(right: 10.0)
                .onClick({ _ => this.done() })
        }
        .width(100.percent)
        .height(48)
    }

    // 底部动物条（已解锁阵容）。
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
    func animalBar() {
        Column() {
            Scroll() {
                Row(space: 8) {
                    ForEach(this.unlockedIds(), itemGeneratorFunc: {
                        id: String, idx: Int64 =>
                        Column() {
                            this.imgBranch(id, 48.0)
                        }
                        .padding(3.0)
                        .borderRadius(14)
                        .border(width: if (id == this.animalId) { 2.5 } else { 0.0 },
                            color: if (id == this.animalId) { pal.amber } else { Color.Transparent })
                        .onClick({ _ => this.animalId = id })
                    }, keyGeneratorFunc: { id: String, idx: Int64 => id })
                }
                .padding(left: 16.0, right: 16.0)
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
        }
        .width(100.percent)
        .height(76)
        .backgroundColor(withAlpha(pal.sunken, 0.5))
    }

    // 心情邀约浮层。
    @Builder
    func moodInvite() {
        Column() {
            Blank().height(96)
            Column() {
                Row() {
                    Blank().width(26)
                    Column(space: 2) {
                        Text(T.moodInviteTitle).fontSize(14.5).fontWeight(FontWeight.W700).fontColor(pal.inkMid)
                        Text(T.moodInviteHint).fontSize(10.5).fontColor(pal.inkSoft)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    Text("✕").fontSize(15).fontColor(pal.inkFaint).padding(6.0)
                        .onClick({ _ => this.inviteOpen = false })
                }
                .width(100.percent)
                Blank().height(10)
                Row() {
                    ForEach(this.moodKeys(), itemGeneratorFunc: {
                        mk: String, idx: Int64 =>
                        Column(space: 4) {
                            MoodBadge(moodKey: mk, badgeSize: 38.0, selected: this.moodKey == mk)
                            Text(moodLabelOf(mk)).fontSize(10.5).fontColor(pal.inkSoft)
                        }
                        .padding(left: 5.0, right: 5.0)
                        .onClick({ _ =>
                            this.moodKey = mk
                            this.inviteOpen = false
                        })
                    }, keyGeneratorFunc: { mk: String, idx: Int64 => mk })
                }
                .width(100.percent)
                .justifyContent(FlexAlign.Center)
            }
            .padding(left: 18.0, right: 12.0, top: 14.0, bottom: 18.0)
            .backgroundColor(pal.card)
            .borderRadius(20)
            .margin(left: 14.0, right: 14.0)
            Blank()
        }
        .width(100.percent)
        .height(100.percent)
        .alignItems(HorizontalAlign.Start)
        .onClick({ _ => this.inviteOpen = false })
    }

    func moodKeys(): Array<String> {
        return ["angry", "sad", "curious", "happy", "ecstatic"]
    }

    func tryClose(): Unit {
        if (this.text == "" && this.signature == "") {
            stackPop()
        } else {
            stackPop()
        }
    }

    // 「好了」：保存卡片。
    func done(): Unit {
        Hilog.info(1, "InkCJ", "done called, textLen=${this.text.size} saving=${this.saving}")
        if (this.saving) {
            return
        }
        if (this.text == "" || this.text.trimAscii() == "") {
            Hilog.info(1, "InkCJ", "empty text, abort")
            return
        }
        this.saving = true
        let now = DateTime.now()
        let st = AppState.instance
        let mood: ?String = if (this.moodKey == "") { None<String> } else { Some(this.moodKey) }
        var align = "left"
        if (this.centered) {
            align = "center"
        }
        if (this.existingId != "") {
            for (e in st.entries) {
                if (e.id == this.existingId) {
                    let updated = CardEntry(id: e.id, animalId: this.animalId, text: this.text,
                        signature: this.signature, dateText: e.dateText, mood: mood,
                        imagePaths: e.imagePaths, align: align, createdAtMs: e.createdAtMs)
                    st.replaceEntry(e, updated)
                    break
                }
            }
        } else {
            let e = CardEntry(id: "${now.toUnixTimeStamp().toMilliseconds()}",
                animalId: this.animalId, text: this.text, signature: this.signature,
                dateText: this.dateText(), mood: mood, align: align,
                createdAtMs: now.toUnixTimeStamp().toMilliseconds())
            st.addEntry(e)
        }
        this.saving = false
        Hilog.info(1, "InkCJ", "saved, entries=${AppState.instance.entries.size}")
        stackPop()
    }
}

// ── 心情徽章 ────────────────────────────────────────────────────

@Component
class MoodBadge {
    var moodKey: String = "happy"
    var badgeSize: Float64 = 44.0
    var selected: Bool = false

    func build() {
        Text(this.emoji())
            .fontSize(this.badgeSize * 0.62)
            .width(this.badgeSize)
            .height(this.badgeSize)
            .textAlign(TextAlign.Center)
            .borderRadius(this.badgeSize / 2.0)
            .backgroundColor(if (this.selected) { this.tint() } else { 0xFFFFFFFF })
            .border(width: 1.6, color: this.tint())
    }

    func mood(): Mood {
        match (Mood.tryParse(Some(this.moodKey))) {
            case Some(m) => m
            case None => Happy
        }
    }

    func tint(): UInt32 {
        this.mood().tint()
    }

    func emoji(): String {
        match (this.mood()) {
            case Angry => "😠"
            case Sad => "😢"
            case Curious => "🤔"
            case Happy => "😊"
            case Ecstatic => "🤩"
        }
    }
}
