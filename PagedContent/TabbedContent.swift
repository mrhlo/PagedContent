//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

protocol TabbedContentDelegate: class {
    func tabbedViewDidScroll(_ scrollView: UIScrollView)
}

class TabbedContentViewController: UIViewController {
    var views = [UIView]() {
        didSet {
            tabbedContentView.setup(views: views)
        }
    }
    
    let tabbedContentView: TabbedContentView
    
    weak var menuController: TabController?
    weak var delegate: TabbedContentDelegate?
    
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
    
    override public func loadView() {
        view = tabbedContentView
    }
}

extension TabbedContentViewController: TabController {
    func select(index: Int) {
        tabbedContentView.select(index: index)
    }
    
    func indexChanged(to index: Int) {
        menuController?.select(index: index)
    }
}

class TabbedContentView: UIView {
    var scrollView = UIScrollView(frame: CGRect.zero)
    
    var controller: TabbedContentViewController!
    
    var views = [UIView]()
    var containerViews = [UIView]()
    
    var selectedIndex = 0
    var hasFullSizeContent = true
    
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
    
    func select(index: Int) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * frame.width, y: 0), animated: true)
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
