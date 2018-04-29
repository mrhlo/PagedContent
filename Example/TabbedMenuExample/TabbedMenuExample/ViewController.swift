//
//  ViewController.swift
//  PagedContentExample
//
//  Created by Halil Gursoy on 31/12/2016.
//  Copyright © 2016 Halil. All rights reserved.
//

import UIKit
import PagedContent

class ViewController: UIViewController {
    var pagedContentViewController: PagedContentViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Posts"
        
        let backgroundColors = [UIColor.blue, UIColor.red, UIColor.yellow, UIColor.brown, UIColor.cyan, UIColor.green, UIColor.black]
        
        let tabs = ["view1", "view2", "view3", "view4"].enumerated().map { index, title -> PagedContentTab in
            
            let view = UIView()
            view.backgroundColor = backgroundColors[index]
            return PagedContentTab(title: title, view: view)
        }
        pagedContentViewController?.update(tabs: tabs)
        pagedContentViewController?.isSwipingBetweenTabsEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pagedContent" {
            pagedContentViewController = segue.destination as? PagedContentViewController
        }
    }

}

