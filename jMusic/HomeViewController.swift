//
//  FirstViewController.swift
//  jMusic
//
//  Created by Jeevan on 22/07/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
class HomeViewController: UIViewController,AVAudioPlayerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    //variables
    var songsList=[Any]()
    var allSongsDetails = [String: Array<Any>]()
    var audioPlayer: AVPlayer?
    var playerItem:AVPlayerItem?
    var currentPlayTime:TimeInterval?
    var timer = Timer()
    var imageCache : NSCache<AnyObject, UIImage> = NSCache()
    var songImage:UIImage!
    var selectedSongIndex:Int = 0
    //outlets
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songsCollectionView: UICollectionView!
    @IBOutlet weak var playerLayoutView: UIView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var progressIndicator: UISlider!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    // MARK: VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        updateViewTheme(themeStyle: appDelegate.ApplicationThemeStyleDefault)
    
        songsCollectionView.dataSource=self
        songsCollectionView.delegate=self
        //songsCollectionView.decelerationRate=UIScrollViewDecelerationRateFast
        songsCollectionView.isPagingEnabled = true
        let nib = UINib(nibName: "SongInfoCell", bundle: nil)
        songsCollectionView.register(nib, forCellWithReuseIdentifier: "songInfoCell")
        var jsonResponse:Any?
        if let path = Bundle.main.path(forResource: "songs", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                 jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
            } catch {
                // handle error
                print("Error deserializing JSON: \(error)")
            }
            songsList=(jsonResponse as? [Any])!
            getAllSongsMetaData()
        }
        do {
            let firstSongString:String = (songsList[0] as! [String:String])["songUrl"]!
            let url = URL(string: firstSongString)
            playerItem = AVPlayerItem(url: url!)
            audioPlayer = AVPlayer(playerItem: playerItem)
            let currentItemDurationAsCMTime:CMTime = (audioPlayer?.currentItem?.asset.duration)!
            if(!(currentItemDurationAsCMTime.seconds.isNaN||currentItemDurationAsCMTime.seconds.isInfinite)){
                songDurationLabel.text = changeTimeIntervalToDisplayableString(time: currentItemDurationAsCMTime.seconds)
                progressIndicator.minimumValue=0.0
                progressIndicator.maximumValue=Float(currentItemDurationAsCMTime.seconds)
                
            }
            if let metadataList = playerItem?.asset.metadata{
                for item in metadataList {
                    if item.commonKey != nil && item.value != nil {
                        if item.commonKey  == "title" {
                            print("title:\(item.stringValue!)")
                            songNameLabel.text = item.stringValue!
                            songNameLabel.translatesAutoresizingMaskIntoConstraints = false
                            setupAutoLayout(label: songNameLabel)
                            if(songNameLabel.isTruncated()){
                                startMarqueeLabelAnimation(label: songNameLabel)
                            }
                        }
                        if item.commonKey   == "artist" {
                            print("artist:\(item.stringValue!)")
                            artistLabel.text = item.stringValue
                        }
                        if item.commonKey  == "artwork" {
                            if let image = UIImage(data: (item.value as! NSData) as Data) {
                                //nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
                                print("imageDesc:\(image.description)")
                                songImage = image
                            }
                        }
                    }
                }
                
            }

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.finishedPlaying(myNotification:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: audioPlayer?.currentItem)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "songInfoCell"
        let cell:SongInfoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SongInfoCell
        cell.songThumbnailImage.tag = 3000+indexPath.item //3000 tag for song imageview
        cell.songCellPlayButton.tag = 2000+indexPath.item //2000 tag for play buttons in songsCollectionView cells
        cell.songCellPlayButton.addTarget(self, action: #selector(songSelectedFromCollectionView), for: .touchUpInside)
        cell.songThumbnailImage.image=UIImage(named: "musicSymbolsImage.png")
        let songString:String = (songsList[indexPath.item] as! [String:String])["songUrl"]!
        let songDetails:Array<Any> = allSongsDetails[songString]!
        cell.songName.text = songDetails[0] as? String
        cell.artistName.text = songDetails[1] as? String
        //if song has related image set cell image to that
        if let songRelatedData:Data = songDetails[2] as? Data {
            if(!songRelatedData.isEmpty && self.view.viewWithTag(3000+indexPath.item) != nil){
                (self.view.viewWithTag(3000+indexPath.item) as! UIImageView).image=UIImage(data: songRelatedData)
            }
        }
        //else put images of imageurls from songs.json file into the cells
        else{
            let imageUrlString = (songsList[indexPath.item] as! [String:String])["imageUrl"]
            let url = URL(string: imageUrlString!)!
            if let cachedVersionImage = imageCache.object(forKey: url as AnyObject) {
                // use the cached version
                cell.songThumbnailImage.image=cachedVersionImage
            } else {
                // create it from scratch then store in the cache
                getDataFromUrl(url:url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("no data for item at : \(indexPath.item)")
                        return }
                    DispatchQueue.main.async() {
                        if (self.view.viewWithTag(3000+indexPath.item) != nil){
                            (self.view.viewWithTag(3000+indexPath.item) as! UIImageView).image=UIImage(data: data)
                            self.imageCache.setObject(UIImage(data:data)!, forKey: url as AnyObject)
                        }
                    }
                }
            }
        }

        return cell;
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //highLightCellAtIndexPath(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: songsCollectionView.frame.size.width-6, height: songsCollectionView.frame.size.height-100)
    }
    // MARK: Outlet Methods
    @IBAction func playAudioAtSliderValue(_ sender: Any) {
        if audioPlayer?.rate == 0{
            audioPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(progressIndicator.value), 1000))
            playButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
        } else {
            audioPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(progressIndicator.value), 1000))
        }
        
    }
    @IBAction func playButtonClick(_ sender: Any) {
        
        if audioPlayer?.rate == 0{
            audioPlayer!.play()
            playButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
        } else {
            audioPlayer!.pause()
            playButton.setImage(UIImage(named: "playIcon.png"), for: .normal)
            timer.invalidate()
        }
    }
    // MARK: Helper Methods
    func updateViewTheme(themeStyle:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var vcBGColor:UIColor
        var vcTextColor:UIColor
        vcBGColor=appDelegate.defaultThemeBGColor
        vcTextColor=appDelegate.defaultThemeTextColor
        
        if(themeStyle==appDelegate.ApplicationThemeStyleDark){
            vcBGColor=appDelegate.darkThemeBGColor
            vcTextColor=appDelegate.darkThemeTextColor
        }
        else if(themeStyle==appDelegate.ApplicationThemeStyleDefault){
            vcBGColor=appDelegate.defaultThemeBGColor
            vcTextColor=appDelegate.defaultThemeTextColor
        }
        self.artistLabel.textColor=vcTextColor
        self.currentTimeLabel.textColor=vcTextColor
        self.songDurationLabel.textColor=vcTextColor
        self.songNameLabel.textColor=vcTextColor
        
        self.playerLayoutView.backgroundColor=vcBGColor
        self.songsCollectionView.backgroundColor=vcBGColor
        self.view.backgroundColor=vcBGColor
    }
    func updateCurrentTime(){
        let currentCMTime:CMTime=(audioPlayer?.currentTime())!
        let currentTime:TimeInterval=currentCMTime.seconds
        currentTimeLabel.text=changeTimeIntervalToDisplayableString(time: currentTime)
        progressIndicator.setValue(Float(currentTime), animated: false)
        print("loadedTimeRanges:\(String(describing: audioPlayer?.currentItem?.loadedTimeRanges))")
        print("seekableTimeRanges:\(String(describing: audioPlayer?.currentItem?.seekableTimeRanges))")
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
        let horizontalConstraintLeft = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.leftMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.leftMargin, multiplier: 1, constant: 20)
        let horizontalConstraintRight = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.rightMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.rightMargin, multiplier: 1, constant: 20)
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 20)
        
        self.playerLayoutView.addConstraints([horizontalConstraintLeft,horizontalConstraintRight, verticalConstraint])
        
    }
    func finishedPlaying(myNotification:Notification) {
        playButton.setImage(UIImage(named: "playIcon.png"), for: .normal)
        timer.invalidate()
        let stopedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
        stopedPlayerItem.seek(to:kCMTimeZero)
        currentTimeLabel.text=changeTimeIntervalToDisplayableString(time: kCMTimeZero.seconds)
        progressIndicator.setValue(Float(kCMTimeZero.seconds), animated: false)
    }
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    func getAllSongsMetaData(){
        for song in songsList{
            let songString:String = (song as! [String:String])["songUrl"]!
            let url:URL = URL(string:songString)!
            let newPlayerItem:AVPlayerItem = AVPlayerItem(url: url)
            let metadataList = newPlayerItem.asset.metadata
            var songName:String = ""
            var artistName:String = ""
            var imageData:Data = Data.init()
            for item in metadataList {
                if item.commonKey != nil && item.value != nil {
                    if item.commonKey  == "title" {
                        songName = item.stringValue!
                    }
                    if item.commonKey   == "artist" {
                        artistName = item.stringValue!
                    }
                    if item.commonKey  == "artwork" {
                        imageData = (item.value as! NSData) as Data
                    }
                }
            }
            let songDetailsArray = [songName,artistName,imageData] as [Any]
            allSongsDetails[songString] = songDetailsArray
        }
    }
    func songSelectedFromCollectionView(_ sender: UIButton){
        sender.isHidden = true
        if(self.view.viewWithTag(2000+selectedSongIndex) != nil){
            self.view.viewWithTag(2000+selectedSongIndex)?.isHidden = false
        }
        selectedSongIndex = sender.tag-2000
        let selectedSongString:String = (songsList[selectedSongIndex] as! [String:String])["songUrl"]!
        DispatchQueue.global(qos: .background).async {
            // Background Thread
            self.changeCurrentPlayerItem(urlString: selectedSongString)
            self.audioPlayer?.play()
            DispatchQueue.main.async {
                // Run UI Updates
                self.playButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
                self.timer.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
            }
        }
    }
    func changeCurrentPlayerItem(urlString:String){
        do {
            let url:URL = URL(string:urlString)!
            let newPlayerItem:AVPlayerItem = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(myNotification:)), name: .AVPlayerItemDidPlayToEndTime, object: newPlayerItem)

            audioPlayer?.replaceCurrentItem(with: newPlayerItem)
            let currentItemDurationAsCMTime:CMTime = (audioPlayer?.currentItem?.asset.duration)!
            if(!(currentItemDurationAsCMTime.seconds.isNaN||currentItemDurationAsCMTime.seconds.isInfinite)){
                songDurationLabel.text = changeTimeIntervalToDisplayableString(time: currentItemDurationAsCMTime.seconds)
                progressIndicator.minimumValue=0.0
                progressIndicator.maximumValue=Float(currentItemDurationAsCMTime.seconds)
            }
            DispatchQueue.main.async {
                // Run UI Updates
                self.songNameLabel.text = self.allSongsDetails[urlString]![0] as? String
                self.artistLabel.text = self.allSongsDetails[urlString]![1] as? String
            }
            
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        
        playButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
        timer.invalidate()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension UILabel {
    func countLabelLines() -> Int {
        // Call self.layoutIfNeeded() if your view is uses auto layout
        let myText = self.text! as NSString
        let attributes = [NSFontAttributeName : self.font]
        
        let labelSize = myText.boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
    func isTruncated() -> Bool {
        
        if (self.countLabelLines() > self.numberOfLines) {
            return true
        }
        return false
    }
}
extension AVPlayer {
    var isReadyToPlay:Bool {
        let timeRange = currentItem?.loadedTimeRanges.first as? CMTimeRange
        guard let duration = timeRange?.duration else { return false }
        let timeLoaded = Int(duration.value) / Int(duration.timescale) // value/timescale = seconds
        let loaded = timeLoaded > 0
        
        return status == .readyToPlay && loaded
    }
}
