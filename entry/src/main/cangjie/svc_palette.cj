package ohos_app_cangjie_entry

// 语义色板。
// 只描述「应用外壳」——页面背景、卡片、墨色文字、品牌强调色。
// 拟物纸面（EditablePaper / StyleCard）是成品卡管线，颜色取自 AnimalSpec，不随主题变化。
// 仓颉端首版固定亮色板（结构与参考端一一对应，后续可挂暗色）。

class Pal {
    let paper: UInt32
    let paperSunken: UInt32
    let card: UInt32
    let cardAlt: UInt32
    let sunken: UInt32
    let line: UInt32
    let ink: UInt32
    let inkMid: UInt32
    let inkSoft: UInt32
    let inkFaint: UInt32
    let sea: UInt32
    let seaInk: UInt32
    let seaDeep: UInt32
    let header: UInt32
    let headerCard: UInt32
    let headerChip: UInt32
    let headerPanel: UInt32
    let bubble: UInt32
    let amber: UInt32
    let sunTint: UInt32
    let coral: UInt32
    let coralSoft: UInt32
    let woodTop: UInt32
    let woodBottom: UInt32

    init(paper!: UInt32, paperSunken!: UInt32, card!: UInt32, cardAlt!: UInt32,
        sunken!: UInt32, line!: UInt32, ink!: UInt32, inkMid!: UInt32, inkSoft!: UInt32,
        inkFaint!: UInt32, sea!: UInt32, seaInk!: UInt32, seaDeep!: UInt32,
        header!: UInt32, headerCard!: UInt32, headerChip!: UInt32, headerPanel!: UInt32,
        bubble!: UInt32, amber!: UInt32, sunTint!: UInt32, coral!: UInt32,
        coralSoft!: UInt32, woodTop!: UInt32, woodBottom!: UInt32) {
        this.paper = paper
        this.paperSunken = paperSunken
        this.card = card
        this.cardAlt = cardAlt
        this.sunken = sunken
        this.line = line
        this.ink = ink
        this.inkMid = inkMid
        this.inkSoft = inkSoft
        this.inkFaint = inkFaint
        this.sea = sea
        this.seaInk = seaInk
        this.seaDeep = seaDeep
        this.header = header
        this.headerCard = headerCard
        this.headerChip = headerChip
        this.headerPanel = headerPanel
        this.bubble = bubble
        this.amber = amber
        this.sunTint = sunTint
        this.coral = coral
        this.coralSoft = coralSoft
        this.woodTop = woodTop
        this.woodBottom = woodBottom
    }
}

let pal = Pal(
    paper: 0xFFFBF6EC,
    paperSunken: 0xFFF3EDE0,
    card: 0xFFFFFDF6,
    cardAlt: 0xFFFFFFFF,
    sunken: 0xFFEFEBE9,
    line: 0xFFD7CCC8,
    ink: 0xFF4E342E,
    inkMid: 0xFF5D4037,
    inkSoft: 0xFF795548,
    inkFaint: 0xFFA1887F,
    sea: 0xFF3E6B5A,
    seaInk: 0xFF3E6B5A,
    seaDeep: 0xFF2F5247,
    header: 0xFFFFD35C,
    headerCard: 0xFFFFFFFF,
    headerChip: 0xB8FFFFFF,
    headerPanel: 0x8CFFFFFF,
    bubble: 0xFFFFF6DF,
    amber: 0xFFF2B33D,
    sunTint: 0x73FFD35C,
    coral: 0xFFE25A4E,
    coralSoft: 0xFFFFD9C9,
    woodTop: 0xFFB98B5E,
    woodBottom: 0xFF9C6F44,
)
