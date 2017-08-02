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

    @IBOutlet weak var playerLayoutView: UIView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var progressIndicator: UISlider!
    @IBOutlet weak var songDurationLabel: UILabel!
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
            songDurationLabel.text = changeTimeIntervalToDisplayableString(time: audioPlayer!.duration)
            progressIndicator.minimumValue=0.0
            progressIndicator.maximumValue=Float(audioPlayer!.duration)
            songNameLabel.text="Shape of you - Ed Shereen. Shape of you mp3"
            songNameLabel.translatesAutoresizingMaskIntoConstraints = false
            setupAutoLayout(label: songNameLabel)
            startMarqueeLabelAnimation(label: songNameLabel)
        }
        catch{   }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateCurrentTime(){
        let currentTime:TimeInterval=audioPlayer!.currentTime
        currentTimeLabel.text=changeTimeIntervalToDisplayableString(time: currentTime)
        progressIndicator.setValue(Float(currentTime), animated: false)
    }
    func changeTimeIntervalToDisplayableString(time:TimeInterval)->String{
        var minutes = floor(time/60)
        var seconds = Int(round(time - minutes * 60))
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
        return "\(stringMinutes):\(stringSeconds)"
    }
    func startMarqueeLabelAnimation(label:UILabel) {
        
        DispatchQueue.main.async(execute: {
            
            UILabel.animate(withDuration: 10.0, delay: 0.0, options: ([.curveEaseOut, .repeat]), animations: {() -> Void in
                label.frame.origin.x-=200
                
            }, completion:  nil)
        })
    }
    func setupAutoLayout(label:UILabel) {
        let horizontalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.leftMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.leftMargin, multiplier: 1, constant: 20)
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 110)
        
        self.playerLayoutView.addConstraints([horizontalConstraint, verticalConstraint])
        
    }
    @IBAction func playAudioAtSliderValue(_ sender: Any) {
        if (audioPlayer?.isPlaying)! {
            audioPlayer!.currentTime=TimeInterval(progressIndicator.value)
        }else if (audioPlayer!.prepareToPlay()){
            audioPlayer!.play(atTime: TimeInterval(progressIndicator.value))
            playButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
            
        }
        
    }    

}

