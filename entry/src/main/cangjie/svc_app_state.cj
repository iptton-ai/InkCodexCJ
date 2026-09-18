package ohos_app_cangjie_entry

import std.collection.ArrayList
import std.collection.HashMap
import std.collection.HashSet
import std.time.DateTime

// 全局应用状态：entries / unlocks / mails / habits 的单一事实来源。
// 仓颉端通知机制：UI 组件 aboutToAppear 时 addListener，回调里 bump 自己的 @State rev。

class AppState {
    static let instance = AppState()

    let store: CardStore = CardStore()

    var entries: ArrayList<CardEntry> = ArrayList<CardEntry>()
    var unlocks: Unlocks = Unlocks()
    var mails: ArrayList<MailEntry> = ArrayList<MailEntry>()
    var habits: ArrayList<Habit> = ArrayList<Habit>()

    // 应用密码锁；空串=未启用。
    var pin: String = ""

    // 断签提醒。
    var remindEnabled: Bool = false
    var remindHour: Int64 = 21
    var remindDismissedDay: String = ""

    private var ready: Bool = false
    private var listeners: ArrayList<() -> Unit> = ArrayList<() -> Unit>()

    func addListener(f: () -> Unit): Unit {
        listeners.add(f)
    }

    func removeListener(f: () -> Unit): Unit {
        var i: Int64 = 0
        while (i < listeners.size) {
            // 仓颉函数无法直接比较；配合 rev 机制由组件在 aboutToDisappear 清理时整表重建。
            i += 1
        }
    }

    func notify(): Unit {
        for (f in listeners) {
            f()
        }
    }

    func ensureLoaded(): Unit {
        if (ready) {
            return
        }
        store.ensure()
        entries = store.loadAll()
        unlocks = store.loadUnlocks()
        let m = store.loadMail()
        mails = store.ensureWelcomeMail(m, unlocks)
        habits = store.loadHabits()
        pin = store.loadPin()
        remindEnabled = store.loadRemindEnabled()
        remindHour = clamp64(store.getInt(CardStore.K_REMIND_HOUR, 21), 0, 23)
        remindDismissedDay = store.getString(CardStore.K_REMIND_DISMISSED, "")
        ready = true
        recheckUnlocks()
        notify()
    }

    // ── 查询 ─────────────────────────────────────────────────────
    func sorted(): ArrayList<CardEntry> {
        let list = ArrayList<CardEntry>()
        for (e in entries) {
            list.add(e)
        }
        // 置顶优先，同组内 createdAt 倒序。
        list.sortBy(comparator: { a: CardEntry, b: CardEntry =>
            if (a.pinned != b.pinned) {
                if (a.pinned) { Ordering.LT } else { Ordering.GT }
            } else if (b.createdAtMs > a.createdAtMs) {
                Ordering.LT
            } else if (b.createdAtMs < a.createdAtMs) {
                Ordering.GT
            } else {
                Ordering.EQ
            }
        })
        return list
    }

    // 写卡流水：dayKey -> 当日最新一条。
    func latestByDay(): HashMap<String, CardEntry> {
        let map = HashMap<String, CardEntry>()
        for (e in entries) {
            let k = dayKey(epochMsToDateTime(e.createdAtMs))
            match (map.get(k)) {
                case Some(cur) =>
                    if (e.createdAtMs > cur.createdAtMs) {
                        map.add(k, e)
                    }
                case None => map.add(k, e)
            }
        }
        return map
    }

    // 写卡连投（连续投瓶天数）：从今天（或昨天）往回数有记录的连续天数。
    func computeStreak(): Int64 {
        let days = latestByDay()
        var d = DateTime.now()
        if (!days.contains(dayKey(d))) {
            d = d.addDays(-1)
            if (!days.contains(dayKey(d))) {
                return 0
            }
        }
        var streak: Int64 = 0
        while (days.contains(dayKey(d))) {
            streak += 1
            d = d.addDays(-1)
        }
        return streak
    }

    func unreadMailCount(): Int64 {
        var n: Int64 = 0
        for (m in mails) {
            if (!m.read) {
                n += 1
            }
        }
        return n
    }

    // 累计书写字数（按码点近似字素）。
    func totalWrittenChars(): Int64 {
        var n: Int64 = 0
        for (e in entries) {
            n += e.text.toArray().size
        }
        return n
    }

    func distinctDayCount(): Int64 {
        return latestByDay().size
    }

    private func isNight(d: DateTime): Bool {
        return d.hour >= 22 || d.hour < 5
    }

    func nightCardsThisMonth(): Int64 {
        let now = DateTime.now()
        var n: Int64 = 0
        for (e in entries) {
            let d = epochMsToDateTime(e.createdAtMs)
            if (d.year == now.year && d.monthValue == now.monthValue && isNight(d)) {
                n += 1
            }
        }
        return n
    }

    private func isMorning(d: DateTime): Bool {
        return d.hour >= 6 && d.hour < 10
    }

    // 连续清晨记录天数（6–9 点写字，连 3 天）。
    func morningStreakDays(): Int64 {
        let days = latestByDay()
        let morningDays = HashSet<String>()
        for (e in entries) {
            let d = epochMsToDateTime(e.createdAtMs)
            if (isMorning(d)) {
                morningDays.add(dayKey(d))
            }
        }
        var d = DateTime.now()
        if (!morningDays.contains(dayKey(d))) {
            d = d.addDays(-1)
            if (!morningDays.contains(dayKey(d))) {
                return 0
            }
        }
        var streak: Int64 = 0
        while (morningDays.contains(dayKey(d)) && days.contains(dayKey(d))) {
            streak += 1
            d = d.addDays(-1)
        }
        return streak
    }

    // 图鉴解锁总判定。一旦进 unlockedAnimalIds 即永久。
    func isUnlocked(a: AnimalSpec): Bool {
        let byCond = match (a.id) {
            case "whale" => unlocks.firstCardDone
            case "jelly" => unlocks.unlockedAnimalIds.contains("jelly")
            case "hermit" => unlocks.unlockedAnimalIds.contains(a.id)
            case "crab" => totalWrittenChars() >= 400
            case "nautilus" => entries.size >= 30
            case "albatross" => !mails.isEmpty()
            case "angler" => nightCardsThisMonth() >= 3
            case "ray" => distinctDayCount() >= 15
            case "gull" => morningStreakDays() >= 3
            case _ => true
        }
        return byCond || unlocks.unlockedAnimalIds.contains(a.id)
    }

    func unlockedAnimalCount(): Int64 {
        var n: Int64 = 0
        for (a in AnimalSpec.all) {
            if (isUnlocked(a)) {
                n += 1
            }
        }
        return n
    }

    func bestHabitStreak(): Int64 {
        var best: Int64 = 0
        for (h in habits) {
            let s = h.streak()
            if (s > best) {
                best = s
            }
        }
        return best
    }

    // 解锁巡检：把已达成条件的居民固化进 unlockedAnimalIds（持久）。
    func recheckUnlocks(): Unit {
        let earned = HashSet<String>()
        if (unlocks.firstCardDone) {
            earned.add("whale")
        }
        if (totalWrittenChars() >= 400) {
            earned.add("crab")
        }
        if (entries.size >= 30) {
            earned.add("nautilus")
        }
        if (!mails.isEmpty()) {
            earned.add("albatross")
        }
        if (nightCardsThisMonth() >= 3) {
            earned.add("angler")
        }
        if (distinctDayCount() >= 15) {
            earned.add("ray")
        }
        if (morningStreakDays() >= 3) {
            earned.add("gull")
        }
        var changed = false
        for (k in earned) {
            if (!unlocks.unlockedAnimalIds.contains(k)) {
                unlocks.unlockedAnimalIds.add(k)
                changed = true
            }
        }
        if (changed) {
            store.saveUnlocks(unlocks)
        }
    }

    // ── 每日投喂 ─────────────────────────────────────────────────
    func addHabit(name: String, targetDays: Int64): Habit {
        let h = Habit(
            id: "${epochMs(DateTime.now())}",
            name: name,
            targetDays: clamp64(targetDays, 1, 365),
            createdAtMs: epochMs(DateTime.now()),
        )
        habits.add(h)
        store.saveHabits(habits)
        notify()
        return h
    }

    func removeHabit(id: String): Unit {
        let keep = ArrayList<Habit>()
        for (h in habits) {
            if (h.id != id) {
                keep.add(h)
            }
        }
        habits = keep
        store.saveHabits(habits)
        notify()
    }

    // 一键完成今日投喂。返回 true=今日首次完成。
    func completeHabitToday(id: String): Bool {
        var target: ?Habit = None<Habit>
        for (h in habits) {
            if (h.id == id) {
                target = Some(h)
            }
        }
        match (target) {
            case Some(h) =>
                let k = dayKey(DateTime.now())
                if (h.doneDays.contains(k)) {
                    return false
                }
                h.doneDays.add(k)
                store.saveHabits(habits)
                if (!unlocks.unlockedAnimalIds.contains("jelly") && h.streak() >= 7) {
                    unlocks.unlockedAnimalIds.add("jelly")
                    store.saveUnlocks(unlocks)
                }
                notify()
                return true
            case None => return false
        }
    }

    func countInMonth(year: Int64, month: Int64): Int64 {
        var n: Int64 = 0
        for (e in entries) {
            let d = epochMsToDateTime(e.createdAtMs)
            if (d.year == year && d.monthValue == month) {
                n += 1
            }
        }
        return n
    }

    // 本月记录满 8 篇，下月月初解锁当月装订本。
    func monthUnlocked(year: Int64, month: Int64): Bool {
        let now = DateTime.now()
        let isPast = year < now.year || (year == now.year && month < now.monthValue)
        return isPast && countInMonth(year, month) >= 8
    }

    // ── 变更 ─────────────────────────────────────────────────────
    func addEntry(e: CardEntry): Unit {
        entries.add(e, at: 0)
        store.saveIndex(entries)
        unlocks.firstCardDone = true
        unlocks.unlockedAnimalIds.add(e.animalId)
        unlocks.feedStreak = computeStreak()
        recheckUnlocks()
        store.saveUnlocks(unlocks)
        notify()
    }

    // 编辑已有记录：替换文本/模板/心情，保留原有置顶/锁定/创建时间。
    func replaceEntry(old: CardEntry, updated: CardEntry): Unit {
        var i: Int64 = 0
        while (i < entries.size) {
            if (entries[i].id == old.id) {
                entries[i].animalId = updated.animalId
                entries[i].text = updated.text
                entries[i].signature = updated.signature
                entries[i].dateText = updated.dateText
                entries[i].mood = updated.mood
                if (!updated.imagePaths.isEmpty()) {
                    entries[i].imagePaths = updated.imagePaths
                }
                entries[i].align = updated.align
                break
            }
            i += 1
        }
        store.saveIndex(entries)
        notify()
    }

    func persistEntry(e: CardEntry): Unit {
        store.saveIndex(entries)
        notify()
    }

    func deleteEntry(id: String): Unit {
        let keep = ArrayList<CardEntry>()
        for (e in entries) {
            if (e.id != id) {
                keep.add(e)
            }
        }
        entries = keep
        store.saveIndex(entries)
        unlocks.feedStreak = computeStreak()
        store.saveUnlocks(unlocks)
        notify()
    }

    func markMailRead(id: String): Unit {
        for (m in mails) {
            if (m.id == id) {
                m.read = true
            }
        }
        store.saveMail(mails)
        notify()
    }

    func finishGuide(): Unit {
        unlocks.editorGuideDone = true
        store.saveUnlocks(unlocks)
        notify()
    }

    func setPin(p: String): Unit {
        pin = p
        store.savePin(p)
        notify()
    }

    func setRemind(enabled!: ?Bool = None<Bool>, hour!: ?Int64 = None<Int64>): Unit {
        match (enabled) {
            case Some(v) => remindEnabled = v
            case None => ()
        }
        match (hour) {
            case Some(h) => remindHour = clamp64(h, 0, 23)
            case None => ()
        }
        store.saveRemindEnabled(remindEnabled)
        store.putInt(CardStore.K_REMIND_HOUR, remindHour)
        store.putString(CardStore.K_REMIND_DISMISSED, remindDismissedDay)
        notify()
    }

    func dismissRemindToday(): Unit {
        remindDismissedDay = dayKey(DateTime.now())
        store.putString(CardStore.K_REMIND_DISMISSED, remindDismissedDay)
        notify()
    }

    // 断签提醒触发条件：已开启、过了提醒时刻、今天还没写卡、今日未手动关掉。
    func remindDue(): Bool {
        if (!remindEnabled || remindDismissedDay == dayKey(DateTime.now())) {
            return false
        }
        let now = DateTime.now()
        if (now.hour < remindHour) {
            return false
        }
        return !latestByDay().contains(dayKey(now))
    }

    func todayWritten(): Bool {
        return latestByDay().contains(dayKey(DateTime.now()))
    }
}

// DateTime -> epoch 毫秒。
func epochMs(d: DateTime): Int64 {
    return d.toUnixTimeStamp().toMilliseconds()
}

// epoch 毫秒 -> DateTime（本地时区）。
func epochMsToDateTime(ms: Int64): DateTime {
    return DateTime.fromUnixTimeStamp(Duration.millisecond * ms)
}

func clamp64(v: Int64, lo: Int64, hi: Int64): Int64 {
    if (v < lo) {
        return lo
    }
    if (v > hi) {
        return hi
    }
    return v
}
