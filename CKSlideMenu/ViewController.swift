//
//  ViewController.swift
//  CKSlideMenu
//
//  Created by ck on 2017/6/19.
//  Copyright © 2017年 caike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var slideMenu:CKSlideMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = "Demo"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func example1(_ sender: Any) {
        let vc = CKChildViewController()
        vc.exmapleIndex = 1
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func example2(_ sender: Any) {
        let vc = CKChildViewController()
        vc.exmapleIndex = 2
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func example3(_ sender: Any) {
        let vc = CKChildViewController()
        vc.exmapleIndex = 3
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func example4(_ sender: Any) {
        let vc = CKChildViewController()
        vc.exmapleIndex = 4
        navigationController?.pushViewController(vc, animated: true)
    }
}

