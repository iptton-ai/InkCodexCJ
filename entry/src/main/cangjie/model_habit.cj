package ohos_app_cangjie_entry

import std.collection.HashSet
import std.time.DateTime
import stdx.encoding.json.*

// 自定义习惯项（每日投喂·打卡 v2）。
// 用户自建习惯，首页一键完成；单习惯连续投喂 7 天解锁夜光。

class Habit {
    let id: String
    var name: String
    var targetDays: Int64
    let createdAtMs: Int64

    // 已完成日的 dayKey 集合。
    var doneDays: HashSet<String>

    init(id!: String, name!: String, targetDays!: Int64 = 14,
        createdAtMs!: Int64 = 0, doneDays!: HashSet<String> = HashSet<String>()) {
        this.id = id
        this.name = name
        this.targetDays = targetDays
        this.createdAtMs = createdAtMs
        this.doneDays = doneDays
    }

    func doneToday(): Bool {
        return doneDays.contains(dayKey(DateTime.now()))
    }

    // 单习惯连续投喂天数：从今天（或昨天）往回数连续完成的日期数。
    func streak(): Int64 {
        var d = DateTime.now()
        if (!doneDays.contains(dayKey(d))) {
            d = d.addDays(-1)
            if (!doneDays.contains(dayKey(d))) {
                return 0
            }
        }
        var n: Int64 = 0
        while (doneDays.contains(dayKey(d))) {
            n += 1
            d = d.addDays(-1)
        }
        return n
    }

    func toJson(): JsonObject {
        let o = JsonObject()
        o.put("id", JsonString(id))
        o.put("name", JsonString(name))
        o.put("targetDays", JsonInt(targetDays))
        o.put("createdAtMs", JsonInt(createdAtMs))
        let arr = JsonArray()
        for (k in doneDays) {
            arr.add(JsonString(k))
        }
        o.put("doneDays", arr)
        return o
    }

    static func fromJson(v: JsonValue): ?Habit {
        try {
            let o = v.asObject()
            let id = strOf(o, "id")
            if (id.isEmpty()) {
                return None<Habit>
            }
            let done = HashSet<String>()
            match (o.get("doneDays")) {
                case Some(av) =>
                    if (isJsonArr(av)) {
                        for (e in av.asArray().getItems()) {
                            if (isJsonStr(e)) {
                                done.add(e.asString().getValue())
                            }
                        }
                    }
                case None => ()
            }
            return Some(Habit(
                id: id,
                name: strOf(o, "name"),
                targetDays: intOf(o, "targetDays"),
                createdAtMs: intOf(o, "createdAtMs"),
                doneDays: done,
            ))
        } catch (e: Exception) {
            return None<Habit>
        }
    }
}
