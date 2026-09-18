package ohos_app_cangjie_entry

import std.collection.HashSet

// 海洋驻园排版师：每种动物 = 一套拟物模板 + 人设。
// 首波五位 + wave2 五位 + wave3 四位，全部 14 位。
// 仅中文版：species/name/title/motto 直接以中文常量内联。

enum CardStyle {
    | Washi
    | Bookish
    | Nordic
    | Letterpress
    | Doodle
    | Poster
    | Glow
    | Tag
    | Grid
    | Chart
    | Postcard
    | Sonar
    | Telegram
    | Chalk
}

class AnimalSpec {
    let id: String
    let species: String
    let name: String
    let title: String
    let motto: String
    let style: CardStyle
    let fontFamily: String
    let bg: UInt32
    let ink: UInt32
    let accent: UInt32
    let seal: UInt32

    init(id!: String, species!: String, name!: String, title!: String, motto!: String,
        style!: CardStyle, fontFamily!: String, bg!: UInt32, ink!: UInt32,
        accent!: UInt32, seal!: UInt32) {
        this.id = id
        this.species = species
        this.name = name
        this.title = title
        this.motto = motto
        this.style = style
        this.fontFamily = fontFamily
        this.bg = bg
        this.ink = ink
        this.accent = accent
        this.seal = seal
    }

    static let all: Array<AnimalSpec> = [
        AnimalSpec(id: "otter", species: "海獭", name: "阿浮",
            title: "漂流手帖排版师",
            motto: "「仰在水面上，用小石头把字一颗颗敲开。」",
            style: Washi, fontFamily: "LXGWenKai",
            bg: 0xFFFAF5EA, ink: 0xFF4A3B2A, accent: 0xFFB4543E, seal: 0xFFB4543E),
        AnimalSpec(id: "octo", species: "章鱼", name: "墨教授",
            title: "深海藏书排版师",
            motto: "「八只手，一次也只认真排一版。」",
            style: Bookish, fontFamily: "NotoSerifSC",
            bg: 0xFFF6EFDC, ink: 0xFF2F3A2F, accent: 0xFF3E6B5A, seal: 0xFF3E6B5A),
        AnimalSpec(id: "penguin", species: "企鹅", name: "波波",
            title: "冰原极简排版师",
            motto: "「删掉的东西越多，留下来的越重要。」",
            style: Nordic, fontFamily: "system",
            bg: 0xFFFFFFFF, ink: 0xFF33424E, accent: 0xFF7FA8C9, seal: 0xFF33424E),
        AnimalSpec(id: "turtle", species: "海龟", name: "老墨先生",
            title: "铅字潮痕排版师",
            motto: "「游得慢，才看得清每一个字。」",
            style: Letterpress, fontFamily: "NotoSerifSC",
            bg: 0xFFEFE3C8, ink: 0xFF503A24, accent: 0xFF8A6B41, seal: 0xFF6B4F2E),
        AnimalSpec(id: "bubble", species: "河豚", name: "泡泡",
            title: "气泡涂鸦排版师",
            motto: "「气鼓鼓的时候，就想写很大的字。」",
            style: Doodle, fontFamily: "LXGWenKai",
            bg: 0xFFFFE9AE, ink: 0xFF5C4318, accent: 0xFFE8833A, seal: 0xFFD9622B),
        AnimalSpec(id: "whale", species: "座头鲸", name: "长风",
            title: "深海大字排版师",
            motto: "「心里有长风，字就要写得大。」",
            style: Poster, fontFamily: "NotoSerifSC",
            bg: 0xFF16324A, ink: 0xFFEDF4F1, accent: 0xFFD9B36C, seal: 0xFF7A94A6),
        AnimalSpec(id: "jelly", species: "灯塔水母", name: "夜光",
            title: "荧光诗签排版师",
            motto: "「返老还童过很多次，最不怕的就是重来。」",
            style: Glow, fontFamily: "LXGWenKai",
            bg: 0xFF0D1B2A, ink: 0xFFDFF6F8, accent: 0xFF82D9E3, seal: 0xFF82D9E3),
        AnimalSpec(id: "hermit", species: "寄居蟹", name: "小安",
            title: "换壳标签排版师（季节限定）",
            motto: "「壳是季节的，字是自己的。」",
            style: Tag, fontFamily: "system",
            bg: 0xFFF1E4C8, ink: 0xFF4A3A26, accent: 0xFFD96A3B, seal: 0xFFB8552D),
        AnimalSpec(id: "crab", species: "招潮蟹", name: "阿横",
            title: "方格稿纸排版师",
            motto: "「横着走，也一格一格走直。」",
            style: Grid, fontFamily: "LXGWenKai",
            bg: 0xFFEFF2EA, ink: 0xFF2E332E, accent: 0xFFC65F45, seal: 0xFFC65F45),
        AnimalSpec(id: "nautilus", species: "鹦鹉螺", name: "老罗",
            title: "航海图志排版师",
            motto: "「五亿年的老航海，最见不得歪字。」",
            style: Chart, fontFamily: "NotoSerifSC",
            bg: 0xFFECE8D8, ink: 0xFF2F3E3C, accent: 0xFF3D7085, seal: 0xFF8C6D3F),
        AnimalSpec(id: "albatross", species: "信天翁", name: "航邮",
            title: "海运明信片排版师",
            motto: "「飞得越远，越想念近处的字。」",
            style: Postcard, fontFamily: "LXGWenKai",
            bg: 0xFFBFD9D6, ink: 0xFF27404A, accent: 0xFFC0392B, seal: 0xFFC0392B),
        AnimalSpec(id: "angler", species: "鮟鱇", name: "提灯",
            title: "声呐深潜排版师",
            motto: "「深黑的地方，更需要一行亮着的字。」",
            style: Sonar, fontFamily: "system",
            bg: 0xFF123524, ink: 0xFFB8F5C9, accent: 0xFFE8FBEF, seal: 0xFF58C97C),
        AnimalSpec(id: "ray", species: "电鳐", name: "伏特",
            title: "电报纸带排版师",
            motto: "「有电的话，就用电报说。」",
            style: Telegram, fontFamily: "NotoSerifSC",
            bg: 0xFFEDF2F0, ink: 0xFF2F3E3C, accent: 0xFF2E6F8E, seal: 0xFF2E6F8E),
        AnimalSpec(id: "gull", species: "海鸥", name: "粉笔姐",
            title: "港口黑板排版师",
            motto: "「今天海况如何，写黑板上的才算数。」",
            style: Chalk, fontFamily: "LXGWenKai",
            bg: 0xFF22332B, ink: 0xFFF2F0E4, accent: 0xFFE8D48B, seal: 0xFFE8D48B),
    ]

    static let baseIds: HashSet<String> = HashSet<String>(["otter", "octo", "penguin", "turtle", "bubble"])

    static func byId(id: String): AnimalSpec {
        for (a in all) {
            if (a.id == id) {
                return a
            }
        }
        return all[0]
    }
}
