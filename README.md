# PagedContent - iOS Implementation of Android's ViewPager

###About

PagedContent is an iOS implementation of Android's ViewPager. It allows to place content in "pages" in order to show one part of the content while hiding others. It uses a menu-based navigation to go through the different parts of the content.

###Usage

The easiest way to use the component is to embed the `PagedContentViewController` in your view controller using a container view, or to initialize a `PagedContentViewController` in your parent view controller and adding it's view to your main view.

To setup each page of the content, you must create a `PagedContentTab` object with a title and a `UIView` object which will be the content of that page; and pass a list of these objects to the `PagedContentViewControler`. An example of this is as the following:

```swift
let backgroundColors = [UIColor.blue, UIColor.red, UIColor.yellow, UIColor.brown, UIColor.cyan, UIColor.green, UIColor.black]
        
        let tabs = ["view1", "view2", "view3", "view4"].enumerated().map { index, title -> PagedContentTab in
            
            let view = UIView()
            view.backgroundColor = backgroundColors[index]
            return PagedContentTab(image: UIImage(named: "Icon"), view: view)
        }
pagedContentViewController?.update(tabs: tabs)
```