//
//  RecordingsViewController.swift
//  jMusic
//
//  Created by Brillio Mac Mini 3 on 27/12/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit
import AVFoundation
class RecordingsViewController: UIViewController,AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate {
    var savedRecordings=Array<Any>()
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var timer = Timer()
    var cellTimer = Timer()
    var audioPlayer:AVAudioPlayer!
    var previousPlayButtonTag:Int=0
//    var audioEngine:AVAudioEngine!
//    var audioFile:AVAudioFile!
    
    var currentCMTime:CMTime=CMTimeMake(0, 1)
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordingsTableView: UITableView!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var recordingsInnerView: UIView!
    //MARK: - view cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        self.recordingsTableView.delegate=self
        self.recordingsTableView.dataSource=self
        self.recordingsTableView.register(UINib(nibName: "RecordingCustomTVCell", bundle: nil), forCellReuseIdentifier: "recordingCustomCell")
        recordingsInnerView.layer.cornerRadius = 15
        saveButton.layer.cornerRadius=8
        self.getAudioFilesListFromDirectory()
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
    //MARK: - IB Action Methods
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

    
    @IBAction func saveRecording(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Save your recording", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            // do something with textField
            //1.save the recording
            self.renameAudioFile(newName: textField.text!)
            //2.update the table
            self.getAudioFilesListFromDirectory()
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
        finishRecording(success: false)
        UIView.animate(withDuration: 10, animations: {
            self.view.sendSubview(toBack: self.recordingView)
        }, completion: nil)
        currentCMTime=CMTimeMake(0, 1)
        self.updateCurrentTime()
    }
    //MARK: - Recording Methods
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
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
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
    //MARK: - Helpers
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func getAudioFilesListFromDirectory(){
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            savedRecordings = fileURLs.filter{ $0.pathExtension == "m4a" }
            self.recordingsTableView.reloadData()
        } catch {
            print("Error while enumerating files : \(error.localizedDescription)")
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
    func playClicked(_ sender: UIButton){
        if(sender.tag==previousPlayButtonTag){
            audioPlayer?.stop()
            previousPlayButtonTag=0
            cellTimer.invalidate()
            resetAllCellsDisplay()
            return
        }
        resetAllCellsDisplay()
        if let image = UIImage(named: "stop") {
            sender.setImage(image, for: .normal)
        }
        let selectedCellIndex:Int = sender.tag - 1000
        let url = savedRecordings[selectedCellIndex] as! URL
        do {
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.play()
            cellTimer.invalidate()
            cellTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: selectedCellIndex, repeats: true)
            previousPlayButtonTag = sender.tag
        } catch {
            // couldn't load file :(
        }
    }
    func resetAllCellsDisplay(){
        let cells = self.recordingsTableView.visibleCells as! Array<RecordingCustomTVCell>
        for cell in cells{
            if let image = UIImage(named: "play") {
                cell.playButton.setImage(image, for: .normal)
            }
            cell.slider.value=0.0
        }
    }
    func updateSlider(timer:Timer){
        let index:Int = timer.userInfo as! Int
        let currentItemDuration:TimeInterval = (audioPlayer?.duration)!
        let slider:UISlider = self.view.viewWithTag(index+2000) as! UISlider
        slider.minimumValue=0.0
        slider.maximumValue=Float(currentItemDuration)
        slider.setValue(Float((audioPlayer?.currentTime)!), animated: false)
    }
    //MARK: - AVAudioPlayer Delegates
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //You can stop the audio
        audioPlayer.stop()
        previousPlayButtonTag=0
        resetAllCellsDisplay()
        
    }
    //MARK: - tableView delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return savedRecordings.count //number of sections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1.init cell
        let cell:RecordingCustomTVCell = tableView.dequeueReusableCell(withIdentifier: "recordingCustomCell", for: indexPath) as! RecordingCustomTVCell
        let recordingPath:String = (savedRecordings[indexPath.section] as! URL).path
        var directory:String=getDocumentsDirectory().path
        directory.append("/")
        let recordingFileName:String=recordingPath.replacingOccurrences(of: directory, with: "", options: .literal, range: nil)
        let recordingName=recordingFileName.replacingOccurrences(of: ".m4a", with: "", options: .literal, range: nil)
        cell.recordingName.text = recordingName
        // 2.cell design
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth=0.5
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.masksToBounds = true
        cell.backgroundColor = UIColor.clear
        // 3.add tags
        cell.playButton.tag = 1000 + indexPath.section
        cell.slider.tag = 2000 + indexPath.section
        cell.playButton.addTarget(self, action: #selector(playClicked), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            do {
                let fileManager = FileManager.default
                let filePath:String = (savedRecordings[indexPath.section] as! URL).path
                // Check if file exists
                if fileManager.fileExists(atPath: filePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: filePath)
                    getAudioFilesListFromDirectory()
                } else {
                    print("File does not exist")
                }
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
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
