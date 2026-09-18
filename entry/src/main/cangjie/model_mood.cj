package ohos_app_cangjie_entry

// 心情五档（对齐参考实机定名：气愤/伤心/好奇/开心/超开心）。

enum Mood {
    | Angry
    | Sad
    | Curious
    | Happy
    | Ecstatic

    func label(): String {
        match (this) {
            case Angry => "气愤"
            case Sad => "伤心"
            case Curious => "好奇"
            case Happy => "开心"
            case Ecstatic => "超开心"
        }
    }

    // 通用海洋表情徽章的底色（潮水色系）。
    func tint(): UInt32 {
        match (this) {
            case Angry => 0xFFE25A4E
            case Sad => 0xFF6C8BA4
            case Curious => 0xFF8A79C9
            case Happy => 0xFFEEA83A
            case Ecstatic => 0xFFEF8A44
        }
    }

    // 徽章上小鱼干方向角（绘图参数）。
    func faceAngle(): Float64 {
        match (this) {
            case Angry => -0.18
            case Sad => 0.22
            case Curious => -0.06
            case Happy => 0.0
            case Ecstatic => 0.0
        }
    }

    static func tryParse(name: ?String): ?Mood {
        match (name) {
            case Some(n) =>
                match (n) {
                    case "angry" => Some(Angry)
                    case "sad" => Some(Sad)
                    case "curious" => Some(Curious)
                    case "happy" => Some(Happy)
                    case "ecstatic" => Some(Ecstatic)
                    case _ => None<Mood>
                }
            case None => None<Mood>
        }
    }

    func toKey(): String {
        match (this) {
            case Angry => "angry"
            case Sad => "sad"
            case Curious => "curious"
            case Happy => "happy"
            case Ecstatic => "ecstatic"
        }
    }
}
