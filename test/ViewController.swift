//
//  ViewController.swift
//  test
//
//  Created by 野口拓馬 on 2017/02/17.
//  Copyright © 2017年 Takuma Noguchi. All rights reserved.
//

import UIKit
import SystemConfiguration
import Hostess
import Alamofire

class ViewController: UIViewController, SSDPDiscoveryDelegate, SampleStreamingDataDelegate, HttpAsynchronousRequestParserDelegate, SampleEventObserverDelegate {

    @IBOutlet weak var ImageView: UIImageView!
    var streamingDataManager: SampleStreamingDataManager!
    var eventObserver: SampleCameraEventObserver!
    var isTethering: Bool = false
    var checkIpManager: SessionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventObserver = SampleCameraEventObserver.getInstance()
        streamingDataManager = SampleStreamingDataManager()
        
        let hostess = Hostess()
        let deviceIps = hostess.addresses.filter { $0.contains("172.20.10") }
        isTethering = deviceIps.count > 0
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1 // seconds
        configuration.timeoutIntervalForResource = 1 // seconds
        checkIpManager = Alamofire.SessionManager(configuration: configuration)
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
            self.streamingDataManager.stop()
        } else {
            let responseDic: [String: Any] = ServiceDiscovery().resultUserDefoult.dictionary(forKey: "response")!
            let result: String = responseDic["result"] as! String
            let liveviewUrl: String = result
            if isTethering {
                checkIp(liveviewUrl: liveviewUrl, last3: 2)
            } else {
                self.streamingDataManager.start(liveviewUrl, viewDelegate: self)
            }
        
        }
    }
    
    @IBAction func tapGetBtn(_ sender: UIButton) {
        ServiceDiscovery().toLiveViewURL()
    }
    
    @IBAction func accessURL(_ sender: UIButton) {
        ServiceDiscovery().getLiveview()
    }

    private func checkIp(liveviewUrl: String, last3: Int) {
        if last3 >= 255 {
            print("device not found..")
            return
        }
        
        let ipAddress: String = "172.20.10.\(last3)"
        print("try.. -> \(ipAddress)")
        checkIpManager.request("http://\(ipAddress):10000/sony/camera", method: .post, parameters: [
            "method": "getShootMode",
            "params": [],
            "id": 1,
            "version": "1.0"
            ], encoding: JSONEncoding.default).responseJSON(queue: DispatchQueue.main) { response in
                if response.result.isSuccess {
                    let tmpLiveviewUrl = NSURL(string: liveviewUrl)
                    let scheme: String = tmpLiveviewUrl!.scheme!
                    let port: String = String(describing: tmpLiveviewUrl!.port!)
                    let path: String = tmpLiveviewUrl!.path!
                    let query: String = tmpLiveviewUrl!.query!
                    self.streamingDataManager.start("\(scheme)://\(ipAddress):\(port)\(path)?\(query)", viewDelegate: self)
                } else {
                    if let strongSelf: ViewController = self {
                        strongSelf.checkIp(liveviewUrl: liveviewUrl, last3: last3 + 1)
                    }
                }
        }
    }

}
