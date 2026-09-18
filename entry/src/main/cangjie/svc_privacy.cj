package ohos_app_cangjie_entry

import std.collection.ArrayList

// 首启隐私政策同意状态（版本化：政策实质变更升版本，旧同意作废）。

class PrivacyConsent {
    static let instance = PrivacyConsent()

    var agreed: Bool = false

    private var listeners: ArrayList<() -> Unit> = ArrayList<() -> Unit>()

    func addListener(f: () -> Unit): Unit {
        listeners.add(f)
    }

    func notifyAll(): Unit {
        for (f in listeners) {
            f()
        }
    }

    // 启动时（首帧前）读回，避免 gate 闪现。
    func load(): Unit {
        let store = CardStore()
        store.ensure()
        agreed = store.loadPrivacyAgreed()
    }

    func agree(): Unit {
        agreed = true
        let store = CardStore()
        store.ensure()
        store.savePrivacyAgreed()
        notifyAll()
    }
}
