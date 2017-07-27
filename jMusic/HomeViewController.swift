//
//  FirstViewController.swift
//  jMusic
//
//  Created by Jeevan on 22/07/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit
import AVFoundation	

class HomeViewController: UIViewController,AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    var currentPlayTime:TimeInterval?
    @IBOutlet weak var playButton: UIButton!
    @IBAction func playButtonClick(_ sender: Any) {
        if (audioPlayer?.isPlaying)! {
            playButton.setImage(UIImage(named: "playIcon.png"), for: .normal)
            audioPlayer!.pause()
        } else if (audioPlayer!.prepareToPlay()){
            audioPlayer!.play()
            playButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let soundURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "ShapeOfYou", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL as URL)
            audioPlayer!.delegate = self
        }
        catch{   }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

