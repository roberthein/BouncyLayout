import UIKit

public class BouncyLayout: UICollectionViewFlowLayout {
    
    private lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(collectionViewLayout: self) }()
    
    public override func prepare() {
        super.prepare()
        guard let view = collectionView, let attributes = super.layoutAttributesForElements(in: view.bounds)?.flatMap({ $0.copy() as? UICollectionViewLayoutAttributes }) else { return }
        
        oldBehaviors(for: attributes).forEach { animator.removeBehavior($0) }
        newBehaviors(for: attributes).forEach {
            $0.damping = 0.7
            $0.frequency = 1.5
            animator.addBehavior($0)
        }
    }
    
    private func oldBehaviors(for attributes: [UICollectionViewLayoutAttributes]) -> [UIAttachmentBehavior] {
        return animator.behaviors.flatMap { $0 as? UIAttachmentBehavior }.filter {
            guard let item = $0.items.first as? UICollectionViewLayoutAttributes else { return false }
            return !attributes.map { $0.indexPath }.contains(item.indexPath)
        }
    }
    
    private func newBehaviors(for attributes: [UICollectionViewLayoutAttributes]) -> [UIAttachmentBehavior] {
        let indexPaths = animator.behaviors.flatMap { $0 as? UIAttachmentBehavior }.flatMap { $0.items.first as? UICollectionViewLayoutAttributes }.map { $0.indexPath }
        return attributes.filter { return !indexPaths.contains($0.indexPath) }.map { UIAttachmentBehavior(item: $0, attachedToAnchor: $0.center) }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return animator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return animator.layoutAttributesForCell(at: indexPath)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        animator.behaviors.flatMap { $0 as? UIAttachmentBehavior }.forEach {
            guard let view = collectionView, let item = $0.items.first else { return }
            update(behavior: $0, and: item, in: view, for: newBounds)
            animator.updateItem(usingCurrentState: item)
        }
        return false
    }
    
    private func update(behavior: UIAttachmentBehavior, and item: UIDynamicItem, in view: UICollectionView, for bounds: CGRect) {
        let delta = CGVector(dx: bounds.origin.x - view.bounds.origin.x, dy: bounds.origin.y - view.bounds.origin.y)
        let resistance = CGVector(dx: fabs(view.panGestureRecognizer.location(in: view).x - behavior.anchorPoint.x) / 1000, dy: fabs(view.panGestureRecognizer.location(in: view).y - behavior.anchorPoint.y) / 1000)
        item.center.y += delta.dy < 0 ? max(delta.dy, delta.dy * resistance.dy) : min(delta.dy, delta.dy * resistance.dy)
        item.center.x += delta.dx < 0 ? max(delta.dx, delta.dx * resistance.dx) : min(delta.dx, delta.dx * resistance.dx)
    }
}
