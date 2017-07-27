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
    var timer = Timer()
    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBAction func playButtonClick(_ sender: Any) {
        if (audioPlayer?.isPlaying)! {
            playButton.setImage(UIImage(named: "playIcon.png"), for: .normal)
            audioPlayer!.pause()
            timer.invalidate()
        } else if (audioPlayer!.prepareToPlay()){
            audioPlayer!.play()
            playButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
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
    func updateCurrentTime(){
        let currentTime:TimeInterval=audioPlayer!.currentTime
        var minutes = floor(currentTime/60)
        var seconds = Int(round(currentTime - minutes * 60))
        if(seconds==60){
            seconds=0
            minutes=minutes+1
        }
        let stringMinutes:String
        let stringSeconds:String
        if(Int(minutes)<10){
            stringMinutes="0\(Int(minutes))"
        }
        else{
            stringMinutes="\(Int(minutes))"
        }
        if(seconds<10){
            stringSeconds="0\(seconds)"
        }
        else{
            stringSeconds="\(seconds)"
        }
        currentTimeLabel.text="\(stringMinutes):\(stringSeconds)"
    }
    

}

