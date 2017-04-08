//
//  Copyright © 2017 Halil. All rights reserved.
//

import UIKit

public struct PagedContentTab {
    let title: String?
    let image: UIImage?
    let imageSize: CGSize?
    let view: UIView?
    
    public init(title: String? = nil,
                image: UIImage? = nil,
                imageSize: CGSize? = nil,
                view: UIView? = nil) {
        self.title = title
        self.image = image
        self.imageSize = imageSize
        self.view = view
    }
}

public class PagedContentViewController: UIViewController {
    var contentViewController: TabbedContentViewController?
    var menuViewController: TabbedMenuViewController?
    
    public var menuHeight: CGFloat = 44 {
        didSet {
            view.layoutSubviews()
        }
    }
    
    public var menuView: UIView? {
        get {
            return menuViewController?.view
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        menuViewController = TabbedMenuViewController()
        contentViewController = TabbedContentViewController()
        
        menuViewController?.contentController = contentViewController
        contentViewController?.menuController = menuViewController
        
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    public init() {
        menuViewController = TabbedMenuViewController()
        contentViewController = TabbedContentViewController()
        
        menuViewController?.contentController = contentViewController
        contentViewController?.menuController = menuViewController
        
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
    }
    
    public func setup(theme: PagedContentTabTheme) {
        menuViewController?.setTheme(theme)
    }
    
    public func update(tabs: [PagedContentTab]) {
        menuViewController?.tabs = tabs
        contentViewController?.views = tabs.flatMap { $0.view }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupChildViewFrames()
    }
    
    override public func loadView() {
        view = UIView()
    }
    
    private func setupChildViewFrames() {
        menuViewController?.view.frame = CGRect(origin: .zero,
                                                size: CGSize(width: view.frame.width, height: menuHeight))
        
        contentViewController?.view.frame = CGRect(origin: CGPoint(x: 0, y: menuHeight),
                                                   size: CGSize(width: view.frame.width, height: view.frame.height - menuHeight))
    }
    
    private func setupUI() {
        view.addSubview(menuViewController!.view)
        view.addSubview(contentViewController!.view)
    }
}
