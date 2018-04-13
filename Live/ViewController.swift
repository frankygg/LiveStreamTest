//
//  ViewController.swift
//  Live
//
//  Created by 大容 林 on 2018/4/13.
//  Copyright © 2018年 DjangoCode. All rights reserved.
//

import UIKit
import LFLiveKit
//MARK: - Getters and Setters


class ViewController: UIViewController ,LFLiveSessionDelegate {
    
    @IBAction func Watch(_ sender: Any) {
    player?.play()
    }
    @IBOutlet weak var myPreView: UIView!
    let rtmpURL = "rtmp://206.189.43.63/live/livestream1"
    var player : PLPlayer?
    lazy var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low3, outputImageOrientation: UIInterfaceOrientation.portrait)
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        
        session?.delegate = self
        session?.preView = self.myPreView
        session?.running = true
        return session!
    }()
    let option = PLPlayerOption.default()
    

    
    
    @IBAction func liveAction(_ sender: UIButton) {
        startLive()
        
    }
    //MARK: - Event
    func startLive() -> Void {
        myPreView.isHidden = false
        let stream = LFLiveStreamInfo()
        stream.url =  rtmpURL
        session.startLive(stream)
    }
    
    func stopLive() -> Void {
        session.stopLive()
    }
    func authorize()->Bool{
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        
        switch status {
        case .authorized:
            return true
            
        case .notDetermined:
            // 请求授权
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: {
                (status) in
                DispatchQueue.main.async(execute: { () -> Void in
                    _ = self.authorize()
                })
            })
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            let alertController = UIAlertController(title: "麦克风访问受限",
                                                    message: "点击“设置”，允许访问您的麦克风",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
            
            let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
                (action) -> Void in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],
                                                  completionHandler: {
                                                    (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
        }
        return false
    }
    func cameraPermissions() -> Bool{
        
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if(authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted) {
            return false
        }else {
            return true
        }
        
    }
    override func viewDidLoad() {
        cameraPermissions()
        authorize()
        playerConfigure()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func playerConfigure(){
        option.setOptionValue(15, forKey: PLPlayerOptionKeyTimeoutIntervalForMediaPackets)
        option.setOptionValue(1000, forKey: PLPlayerOptionKeyMaxL1BufferDuration)
        option.setOptionValue(1000, forKey: PLPlayerOptionKeyMaxL2BufferDuration)
        option.setOptionValue(true, forKey: PLPlayerOptionKeyVideoToolbox)
        self.player = PLPlayer(liveWith: URL(string: rtmpURL), option: option)
        player?.playerView?.frame = myPreView.frame
        myPreView.isHidden = true
        self.view.addSubview((player?.playerView)!)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



