//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

public protocol TabbedContentDelegate: class {
    func tabbedViewDidScroll(_ scrollView: UIScrollView)
    func tabbedViewDidScroll(toTabAt index: Int)
}

public extension TabbedContentDelegate {
    func tabbedViewDidScroll(_ scrollView: UIScrollView) {}
    func tabbedViewDidScroll(toTabAt index: Int) {}
}

public class TabbedContentViewController: UIViewController {
    public var views = [UIView]() {
        didSet {
            tabbedContentView.setup(views: views)
        }
    }
    
    let tabbedContentView: TabbedContentView
    
    public weak var menuController: TabController?
    public weak var delegate: TabbedContentDelegate?
    
    var isScrollEnabled = true {
        didSet {
            tabbedContentView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    var hasFullSizedContent: Bool {
        get {
            return tabbedContentView.hasFullSizeContent
        }
        set(value) {
            tabbedContentView.hasFullSizeContent = value
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        tabbedContentView = TabbedContentView(coder: aDecoder)!
        
        super.init(coder: aDecoder)
        
        tabbedContentView.controller = self
    }
    
    public init() {
        tabbedContentView = TabbedContentView(frame: .zero)
        
        super.init(nibName: nil, bundle: nil)
        
        tabbedContentView.controller = self
    }
    
    override public func loadView() {
        view = tabbedContentView
    }
    
    public func changeIndex(to index: Int, animated: Bool = true) {
        guard tabbedContentView.numberOfTabs > index else { return }
        
        tabbedContentView.select(index: index)
        indexChanged(to: index, animated: animated)
    }
}

extension TabbedContentViewController: TabController {
    public func select(index: Int, animated: Bool) {
        tabbedContentView.select(index: index, animated: animated)
        delegate?.tabbedViewDidScroll(toTabAt: index)
    }
    
    public func indexChanged(to index: Int) {
        indexChanged(to: index, animated: true)
    }
    
    func indexChanged(to index: Int, animated: Bool) {
        menuController?.select(index: index, animated: animated)
        delegate?.tabbedViewDidScroll(toTabAt: index)
    }
}

class TabbedContentView: UIView {
    var scrollView = UIScrollView(frame: CGRect.zero)
    
    var controller: TabbedContentViewController!
    
    var views = [UIView]()
    var containerViews = [UIView]()
    
    var selectedIndex = 0
    var hasFullSizeContent = true
    
    var numberOfTabs: Int {
        return views.count
    }
    
    var contentWidth: CGFloat {
        get {
            return scrollView.contentSize.width
        }
        set(value) {
            scrollView.contentSize.width = value
        }
    }
    
    var contentHeight: CGFloat {
        get {
            return scrollView.contentSize.height
        }
        set(value) {
            scrollView.contentSize.height = value
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialSetup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialSetup()
    }
    
    func initialSetup() {
        autoresizesSubviews = true
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.frame = frame
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        views.forEach { view in
            view.frame.size = frame.size
            
            let index = views.index(of: view)!
            
            let containerView = containerViews[index]
            containerView.frame.size = frame.size
            containerView.frame.origin.x = CGFloat(index) * frame.width
            
            contentWidth = max(containerView.frame.right, contentWidth)
        }
        
        contentHeight = frame.height
    }
    
    func setup(views: [UIView]) {
        self.containerViews.forEach { $0.removeFromSuperview() }
        self.views.forEach { $0.removeFromSuperview() }
        self.views.removeAll()
        self.containerViews.removeAll()
        
        contentWidth = 0
        contentHeight = 0
        
        self.views = views
        
        self.views.forEach(setup)
        
        layoutSubviews()
    }
    
    func setup(view: UIView) {
        let containerView = UIView(frame: CGRect.zero)
        
        containerView.addSubview(view)
        containerView.backgroundColor = UIColor.clear
        
        containerViews.append(containerView)
        
        scrollView.addSubview(containerView)
    }
    
    func select(index: Int, animated: Bool = true) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * frame.width, y: 0), animated: animated)
        selectedIndex = index
    }
}

extension TabbedContentView: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScrolling()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.x > 0 else { return }
        
        controller.delegate?.tabbedViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndScrolling() {
        let offsetX = scrollView.contentOffset.x
        let currentPageOffsetX = CGFloat(selectedIndex) * frame.width
        
        let rate = offsetX / frame.width
        let newIndex = offsetX - currentPageOffsetX >= 0 ? Int(floor(rate)) : Int(ceil(rate))
        
        if newIndex != selectedIndex {
            select(index: newIndex)
            controller.indexChanged(to: newIndex)
        }
    }
}
