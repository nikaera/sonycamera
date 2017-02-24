//
//  ViewController.swift
//  test
//
//  Created by 野口拓馬 on 2017/02/17.
//  Copyright © 2017年 Takuma Noguchi. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController, SSDPDiscoveryDelegate{
    
    
    @IBOutlet weak var ImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func tapBtn(_ sender: UIButton) {
        ServiceDiscovery().searchForServices()
        
    }
    
    @IBAction func checkCurrentMode(_ sender: UIButton) {
        //tap after Session Closed
        ServiceDiscovery().getCurrentMode()
    }
    
    
    @IBAction func setShootMode(_ sender: UIButton) {
        ServiceDiscovery().setShootMode()
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        ServiceDiscovery().takePic()
        
    }
    
    @IBAction func tapShowImage(_ sender: UIButton) {
        let responseDic: [String: Any] = ServiceDiscovery().resultUserDefoult.dictionary(forKey: "response")!
        print(responseDic["result"] as! String)
        let imageURL = URL(string: responseDic["result"] as! String)
        let data = try? Data(contentsOf: imageURL!)
        
        ImageView.image = UIImage(data: data!)
        ImageView.contentMode = .scaleToFill
    }
    
    @IBAction func tapGetBtn(_ sender: UIButton) {
        ServiceDiscovery().toLiveViewURL()
    }
    
    @IBAction func accessURL(_ sender: UIButton) {
        ServiceDiscovery().getLiveview()
    }


}
