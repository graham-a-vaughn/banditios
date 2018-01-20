//  Copyright © 2016 Rev.com, Inc. All rights reserved.
//

import Foundation
import RxSwift

/// Adds DisposeBag property to all classes derived from NSObect.
/// Taken from https://github.com/RxSwiftCommunity/NSObject-Rx.
public extension NSObject {
    fileprivate struct AssociatedKeys {
        static var DisposeBag = "rx_disposeBag"
    }
    
    fileprivate func doLocked(_ closure: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        closure()
    }
    
    public var disposeBag: DisposeBag {
        get {
            var disposeBag: DisposeBag!
            doLocked {
                let lookup = objc_getAssociatedObject(self, &AssociatedKeys.DisposeBag) as? DisposeBag
                if let lookup = lookup {
                    disposeBag = lookup
                } else {
                    let newDisposeBag = DisposeBag()
                    self.disposeBag = newDisposeBag
                    disposeBag = newDisposeBag
                }
            }
            return disposeBag
        }
        
        set {
            doLocked {
                objc_setAssociatedObject(self, &AssociatedKeys.DisposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

