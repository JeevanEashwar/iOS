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
class HomeViewController: UIViewController,AVAudioPlayerDelegate,UICollectionViewDataSource,UICollectionViewDelegate	 {
    
    var audioPlayer: AVAudioPlayer?
    var currentPlayTime:TimeInterval?
    var timer = Timer()
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songsCollectionView: UICollectionView!
    
    @IBOutlet weak var playerLayoutView: UIView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var progressIndicator: UISlider!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    var songImage:UIImage!
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        songsCollectionView.dataSource=self
        songsCollectionView.delegate=self
        songsCollectionView.decelerationRate=UIScrollViewDecelerationRateFast
        let nib = UINib(nibName: "SongInfoCell", bundle: nil)
        songsCollectionView.register(nib, forCellWithReuseIdentifier: "songInfoCell")
        let soundURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "ShapeOfYou", ofType: "mp3")!)
        let audioInfo = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo:[NSObject:AnyObject] = [:]
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL as URL)
            audioPlayer!.delegate = self
            songDurationLabel.text = changeTimeIntervalToDisplayableString(time: audioPlayer!.duration)
            progressIndicator.minimumValue=0.0
            progressIndicator.maximumValue=Float(audioPlayer!.duration)
            songNameLabel.text="Shape of you - Ed Shereen. Shape of you mp3"
            songNameLabel.translatesAutoresizingMaskIntoConstraints = false
            setupAutoLayout(label: songNameLabel)
            if(songNameLabel.isTruncated()){
                startMarqueeLabelAnimation(label: songNameLabel)
            }
            /****************************/
            let playerItem = AVPlayerItem(url: soundURL as URL)  //this will be your audio source
            print(soundURL.path!)
            
            let metadataList = playerItem.asset.metadata 
            for item in metadataList {
                if item.commonKey != nil && item.value != nil {
                    if item.commonKey  == "title" {
                        print(item.stringValue)
                        songNameLabel.text = item.stringValue
                    }
                    if item.commonKey   == "type" {
                        print(item.stringValue)
                        //nowPlayingInfo[MPMediaItemPropertyGenre] = item.stringValue
                    }
                    if item.commonKey  == "albumName" {
                        print(item.stringValue)
                        //nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = item.stringValue
                    }
                    if item.commonKey   == "artist" {
                        print(item.stringValue)
                        artistLabel.text = item.stringValue
                    }
                    if item.commonKey  == "artwork" {
                        if let image = UIImage(data: (item.value as! NSData) as Data) {
                            //nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
                            print(image.description)
                            songImage = image
                        }
                    }
                }
            }
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
        let horizontalConstraintLeft = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.leftMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.leftMargin, multiplier: 1, constant: 20)
        let horizontalConstraintRight = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.rightMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.rightMargin, multiplier: 1, constant: 20)
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 20)
        
        self.playerLayoutView.addConstraints([horizontalConstraintLeft,horizontalConstraintRight, verticalConstraint])
        
    }
    func highLightCellAtIndexPath(indexPath:IndexPath){
        songsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        for i in 0..<songsCollectionView.visibleCells.count {
            let cell = songsCollectionView.visibleCells[i]
            cell.layer.borderWidth=0.0
            cell.alpha=0.3
        }
        let cell = songsCollectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.cornerRadius=(cell?.layer.frame.width)!/2
        cell?.alpha=1.0
    }
    // MARK: CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "songInfoCell"
        let cell:SongInfoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SongInfoCell
        let image : UIImage = UIImage(named:"musicSymbolsImage")!
        cell.songThumbnailImage.image = songImage
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        highLightCellAtIndexPath(indexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.width+40)
    }
    func scrollToNearestVisibleCollectionViewCell() {
        let visibleCenterPositionOfScrollView = Float(songsCollectionView.contentOffset.x + (songsCollectionView!.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<songsCollectionView.visibleCells.count {
            let cell = songsCollectionView.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
            
            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = songsCollectionView.indexPath(for: cell)!.row
            }
        }
        if closestCellIndex != -1 {
            highLightCellAtIndexPath(indexPath: IndexPath(row: closestCellIndex, section: 0))
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestVisibleCollectionViewCell()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestVisibleCollectionViewCell()
        }
    }
    // MARK: Outlet Methods
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
    
    
}

