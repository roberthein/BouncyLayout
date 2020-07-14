import Foundation
import UIKit

open class BouncyLayout: UICollectionViewFlowLayout {
    
    fileprivate let VIEWPORT_BUFFER: CGFloat = 200.0
    
    public enum BounceStyle {
        case subtle
        case regular
        case prominent
        
        var damping: CGFloat {
            switch self {
                case .subtle: return 0.8
                case .regular: return 0.7
                case .prominent: return 0.5
            }
        }
        
        var frequency: CGFloat {
            switch self {
                case .subtle: return 2
                case .regular: return 1.5
                case .prominent: return 1
            }
        }
    }
    
    private var damping: CGFloat = BounceStyle.regular.damping
    private var frequency: CGFloat = BounceStyle.regular.frequency
    
    // updateItem doesn't take into account size changes
    // so we track visible size changes and re-prepare
    // behaviors on change
    private var visibleItemsSizeCache: [IndexPath:CGSize] = [:]
    private var visibleIndexPaths: Set<IndexPath> = Set()
    
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    
    public convenience init(style: BounceStyle) {
        self.init()
        
        damping = style.damping
        frequency = style.frequency
    }
    
    public convenience init(damping: CGFloat, frequency: CGFloat) {
        self.init()
        
        self.damping = damping
        self.frequency = frequency
    }
    
    open override func prepare() {
        super.prepare()
        
        // Give viewport directional buffer
        // to account for fast scrolling
        guard let view = collectionView, let items = super.layoutAttributesForElements(in: view.bounds.insetBy(dx: -VIEWPORT_BUFFER, dy: -VIEWPORT_BUFFER)) else { return }
        
        let indexPathsForRange = Set(items.map(\.indexPath))
        
        // Remove items that aren't in viewport
        for behavior in animator.behaviors {
            if let behavior = behavior as? UIAttachmentBehavior {
                guard let firstItem = behavior.items.first as? UICollectionViewLayoutAttributes else {
                    continue
                }
                if !indexPathsForRange.contains(firstItem.indexPath) {
                    animator.removeBehavior(behavior)
                    visibleIndexPaths.remove(firstItem.indexPath)
                    visibleItemsSizeCache.removeValue(forKey: firstItem.indexPath)
                }
            }
        }
        
        // Add missing items that are in viewport
        // If there has been a cell size change
        // then reset behaviors for viewport cells
        for item in items {
            if !visibleIndexPaths.contains(item.indexPath) {
                addItem(item, in: view)
            } else if visibleItemsSizeCache[item.indexPath]?.equalTo(item.size) == false {
                animator.removeAllBehaviors()
                visibleIndexPaths.removeAll()
                items.forEach { addItem($0, in: view) }
                break
            }
        }
    }
    
    private func addItem(_ item: UICollectionViewLayoutAttributes, in view: UICollectionView) {
        let behavior = UIAttachmentBehavior(item: item, attachedToAnchor: floor(item.center))
        animator.addBehavior(behavior, damping, frequency)
        visibleIndexPaths.insert(item.indexPath)
        visibleItemsSizeCache[item.indexPath] = item.bounds.size
    }
    
    private func addItem(_ item: UIDynamicItem, in view: UICollectionView) {
        guard let item = item as? UICollectionViewLayoutAttributes else {
            return
        }
        
        addItem(item, in: view)
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        animator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        animator.layoutAttributesForCell(at: indexPath) ?? super.layoutAttributesForItem(at: indexPath)
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let view = collectionView else { return false }
        
        animator.behaviors.forEach {
            guard let behavior = $0 as? UIAttachmentBehavior,
                let item = behavior.items.first else {
                    return
            }
            update(behavior: behavior, and: item, in: view, for: newBounds)
            animator.updateItem(usingCurrentState: item)
        }
        
        return false // animator will automatically notify FlowLayout to invalidate
    }
    
    private func update(behavior: UIAttachmentBehavior, and item: UIDynamicItem, in view: UICollectionView, for bounds: CGRect) {
        let delta = CGVector(dx: bounds.origin.x - view.bounds.origin.x, dy: bounds.origin.y - view.bounds.origin.y)
        let resistance = CGVector(dx: abs(view.panGestureRecognizer.location(in: view).x - behavior.anchorPoint.x) / 1000, dy: abs(view.panGestureRecognizer.location(in: view).y - behavior.anchorPoint.y) / 1000)
        
        switch scrollDirection {
            case .horizontal: item.center.x += delta.dx < 0 ? max(delta.dx, delta.dx * resistance.dx) : min(delta.dx, delta.dx * resistance.dx)
            case .vertical: item.center.y += delta.dy < 0 ? max(delta.dy, delta.dy * resistance.dy) : min(delta.dy, delta.dy * resistance.dy)
            @unknown default:
                item.center.y += delta.dy < 0 ? max(delta.dy, delta.dy * resistance.dy) : min(delta.dy, delta.dy * resistance.dy)
        }
        
        item.center = floor(item.center)
    }
}

extension UIDynamicAnimator {
    open func addBehavior(_ behavior: UIAttachmentBehavior, _ damping: CGFloat, _ frequency: CGFloat) {
        behavior.damping = damping
        behavior.frequency = frequency
        addBehavior(behavior)
    }
}

fileprivate func floor(_ point: CGPoint) -> CGPoint {
    CGPoint(x: floor(point.x), y: floor(point.y))
}
