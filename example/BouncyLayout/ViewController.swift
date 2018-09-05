import UIKit
import BouncyLayout

class ViewController: UIViewController {
    
    let numberOfItems = 50
    var randomCellStyle: CellStyle { return arc4random_uniform(10) % 2 == 0 ? .blue : .gray }
    
    lazy var style: [CellStyle] = { (0..<self.numberOfItems).map { _ in self.randomCellStyle } }()
    lazy var topOffset: [CGFloat] = { (0..<self.numberOfItems).map { _ in CGFloat(arc4random_uniform(250)) } }()
    
    lazy var sizes: [CGSize] = {
        guard let example = self.example else { return [] }
        
        return (0..<self.numberOfItems).map { _ in
            switch example {
            case .chatMessage: return CGSize(width: UIScreen.main.bounds.width - 20, height: 40)
            case .photosCollection: return CGSize(width: floor((UIScreen.main.bounds.width - (5 * 10)) / 4), height: floor((UIScreen.main.bounds.width - (5 * 10)) / 4))
            case .barGraph: return CGSize(width: 40, height: 400)
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
        case .photosCollection: return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        case .barGraph: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
    }
    
    lazy var layout = BouncyLayout(style: .regular)
    
    lazy var collectionView: UICollectionView = {
        
        if self.example == .barGraph {
            self.layout.scrollDirection = .horizontal
        }
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = self.backgroundColor(for: self.example)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        
        return view
    }()
    
    func backgroundColor(for example: Example) -> UIColor {
        
        switch example {
        case .chatMessage: return UIColor(red: 0/255, green: 98/255, blue: 239/255, alpha: 1)
        case .photosCollection: return UIColor(red: 0/255, green: 153/255, blue: 202/255, alpha: 1)
        case .barGraph: return UIColor(red: 0/255, green: 208/255, blue: 166/255, alpha: 1)
        }
    }
    
    var example: Example!
    
    convenience init(example: Example) {
        self.init()
        self.example = example
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = example.title
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
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
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
        return example == .photosCollection ? 10 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return example == .photosCollection ? 10 : 0
    }
}

