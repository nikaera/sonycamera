//
//  ServiceDiscovery.swift
//  test
//
//  Created by 野口拓馬 on 2017/02/21.
//  Copyright © 2017年 Takuma Noguchi. All rights reserved.


import Foundation

public class ServiceDiscovery: NSObject{
    
    private let discovery: SSDPDiscovery = SSDPDiscovery.defaultDiscovery
    fileprivate var session: SSDPDiscoverySession?
    
    var ServiceTypeTag: String  = ""
    var ActionListTag: String = ""
    var tmpKey: String = ""
    var tmpVal: String = ""
    var tmpdic: [String:String] = ["":""]
    var urldic: [String:String] = ["":""]
    
    var resDic: [String:Any]!
    //userdefaoultの作成
    let urlDefault = UserDefaults.standard
    let resultUserDefoult = UserDefaults.standard
    
    public func searchForServices() {
        // Create the request for Sony camera
        let sonyHandyCam = SSDPSearchTarget.serviceType(schema: "schemas-sony-com", serviceType: "ScalarWebAPI", version: 1)

//        let allST = SSDPSearchTarget.all
        let request = SSDPMSearchRequest(delegate: self, searchTarget: sonyHandyCam)
//        let request = SSDPMSearchRequest(delegate: self, searchTarget: allST)
        // Start a discovery session for the request and timeout after 10 seconds of searching.
        self.session = try! discovery.startDiscovery(request: request, timeout: 10.0)

        //これでデバグできた
//        Logger.defaultLevel = .debug
//        Logger.attach(BasicConsoleLogger.logger)
        
    }
    
    
    
    public func getCurrentMode(){

        //userDefaultの読み込み
        urldic = urlDefault.dictionary(forKey: "urldic") as! [String : String]
        print(urldic["camera"]! as String)
     
        let cameraURLString = urldic["camera"]! as String
        
        let url: URL = URL(string: cameraURLString)!
//        let url: URL = URL(string: "http://172.20.10.3:10000/sony/camera")!
        
        //set body for POST in json
        let body: [String:Any] = [
            "method": "getShootMode",
            "params": [],
            "id": 1,
            "version": "1.0"
        ]
        
        //このやり方はRequestClassを使ってない
        postMethod(url: url, body: body)
        
        let body2: [String:Any] = ["method": "getEvent",
                                  "params": [false],
                                  "id": 1,
                                  "version": "1.0"
        ]
        
//        let url = URL(string: tmpdic["camera"] ?? "")
        postMethod(url: url, body: body2)
        

    }
    
    public func setShootMode(){
        urldic = urlDefault.dictionary(forKey: "urldic") as! [String : String]
        let cameraURLString = urldic["camera"]! as String
        let url: URL = URL(string: cameraURLString)!
        let body: [String:Any] = [
            "method": "setShootMode",
            "params": ["stil"],
            "id": 1,
            "version": "1.0"
        ]
        
        postMethod(url: url, body: body)
        
    }
    
    public func takePic(){
        urldic = urlDefault.dictionary(forKey: "urldic") as! [String : String]
        let cameraURLString = urldic["camera"]! as String
        let url: URL = URL(string: cameraURLString)!
//        let url: URL = URL(string: "http://172.20.10.3:10000/sony/camera")!
        let body: [String:Any] = [
            "method": "actTakePicture",
            "params": [],
            "id": 1,
            "version": "1.0"
        ]
        
        postMethod(url: url, body: body)
        resDic = resultUserDefoult.dictionary(forKey: "response")
//        print(resDic["result"] as! String)
    }
    
    public func toLiveViewURL(){
        urldic = urlDefault.dictionary(forKey: "urldic") as! [String : String]
        let cameraURLString = urldic["camera"]! as String
        let url: URL = URL(string: cameraURLString)!
        let body: [String:Any] = [
            "method": "startLiveview",
            "params": [],
            "id": 1,
            "version": "1.0"
        ]
        postMethod(url: url, body: body)
        
//        body = [
//            "method": "startRecMode",
//            "params": [],
//            "id": 1,
//            "version": "1.0"
//        ]
//        postMethod(url: url, body: body)
    }

    
    public func stopSearching() {
        self.session?.close()
        self.session = nil
    }
    
    public func getLiveview(){
        resDic = resultUserDefoult.dictionary(forKey: "response")
//        print(resDic ?? "")
        let liveViewURLString = resDic["result"] as! String
        print(liveViewURLString)
        let url = URL(string: liveViewURLString)
        get(url: url!, completionHandler: {data, response, error in
            if let res = response{
                print(res)
            }
            if let dat = data {
                print(dat)
            }
            if let err = error {
                print(err)
            }
        })
    }

    
    public func postMethod(url: URL, body: [String:Any]){
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            req.httpBody = try
                JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print(error.localizedDescription)
        }

        
        let task = URLSession.shared.dataTask(with: req, completionHandler: {dat, res, err in
            if err != nil{
                print(err!)
            } else {
//                let result = String(data: dat!, encoding: .utf8)!
//                print(result)
              
                do {
                    //パース
                    var tmpDic: [String:Any] = ["id": "",
                                                "result": ""]
                    let json: [String:Any] = try JSONSerialization.jsonObject(with: dat!, options: []) as! [String:Any]
                    tmpDic["id"] = json["id"] as! Int
//                    print(json["id"] as! Int)
                    if json["result"] as? NSArray != nil{

                        let jsonArray = json["result"] as! NSArray
                        if let jsonArray2: NSArray = jsonArray[0] as? NSArray{

//                            print(jsonArray2[0])
                            tmpDic["result"] = jsonArray2[0]
                        }else{
//                            print(json["id"] as! Int)
//                            print(jsonArray[0])
                            tmpDic["result"] = jsonArray[0]
                        }
                        if json["error"] != nil{
//                            print(json["error"].debugDescription)
                        }
//                        print(tmpDic)
                        self.resultUserDefoult.set(tmpDic, forKey: "response")
                    }
                    print(json)
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }
    
    
    
    // GET METHOD
    public func get(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request: URLRequest = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    
}



extension ServiceDiscovery: SSDPDiscoveryDelegate, XMLParserDelegate{
    
    
    public func discoveredDevice(response: SSDPMSearchResponse, session: SSDPDiscoverySession) {
        print("Found device \(response)\n")
        
    }
    
    public func discoveredService(response: SSDPMSearchResponse, session: SSDPDiscoverySession) {
        
        print("Found service \(response)\n")
        
        let url = response.location
        
        guard let parser = XMLParser(contentsOf: url) else {return}
        parser.delegate = self
        parser.parse()
    }
    
    //start parse
    public func parserDidStartDocument(_ parser: XMLParser) {
        print("start parse")
    }
    
    //find start tag
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        print("tag :" + elementName)
        
        if elementName == "av:X_ScalarWebAPI_ServiceType"{
            ServiceTypeTag = elementName
//            print(ServiceTypeTag)
        }
        
        if elementName == "av:X_ScalarWebAPI_ActionList_URL"{
            ActionListTag = elementName
        }
    }
    
    //data between tag and tag
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
//        print("element:" + string)
        if ServiceTypeTag == "av:X_ScalarWebAPI_ServiceType" {
//            print(string)
            tmpKey = string
        }
        if ActionListTag == "av:X_ScalarWebAPI_ActionList_URL"{
            tmpVal = string + "/" + tmpKey
        }
    }

    
    //find finish tag
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        print("/tag :" + elementName)
        tmpdic[tmpKey] = tmpVal
        if ServiceTypeTag == "av:X_ScalarWebAPI_ServiceType"{
           ServiceTypeTag = ""
        }
        if ActionListTag == "av:X_ScalarWebAPI_ActionList_URL"{
            ActionListTag = ""
        }
    }
    
    //finish parse
    public func parserDidEndDocument(_ parser: XMLParser) {
        print("finish parse")
//        print(tmpdic)
        tmpdic.removeValue(forKey: "")
//        print(tmpdic)
    }
    
    
    public func closedSession(_ session: SSDPDiscoverySession) {
//        print(tmpdic)
//        urlDefault.removeObject(forKey: "urldic")
        urlDefault.set(tmpdic, forKey: "urldic")
//        print(urlDefault)
//        print(tmpdic["camera"] ?? "")

        print("Session closed\n")
        
        
    }
    
    
}
