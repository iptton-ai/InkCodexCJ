package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import kit.LocalizationKit.*
import kit.PerformanceAnalysisKit.Hilog
import std.collection.ArrayList
import std.time.DateTime
import std.time.TimeZone

// ── 首启隐私政策门（大陆上架合规）────────────────────────────────

@Component
class PrivacyGateView {
    func build() {
        Column() {
            Blank().layoutWeight(2)
            Text("✍️").fontSize(40)
            Blank().height(14)
            Text(T.privacyGateTitle)
                .fontSize(20).fontWeight(FontWeight.W700).fontColor(pal.ink)
            Blank().height(20)
            Column() {
                Text(T.privacyGateBody)
                    .fontSize(14).fontColor(pal.ink).lineHeight(24.0)
                Blank().height(12)
                Text(T.privacyGateLink)
                    .fontSize(14).fontColor(pal.seaInk)
                    .onClick({ _ =>
                        navParam = ""
                        stackPush(RN_POLICY)
                    })
            }
            .alignItems(HorizontalAlign.Start)
            .padding(20.0)
            .backgroundColor(pal.card)
            .borderRadius(18)
            .border(width: 1.0, color: pal.line)
            .width(100.percent)
            Blank().height(26)
            Button(T.privacyGateAgree)
                .width(100.percent).height(46)
                .backgroundColor(pal.sea)
                .fontColor(0xFFFFFFFF)
                .onClick({ _ => PrivacyConsent.instance.agree() })
            Button(T.privacyGateDecline)
                .fontSize(13.5)
                .backgroundColor(Color.Transparent)
                .fontColor(pal.inkSoft)
                .onClick({ _ =>
                    // 不同意：保留在本页（不强制退出进程，便于误触恢复）。
                })
            Blank().layoutWeight(3)
        }
        .padding(left: 26.0, right: 26.0)
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(pal.paper)
    }
}

// ── 首页：漂流时间线 ─────────────────────────────────────────────

@Component
class HomePage {
    @State
    var rev: Int64 = 0

    @State
    var calendarOpen: Bool = false

    protected override func aboutToAppear() {
        let self = this
        let f = { =>
            self.rev += 1
            Hilog.info(1, "InkCJ", "home listener fired rev=${self.rev}")
        }
        AppState.instance.addListener(f)
    }

    func build() {
        Stack(alignContent: Alignment.BottomEnd) {
            Column() {
                this.header()
                if (AppState.instance.remindDue()) {
                    this.remindBanner()
                }
                if (AppState.instance.sorted().isEmpty()) {
                    EmptyShore(title: T.emptyTitle, hint: T.emptyHint)
                } else {
                    TimelineList(entryIds: this.sortedIds(), onTapEntry: { id: String =>
                        navParam = id
                        stackPush(RN_DETAIL)
                    })
                }
            }
            .width(100.percent)
            .height(100.percent)
            this.dockCluster()
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(pal.paper)
        .opacity(this.revOpacity())
    }

    func revOpacity(): Float64 {
        let _ = this.rev
        return 1.0
    }

    func arrowGlyph(): String {
        if (this.calendarOpen) {
            return "︿"
        }
        return "﹀"
    }

    func sortedIds(): Array<String> {
        let st = AppState.instance
        let sorted = st.sorted()
        var ids = ArrayList<String>()
        for (e in sorted) {
            ids.add(e.id)
        }
        return ids.toArray()
    }

    // 页头（晨光黄）：标题+连投 + 邮箱入口 + 漂流条/月历切换。
    @Builder
    func header() {
        Column() {
            Row() {
                Column(space: 2) {
                    Row(space: 6) {
                        Text(T.homeTitle).fontSize(19).fontWeight(FontWeight.W800).fontColor(pal.ink)
                        Text(this.arrowGlyph()).fontSize(15).fontColor(pal.inkSoft)
                    }
                    Text(this.subTitle())
                        .fontSize(11.5).fontColor(pal.inkMid)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .onClick({ _ => this.calendarOpen = !this.calendarOpen })
                Stack() {
                    Text("📮").fontSize(20).padding(6.0)
                    if (AppState.instance.unreadMailCount() > 0) {
                        Column()
                            .width(9).height(9).borderRadius(4.5)
                            .backgroundColor(pal.coral)
                            .margin(top: 2.0, left: 26.0)
                    }
                }
                .onClick({ _ =>
                    navParam = ""
                    stackPush(RN_MAILBOX)
                })
            }
            .width(100.percent)
            Blank().height(4.0)
            if (this.calendarOpen) {
                TideCalendar(onEntryTap: { id: String =>
                    navParam = id
                    stackPush(RN_DETAIL)
                })
            } else {
                this.feedStrip()
            }
        }
        .padding(left: 8.0, right: 14.0, top: 6.0, bottom: 14.0)
        .backgroundColor(pal.header)
        .borderRadius(bottomLeft: 26.0, bottomRight: 26.0)
        .width(100.percent)
    }

    func subTitle(): String {
        let st = AppState.instance
        let streak = st.computeStreak()
        let now = DateTime.now()
        let d = "${now.monthValue}月${now.dayOfMonth}日"
        if (streak > 0) {
            return "${d} · 已连投 ${streak} 天"
        }
        return "${d} · 每个字，都值得被海浪排好"
    }

    // 漂流条：最近 10 天圆格。
    func isToday(day: Int64): Bool {
        day == DateTime.now().dayOfMonth
    }

    @Builder
    func feedStrip() {
        Row(space: 4) {
            ForEach(this.lastDays(), itemGeneratorFunc: {
                day: Int64, idx: Int64 =>
                Column(space: 3) {
                    this.dayCell(day)
                    Text(this.dayLabel(day))
                        .fontSize(9.5)
                        .fontColor(if (this.isToday(day)) { pal.ink } else { pal.inkSoft })
                }
                .layoutWeight(1)
                .onClick({ _ => this.onStripTap(day) })
            }, keyGeneratorFunc: { day: Int64, idx: Int64 => "d${idx}-${day}" })
        }
        .width(100.percent)
        .height(62)
    }

    func dayLabel(day: Int64): String {
        if (day == 0) {
            return ""
        }
        return "${day}"
    }

    func lastDays(): Array<Int64> {
        let now = DateTime.now()
        var days = ArrayList<Int64>()
        var i: Int64 = 9
        while (i >= 0) {
            days.add(now.addDays(-i).dayOfMonth)
            i -= 1
        }
        return days.toArray()
    }

    func dayKeyOfMonth(day: Int64): String {
        let now = DateTime.now()
        return dayKey(DateTime.of(year: now.year, month: now.monthValue, dayOfMonth: day, hour: 12, minute: 0, second: 0, nanosecond: 0, timeZone: TimeZone.Local))
    }

    func dayHasEntry(day: Int64): Bool {
        return AppState.instance.latestByDay().contains(this.dayKeyOfMonth(day))
    }

    func onStripTap(day: Int64): Unit {
        if (this.dayHasEntry(day)) {
            match (AppState.instance.latestByDay().get(this.dayKeyOfMonth(day))) {
                case Some(e) =>
                    navParam = e.id
                    stackPush(RN_DETAIL)
                case None => ()
            }
        } else if (day == DateTime.now().dayOfMonth) {
            navParam = ""
            stackPush(RN_EDITOR)
        }
    }

    func cellHas(day: Int64): Bool {
        this.dayHasEntry(day)
    }

    func cellBg(day: Int64): UInt32 {
        if (this.cellHas(day) || this.isToday(day)) {
            return pal.headerCard
        }
        return withAlpha(pal.headerCard, 0.55)
    }

    func cellBorder(day: Int64): Length {
        if (!this.cellHas(day) && this.isToday(day)) {
            return 2.0
        }
        return 0.0
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
    func dayCell(day: Int64) {
        Column() {
            if (this.cellHas(day)) {
                this.imgBranch(this.animalOfDay(day), 34.0)
            } else {
                Text("+")
                    .fontSize(if (this.isToday(day)) { 20 } else { 15 })
                    .fontWeight(FontWeight.W600)
                    .fontColor(if (this.isToday(day)) { pal.ink } else { pal.inkFaint })
            }
        }
        .width(38).height(38)
        .borderRadius(19)
        .backgroundColor(this.cellBg(day))
        .border(width: this.cellBorder(day), color: pal.ink)
    }

    func animalOfDay(day: Int64): String {
        let key = this.dayKeyOfMonth(day)
        match (AppState.instance.latestByDay().get(key)) {
            case Some(e) => e.animalId
            case None => "otter"
        }
    }

    // 断签提醒横幅。
    @Builder
    func remindBanner() {
        Row(space: 9) {
            Text("🌊").fontSize(16)
            Text(this.remindText())
                .fontSize(12.5).fontWeight(FontWeight.W600).fontColor(pal.ink)
                .layoutWeight(1)
                .onClick({ _ =>
                    navParam = ""
                    stackPush(RN_EDITOR)
                })
            Text("×").fontSize(15).fontColor(pal.inkSoft)
                .padding(6.0)
                .onClick({ _ => AppState.instance.dismissRemindToday() })
        }
        .padding(left: 14.0, right: 4.0, top: 10.0, bottom: 10.0)
        .margin(left: 16.0, right: 16.0)
        .backgroundColor(pal.sunTint)
        .borderRadius(14)
        .border(width: 1.0, color: withAlpha(pal.amber, 0.6))
    }

    func remindText(): String {
        let n = AppState.instance.computeStreak()
        if (n > 0) {
            return T.remindBannerStreak(n)
        }
        return T.remindBannerPlain
    }

    // 右下按钮簇：灯塔 chip + 投瓶 FAB。
    @Builder
    func dockCluster() {
        Row(space: 12) {
            Column() {
                Text("🗼").fontSize(20)
            }
            .width(44).height(44)
            .borderRadius(22)
            .backgroundColor(pal.card)
            .border(width: 1.0, color: pal.line)
            .onClick({ _ => openDockSheet() })
            Button("＋")
                .width(58).height(58)
                .fontSize(26)
                .fontColor(0xFFFFFDF6)
                .backgroundColor(0xFF3E6B5A)
                .borderRadius(29)
                .border(width: 1.4, color: withAlpha(0xFFDFF0E9, 0.35))
                .shadow(radius: 12.0, color: withAlpha(0xFF3E6B5A, 0.32), offsetY: 5.0)
                .onClick({ _ =>
                    navParam = ""
                    stackPush(RN_EDITOR)
                })
        }
        .margin(right: 18.0, bottom: 24.0)
    }
}

// 码头 sheet（透明遮罩页 + 底部浮卡）。
func openDockSheet(): Unit {
    navParam = ""
    stackPush(RN_DOCK)
}
