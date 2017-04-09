/*
 Copyright 2017
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
