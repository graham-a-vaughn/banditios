//
//  UIView+Bandit.swift
//  Time Bandit
//
//  Created by Graham Vaughn on 1/15/18.
//  Copyright © 2018 Graham Vaughn. All rights reserved.
//

import UIKit

extension UIView {
    /// Per NSHipster, make corner radius easily settable in IB
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    /// expose layer.borderColor as a setttable property in IB
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    /// expose layer.borderWidth as a settable property in IB
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /*
     Find the first subview of this view with the given class name, or nil if no such
     subview exists. it's a depth-first search. This searches the full subview
     hierarchy (not just immediate child subviews)
     
     This method should primarily be used for finding apple private framework views, whose
     classnames we cannot access directly. otherwise, it's more type-safe to call
     findSubviewMatching, passing a predicate of the form { $0 is <ClassName> }
     
     :param: viewClass find subviews with this class name. Note, for swift classes
     this needs to be the fully-qualified name including module prefix.
     :returns: the first subview of this with given class name, or nil if no subview
     with that class name exists
     */
    /*
    func findSubviewWithClass(_ viewClass: String) -> UIView? {
        return self.findSubviewMatching { $0.isKind(of: NSClassFromString(viewClass)!) }
    }
    
    func findSubviewsWithClass(_ viewClass: String) -> [UIView] {
        return self.findSubviewsMatching { $0.isKind(of: NSClassFromString(viewClass)!) }
    }
    
    /// Find the view in the view subtree rooted at this view which is the current first responder, if any.
    func findFirstResponder() -> UIView? {
        return findSubviewMatching { $0.isFirstResponder }
    }
    
    /*
     Find the first subview of this view matching given predicate, or nil if no such
     subview exists. it's a depth-first search. This searches the full subview
     hierarchy (not just immediate child subviews)
     
     :param: predicate a closure evaluated for each subview to see if matches
     :returns: the first subview of this for which the predicate returns true, or nil if no subview
     matches
     */
    func findSubviewMatching(_ predicate: (UIView) -> Bool) -> UIView? {
        if predicate(self) {
            return self
        }
        
        for subView in self.subviews {
            if let matchingSubview = subView.findSubviewMatching(predicate) {
                return matchingSubview
            }
        }
        
        return nil
    }
    
    /*
     Finds all subviews of this view that are of the given class. This searches the full subview
     hierarchy (not just immediate child subviews)
     
     :param: viewClass find subviews that are of this type.
     :returns: an array of all subviews of this of the given type. if no matches, an empty
     array is returned.
     */
    func findSubviewsWithType<T: UIView>(_ viewClass: T.Type) -> [UIView] {
        return self.findSubviewsMatching {
            return $0 is T
        }
    }
    
    func pinToView(_ view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    /*
     Finds all subviews of this view matching given predicate. This searches the full subview
     hierarchy (not just immediate child subviews)
     
     :param: predicate a closure evaluated for each subview to see if matches
     :returns: an array of all subviews of this for which the predicate returns true.
     if no matches, an empty array is returned.
     */
    func findSubviewsMatching(_ predicate: (UIView) -> Bool) -> [UIView] {
        let matchingSubviews = self.subviews.flatMap { ($0 ).findSubviewsMatching(predicate)}
        var matches = predicate(self) ? [self] : []
        matches.append(contentsOf: matchingSubviews)
        return matches
    }
    
    /*
     Find the first ancestor superview of this view with the given class name, or nil if no such
     superview exists. This searches the full superview
     hierarchy (not just immediate superview), starting from this view and going up
     
     This method should primarily be used for finding apple private framework views, whose
     classnames we cannot access directly. otherwise, it's more type-safe to call
     findSubviewMatching, passing a predicate of the form { $0 is <ClassName> }
     
     :param: viewClass find superview with this class name. Note, for swift classes
     this needs to be the fully-qualified name including module prefix.
     :returns: the most immediate superview of this with given class name, or nil if no superview
     with that class name exists
     */
    func findSuperviewWithType(_ viewClass: String) -> UIView? {
        return self.findSuperviewMatching { $0.isKind(of: NSClassFromString(viewClass)!) }
    }
    
    /*
     Find the first ancestor superview of this view with the given tag, or nil if no such
     superview exists. This searches the full superview
     hierarchy (not just immediate superview), starting from this view and going up
     
     :param: tag find superview with this tag
     :returns: the most immediate superview of this with given class name, or nil if no superview
     with that tag exists
     */
    func findSuperviewWithTag(_ tag: Int) -> UIView? {
        return self.findSuperviewMatching { $0.tag == tag }
    }
    
    /*
     Find the first ancestor superview of this view matching given predicate, or nil if no such
     superview exists. This searches the full superview
     hierarchy (not just immediate superview), starting from this view and going up
     
     :param: predicate a closure evaluated for each subview to see if matches
     :returns: the most immediate superview of this for which the predicate returns true,
     or nil if no superview matches
     */
    func findSuperviewMatching(_ predicate: (UIView) -> Bool) -> UIView? {
        if predicate(self) {
            return self
        }
        
        if let superview = self.superview {
            return superview.findSuperviewMatching(predicate)
        }
        
        return nil
    }
    
    /// changes a view's anchor point to the given anchor point and then
    /// updates the position so that the view stays in place
    func setAnchorPoint(_ anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x,
                               y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x,
                               y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position = self.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
    
    /**
     Searches for a child of this view that is a UITextField and makes it first responder.  Implemented as a gesture recognizer selector so you can attach a tap gesture recognizer on a containing view in a storyboard and connect its selector property to this method of the target view.
     
     - parameter recognizer: The UIGestureRecognizer that is handling this gesture.
     */
    @IBAction private func makeTextFieldChildFirstResponder (_ recognizer: UIGestureRecognizer) {
        if let textField = self.findSubviewMatching({ $0 is UITextField }) {
            textField.becomeFirstResponder()
        }
    }
    
    /**
     hides this view and shows a different one with optional animation
     
     - parameter otherView: the view to show
     - parameter animated: whether to animate the transition
     */
    func transitionToView(_ otherView: UIView, animated: Bool) {
        let animateDuration = animated ? 0.5 : 0
        self.alpha = 1.0
        self.isHidden = false
        otherView.alpha = 0.0
        otherView.isHidden = false
        UIView.animate(withDuration: animateDuration,
                       animations: {
                        self.alpha = 0.0
                        otherView.alpha = 1.0
        }, completion: { finished in
            if finished {
                self.isHidden = true
                otherView.isHidden = false
            }
        })
    }
    
    /**
     hides one view and shows another with optional animation
     
     - parameter view1: the first view
     - parameter view2: the second view
     - parameter firstToSecond: if true, transition from view1 to view2. If false, transition from view2 to view1
     - parameter animated: whether to animate the transition
     */
    class func transitionBetweenViews(view1: UIView, view2: UIView, firstToSecond: Bool, animated: Bool) {
        let v1 = firstToSecond ? view1 : view2
        let v2 = firstToSecond ? view2 : view1
        v1.transitionToView(v2, animated: animated)
    }
    
    /**
     Returns the scale factor of this view's coordinate system to the window's. This is the same
     as calling UIView.convertRect(fromView:) with a nil "fromView" argument and comparing the
     scaled vs. original sizes.
     
     :return: A scaling factor. On iPad at baseline zoom, this will be ≈ 1.0. On a smaller device like
     an iPhone at baseline zoom, this will be > 1.0.
     */
    func viewToWindowScalingFactor() -> CGFloat {
        let baseRect = CGRect (x: 0.0, y: 0.0, width: 1000, height: 1000)
        let scaledRect = convert (baseRect, from: nil)
        return scaledRect.width / baseRect.width
    }
    
    /**
     Shorthand for seeing if a views size class is compact
     */
    var isCompact: Bool {
        return self.traitCollection.isCompact()
    }
    
    /// The inverse of isHidden, since sometimes logic is more easily readable this way.
    var isVisible: Bool {
        get {
            return !isHidden
        }
        set {
            isHidden = !newValue
        }
    }
    
    /**
     Retrieves the named constraint, if it is found within this view's constraints array.
     If there are multiple constraints with this identifier, returns the first.
     */
    func constraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
        return constraints.filter({$0.identifier == identifier}).first
    }
    
    /// creates constraints in the superview that make this view the same size as its superview
    func autolayoutPinToSuperview() {
        guard let superview = self.superview else { fatalError("autolayoutPinToSuperview() called without superview") }
        superview.addConstraints([
            left(self) |==| left(superview),
            right(self) |==| right(superview),
            top(self) |==| top(superview),
            bottom(self) |==| bottom(superview)
            ])
    }
    
    /**
     If duration parameter is non-nil, animate the changes in the given closure.
     if duration is nil, perform the changes immediately without animation.
     - parameter duration: duration for animation of the changes, or nil to make the changes without animation
     - parameter animations: closure which will make the changes, same as would be passed to the UIView.animate* functions
     */
    class func maybeAnimate(withDuration duration: TimeInterval?, animations: @escaping () -> Void) {
        if let duration = duration {
            UIView.animate(withDuration: duration, animations: animations)
        } else {
            animations()
        }
    }
    
    /// removes all subviews by calling .removeFromSuperview()
    func removeAllSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    /// returns all instances of MBProgressHUD that are direct subviews of self
    func allProgressHUDs() -> [MBProgressHUD] {
        return subviews.filterMap() { $0 as? MBProgressHUD }
    }
    
    /// Display an MBProgressHUD with a custom title and a checkmark image
    /// - parameter title: Title displayed in the HUD
    /// - parameter details: Message displayed beneath the title
    /// - parameter hideDelay: Delay after which the HUD will be hidden, defaults to 1 second
    /// - parameter onCompletion: Code block to be executed when the HUD is hidden
    func showSuccessHUD(title: String, details: String? = nil, hideDelay: TimeInterval = 1.0,
                        onCompletion: @escaping () -> Void = {}) {
        // default to displaying the HUD in the center of the window
        let hud = MBProgressHUD(view: self)
        self.addSubview(hud)
        hud.label.text = title
        if let theDetails = details {
            hud.detailsLabel.text = theDetails
        }
        hud.mode = .customView
        hud.customView = UIImageView(image: UIImage(named:"37x-Checkmark.png"))
        hud.show(animated: true)
        
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: hideDelay)
        hud.completionBlock = onCompletion
    }
    
    // Creates a springy zooming animation effect
    func zoomAnimate() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        },
            completion: { completed in
                UIView.animate(
                    withDuration: 0.7,
                    delay: 0,
                    usingSpringWithDamping: 0.2,
                    initialSpringVelocity: 0.0,
                    options: .allowUserInteraction,
                    animations: {
                        self.transform = .identity
                },
                    completion: nil)
        })
    }
    
    func hideSelf(animated: Bool = true) {
        UIView.maybeAnimate(withDuration: animated ? 0.3 : nil) {
            self.alpha = 0.0
        }
    }
    
    func showSelf(animated: Bool = true) {
        UIView.maybeAnimate(withDuration: animated ? 0.3 : nil) {
            self.alpha = 1.0
        }
    }
 */
}
