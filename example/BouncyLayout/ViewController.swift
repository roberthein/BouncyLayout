import UIKit
import BouncyLayout

class ViewController: UIViewController {
    
    let numberOfItems = 100
    var randomCellStyle: CellStyle { return arc4random_uniform(10) % 2 == 0 ? .blue : .gray }
    var randomFloat: CGFloat { return max(45, CGFloat(arc4random_uniform(100))) }
    
    lazy var style: [CellStyle] = { (0..<self.numberOfItems).map { _ in self.randomCellStyle } }()
    lazy var topOffset: [CGFloat] = { (0..<self.numberOfItems).map { _ in CGFloat(arc4random_uniform(250)) } }()
    
    lazy var sizes: [CGSize] = {
        guard let example = self.example else { return [] }
        
        return (0..<self.numberOfItems).map { _ in
            switch example {
            case .chatMessage: return CGSize(width: UIScreen.main.bounds.width - 20, height: self.randomFloat)
            case .photosCollection: return CGSize(width: (UIScreen.main.bounds.width - (4 * 15)) / 3, height: (UIScreen.main.bounds.width - (4 * 15)) / 3)
            case .barGraph: return CGSize(width: 45, height: 400)
            }
        }
    }()
    
    var insets: UIEdgeInsets {
        guard let example = self.example else { return .zero }
        
        switch example {
        case .chatMessage: return UIEdgeInsets(top: 200, left: 0, bottom: 200, right: 0)
        case .photosCollection: return UIEdgeInsets(top: 200, left: 0, bottom: 200, right: 0)
        case .barGraph: return UIEdgeInsets(top: 0, left: 200, bottom: 0, right: 200)
        }
    }
    
    var additionalInsets: UIEdgeInsets {
        guard let example = self.example else { return .zero }
        
        switch example {
        case .chatMessage: return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        case .photosCollection: return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        case .barGraph: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
    }
    
    lazy var layout = BouncyLayout()
    
    lazy var collectionView: UICollectionView = {
        
        if self.example == .barGraph {
            self.layout.scrollDirection = .horizontal
        }
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delaysContentTouches = false
        view.alwaysBounceVertical = self.example != .barGraph
        view.alwaysBounceHorizontal = self.example == .barGraph
        view.backgroundColor = nil
        view.isOpaque = false
        view.delegate = self
        view.dataSource = self
        view.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        
        return view
    }()
    
    var example: Example!
    
    convenience init(example: Example) {
        self.init()
        self.example = example
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.clipsToBounds = true
        
        collectionView.contentInset = UIEdgeInsets(top: insets.top + additionalInsets.top, left: insets.left + additionalInsets.left, bottom: insets.bottom + additionalInsets.bottom, right: insets.right + additionalInsets.right)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: -insets.top),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -insets.left),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right)
            ])
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        cell.setCell(style: style[indexPath.row], example: example)
        
        if example == .barGraph {
            cell.top.constant = topOffset[indexPath.row]
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizes[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return example == .photosCollection ? 15 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return example == .photosCollection ? 15 : 0
    }
}
