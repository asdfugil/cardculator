import Orion
import CardculatorC

import SwiftUI
import os

var calculatorWindow: CalculatorWindow!
var listener: CardculatorListener?
var closeCCCallback: () -> Void = {}


class CardculatorListener: NSObject /*, LAListener*/ {
//    let listenerId = "ovh.exerhythm.cardculator"

//    func activator(_ activator: LAActivator?, receive event: LAEvent?) {
//        guard PreferenceManager.shared.settings.enabled.boolValue else { return }
//        event?.isHandled = true
//        presentCalculator()
//    }

    @objc func presentCalculator() {
        if calculatorWindow.vc.calculatorViewShown() {
            calculatorWindow.vc.hideCalculatorView()
        } else {
            calculatorWindow.vc.showCalculatorView()
        }
    }

    @objc func ccButtonTapped() {
        presentCalculator()
        closeCCCallback()
    }

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(ccButtonTapped), name: .init("CCPresentCalculator"), object: nil)
//        let lashared = LAActivator.sharedInstance()
//        if !lashared!.hasSeenListener(withName: listenerId) {
//            lashared?.assign(LAEvent.event(withName: "libactivator.slide-in.bottom-right") as? LAEvent, toListenerWithName: listenerId)
//        }
//        lashared!.register(self, forName: listenerId)
    }
}

class SpringBoardHook: ClassHook<SpringBoard> {
    func applicationDidFinishLaunching(_ application : AnyObject) {
        orig.applicationDidFinishLaunching(application)
        
        do {
            try PreferenceManager.shared.loadSettings()
        } catch {
            remLog(error.localizedDescription)
        }
        remLog("loaded")

        calculatorWindow = CalculatorWindow(frame: UIScreen.main.bounds)
        
        listener = CardculatorListener()
        
        
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = "net.sourceloc.cardculator.prefs/Update" as CFString
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

        CFNotificationCenterAddObserver(center, observer, { center, observer, name, object, userInfo in
            remLog("relo")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                reloadSettings()
            })
        }, name, nil, .deliverImmediately)
    }
}


func reloadSettings() {
    remLog("ReloadSettings 2")
    do {
        try PreferenceManager.shared.loadSettings()
    } catch {
        remLog("Failed to load settings: \(error.localizedDescription)")
    }
}


class CCUIModularControlCenterOverlayViewControllerHook: ClassHook<CCUIModularControlCenterOverlayViewController> {
    // orion: new
    @objc func cardculator_hideCC() {
        target.dismiss(animated: true, withCompletionHandler: nil)
    }

    func viewDidLoad() {
        orig.viewDidLoad()
        closeCCCallback = cardculator_hideCC
    }
}



struct Cardculator: Tweak {
    init() {
        remLog("wut")
    }
}
