//
//  RecordingsViewController.swift
//  jMusic
//
//  Created by Brillio Mac Mini 3 on 27/12/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit
import AVFoundation
class RecordingsViewController: UIViewController,AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var timer = Timer()
    var currentCMTime:CMTime=CMTimeMake(0, 1)
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordingsTableView: UITableView!
    @IBOutlet weak var recordingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        // permission granted
                        print("recordings permission granted.")
                    } else {
                        // failed to record!
                        print("recordings permission denied.")
                    }
                }
            }
        } catch {
            //failed to record!
            print("failed to record!")
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addNewRecording(_ sender: Any) {
        self.saveButton.isEnabled = false
        self.saveButton.alpha = 0.5
        UIView.animate(withDuration: 10, animations: {
            self.view.bringSubview(toFront: self.recordingView)
        }, completion: nil)
    }
    @IBAction func recordButtonClicked(_ sender: Any) {
        if audioRecorder == nil || !audioRecorder.isRecording {
            if let image = UIImage(named: "stop") {
                self.recordButton.setImage(image, for: .normal)
            }
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
            startRecording()
        } else {
            finishRecording(success: true)
            if let image = UIImage(named: "microphone") {
                self.recordButton.setImage(image, for: .normal)
            }
            timer.invalidate()
            currentCMTime=CMTimeMake(0, 1)
            self.updateCurrentTime()
        }
    }

    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false)
            timer.invalidate()
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            //enable save button
            self.saveButton.isEnabled = true
            self.saveButton.alpha = 1.0
        } else {
            // save button should remain disabled
            self.saveButton.isEnabled = false
            self.saveButton.alpha = 0.5
            // recording failed :(
        }
    }
    @IBAction func saveRecording(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Save your recording", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            // do something with textField
            //1.save the recording
            self.renameAudioFile(newName: textField.text!)
            //2.update the table
            
            //3.send the view back
            UIView.animate(withDuration: 10, animations: {
                self.view.sendSubview(toBack: self.recordingView)
            }, completion: nil)
            self.currentCMTime=CMTimeMake(0, 1)
            self.updateCurrentTime()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "recording1"
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func discardRecording(_ sender: Any) {
        UIView.animate(withDuration: 10, animations: {
            self.view.sendSubview(toBack: self.recordingView)
        }, completion: nil)
        currentCMTime=CMTimeMake(0, 1)
        self.updateCurrentTime()
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    func renameAudioFile(newName:String){
        let newAudioFilePath = getDocumentsDirectory().appendingPathComponent("\(newName).m4a")
        do{
            try FileManager.default.moveItem(at: audioRecorder.url, to: newAudioFilePath)
        }
        catch{
            print("could not rename the file")
        }
    }
    func updateCurrentTime(){
        let timeToAdd:CMTime = CMTimeMakeWithSeconds(1,1)
        let currentTime:TimeInterval=currentCMTime.seconds
        self.recordingTimeLabel.text=changeTimeIntervalToDisplayableString(time: currentTime)
        currentCMTime = CMTimeAdd(currentCMTime,timeToAdd)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
