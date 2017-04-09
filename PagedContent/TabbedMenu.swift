/*
 Copyright 2017
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

public protocol TabController: class {
    func indexChanged(to index: Int)
    func select(index: Int, animated: Bool)
}

public class TabbedMenuViewController: UIViewController {
    
    fileprivate let tabbedMenuView: TabbedMenuView
    
    public weak var contentController: TabController?
    
    public var tabs = [PagedContentTab]() {
        didSet {
            tabbedMenuView.setup(tabs: tabs)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        tabbedMenuView = TabbedMenuView(coder: aDecoder)!
        
        super.init(coder: aDecoder)
        
        tabbedMenuView.controller = self
    }
    
    public init() {
        tabbedMenuView = TabbedMenuView(frame: .zero)
        
        super.init(nibName: nil, bundle: nil)
        
        tabbedMenuView.controller = self
    }
    
    override public func loadView() {
        view = tabbedMenuView
    }
    
    public func setTheme(_ theme: PagedContentTabTheme) {
        tabbedMenuView.theme = theme
    }
}

extension TabbedMenuViewController: TabController {
    public func indexChanged(to index: Int) {
        contentController?.select(index: index, animated: true)
    }
    
    public func select(index: Int, animated: Bool) {
        tabbedMenuView.select(index: index, animated: animated)
    }
}

public struct PagedContentTabTheme {
    let backgroundColor: UIColor
    let textColor: UIColor
    let selectedColors: [UIColor]
    let selectedColor: UIColor?
    let font: UIFont
    let selectedFont: UIFont
    let buttonPadding: CGFloat
    let borderColor: UIColor
    let isFullWidth: Bool
    
    public static let defaultTheme: PagedContentTabTheme = PagedContentTabTheme(
        backgroundColor: .white,
        textColor: .lightGray,
        selectedColor: .black,
        font: UIFont.systemFont(ofSize: 14),
        selectedFont: UIFont.systemFont(ofSize: 14),
        buttonPadding: 30,
        borderColor: .lightGray,
        isFullWidth: false
    )
    
    public init(backgroundColor: UIColor = PagedContentTabTheme.defaultTheme.backgroundColor,
                textColor: UIColor = PagedContentTabTheme.defaultTheme.textColor,
                selectedColor: UIColor = PagedContentTabTheme.defaultTheme.selectedColor!,
                font: UIFont = PagedContentTabTheme.defaultTheme.font,
                selectedFont: UIFont = PagedContentTabTheme.defaultTheme.font,
                buttonPadding: CGFloat = PagedContentTabTheme.defaultTheme.buttonPadding,
                borderColor: UIColor = PagedContentTabTheme.defaultTheme.borderColor,
                isFullWidth: Bool = PagedContentTabTheme.defaultTheme.isFullWidth) {
        
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.selectedColor = selectedColor
        self.selectedColors = [selectedColor]
        self.font = font
        self.selectedFont = selectedFont
        self.buttonPadding = buttonPadding
        self.borderColor = borderColor
        self.isFullWidth = isFullWidth
        
    }
    
    public init(backgroundColor: UIColor = PagedContentTabTheme.defaultTheme.backgroundColor,
                textColor: UIColor = PagedContentTabTheme.defaultTheme.textColor,
                selectedColors: [UIColor],
                font: UIFont = PagedContentTabTheme.defaultTheme.font,
                selectedFont: UIFont = PagedContentTabTheme.defaultTheme.font,
                buttonPadding: CGFloat = PagedContentTabTheme.defaultTheme.buttonPadding,
                borderColor: UIColor = PagedContentTabTheme.defaultTheme.borderColor,
                isFullWidth: Bool = PagedContentTabTheme.defaultTheme.isFullWidth) {
        
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.selectedColors = selectedColors
        self.font = font
        self.selectedFont = selectedFont
        self.buttonPadding = buttonPadding
        self.borderColor = borderColor
        self.selectedColor = nil
        self.isFullWidth = isFullWidth
    }
}


public class TabbedMenuView: UIView {
    
    var controller: TabbedMenuViewController!
    
    fileprivate let scrollView = UIScrollView(frame: CGRect.zero)
    fileprivate let selectedBottomLine = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: 3)))
    
    fileprivate var tabs = [PagedContentTab]()
    fileprivate var buttons = [UIButton]()
    fileprivate var theme = PagedContentTabTheme.defaultTheme {
        didSet {
            setupUI(withTheme: theme)
        }
    }
    
    fileprivate var selectedIndex = 0
    
    fileprivate var contentWidth: CGFloat {
        get {
            return scrollView.contentSize.width
        }
        set(value) {
            scrollView.contentSize.width = value
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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        buttons.forEach {
            var frame = $0.frame
            frame.size.height = self.frame.height
            $0.frame = frame
        }
        
        if theme.isFullWidth {
            adjustButtonSizesForFullWidth()
        }
        
        selectedBottomLine.frame.origin.y = scrollView.frame.height - selectedBottomLine.frame.height
    }
    
    func initialSetup() {
        autoresizesSubviews = true
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.frame = frame
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        scrollView.addSubview(selectedBottomLine)
        
        setupUI(withTheme: theme)
    }
    
    fileprivate func setupUI(withTheme theme: PagedContentTabTheme) {
        scrollView.backgroundColor = UIColor.clear
        backgroundColor = theme.backgroundColor
        
        layer.borderWidth = 0.5
        layer.borderColor = theme.borderColor.cgColor
        
        selectedBottomLine.backgroundColor = theme.selectedColor
    }
    
    fileprivate func setup(tabs: [PagedContentTab]) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        contentWidth = 0
        
        self.tabs = tabs
        
        tabs.forEach(setup)
        selectedIndex = 0
        selectedBottomLine.isHidden = buttons.isEmpty
        
        guard !buttons.isEmpty
            else {
                isHidden = true
                return
        }
        
        isHidden = false
        
        updateSelectedButtons(newIndex: selectedIndex)
        moveBottomLine(from: buttons[selectedIndex], to: buttons[selectedIndex], animate: false)
        
        if theme.isFullWidth {
            adjustButtonSizesForFullWidth()
        }
    }
    
    fileprivate func adjustButtonSizesForFullWidth() {
        guard contentWidth < frame.width && !tabs.isEmpty else { return }
        
        let buttonWidth = frame.width / CGFloat(buttons.count)
        buttons.forEach { button in
            guard let index = buttons.index(of: button) else { return }
            let x = index == 0 ? 0 : buttons[index-1].frame.right
            
            button.frame.origin.x = x
            button.frame.size.width = buttonWidth
        }
        contentWidth = buttons.last?.frame.right ?? 0
        moveBottomLine(from: buttons[selectedIndex], to: buttons[selectedIndex], animate: false)
    }
    
    fileprivate func setup(tab: PagedContentTab) {
        let button = makeTabButton(for: tab)
        
        var buttonFrame = button.frame
        
        let previousButtonRight = buttons.last?.frame.right ?? 0
        
        buttonFrame.origin.x = previousButtonRight + theme.buttonPadding
        button.frame = buttonFrame
        
        scrollView.addSubview(button)
        scrollView.contentSize = CGSize(width: button.frame.right + theme.buttonPadding, height: 0)
        buttons.append(button)
    }
    
    fileprivate func updateSelectedButtons(newIndex: Int, oldIndex: Int? = nil) {
        if let oldIndex = oldIndex {
            var previouslySelectedButton = buttons[oldIndex]
            updateUI(for: &previouslySelectedButton, with: theme, selected: false)
        }
        
        var selectedButton = buttons[newIndex]
        updateUI(for: &selectedButton, with: theme, index: newIndex, selected: true)
    }
    
    fileprivate func moveBottomLine(from fromButton: UIButton, to toButton: UIButton, animate: Bool) {
        let fromFrame = frameForBottomLine(relativeTo: fromButton)
        let toFrame = frameForBottomLine(relativeTo: toButton)
        
        selectedBottomLine.frame = fromFrame
        moveBottomLine(toFrame: toFrame, animate: animate)
    }
    
    fileprivate func moveBottomLine(toFrame frame: CGRect, animate: Bool) {
        let duration = animate ? 0.3 : 0
        UIView.animate(withDuration: duration) {
            self.selectedBottomLine.frame = frame
        }
    }
    
    fileprivate func frameForBottomLine(relativeTo button: UIButton) -> CGRect {
        var newFrame = selectedBottomLine.frame
        
        let linePadding: CGFloat = 5
        newFrame.size.width = button.frame.width + linePadding * 2
        newFrame.centerX = button.frame.origin.x + button.frame.centerX
        
        return newFrame
    }
    
    fileprivate func makeTabButton(for tab: PagedContentTab) -> UIButton {
        var button = UIButton(type: .custom)
        
        button.setTitle(tab.title, for: .normal)
        
        let imageRightPadding: CGFloat = 10
        
        let imageSize = tab.imageSize ?? (tab.image?.size ?? .zero)
        
        if let image = tab.image {
            button.setImage(image.byScaling(to: imageSize), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imageRightPadding)
        }
        updateUI(for: &button, with: theme, selected: false)
        
        let imageWidth = imageSize.width > 0 ? imageSize.width + imageRightPadding : 0
        
        let textWidth = tab.title?.widthWithConstrainedHeight(height: frame.height, font: theme.font) ?? 0
        
        let width = textWidth + imageWidth
        let buttonFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: frame.height))
        button.frame = buttonFrame
        
        button.addTarget(self, action: #selector(buttonSelected(_:)), for: .touchUpInside)
        
        return button
    }
    
    fileprivate func updateUI(for button: inout UIButton, with theme: PagedContentTabTheme, index: Int = 0, selected: Bool) {
        let selectedColor = theme.selectedColor ?? theme.selectedColors[index]
        
        let titleColor = selected ? selectedColor : theme.textColor
        let font = selected ? theme.selectedFont : theme.font
        
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = font
        selectedBottomLine.backgroundColor = selectedColor
    }
    
    @objc fileprivate func buttonSelected(_ button: UIButton) {
        guard let index = buttons.index(of: button),
            index != selectedIndex
            else { return }
        
        select(index: index)
        controller.indexChanged(to: index)
    }
    
    func select(index: Int, animated: Bool = true) {
        guard index < buttons.count else { return }
        
        updateSelectedButtons(newIndex: index, oldIndex: selectedIndex)
        let oldButton = buttons[selectedIndex]
        let newButton = buttons[index]
        
        moveBottomLine(from: oldButton, to: newButton, animate: animated)
        
        selectedIndex = index
        
        let newButtonRight = newButton.frame.right
        let newButtonLeft = newButton.frame.origin.x
        let leftAlign = newButtonLeft < scrollView.contentOffset.x
        let rightAlign = newButtonRight > scrollView.contentOffset.x + frame.width
        
        if rightAlign || leftAlign {
            scroll(to: newButton.frame, leftAlign: leftAlign)
        }
    }
    
    fileprivate func scroll(to buttonFrame: CGRect, leftAlign: Bool) {
        let x = buttonFrame.origin.x
        let buttonPadding = x == 0 ? 0 : theme.buttonPadding
        
        var contentOffsetX: CGFloat = 0
        
        if leftAlign {
            contentOffsetX = x - buttonPadding
        } else {
            let buttonOriginX = x + buttonFrame.width + buttonPadding
            let lastPointX = scrollView.contentSize.width - scrollView.frame.width
            contentOffsetX = CGFloat.minimum(buttonOriginX, lastPointX)
        }
        
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
    }
}

