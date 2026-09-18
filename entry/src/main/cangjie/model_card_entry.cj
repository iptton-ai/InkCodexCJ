package ohos_app_cangjie_entry

import std.collection.ArrayList
import stdx.encoding.json.*

// 一张已保存卡片（schema v2）。
// 仓颉端不落 PNG：收集册/详情页用 StyleCard 依数据重放渲染。

class CardEntry {
    let id: String
    var animalId: String
    var text: String
    var signature: String
    var dateText: String

    // 标记时的心情；可为空。
    var mood: ?String

    var pinned: Bool
    var locked: Bool

    // 海洋贴纸铺的贴入记录：元素格式 'id|x|y|rot'。
    var imagePaths: ArrayList<String>

    // 正文对齐：'left' | 'center'。
    var align: String

    // 创建时间 epoch 毫秒。
    let createdAtMs: Int64

    init(id!: String, animalId!: String, text!: String, signature!: String = "",
        dateText!: String = "", mood!: ?String = None<String>, pinned!: Bool = false,
        locked!: Bool = false, imagePaths!: ArrayList<String> = ArrayList<String>(),
        align!: String = "left", createdAtMs!: Int64 = 0) {
        this.id = id
        this.animalId = animalId
        this.text = text
        this.signature = signature
        this.dateText = dateText
        this.mood = mood
        this.pinned = pinned
        this.locked = locked
        this.imagePaths = imagePaths
        this.align = align
        this.createdAtMs = createdAtMs
    }

    func toJson(): JsonObject {
        let o = JsonObject()
        o.put("id", JsonString(id))
        o.put("animalId", JsonString(animalId))
        o.put("text", JsonString(text))
        o.put("signature", JsonString(signature))
        o.put("dateText", JsonString(dateText))
        match (mood) {
            case Some(m) => o.put("mood", JsonString(m))
            case None => o.put("mood", JsonNull())
        }
        o.put("pinned", JsonBool(pinned))
        o.put("locked", JsonBool(locked))
        let arr = JsonArray()
        for (p in imagePaths) {
            arr.add(JsonString(p))
        }
        o.put("imagePaths", arr)
        o.put("align", JsonString(align))
        o.put("createdAtMs", JsonInt(createdAtMs))
        return o
    }

    static func fromJson(v: JsonValue): ?CardEntry {
        try {
            let o = v.asObject()
            let id = strOf(o, "id")
            if (id.isEmpty()) {
                return None<CardEntry>
            }
            var mood: ?String = None<String>
            match (o.get("mood")) {
                case Some(mv) =>
                    if (isJsonStr(mv)) {
                        mood = Some(mv.asString().getValue())
                    }
                case None => ()
            }
            let paths = ArrayList<String>()
            match (o.get("imagePaths")) {
                case Some(av) =>
                    if (isJsonArr(av)) {
                        for (e in av.asArray().getItems()) {
                            if (isJsonStr(e)) {
                                paths.add(e.asString().getValue())
                            }
                        }
                    }
                case None => ()
            }
            return Some(CardEntry(
                id: id,
                animalId: strOf(o, "animalId"),
                text: strOf(o, "text"),
                signature: strOf(o, "signature"),
                dateText: strOf(o, "dateText"),
                mood: mood,
                pinned: boolOf(o, "pinned"),
                locked: boolOf(o, "locked"),
                imagePaths: paths,
                align: strOf(o, "align"),
                createdAtMs: intOf(o, "createdAtMs"),
            ))
        } catch (e: Exception) {
            return None<CardEntry>
        }
    }
}

internal func strOf(o: JsonObject, key: String): String {
    match (o.get(key)) {
        case Some(v) =>
            if (isJsonStr(v)) {
                return v.asString().getValue()
            }
            return ""
        case None => return ""
    }
}

internal func isJsonStr(v: JsonValue): Bool {
    match (v.kind()) {
        case JsonKind.JsString => true
        case _ => false
    }
}

internal func isJsonArr(v: JsonValue): Bool {
    match (v.kind()) {
        case JsonKind.JsArray => true
        case _ => false
    }
}

internal func boolOf(o: JsonObject, key: String): Bool {
    match (o.get(key)) {
        case Some(v) =>
            match (v.kind()) {
                case JsonKind.JsBool => v.asBool().getValue()
                case _ => false
            }
        case None => return false
    }
}

internal func intOf(o: JsonObject, key: String): Int64 {
    match (o.get(key)) {
        case Some(v) =>
            match (v.kind()) {
                case JsonKind.JsInt => v.asInt().getValue()
                case _ => 0
            }
        case None => return 0
    }
}
