import UIKit

enum CellStyle {
    case blue
    case gray
    
    func color(for example: Example) -> UIColor {
        
        switch self {
        case .blue:
            return UIColor.white.withAlphaComponent(1)
//            switch example {
//            case .chatMessage: return UIColor(red: 0/255, green: 98/255, blue: 239/255, alpha: 1)
//            case .photosCollection: return UIColor(red: 0/255, green: 208/255, blue: 166/255, alpha: 1)
//            case .barGraph: return UIColor(red: 0/255, green: 153/255, blue: 202/255, alpha: 1)
//            }
        case .gray:
            return UIColor.white.withAlphaComponent(0.7)
//            return UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        }
    }
    
    func insets(for example: Example) -> UIEdgeInsets {
        switch example {
        case .chatMessage: return UIEdgeInsets(top: 5, left: self == .blue ? 80 : 5, bottom: -5, right: self == .blue ? -5 : -80)
        case .photosCollection: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .barGraph: return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
    }
}

class Cell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "Cell"
    
    lazy var top: NSLayoutConstraint = self.background.topAnchor.constraint(equalTo: self.contentView.topAnchor)
    lazy var left: NSLayoutConstraint = self.background.leftAnchor.constraint(equalTo: self.contentView.leftAnchor)
    lazy var bottom: NSLayoutConstraint = self.background.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    lazy var right: NSLayoutConstraint = self.background.rightAnchor.constraint(equalTo: self.contentView.rightAnchor)
    
    func setCell(style: CellStyle, example: Example) {
        background.backgroundColor = style.color(for: example)
        let insets = style.insets(for: example)
        
        top.constant = insets.top
        left.constant = insets.left
        bottom.constant = insets.bottom
        right.constant = insets.right
        
    }
    
    lazy var background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = nil
        contentView.addSubview(background)
        
        NSLayoutConstraint.activate([top, left, bottom, right])
        
        
    }
}
