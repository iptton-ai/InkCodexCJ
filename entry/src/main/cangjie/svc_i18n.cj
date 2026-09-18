package ohos_app_cangjie_entry

// 中文文案常量（参考端 i18n 的 zh 母本，仓颉端仅中文）。
// 命名与参考端 AppLocalizations key 对齐，方便后续扩回多语言。

class T {
    T() {}

    static let appTitle = "InkCodex 墨鱼集"

    // 通用
    static let doneBtn = "好了"
    static let cancel = "再想想"
    static let confirm = "确定"
    static let deleteBtn = "删除"
    static let keepWriting = "继续写"
    static let discard = "丢掉"
    static let backToShore = "回海岸"
    static let exit = "退出"

    static func dateFull(y: Int64, m: Int64, d: Int64): String {
        "${y}年${m}月${d}日"
    }
    static func moodLine(v: String): String {
        "心情：${v}"
    }

    // 首页
    static let homeTitle = "漂流海岸"
    static func headerSubStreak(n: Int64): String {
        "${n} · 已连投 ${n} 天"
    }
    static let remindBannerPlain = "今天还没投瓶，去写一张吧"
    static func remindBannerStreak(n: Int64): String {
        "已连投 ${n} 天，别断了潮汐"
    }
    static func noBottleSnack(d: String): String {
        "${d} 的海面没有瓶子"
    }
    static let emptyTitle = "海面还很安静"
    static let emptyHint = "写下一张手帖，扔进海里漂流"
    static let dockGestureHint = "上拉或点亮灯塔去码头"
    static let dockTooltip = "去码头"
    static let fabLabel = "投一瓶"

    // 码头
    static let dockTitle = "码头 · 深海排版局"
    static let ticketBox = "漂流瓶箱子"
    static let ticketMonthly = "潮汐月刊"
    static let ticketDex = "居民图鉴"
    static func bottlesOnShelf(n: Int64): String {
        "架上 ${n} 只瓶"
    }
    static func monthlyProgress(n: Int64): String {
        "本月 ${n}/8 篇 · 满页装订"
    }
    static func dexUnlocked(x: Int64, y: Int64): String {
        "已解锁 ${x}/${y}"
    }

    // 习惯（投喂）
    static let habitSheetTitle = "每日投喂"
    static let habitSheetHint = "建一个想天天投喂的小习惯"
    static let habitNameHint = "习惯名（如：每日运动）"
    static func habitRow(name: String, s: Int64): String {
        "${name} · 连投 ${s} 天"
    }
    static func habitTarget(t: Int64): String {
        "目标 ${t} 天"
    }
    static let habitAddBtn = "放进海里"
    static let habitDone = "今日已投喂"
    static let habitAlready = "今天投喂过了"
    static func habitStatLine(a: Int64, b: Int64, total: Int64): String {
        "${a}/${b} 天 · 累计 ${total}"
    }

    // 编辑器
    static let writeHint = "写点什么吧…"
    static let keepWritingHint = "继续书写…"
    static let markMoodChip = "标记心情"
    static let markMoodInline = "＋ 点这里标记心情"
    static let moodInviteTitle = "从标记此刻的心情开始吧"
    static let moodInviteHint = "心情会以手写体印在纸面首行"
    static let moodSheetHint = "心情会以手写体印在纸面首行"
    static let discardTitle = "丢掉这张？"
    static let discardBody = "还没收进海里，离开就找不回来了"
    static let needText = "先写点什么吧"
    static let cardSaved = "已收进漂流海岸"
    static let cardUpdated = "这张卡已换新"
    static let doneSheetTitle = "已入海漂流"
    static let doneSheetHint = "它会在海岸上等你，也可以去码头看看"
    static let shareBtn = "分享"
    static let switchDesigner = "换排版师"
    static let fontSmall = "小字"
    static let fontStd = "标准"
    static let fontLarge = "大字"
    static let stickerShopTitle = "海洋贴纸铺"
    static let stickerShopHint = "点一枚贴上卡面"
    static func removeStickers(n: Int64): String {
        "揭掉全部（${n}）"
    }
    static let coachMood = "先选一枚心情章"
    static let coachAnimal = "点下面的动物，换一种纸"
    static let coachDone = "写完点「好了」收进海里"
    static let renderFailed = "渲染失败，再试一次"
    static let toolSticker = "贴纸"
    static let toolFont = "字号"
    static let toolAlign = "对齐"
    static let toolMood = "心情"
    static let toolSignature = "签名"
    static let signatureHint = "署名（12 字内）"

    // 收集册
    static let shoreLabel = "漂流瓶海岸"
    static let tabTimeline = "时间线"
    static let tabShelfBox = "按角色箱"
    static let shelfEmptyTitle = "架上还空着"
    static let shelfEmptyHint = "写好的瓶子会按角色摆上架"
    static let emptyBottle = "空瓶"
    static func bottleCount(n: Int64): String {
        "${n} 只"
    }
    static let writeFirstCard = "还没收到它的瓶子"
    static let openThisShore = "点开这格看看"

    // 详情
    static let menuEdit = "编辑"
    static let menuShare = "分享"
    static let menuPin = "置顶"
    static let menuUnpin = "取消置顶"
    static let menuLock = "上锁"
    static let menuUnlock = "解锁"
    static let menuDelete = "删除"
    static let cardLocked = "这张卡上了锁"
    static let peek = "看一眼"
    static let deleteTitle = "删掉这张？"
    static let deleteBody = "瓶子会被海浪收回，找不回来了"
    static let lockedToast = "已上锁"
    static let unlockedToast = "已解锁"
    static let entryGone = "这只瓶子已不在海岸上"
    static let shareThisCard = "分享这张卡"
    static func shareFrom(n: String): String {
        "来自「${n}」的手帖"
    }

    // 邮局
    static let postTitle = "深海邮局 POST OFFICE"
    static let signLocal = "深 海 邮 局"
    static let moreMessengers = "更多海洋信使洄游中…"
    static let welcomeTitle = "阿浮的第一只漂流瓶"
    static let welcomeBody = "嘿！我是阿浮，深海排版局的海獭排版师。\n这是你的第一只漂流瓶——海浪刚把它推上岸呢，瓶子里是我手写的一行字：\n欢迎上岛！从今天起，把想写的话交给我。我仰在水面上，用小石头把每一个字都敲得漂漂亮亮。\n潮汐月刊和更多海洋居民，也都在来的路上啦。"
    static func mailFrom(sp: String, n: String): String {
        "来自${sp}「${n}」的信"
    }

    // 月刊
    static let monthlyTitle = "潮汐月刊"
    static let noMonths = "还没有可装订的月份"
    static func monthTile(y: Int64, m: Int64): String {
        "潮汐月刊 · ${y}年${m}月"
    }
    static func monthBookTitle(y: Int64, m: Int64): String {
        "${y}年${m}月 · 潮汐月刊"
    }
    static let monthReportTitle = "本月潮汐报告"
    static let shareLongTip = "分享长图"
    static let saveAlbumTip = "存入相册"
    static let savedAlbum = "已存入相册"
    static let albumNoSupport = "当前平台不支持存相册"
    static let brandMotto = "深海排版局 · 每个字，都值得被海浪排好。"
    static let monthlyReady = "本月已达标，月初装订"
    static func monthUnlockedHint(n: Int64): String {
        "${n} 篇 · 点开翻阅本月潮汐"
    }
    static func monthCurrentHint(n: Int64): String {
        "本月 ${n}/8 篇 · 月初自动装订上月的本子"
    }
    static func monthLockedHint(n: Int64): String {
        "该月仅 ${n} 篇，未满 8 篇不装订"
    }

    // 图鉴
    static let dexTitle = "海洋居民图鉴"
    static let moreResidents = "更多海洋居民洄游中…"
    static let newResident = "新居民已入驻"
    static let autumnShellName = "秋壳 · 小安"
    static let autumnShellHint = "秋壳未洄游 · 敬请期待"
    static let unlockFirstCard = "完成第一张卡片解锁"
    static let unlockFeed7 = "连续投喂 7 天解锁"
    static let unlockChars400 = "累计写满 400 字解锁（一页稿纸的格数）"
    static let unlockBottles30 = "累计投瓶 30 只解锁（老水手资格）"
    static let unlockFirstMail = "收到第一封来信解锁"
    static let unlockNights3 = "单月写满 3 张夜卡（22 点后）解锁"
    static let unlockDays15 = "累计 15 个不同日子有记录解锁"
    static let unlockMorning3 = "连续 3 天清晨（6–9 点）记录解锁"
    static let dexBaseHint = "驻园排版师"
    static let dexHermitHint = "季节限定 · 随潮汐洄游而来"
    static func dexJellyProgress(n: Int64): String {
        "${n}/7 天"
    }
    static func dexCrabProgress(n: Int64): String {
        "${n} / 400 字"
    }
    static func dexNautilusProgress(n: Int64): String {
        "${n} / 30 瓶"
    }
    static func dexAnglerProgress(n: Int64): String {
        "${n} / 3 夜卡"
    }
    static func dexRayProgress(n: Int64): String {
        "${n} / 15 天"
    }
    static func dexGullProgress(n: Int64): String {
        "${n} / 3 天"
    }

    // 搜索 / 统计
    static let searchHint = "搜索写过的字…"
    static let searchEmpty = "海上没有漂着这样的字"
    static let statsTitle = "投喂统计"
    static let totalBottles = "漂流瓶总数"
    static let writeStreakLabel = "已连续投瓶（天）"
    static let bestHabitStreakLabel = "最佳习惯连投（天）"
    static let recent14 = "近 14 天 · 漂流条"
    static let moodTideAll = "心情潮位分布 · 全部记录"
    static let habitProgressTitle = "每日投喂 · 习惯完成度"
    static let remindTitle = "断签提醒"
    static func remindOn(h: Int64): String {
        "过了 ${h} 点还没投瓶，回到首页会提醒你"
    }
    static let remindOff = "已关闭"
    static func remindHourLabel(h: Int64): String {
        "提醒时刻 ${h}:00"
    }
    static let noMoodData = "还没有心情数据"

    // 日历
    static func calendarTitle(y: Int64, m: Int64): String {
        "${y} 年 ${m} 月 · 潮汐月历"
    }
    static let weekDays: Array<String> = ["日", "一", "二", "三", "四", "五", "六"]

    // 稿纸 / 页脚
    static let gridHeaderName = "姓名"
    static let gridHeaderDate = "日期"
    static func gridCountFooter(n: Int64, date: String): String {
        "本页共 ${n} 字 · ${date}"
    }
    static func doodleFooter(name: String, date: String): String {
        "${name} 画于${date}"
    }
    static let seaPost = "SEA POST · 海运"
    static let depthLabel = "DEPTH"
    static let tideHigh = "潮"
    static let tideLow = "汐"

    // 隐私 / 锁
    static let privacyTitle = "隐私政策"
    static let privacyGateTitle = "隐私政策提示"
    static let privacyGateBody = "欢迎使用深海排版局 InkCodex！本应用完全离线：不收集、不上传、不共享你的任何个人数据，你写下的内容仅保存在你自己的设备上。首次使用前，请阅读并同意以下政策。"
    static let privacyGateLink = "查看《隐私政策》全文"
    static let privacyGateAgree = "同意并继续"
    static let privacyGateDecline = "不同意"
    static let privacyDeclineTitle = "不同意并退出？"
    static let privacyDeclineBody = "未同意隐私政策将无法使用本应用。确定要退出吗？"
    static let privacyOnlineLabel = "线上版本（与应用内全文一致）："
    static let privacyPolicyVersion = "政策版本 2026-08-28"
    static let lockTitle = "深海排版局已上锁"
    static let pinHint = "输入 4 位密码"
    static let pinWrong = "PIN 不对，海浪把你挡在门外啦"
    static let pinDigitsHint = "4 位数字"
    static let enterBtn = "入海"
    static let pinOffTitle = "关闭应用密码锁？"
    static let pinOffBody = "关闭后任何人都可打开墨鱼集"
    static let pinOff = "关闭"
    static let pinSetTitle = "设置 4 位密码锁"
    static let pinSetUp = "上锁"
}
