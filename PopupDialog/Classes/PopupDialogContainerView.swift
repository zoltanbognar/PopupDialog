//
//  PopupDialogContainerView.swift
//  Pods
//
//  Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)
//  Author - Martin Wildfeuer (http://www.mwfire.de)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

/// The main view of the popup dialog
final public class PopupDialogContainerView: UIView {

    // MARK: - Appearance

    /// The background color of the popup dialog
    override public dynamic var backgroundColor: UIColor? {
        get { return container.backgroundColor }
        set { container.backgroundColor = newValue }
    }

    /// The corner radius of the popup view
    @objc public dynamic var cornerRadius: Float {
        get { return Float(shadowContainer.layer.cornerRadius) }
        set {
            let radius = CGFloat(newValue)
            shadowContainer.layer.cornerRadius = radius
            container.layer.cornerRadius = radius
        }
    }
    
    // MARK: Shadow related

    /// Enable / disable shadow rendering of the container
    @objc public dynamic var shadowEnabled: Bool {
        get { return shadowContainer.layer.shadowRadius > 0 }
        set { shadowContainer.layer.shadowRadius = newValue ? shadowRadius : 0 }
    }

    /// Color of the container shadow
    @objc public dynamic var shadowColor: UIColor? {
        get {
            guard let color = shadowContainer.layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set { shadowContainer.layer.shadowColor = newValue?.cgColor }
    }
    
    /// Radius of the container shadow
    @objc public dynamic var shadowRadius: CGFloat {
        get { return shadowContainer.layer.shadowRadius }
        set { shadowContainer.layer.shadowRadius = newValue }
    }
    
    /// Opacity of the the container shadow
    @objc public dynamic var shadowOpacity: Float {
        get { return shadowContainer.layer.shadowOpacity }
        set { shadowContainer.layer.shadowOpacity = newValue }
    }
    
    /// Offset of the the container shadow
    @objc public dynamic var shadowOffset: CGSize {
        get { return shadowContainer.layer.shadowOffset }
        set { shadowContainer.layer.shadowOffset = newValue }
    }
    
    /// Path of the the container shadow
    @objc public dynamic var shadowPath: CGPath? {
        get { return shadowContainer.layer.shadowPath}
        set { shadowContainer.layer.shadowPath = newValue }
    }

    /// Main padding for dialog when it has top or bottom position
    @objc public dynamic var mainDialogPadding: CGFloat {
        get { return metrics.dialogPadding}
        set { metrics.dialogPadding = newValue }
    }
    
    /// Padding for main stack content
    @objc public dynamic var mainStackPadding: CGFloat {
        get { return metrics.mainStackPadding}
        set { metrics.mainStackPadding = newValue }
    }
    
    /// Spacing for buttons in buttons stack view
    @objc public dynamic var buttonsStackSpacing: CGFloat {
        get { return buttonStackView.spacing}
        set { buttonStackView.spacing = newValue }
    }
    
    // MARK: - Views

    /// The shadow container is the basic view of the PopupDialog
    /// As it does not clip subviews, a shadow can be applied to it
    internal lazy var shadowContainer: UIView = {
        let shadowContainer = UIView(frame: .zero)
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = UIColor.clear
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowRadius = 5
        shadowContainer.layer.shadowOpacity = 0.4
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowContainer.layer.cornerRadius = 4
        return shadowContainer
    }()

    /// The container view is a child of shadowContainer and contains
    /// all other views. It clips to bounds so cornerRadius can be set
    internal lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white
        container.clipsToBounds = true
        container.layer.cornerRadius = 4
        return container
    }()

    // The container stack view for buttons
    internal lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 0
        return buttonStackView
    }()

    // The main stack view, containing all relevant views
    internal lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.buttonStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    // The preferred width for iPads
    fileprivate let preferredWidth: CGFloat
    
    // Dialog position on the screen
    fileprivate let positionStyle: PopupDialogPositionStyle

    // MARK: - Constraints

    /// The center constraint of the shadow container
    internal var centerYConstraint: NSLayoutConstraint?

    // MARK: - Initializers
    
    internal init(frame: CGRect, preferredWidth: CGFloat, positionStyle: PopupDialogPositionStyle) {
        self.preferredWidth = preferredWidth
        self.positionStyle = positionStyle
        super.init(frame: frame)
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    internal func setupViews() {
        // Add views
        addSubview(shadowContainer)
        shadowContainer.addSubview(container)
        container.addSubview(stackView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }

    private var allConstraints: [NSLayoutConstraint] = []

    private class Metrics {
        var dialogPadding: CGFloat = 10.0
        var mainStackPadding: CGFloat = 10.0
    }
    
    private lazy var metrics: Metrics = {
        return Metrics()
    }()

    internal func setupLayout() { // swiftlint:disable:this function_body_length
        if !allConstraints.isEmpty {
            NSLayoutConstraint.deactivate(allConstraints)
            allConstraints.removeAll()
        }
        
        var iphoneMetrics = [
            "mainStackPadding": metrics.mainStackPadding,
            "topMargin": metrics.dialogPadding,
            "bottomMargin": metrics.dialogPadding,
            "leftMargin": metrics.dialogPadding,
            "rightMargin": metrics.dialogPadding]
        
        if #available(iOS 11.0, *) {
            let newInsets = self.safeAreaInsets
            let leftMargin = newInsets.left > 0 ? newInsets.left + metrics.dialogPadding: metrics.dialogPadding
            let rightMargin = newInsets.right > 0 ? newInsets.right + metrics.dialogPadding: metrics.dialogPadding
            let topMargin = newInsets.top > 0 ? newInsets.top + metrics.dialogPadding: metrics.dialogPadding
            let bottomMargin = newInsets.bottom > 0 ? newInsets.bottom + metrics.dialogPadding: metrics.dialogPadding
            
            iphoneMetrics = [
                "mainStackPadding": metrics.mainStackPadding,
                "topMargin": topMargin,
                "bottomMargin": bottomMargin,
                "leftMargin": leftMargin,
                "rightMargin": rightMargin]
        }

        // Layout views
        let views = ["shadowContainer": shadowContainer, "container": container, "stackView": stackView]

        // Shadow container constraints
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let metrics = ["preferredWidth": preferredWidth]
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=40)-[shadowContainer(==preferredWidth@900)]-(>=40)-|", options: [], metrics: metrics, views: views)
        } else {
            if case .center = positionStyle {
                allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=10,==20@900)-[shadowContainer(<=340,>=300)]-(>=10,==20@900)-|", options: [], metrics: nil, views: views)
            } else if case .top = positionStyle {
                allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftMargin-[shadowContainer]-rightMargin-|", options: [], metrics: iphoneMetrics, views: views)
            } else if case .bottom = positionStyle {
                allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftMargin-[shadowContainer]-rightMargin-|", options: [], metrics: iphoneMetrics, views: views)
            }
        }
        
        if case .center = positionStyle {
            allConstraints += [NSLayoutConstraint(item: shadowContainer, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)]
            centerYConstraint = NSLayoutConstraint(item: shadowContainer, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            
            if let centerYConstraint = centerYConstraint {
                allConstraints.append(centerYConstraint)
            }
        } else if case .top = positionStyle {
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-topMargin-[shadowContainer(>=100)]", options: [], metrics: iphoneMetrics, views: views)
        } else if case .bottom = positionStyle {
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[shadowContainer(>=100)]-bottomMargin-|", options: [], metrics: iphoneMetrics, views: views)
        }
        
        // Container constraints
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: [], metrics: iphoneMetrics, views: views)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: [], metrics: iphoneMetrics, views: views)
        
        // Main stack view constraints
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-mainStackPadding-[stackView]-mainStackPadding-|", options: [], metrics: iphoneMetrics, views: views)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-mainStackPadding-[stackView]-mainStackPadding-|", options: [], metrics: iphoneMetrics, views: views)
        
        // Activate constraints
        NSLayoutConstraint.activate(allConstraints)
    }
}
