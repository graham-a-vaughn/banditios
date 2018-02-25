//  Copyright (c) 2014 Rev.com, Inc. All rights reserved.
//

import UIKit

precedencegroup ConstraintMultiplicative { higherThan: ConstraintAdditive }
precedencegroup ConstraintAdditive { higherThan: ConstraintComparison }
precedencegroup ConstraintComparison { higherThan: ConstraintPriorityAssignment }
precedencegroup ConstraintPriorityAssignment { higherThan: AssignmentPrecedence }

/**
 * Use this syntax for generating auto-layout constraints with a mathematical syntax.
 * Use the attribute extractor functions (centerX, left, top etc.)
 * to select an attribute of a view to place a constraint on.
 * Use |+|, |-| to set the constant and |*| to set the multiplier of the constraint.
 * Use the inequality operators |==|, |<=| and |>=| to combine two (view, attribute) pairs
 * (or one and a constant) into an NSLayoutConstraint.
 * Use the |~| operator to set the priority of a constraint.
 *
 * Examples:
 * centerX(view1) |==| centerX(view2)
 *   the centers of view1 and view2 in the horizontal dimension will line up
 * top(view1) |==| top(view2) |-| 30
 *   the top of view1 will be 30 points below the top of view2
 * top(view1) |<=| bottom(view2) |+| 50 |~| 750
 *   the top of view1 will be at most 50 points above the bottom of view2 with priority 750
 * height(view1) |==| height(view2) |*| 2
 *   the height of view1 will be twice the height of view2
 */


infix operator |*| : ConstraintMultiplicative

// associate a (view, attribute) pair with a multiplier
// a layout constraint can specify that two attributes (of possibly different views)
// must be related to each other by a certain multiplicative factor.
// for example, `height(view1) |==| height(view2) |*| 2`
// creates a constraint that constrains view1's height be be equal to view2's height times 2
func |*| (tuple:(UIView, NSLayoutAttribute),
          m:CGFloat) -> (UIView, NSLayoutAttribute, CGFloat, CGFloat) {
    return (tuple.0, tuple.1, m, 0)
}

// associate a (view, attribute) pair with a constant
// a layout constraint can specify that two attributes (of possibly different views)
// must be related to each other by a certain additive factor.
// for example, `height(view1) |==| height(view2) |+| 50`
// creates a constraint that constrains view1's height be be equal to view2's height plus 50 points
infix operator |+| : ConstraintAdditive

func |+| (tuple:(UIView, NSLayoutAttribute),
          c:CGFloat) -> (UIView, NSLayoutAttribute, CGFloat) {
    return (tuple.0, tuple.1, c)
}

func |+| (tuple:(UIView, NSLayoutAttribute, CGFloat, CGFloat),
          c:CGFloat) -> (UIView, NSLayoutAttribute, CGFloat, CGFloat) {
    return (tuple.0, tuple.1, tuple.2, c)
}

// associate a (view, attribute) pair with a negative constant
// equivalent to using |+| with a negative constant
infix operator |-| : ConstraintAdditive

func |-| (tuple:(UIView, NSLayoutAttribute),
          c:CGFloat) -> (UIView, NSLayoutAttribute, CGFloat) {
    return (tuple.0, tuple.1, -c)
}

func |-| (tuple:(UIView, NSLayoutAttribute, CGFloat, CGFloat),
          c:CGFloat) -> (UIView, NSLayoutAttribute, CGFloat, CGFloat) {
    return (tuple.0, tuple.1, tuple.2, -c)
}

// create an NSConstraint with Equal relation
infix operator |==| : ConstraintComparison

func |==| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute, CGFloat, CGFloat)) -> NSLayoutConstraint {
    return NSLayoutConstraint(
        item: lhs.0,
        attribute: lhs.1,
        relatedBy: NSLayoutRelation.equal,
        toItem: rhs.0,
        attribute: rhs.1,
        multiplier: rhs.2,
        constant: rhs.3 )
}

func |==| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute, CGFloat)) -> NSLayoutConstraint {
    return lhs |==| (rhs.0, rhs.1, 1, rhs.2)
}

func |==| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute)) -> NSLayoutConstraint {
    return lhs |==| rhs |+| 0
}

func |==| (lhs:(UIView, NSLayoutAttribute),
           const: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(
        item: lhs.0,
        attribute: lhs.1,
        relatedBy: NSLayoutRelation.equal,
        toItem: nil,
        attribute: NSLayoutAttribute.notAnAttribute,
        multiplier: 1.0,
        constant: const )
}

// create an NSConstraint with LessThanOrEqual relation
infix operator |<=| : ConstraintComparison

func |<=| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute, CGFloat, CGFloat)) -> NSLayoutConstraint {
    return NSLayoutConstraint(
        item: lhs.0,
        attribute: lhs.1,
        relatedBy: NSLayoutRelation.lessThanOrEqual,
        toItem: rhs.0,
        attribute: rhs.1,
        multiplier: rhs.2,
        constant: rhs.3 )
}

func |<=| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute, CGFloat)) -> NSLayoutConstraint {
    return lhs |<=| (rhs.0, rhs.1, 1, rhs.2)
}

func |<=| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute)) -> NSLayoutConstraint {
    return lhs |<=| rhs |+| 0
}

func |<=| (lhs:(UIView, NSLayoutAttribute),
           const: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(
        item: lhs.0,
        attribute: lhs.1,
        relatedBy: NSLayoutRelation.lessThanOrEqual,
        toItem: nil,
        attribute: NSLayoutAttribute.notAnAttribute,
        multiplier: 1.0,
        constant: const )
}

// create an NSConstraint with GreaterThanOrEqual relation
infix operator |>=| : ConstraintComparison

func |>=| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute, CGFloat, CGFloat)) -> NSLayoutConstraint {
    return NSLayoutConstraint(
        item: lhs.0,
        attribute: lhs.1,
        relatedBy: NSLayoutRelation.greaterThanOrEqual,
        toItem: rhs.0,
        attribute: rhs.1,
        multiplier: rhs.2,
        constant: rhs.3 )
}

func |>=| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute, CGFloat)) -> NSLayoutConstraint {
    return lhs |>=| (rhs.0, rhs.1, 1, rhs.2)
}

func |>=| (lhs:(UIView, NSLayoutAttribute),
           rhs:(UIView, NSLayoutAttribute)) -> NSLayoutConstraint {
    return lhs |>=| rhs |+| 0
}

func |>=| (lhs:(UIView, NSLayoutAttribute),
           const: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(
        item: lhs.0,
        attribute: lhs.1,
        relatedBy: NSLayoutRelation.greaterThanOrEqual,
        toItem: nil,
        attribute: NSLayoutAttribute.notAnAttribute,
        multiplier: 1.0,
        constant: const )
}

// functions for creating pairs of (view, NSLayoutAttribute) for use with above operators
func centerX (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .centerX) }
func centerY (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .centerY) }
func left    (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .left) }
func right   (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .right) }
func top     (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .top) }
func bottom  (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .bottom) }
func height  (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .height) }
func width   (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .width) }
func leading (_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .leading) }
func trailing(_ v:UIView) -> (UIView, NSLayoutAttribute) { return (v, .trailing) }

// priority operator
// Determines the priority with which the constraint system enforces this constraint.
// A constraint of priority 1000 (the default) must be satisfied.
// If you have conflicting constraints of the same priority, you’ll get run time warnings.
// Lower priority constraints will be set as close to their specified value as possible.
infix operator |~| : ConstraintPriorityAssignment

func |~| (constraint: NSLayoutConstraint, priority: UILayoutPriority) -> NSLayoutConstraint {
    constraint.priority = priority
    return constraint
}

