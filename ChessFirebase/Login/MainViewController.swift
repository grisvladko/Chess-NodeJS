//
//  MainViewController.swift
//  ChessFirebase
//
//  Created by hyperactive on 23/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit
import AVKit

class MainViewController: UIViewController {

    @IBOutlet weak var LoginB: UIButton!
    @IBOutlet weak var SignUpB: UIButton!
    
    var videoPlayer: AVQueuePlayer?
    var videoPlayerLayer: AVPlayerLayer?
    var playerLooper: AVPlayerLooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }

    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.connect()
//        setUpVideo()
    }
    
    func setUpElements() {
        Utilities.editButton(LoginB)
        Utilities.editButton(SignUpB)
//        navigationController?.navigationBar.isHidden = true 
    }
    
    func setUpVideo() {
        guard let bundlePath = Bundle.main.path(forResource: "main", ofType: "mp4") else { return }
        
        let url = URL(fileURLWithPath: bundlePath)
        let item = AVPlayerItem(url: url)
        videoPlayer = AVQueuePlayer(playerItem: item)
        
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        videoPlayerLayer?.frame = self.view.frame
        videoPlayerLayer?.videoGravity = .resizeAspectFill
        self.view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        playerLooper = AVPlayerLooper(player: videoPlayer!, templateItem: item)
        
        videoPlayer?.isMuted = true
        videoPlayer?.playImmediately(atRate: 0.8)
    }
}
