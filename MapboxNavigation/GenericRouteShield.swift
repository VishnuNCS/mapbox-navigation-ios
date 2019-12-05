import Foundation
import UIKit

/**
 `GenericRouteShield` is a class to render routes that do not have route-shields.
 */
public class GenericRouteShield: StylableView {
    static let labelFontSizeScaleFactor: CGFloat = 2.0/3.0
    
    //The color to use for the text and border.
    @objc public dynamic var foregroundColor: UIColor? {
        didSet {
            layer.borderColor = foregroundColor?.cgColor
            routeLabel.textColor = foregroundColor
            setNeedsDisplay()
        }
    }
     
    //The label that contains the route code.
    lazy var routeLabel: UILabel = {
        let label: UILabel = .forAutoLayout()
        label.text = routeText
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: pointSize * GenericRouteShield.labelFontSizeScaleFactor)
        
        return label
    }()
    
    //The text to put in the label
    var routeText: String? {
        didSet {
            routeLabel.text = routeText
            invalidateIntrinsicContentSize()
        }
    }
    
    //The size of the text the view attachment is contained within.
    var pointSize: CGFloat {
        didSet {
            routeLabel.font = routeLabel.font.withSize(pointSize * GenericRouteShield.labelFontSizeScaleFactor)
            rebuildConstraints()
        }
    }
    
    convenience init(pointSize: CGFloat, text: String) {
        self.init(frame: .zero)
        self.pointSize = pointSize
        self.routeText = text
        commonInit()
    }
    
    override init(frame: CGRect) {
        pointSize = 0.0
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        pointSize = 0.0
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func rebuildConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
        buildConstraints()
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        
        //build view hierarchy
        addSubview(routeLabel)
        buildConstraints()
        
        setNeedsLayout()
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }

    func buildConstraints() {
        let height = heightAnchor.constraint(equalToConstant: pointSize * 1.2)
        
        let labelCenterY = routeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        let labelLeading = routeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        let labelTrailingSpacing = routeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        
        let constraints = [height, labelCenterY, labelLeading, labelTrailingSpacing]
        
        addConstraints(constraints)
    }
    
    /**
     This generates the cache key needed to hold the `GenericRouteShield`'s `imageRepresentation` in the `ImageCache` caching engine.
     */
    static func criticalHash(dataSource: DataSource) -> String {
        let proxy = GenericRouteShield.appearance()
        var backgroundColor = proxy.backgroundColor
        var foregroundColor = proxy.foregroundColor
        let resolvedColorSelector = Selector(("resolvedColorWithTraitCollection:" as NSString) as String)
        if #available(iOS 13.0, *),
            let bgColor = backgroundColor, bgColor.responds(to: resolvedColorSelector),
            let fgColor = foregroundColor, fgColor.responds(to: resolvedColorSelector),
            let currentTraitCollection = UIApplication.shared.keyWindow?.traitCollection {
                if let backgroundColorInstance = bgColor.perform(resolvedColorSelector, with: currentTraitCollection), let foregroundColorInstance = fgColor.perform(resolvedColorSelector, with: currentTraitCollection) {
                    backgroundColor = backgroundColorInstance.takeRetainedValue() as? UIColor
                    foregroundColor = foregroundColorInstance.takeRetainedValue() as? UIColor
                }
            }
        let criticalProperties: [AnyHashable?] = [dataSource.font.pointSize, backgroundColor, foregroundColor, proxy.borderWidth, proxy.cornerRadius]
        return String(describing: criticalProperties.reduce(0, { $0 ^ ($1?.hashValue ?? 0)}))
    }
}
