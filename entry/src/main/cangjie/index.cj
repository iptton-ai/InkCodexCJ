package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

// 导航参数槽（仓颉 NavPathStack param 取值不便，用全局槽简化）。
var navParam: String = ""

// 路由名常量。
const RN_EDITOR = "editor"
const RN_COLLECTION = "collection"
const RN_DETAIL = "detail"
const RN_MAILBOX = "mailbox"
const RN_MONTHLY = "monthly"
const RN_MONTHBOOK = "monthbook"
const RN_DEX = "dex"
const RN_SEARCH = "search"
const RN_STATS = "stats"
const RN_POLICY = "policy"
const RN_GALLERY = "gallery"
const RN_DOCK = "dock"

@Builder
func pageMap(name: String, param: Any) {
    if (name == RN_EDITOR) {
        EditorPage()
    } else if (name == RN_COLLECTION) {
        CollectionPage()
    } else if (name == RN_DETAIL) {
        EntryDetailPage()
    } else if (name == RN_MAILBOX) {
        MailboxPage()
    } else if (name == RN_MONTHLY) {
        MonthlyPage()
    } else if (name == RN_MONTHBOOK) {
        MonthBookPage()
    } else if (name == RN_DEX) {
        DexPage()
    } else if (name == RN_SEARCH) {
        SearchPage()
    } else if (name == RN_STATS) {
        StatsPage()
    } else if (name == RN_POLICY) {
        PrivacyPolicyPage()
    } else if (name == RN_DOCK) {
        DockSheetPage()
    } else if (name == RN_GALLERY) {
        AnimalGalleryPage()
    }
}

var fontRegistered = false

@Entry
@Component
class EntryView {
    @Provide
    var stack: NavPathStack = NavPathStack()

    @State
    var consentAgreed: Bool = true

    @State
    var pin: String = ""

    @State
    var loaded: Bool = false

    protected override func aboutToAppear() {
        globalStack = Some(this.stack)
        PrivacyConsent.instance.load()
        AppState.instance.ensureLoaded()
        this.consentAgreed = PrivacyConsent.instance.agreed
        this.pin = AppState.instance.pin
        this.loaded = true
        PrivacyConsent.instance.addListener({ =>
            this.consentAgreed = PrivacyConsent.instance.agreed
        })
        AppState.instance.addListener({ =>
            this.pin = AppState.instance.pin
        })
        this.registerFonts()
    }

    func registerFonts(): Unit {
        if (fontRegistered) {
            return
        }
        fontRegistered = true
        try {
            this.getUIContext().getFont().registerFont(
                familyName: "LXGWenKai",
                familySrc: "/resources/rawfile/fonts/LXGWWenKaiLite-Regular.ttf")
            this.getUIContext().getFont().registerFont(
                familyName: "NotoSerifSC",
                familySrc: "/resources/rawfile/fonts/NotoSerifSC-Regular.otf")
        } catch (e: Exception) {
        }
    }

    func build() {
        Navigation(this.stack) {
            if (this.loaded) {
                if (!this.consentAgreed) {
                    PrivacyGateView()
                } else if (this.pin != "") {
                    PinGateView(onPass: { =>
                        this.pin = ""
                    })
                } else {
                    HomePage()
                }
            } else {
                Column().width(100.percent).height(100.percent).backgroundColor(pal.paper)
            }
        }
        .hideTitleBar(true)
        .navDestination(bind(pageMap, this))
    }
}


// 启动闸：4 位本地 PIN。
@Component
class PinGateView {
    var onPass: () -> Unit = { => }

    @State
    var input: String = ""

    @State
    var error: Bool = false

    func build() {
        Column(space: 12) {
            Text("🔒").fontSize(34)
            Text(T.lockTitle)
                .fontSize(17).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF)
            TextInput(text: this.input, placeholder: T.pinHint)
                .maxLength(4)
                .textAlign(TextAlign.Center)
                .width(240)
                .height(46)
                .backgroundColor(0xFFEDEBDF)
                .borderRadius(14)
                .onChange({ v: String =>
                    this.input = v
                    this.error = false
                    if (v == AppState.instance.pin) {
                        this.onPass()
                    }
                })
            if (this.error) {
                Text(T.pinWrong).fontSize(12).fontColor(pal.coralSoft)
            }
            Button(T.enterBtn)
                .width(200).height(42)
                .backgroundColor(pal.header)
                .fontColor(0xFF4E342E)
                .onClick({ _ =>
                    if (this.input == AppState.instance.pin) {
                        this.onPass()
                    } else {
                        this.error = true
                        this.input = ""
                    }
                })
        }
        .width(100.percent)
        .height(100.percent)
        .backgroundColor(0xFF3E6B5A)
        .justifyContent(FlexAlign.Center)
    }
}
