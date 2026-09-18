package ohos_app_cangjie_entry

import std.collection.ArrayList
import std.collection.HashSet
import stdx.encoding.json.*
import kit.ArkData.*
import kit.AbilityKit.UIAbilityContext
import std.time.DateTime

// 全局 UIAbilityContext（MainAbility.onCreate 时注入）。
var appContext: Option<UIAbilityContext> = Option<UIAbilityContext>.None

// 角色来信（深海邮局）。
class MailEntry {
    let id: String
    let animalId: String
    let title: String
    let body: String
    let dateText: String
    var read: Bool

    init(id!: String, animalId!: String, title!: String, body!: String,
        dateText!: String, read!: Bool = false) {
        this.id = id
        this.animalId = animalId
        this.title = title
        this.body = body
        this.dateText = dateText
        this.read = read
    }

    func toJson(): JsonObject {
        let o = JsonObject()
        o.put("id", JsonString(id))
        o.put("animalId", JsonString(animalId))
        o.put("title", JsonString(title))
        o.put("body", JsonString(body))
        o.put("dateText", JsonString(dateText))
        o.put("read", JsonBool(read))
        return o
    }

    static func fromJson(v: JsonValue): ?MailEntry {
        try {
            let o = v.asObject()
            let id = strOf(o, "id")
            if (id.isEmpty()) {
                return None<MailEntry>
            }
            return Some(MailEntry(
                id: id,
                animalId: strOf(o, "animalId"),
                title: strOf(o, "title"),
                body: strOf(o, "body"),
                dateText: strOf(o, "dateText"),
                read: boolOf(o, "read"),
            ))
        } catch (e: Exception) {
            return None<MailEntry>
        }
    }
}

// 成长/解锁状态。
class Unlocks {
    var firstCardDone: Bool
    var welcomeSeeded: Bool
    var editorGuideDone: Bool

    // 写卡连投天数缓存（展示一律实时计算）。
    var feedStreak: Int64

    // 已解锁动物 id：进 set 即永久，删卡不回收。
    var unlockedAnimalIds: HashSet<String>

    init(firstCardDone!: Bool = false, welcomeSeeded!: Bool = false,
        editorGuideDone!: Bool = false, feedStreak!: Int64 = 0,
        unlockedAnimalIds!: HashSet<String> = HashSet<String>()) {
        this.firstCardDone = firstCardDone
        this.welcomeSeeded = welcomeSeeded
        this.editorGuideDone = editorGuideDone
        this.feedStreak = feedStreak
        this.unlockedAnimalIds = unlockedAnimalIds
    }

    func toJson(): JsonObject {
        let o = JsonObject()
        o.put("firstCardDone", JsonBool(firstCardDone))
        o.put("welcomeSeeded", JsonBool(welcomeSeeded))
        o.put("editorGuideDone", JsonBool(editorGuideDone))
        o.put("feedStreak", JsonInt(feedStreak))
        let arr = JsonArray()
        for (k in unlockedAnimalIds) {
            arr.add(JsonString(k))
        }
        o.put("unlockedIds", arr)
        return o
    }

    static func fromJson(v: JsonValue): Unlocks {
        try {
            let o = v.asObject()
            let ids = HashSet<String>()
            match (o.get("unlockedIds")) {
                case Some(av) =>
                    if (isJsonArr(av)) {
                        for (e in av.asArray().getItems()) {
                            if (isJsonStr(e)) {
                                ids.add(e.asString().getValue())
                            }
                        }
                    }
                case None => ()
            }
            return Unlocks(
                firstCardDone: boolOf(o, "firstCardDone"),
                welcomeSeeded: boolOf(o, "welcomeSeeded"),
                editorGuideDone: boolOf(o, "editorGuideDone"),
                feedStreak: intOf(o, "feedStreak"),
                unlockedAnimalIds: ids,
            )
        } catch (e: Exception) {
            return Unlocks()
        }
    }
}

// 本地存储：索引/解锁/来信/习惯/密码/提醒全部存 Preferences。
class CardStore {
    static let K_SCHEMA = "inkcodex.schema"
    static let SCHEMA_VER = "2"
    static let K_INDEX = "inkcodex.card.index.v2"
    static let K_UNLOCKS = "inkcodex.unlocks.v2"
    static let K_MAIL = "inkcodex.mail.v2"
    static let K_HABITS = "inkcodex.habits.v2"
    static let K_PIN = "inkcodex.pin.v2"
    static let K_REMIND = "inkcodex.remind.v2"
    static let K_DOCK_HINT = "inkcodex.dock_hint.v2"
    static let K_PRIVACY = "inkcodex.privacy_agreed"

    private var prefs: Option<Preferences> = Option<Preferences>.None

    func ensure(): Unit {
        let ctx = appContext
        match (ctx) {
            case Some(c) =>
                prefs = Preferences.getPreferences(c, PreferencesOptions("inkcodex"))
            case None => ()
        }
    }

    private func p(): Option<Preferences> {
        return prefs
    }

    func getString(key: String, def: String): String {
        match (p()) {
            case Some(pr) =>
                let v = pr.get(key, PreferencesValueType.StringData(def))
                match (v) {
                    case PreferencesValueType.StringData(s) => return s
                    case _ => return def
                }
            case None => return def
        }
    }

    func putString(key: String, value: String): Unit {
        match (p()) {
            case Some(pr) =>
                pr.put(key, PreferencesValueType.StringData(value))
                pr.flush()
            case None => ()
        }
    }

    func getInt(key: String, def: Int64): Int64 {
        match (p()) {
            case Some(pr) =>
                let v = pr.get(key, PreferencesValueType.Integer(def))
                match (v) {
                    case PreferencesValueType.Integer(n) => return n
                    case _ => return def
                }
            case None => return def
        }
    }

    func putInt(key: String, value: Int64): Unit {
        match (p()) {
            case Some(pr) =>
                pr.put(key, PreferencesValueType.Integer(value))
                pr.flush()
            case None => ()
        }
    }

    // ── 卡片索引 ─────────────────────────────────────────────────
    func loadAll(): ArrayList<CardEntry> {
        let raw = getString(K_INDEX, "")
        let out = ArrayList<CardEntry>()
        if (raw.isEmpty()) {
            return out
        }
        try {
            let v = JsonValue.fromStr(raw)
            if (isJsonArr(v)) {
                for (e in v.asArray().getItems()) {
                    match (CardEntry.fromJson(e)) {
                        case Some(entry) => out.add(entry)
                        case None => ()
                    }
                }
            }
        } catch (e: Exception) {
            return ArrayList<CardEntry>()
        }
        return out
    }

    func saveIndex(all: ArrayList<CardEntry>): Unit {
        let arr = JsonArray()
        for (e in all) {
            arr.add(e.toJson())
        }
        putString(K_INDEX, arr.toJsonString())
    }

    // ── 解锁 ─────────────────────────────────────────────────────
    func loadUnlocks(): Unlocks {
        let raw = getString(K_UNLOCKS, "")
        if (raw.isEmpty()) {
            return Unlocks()
        }
        try {
            return Unlocks.fromJson(JsonValue.fromStr(raw))
        } catch (e: Exception) {
            return Unlocks()
        }
    }

    func saveUnlocks(u: Unlocks): Unit {
        putString(K_UNLOCKS, u.toJson().toJsonString())
    }

    // ── 来信 ─────────────────────────────────────────────────────
    func loadMail(): ArrayList<MailEntry> {
        let raw = getString(K_MAIL, "")
        let out = ArrayList<MailEntry>()
        if (raw.isEmpty()) {
            return out
        }
        try {
            let v = JsonValue.fromStr(raw)
            if (isJsonArr(v)) {
                for (e in v.asArray().getItems()) {
                    match (MailEntry.fromJson(e)) {
                        case Some(m) => out.add(m)
                        case None => ()
                    }
                }
            }
        } catch (e: Exception) {
            return ArrayList<MailEntry>()
        }
        return out
    }

    func saveMail(mails: ArrayList<MailEntry>): Unit {
        let arr = JsonArray()
        for (m in mails) {
            arr.add(m.toJson())
        }
        putString(K_MAIL, arr.toJsonString())
    }

    // ── 习惯 ─────────────────────────────────────────────────────
    func loadHabits(): ArrayList<Habit> {
        let raw = getString(K_HABITS, "")
        let out = ArrayList<Habit>()
        if (raw.isEmpty()) {
            return out
        }
        try {
            let v = JsonValue.fromStr(raw)
            if (isJsonArr(v)) {
                for (e in v.asArray().getItems()) {
                    match (Habit.fromJson(e)) {
                        case Some(h) => out.add(h)
                        case None => ()
                    }
                }
            }
        } catch (e: Exception) {
            return ArrayList<Habit>()
        }
        return out
    }

    func saveHabits(habits: ArrayList<Habit>): Unit {
        let arr = JsonArray()
        for (h in habits) {
            arr.add(h.toJson())
        }
        putString(K_HABITS, arr.toJsonString())
    }

    // ── 密码锁 ───────────────────────────────────────────────────
    func loadPin(): String {
        getString(K_PIN, "")
    }

    func savePin(pin: String): Unit {
        putString(K_PIN, pin)
    }

    // ── 断签提醒 ─────────────────────────────────────────────────
    func loadRemindEnabled(): Bool {
        getString(K_REMIND_ENABLED, "0") == "1"
    }

    func saveRemindEnabled(v: Bool): Unit {
        putString(K_REMIND_ENABLED, if (v) { "1" } else { "0" })
    }

    static let K_REMIND_ENABLED = "inkcodex.remind.enabled.v2"
    static let K_REMIND_HOUR = "inkcodex.remind.hour.v2"
    static let K_REMIND_DISMISSED = "inkcodex.remind.dismissed.v2"

    // ── 码头引导气泡次数 ─────────────────────────────────────────
    func loadDockHintShown(): Int64 {
        getInt(K_DOCK_HINT, 0)
    }

    func saveDockHintShown(n: Int64): Unit {
        putInt(K_DOCK_HINT, n)
    }

    // ── 隐私同意（版本化）────────────────────────────────────────
    func loadPrivacyAgreed(): Bool {
        getString(K_PRIVACY, "") == T.privacyPolicyVersion
    }

    func savePrivacyAgreed(): Unit {
        putString(K_PRIVACY, T.privacyPolicyVersion)
    }

    // 新用户第 0 天即收到阿浮的漂流瓶欢迎信。
    func ensureWelcomeMail(mails: ArrayList<MailEntry>, u: Unlocks): ArrayList<MailEntry> {
        if (!mails.isEmpty() || u.welcomeSeeded) {
            return mails
        }
        let now = DateTime.now()
        let date = T.dateFull(now.year, now.monthValue, now.dayOfMonth)
        mails.add(MailEntry(
            id: "welcome-afa",
            animalId: "otter",
            title: T.welcomeTitle,
            body: T.welcomeBody,
            dateText: date,
        ))
        u.welcomeSeeded = true
        saveUnlocks(u)
        saveMail(mails)
        return mails
    }
}
