//
//  PDFViewController.swift
//  Bezier
//
//  Created by Чингиз Б on 22.06.17.
//  Copyright © 2017 Y Media Labs. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          //UIApplication.shared.isStatusBarHidden = true
        
       // webView.isUserInteractionEnabled = true
        webView.scalesPageToFit = true

        if let pdf = Bundle.main.url(forResource: "condensing_boilers_2016", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(url: pdf)
            webView.loadRequest(req as URLRequest)
        }
        
      
   
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }



}
