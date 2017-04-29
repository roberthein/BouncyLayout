import UIKit

enum CellStyle {
    case blue
    case gray
    
    var color: UIColor {
        switch self {
        case .blue: return UIColor(red: 61/255, green: 131/255, blue: 246/255, alpha: 1)
        case .gray: return UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        }
    }
    
    func insetsFor(_ example: Example) -> UIEdgeInsets {
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
        background.backgroundColor = style.color
        let insets = style.insetsFor(example)
        
        top.constant = insets.top
        left.constant = insets.left
        bottom.constant = insets.bottom
        right.constant = insets.right
        
    }
    
    lazy var background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 35 / 2
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
