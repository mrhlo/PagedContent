//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

public typealias TabbedMenuTheme = TabbedMenuView.Theme

fileprivate typealias Tab = TabbedMenuViewController.Tab

protocol TabController: class {
    func indexChanged(to index: Int)
    func select(index: Int)
}

public class TabbedMenuViewController: UIViewController {
    struct Tab {
        let title: String
        let view: UIView?
    }
    
    fileprivate let tabbedMenuView: TabbedMenuView
    
    weak var contentController: TabController?
    
    var tabs = [Tab]() {
        didSet {
            tabbedMenuView.setup(tabs: tabs)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        tabbedMenuView = TabbedMenuView(coder: aDecoder)!
        super.init(coder: aDecoder)
        
        tabbedMenuView.controller = self
    }
    
    override public func loadView() {
        view = tabbedMenuView
    }
    
    public func setTheme(_ theme: TabbedMenuTheme) {
        tabbedMenuView.theme = theme
    }
}

extension TabbedMenuViewController: TabController {
    func indexChanged(to index: Int) {
        contentController?.select(index: index)
    }
    
    func select(index: Int) {
        tabbedMenuView.select(index: index)
    }
}


public class TabbedMenuView: UIView {
    public struct Theme {
        let backgroundColor: UIColor
        let textColor: UIColor
        let selectedColor: UIColor
        let font: UIFont
        let buttonPadding: CGFloat
        let borderColor: UIColor
        
        static let defaultTheme: Theme = Theme(
            backgroundColor: .white,
            textColor: .black,
            selectedColor: .blue,
            font: UIFont.systemFont(ofSize: 14),
            buttonPadding: 30,
            borderColor: UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0)
        )
        
        init(backgroundColor: UIColor = Theme.defaultTheme.backgroundColor,
             textColor: UIColor = Theme.defaultTheme.textColor,
             selectedColor: UIColor = Theme.defaultTheme.selectedColor,
             font: UIFont = Theme.defaultTheme.font,
             buttonPadding: CGFloat = Theme.defaultTheme.buttonPadding,
             borderColor: UIColor = Theme.defaultTheme.borderColor) {
            
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.selectedColor = selectedColor
            self.font = font
            self.buttonPadding = buttonPadding
            self.borderColor = borderColor
        }
    }
    
    var controller: TabbedMenuViewController!
    
    fileprivate let scrollView = UIScrollView(frame: CGRect.zero)
    fileprivate let selectedBottomLine = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: 3)))
    
    fileprivate var tabs = [Tab]()
    fileprivate var buttons = [UIButton]()
    fileprivate var theme = Theme.defaultTheme {
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
        
        if contentWidth < frame.width && !tabs.isEmpty {
            adjustButtonSizes()
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
    
    fileprivate func setupUI(withTheme theme: Theme) {
        scrollView.backgroundColor = UIColor.clear
        backgroundColor = theme.backgroundColor
        
        layer.borderWidth = 0.5
        layer.borderColor = theme.borderColor.cgColor
        
        selectedBottomLine.backgroundColor = theme.selectedColor
    }
    
    fileprivate func setup(tabs: [Tab]) {
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
    }
    
    fileprivate func adjustButtonSizes() {
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
    
    fileprivate func setup(tab: Tab) {
        let button = makeTabButton(withTitle: tab.title)
        
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
        updateUI(for: &selectedButton, with: theme, selected: true)
    }
    
    fileprivate func moveBottomLine(from fromButton: UIButton, to toButton: UIButton, animate: Bool) {
        let fromFrame = frameForBottomLine(relativeTo: fromButton)
        let toFrame = frameForBottomLine(relativeTo: toButton)
        
        selectedBottomLine.frame = fromFrame
        
        let duration = animate ? 0.3 : 0
        UIView.animate(withDuration: duration) {
            self.selectedBottomLine.frame = toFrame
        }
    }
    
    fileprivate func frameForBottomLine(relativeTo button: UIButton) -> CGRect {
        var newFrame = selectedBottomLine.frame
        
        let linePadding: CGFloat = 5
        newFrame.size.width = button.textWidth + linePadding * 2
        newFrame.centerX = button.frame.origin.x + button.frame.centerX
        
        return newFrame
    }
    
    fileprivate func makeTabButton(withTitle title: String) -> UIButton {
        var button = UIButton(type: .custom)
        
        button.setTitle(title, for: .normal)
        updateUI(for: &button, with: theme, selected: false)
        
        let width = title.widthWithConstrainedHeight(height: frame.height, font: theme.font)
        let buttonFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: frame.height))
        button.frame = buttonFrame
        
        button.addTarget(self, action: #selector(buttonSelected(_:)), for: .touchUpInside)
        
        return button
    }
    
    fileprivate func updateUI(for button: inout UIButton, with theme: Theme, selected: Bool) {
        let titleColor = selected ? theme.selectedColor : theme.textColor
        
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = theme.font
    }
    
    @objc fileprivate func buttonSelected(_ button: UIButton) {
        guard let index = buttons.index(of: button),
            index != selectedIndex
            else { return }
        
        select(index: index)
        controller.indexChanged(to: index)
    }
    
    func select(index: Int) {
        guard index < buttons.count else { return }
        
        updateSelectedButtons(newIndex: index, oldIndex: selectedIndex)
        let oldButton = buttons[selectedIndex]
        let newButton = buttons[index]
        
        moveBottomLine(from: oldButton, to: newButton, animate: true)
        
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

