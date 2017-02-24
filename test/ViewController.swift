//
//  ViewController.swift
//  test
//
//  Created by 野口拓馬 on 2017/02/17.
//  Copyright © 2017年 Takuma Noguchi. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController, SSDPDiscoveryDelegate, SampleStreamingDataDelegate, HttpAsynchronousRequestParserDelegate, SampleEventObserverDelegate {

    @IBOutlet weak var ImageView: UIImageView!
    var streamingDataManager: SampleStreamingDataManager!
    var eventObserver: SampleCameraEventObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventObserver = SampleCameraEventObserver.getInstance()
        streamingDataManager = SampleStreamingDataManager()
    }
    
    @available(iOS 2.0, *)
    public func didFetch(_ image: UIImage!) {
        ImageView.image = image
    }
    
    public func didStreamingStopped() {
    }
    
    public func parseMessage(_ response: Data!, apiName: String!) {
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
        if streamingDataManager.isStarted() {
            eventObserver.stop()
            self.streamingDataManager.stop()
        } else {
            eventObserver.start(with: self)
            
            let responseDic: [String: Any] = ServiceDiscovery().resultUserDefoult.dictionary(forKey: "response")!
            print(responseDic["result"] as! String)
            let liveviewUrl: String = responseDic["result"] as! String
            self.streamingDataManager.start(liveviewUrl, viewDelegate: self)
        }
    }
    
    @IBAction func tapGetBtn(_ sender: UIButton) {
        ServiceDiscovery().toLiveViewURL()
    }
    
    @IBAction func accessURL(_ sender: UIButton) {
        ServiceDiscovery().getLiveview()
    }


}
