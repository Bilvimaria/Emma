//
//  GuidelineViewController.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-02-27.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//

import UIKit
import WebKit

class GuidelineViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = Bundle.main.url(forResource: "Emma",
                                     withExtension: "html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}
