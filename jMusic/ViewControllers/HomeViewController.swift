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
enum SongsLoopType {
    case SingleSong
    case LoopAlbum
    case None
}
enum ListShuffle {
    case Shuffle
    case noShuffle
}
class HomeViewController: UIViewController,AVAudioPlayerDelegate{
    //variables
    //var songsList                                   = [NSDictionary]()
    var songsModelArrayBeforeShuffling                = [SongsModel]()
    //var allSongsDetails                             = [String: Array<Any>]()
    var audioPlayer: AVPlayer?
    var playerItem:AVPlayerItem?
    var currentPlayTime:TimeInterval?
    var timer                                       = Timer()
    var imageCache : NSCache<AnyObject, UIImage>    = NSCache()
    var songImage:UIImage!
    var selectedSongIndex:Int                       = 0
    var animating:Bool                              = false
    var pauseName                                   = "pauseDark"
    var playName                                    = "playDark"
    var currentSongIndex                            = 0
    let domain                                      = "http://localhost/~jeevan"
    var songsLoopType:SongsLoopType                 = .None
    var listShuffle:ListShuffle                     = .noShuffle
    var previousOffset:CGFloat = CGFloat()
    var songsModelArray = [SongsModel]()
    //outlets
     @IBOutlet weak var superViewBackGroundImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songsCollectionView: UICollectionView!
    @IBOutlet weak var playerLayoutView: UIView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var progressIndicator: UISlider!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var largeWhiteIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var previousTrackButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var shuffleButton:UIButton!
    @IBOutlet weak var loopingButton:UIButton!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var listTypeSegmentControl: UISegmentedControl!

    
    // MARK: VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*1. All UI updates here*/
        addGradientToBackGround()
        setUpListViewAndItsSubviews()
        makeAllPlayerButtonsTintable()
        setCurrentStateForLoopAndShuffleButtons()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        updateViewTheme(themeStyle: appDelegate.ApplicationThemeStyleDefault)
        largeWhiteIndicator.isHidden = true // indicator at playbutton is hidden by default
        songsCollectionView.dataSource=self
        songsCollectionView.delegate=self
        songsCollectionView.isPagingEnabled = false
        songsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        let nib = UINib(nibName: "SongInfoCell", bundle: nil)
        songsCollectionView.register(nib, forCellWithReuseIdentifier: "songInfoCell")
        playButton.layer.cornerRadius = playButton.frame.size.width/2
        playButton.layer.masksToBounds = true
        /*2. All Background updates goes here */
        getSongsList()
        
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
        listTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    private func setUpListViewAndItsSubviews(){
        listView.isHidden = true
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: "SongsListTableViewCell", bundle: nil), forCellReuseIdentifier: "songsListTableViewCell")
    }
    private func setCurrentStateForLoopAndShuffleButtons(){
        songsLoopType = .None
        listShuffle = .noShuffle
        updateLoopButtonImage()
        updateShuffleButtonImage()
    }
    private func makeAllPlayerButtonsTintable(){
        //shuffle
        let shuffleButtonorigImage = UIImage(named: "MediaShuffle")
        let shuffleButtonTintedImage = shuffleButtonorigImage?.withRenderingMode(.alwaysTemplate)
        shuffleButton.setImage(shuffleButtonTintedImage, for: .normal)
        shuffleButton.tintColor = .black
        //loop
        let loopButtonorigImage = UIImage(named: "MediaLoopNone")
        let loopButtonTintedImage = loopButtonorigImage?.withRenderingMode(.alwaysTemplate)
        loopingButton.setImage(loopButtonTintedImage, for: .normal)
        loopingButton.tintColor = .black
        //nexttrack
        let nextButtonorigImage = UIImage(named: "nextTrackDark")
        let nextButtonTintedImage = nextButtonorigImage?.withRenderingMode(.alwaysTemplate)
        nextTrackButton.setImage(nextButtonTintedImage, for: .normal)
        nextTrackButton.tintColor = .black
        //previoustrack
        let prevButtonorigImage = UIImage(named: "previousTrackDark")
        let prevButtonTintedImage = prevButtonorigImage?.withRenderingMode(.alwaysTemplate)
        previousTrackButton.setImage(prevButtonTintedImage, for: .normal)
        previousTrackButton.tintColor = .black
        //playbutton
        let playButtonorigImage = UIImage(named: "playDark")
        let playButtonTintedImage = playButtonorigImage?.withRenderingMode(.alwaysTemplate)
        playButton.setImage(playButtonTintedImage, for: .normal)
        playButton.tintColor = .black
        
    }
    private func updateLoopButtonImage() {
        var image:UIImage?
        switch songsLoopType {
        case .None:
            image = UIImage(named: "MediaLoopNone")
        case .LoopAlbum:
            image = UIImage(named: "MediaLoopAlbum")
        case .SingleSong:
            image = UIImage(named: "MediaRepeatSingle")
        }
        let loopButtonorigImage = image
        let loopButtonTintedImage = loopButtonorigImage?.withRenderingMode(.alwaysTemplate)
        loopingButton.setImage(loopButtonTintedImage, for: .normal)
    }
    private func updateShuffleButtonImage() {
        var image:UIImage?
        switch listShuffle {
        case .noShuffle:
            image = UIImage(named: "MediaNoShuffle")
        case .Shuffle:
            image = UIImage(named: "MediaShuffle")
        }
        let shuffleButtonorigImage = image
        let shuffleButtonTintedImage = shuffleButtonorigImage?.withRenderingMode(.alwaysTemplate)
        shuffleButton.setImage(shuffleButtonTintedImage, for: .normal)
    }
    private func addGradientToBackGround(){
        let view = UIView(frame: self.view.frame)
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        //        let firstColor = UIColor(red: 207/255, green: 217/255, blue: 223/255, alpha: 0.7).cgColor
        let lastColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        let firstColor = UIColor.clear.cgColor
        //let lastColor = UIColor.black.cgColor
        gradient.colors = [lastColor,firstColor,lastColor,firstColor,lastColor]
        gradient.locations = [0.0,0.3,0.5,0.8,1.0]
        view.layer.insertSublayer(gradient, at: 0)
        superViewBackGroundImageView.addSubview(view)
        superViewBackGroundImageView.bringSubview(toFront: view)
        // 1
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.regular)
        // 2
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        blurView.alpha = 0.9
        // 3
        superViewBackGroundImageView.addSubview(blurView)
    }
    func setUpProgressIndicatorStyle(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.appTheme == .ApplicationThemeStyleDark){
            let thumbImageNormal = #imageLiteral(resourceName: "lightCD") // UIImage(named: "SliderThumb-Normal")
            progressIndicator.setThumbImage(thumbImageNormal, for: .normal)
            progressIndicator.minimumTrackTintColor = UIColor.magenta
            progressIndicator.maximumTrackTintColor = UIColor.white
        }
        else{
            let thumbImageNormal = #imageLiteral(resourceName: "darkCD") // UIImage(named: "SliderThumb-Normal")
            progressIndicator.setThumbImage(thumbImageNormal, for: .normal)
            progressIndicator.minimumTrackTintColor = UIColor.init(red: 80.0/255.0, green: 39/255.0, blue: 132/255.0, alpha: 1.0)
            progressIndicator.maximumTrackTintColor = UIColor.lightGray
        }
    }
    
   
    // MARK: Outlet Methods
    @IBAction func showListButton(_ sender: Any) {
        listTableView.reloadData()
        listView.isHidden = !listView.isHidden
    }
    @IBAction func playAudioAtSliderValue(_ sender: Any) {
        if audioPlayer?.rate == 0{
            audioPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(progressIndicator.value), 1000))
            playButton.setImage(UIImage(named: pauseName), for: .normal)
            playButton.layer.borderWidth = 0
            if let metaDataArray = audioPlayer?.currentItem?.asset.metadata{
                for item in metaDataArray{
                    if item.commonKey  == "artwork" {
                        if let image = UIImage(data: (item.value as! NSData) as Data) {
                            playButton.setImage(image, for: .normal)
                            playButton.layer.borderWidth = 2
                        }
                    }
                }
            }
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
        } else {
            audioPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(progressIndicator.value), 1000))
        }
        
    }
    @IBAction func playButtonClick(_ sender: Any) {
        if audioPlayer?.rate == 0{
            startSpin()
            audioPlayer!.play()
            playButton.setImage(UIImage(named: pauseName), for: .normal)
            playButton.layer.borderWidth = 0
            if let metaDataArray = audioPlayer?.currentItem?.asset.metadata{
                for item in metaDataArray{
                    if item.commonKey  == "artwork" {
                        if let image = UIImage(data: (item.value as! NSData) as Data) {
                            playButton.setImage(image, for: .normal)
                            playButton.layer.borderWidth = 2
                        }
                    }
                }
            }
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
        } else {
            stopSpin()
            audioPlayer!.pause()
            playButton.setImage(UIImage(named: playName), for: .normal)
            playButton.layer.borderWidth = 0
            if let metaDataArray = audioPlayer?.currentItem?.asset.metadata{
                for item in metaDataArray{
                    if item.commonKey  == "artwork" {
                        if let image = UIImage(data: (item.value as! NSData) as Data) {
                            playButton.setImage(image, for: .normal)
                            playButton.layer.borderWidth = 2
                        }
                    }
                }
            }
            timer.invalidate()
        }
    }
    @IBAction func playPreviousSong(_ sender: Any) {
        if(currentSongIndex>0){
            songsCollectionView.selectItem(at: IndexPath.init(item: currentSongIndex-1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            currentSongIndex -= 1
            playSongWithIndex(currentSongIndex)
            updatePlayerControlsUI()
        }
    }
    
    @IBAction func playNextSong(_ sender: Any) {
        if(currentSongIndex<songsModelArray.count-1){
            songsCollectionView.selectItem(at: IndexPath.init(item: currentSongIndex+1, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            currentSongIndex += 1
            playSongWithIndex(currentSongIndex)
            updatePlayerControlsUI()
        }
    }
    @IBAction func loopButtonClicked(_ sender: Any) {
        switch songsLoopType {
        case .None:
            songsLoopType = .LoopAlbum
        case .LoopAlbum:
            songsLoopType = .SingleSong
        case .SingleSong:
            songsLoopType = .None
        }
        updateLoopButtonImage()
    }
    @IBAction func shuffleButtonClicked(_ sender: Any) {
        switch listShuffle {
        case .noShuffle:
            listShuffle = .Shuffle
            songsModelArrayBeforeShuffling = songsModelArray
            songsModelArray.shuffle()
            songsCollectionView.reloadData()
        case .Shuffle:
            listShuffle = .noShuffle
            songsModelArray = songsModelArrayBeforeShuffling
            songsCollectionView.reloadData()
        }
        updateShuffleButtonImage()
    }

    // MARK: Helper Methods
    func updatePlayerControlsUI() {
        if !previousTrackButton.isEnabled {
            previousTrackButton.alpha = 1.0
            previousTrackButton.isEnabled = true
        }
        if !nextTrackButton.isEnabled {
            nextTrackButton.alpha = 1.0
            nextTrackButton.isEnabled = true
        }
        if currentSongIndex == 0 {
            previousTrackButton.alpha = 0.5
            previousTrackButton.isEnabled = false
        }
        else if currentSongIndex == songsModelArray.count-1 {
            nextTrackButton.alpha = 0.5
            nextTrackButton.isEnabled = false
        }else{
            nextTrackButton.alpha = 1.0
            nextTrackButton.isEnabled = true
            previousTrackButton.alpha = 1.0
            previousTrackButton.isEnabled = true
        }
    }
    func spinViewWithAnimation(_ options:UIViewAnimationOptions){
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [], animations: {
            if let imageView = self.playButton.imageView{
                imageView.transform = imageView.transform.rotated(by: CGFloat(CGFloat.pi/2))
            }
        }, completion:{finished in
            if(finished){
                if (self.animating) {
                    // if flag still set, keep spinning with constant speed
                    self.spinViewWithAnimation(.beginFromCurrentState)
                }
//                else if (options != .curveEaseOut) {
//                    // one last spin, with deceleration
//                    //self.spinViewWithAnimation(.curveEaseOut)
//                }
            }
        })
    }
    func startSpin(){
        if(!animating){
            animating = !animating
            spinViewWithAnimation(.beginFromCurrentState)
        }
    }
    func stopSpin(){
        animating = false
    }
    func spinViewWithAnimation(_ options:UIViewAnimationOptions, _imageView:UIImageView){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            _imageView.transform = _imageView.transform.scaledBy(x: 1.05, y: 1.05)
            
        }, completion:{finished in
            if(finished){
                _imageView.transform = _imageView.transform.scaledBy(x: 1/1.05, y: 1/1.05)
                if (self.animating) {
                    // if flag still set, keep spinning with constant speed
                    self.spinViewWithAnimation(.beginFromCurrentState, _imageView: _imageView)
                }
            }
        })
    }
    func updateViewTheme(themeStyle:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var vcBGColor:UIColor
        var vcTextColor:UIColor
        var buttonsTintColor:UIColor?
        vcBGColor=appDelegate.defaultThemeBGColor
        vcTextColor=appDelegate.defaultThemeTextColor
        if(themeStyle==appDelegate.ApplicationThemeStyleDark){
            vcBGColor=appDelegate.darkThemeBGColor
            vcTextColor=appDelegate.darkThemeTextColor
            buttonsTintColor = UIColor.white
            self.playerLayoutView.backgroundColor = UIColor.black
            self.playerLayoutView.alpha = 0.95
        }
        else if(themeStyle==appDelegate.ApplicationThemeStyleDefault){
            vcBGColor=appDelegate.defaultThemeBGColor
            vcTextColor=appDelegate.defaultThemeTextColor
            buttonsTintColor = UIColor.black
            self.playerLayoutView.backgroundColor = UIColor.white
            self.playerLayoutView.alpha = 0.95
        }
        self.artistLabel.textColor=vcTextColor
        self.currentTimeLabel.textColor=vcTextColor
        self.songDurationLabel.textColor=vcTextColor
        self.songNameLabel.textColor=vcTextColor
        self.playButton.layer.borderColor = vcTextColor.cgColor
        self.view.backgroundColor=vcBGColor
        playButton.tintColor = buttonsTintColor
        previousTrackButton.tintColor = buttonsTintColor
        nextTrackButton.tintColor = buttonsTintColor
        shuffleButton.tintColor = buttonsTintColor
        loopingButton.tintColor = buttonsTintColor
        setUpProgressIndicatorStyle()
        
    }
    func updateCurrentTime(){
        let currentCMTime:CMTime=(audioPlayer?.currentTime())!
        let currentTime:TimeInterval=currentCMTime.seconds
        currentTimeLabel.text=changeTimeIntervalToDisplayableString(time: currentTime)
        progressIndicator.setValue(Float(currentTime), animated: false)
//        print("loadedTimeRanges:\(String(describing: audioPlayer?.currentItem?.loadedTimeRanges))")
//        print("seekableTimeRanges:\(String(describing: audioPlayer?.currentItem?.seekableTimeRanges))")
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
        UILabel.animate(withDuration: 10.0, delay: 0.0, options: ([.curveEaseOut]), animations: {() -> Void in
                label.frame.origin.x -= 150
            }, completion: nil)
        UILabel.animate(withDuration: 10.0, delay: 10.0, options: ([.curveEaseOut]), animations: {() -> Void in
            label.frame.origin.x -= 150
        }, completion:  {finished in
            label.frame.origin.x = 0
        })

    }
    func setupAutoLayout(label:UILabel) {
        let horizontalConstraintLeft = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.leftMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.leftMargin, multiplier: 1, constant: 20)
        let horizontalConstraintRight = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.rightMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.rightMargin, multiplier: 1, constant: -100)
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: playerLayoutView, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 20)
        self.playerLayoutView.addConstraints([horizontalConstraintLeft,horizontalConstraintRight, verticalConstraint])
        
    }
    func finishedPlaying(myNotification:Notification) {
        //loop check
        switch songsLoopType {
        case .None :
            timer.invalidate()
            self.stopSpin()
            let stopedPlayerItem: AVPlayerItem = myNotification.object as! AVPlayerItem
            stopedPlayerItem.seek(to:kCMTimeZero)
            currentTimeLabel.text=changeTimeIntervalToDisplayableString(time: kCMTimeZero.seconds)
            progressIndicator.setValue(Float(kCMTimeZero.seconds), animated: false)
        case .SingleSong :
            self.audioPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(0), 1000))
            self.audioPlayer?.play()
        case .LoopAlbum:
            NotificationCenter.default.removeObserver(self)
            if(currentSongIndex<songsModelArray.count-1){
                playNextSong(self)
            }else if currentSongIndex == songsModelArray.count-1 {
                currentSongIndex = 0
                songsCollectionView.selectItem(at: IndexPath.init(item: currentSongIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                playSongWithIndex(currentSongIndex)
                updatePlayerControlsUI()
            }
            
        }
    }
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    private func getSongsList() {
        guard let listUrl = URL.init(string: "\(domain)/list.php") else {return}
        let task = URLSession.shared.dataTask(with: listUrl, completionHandler: {data,response,error in
            guard let data = data else {
                print("List fetch failed with no data.")
                return
            }
            do {
                if let songsArray = try JSONSerialization.jsonObject(with: data) as? [NSDictionary]{
                    DispatchQueue.global(qos: .background).async {
                        self.getAllSongsMetaData(for: songsArray)
                        DispatchQueue.main.async {
                            self.songsCollectionView.reloadData()
                        }
                    }
                    if let firstSongPath = songsArray.first?["path"] as? String{
                        if let url = URL.init(string: "\(self.domain+firstSongPath).mp3") {
                            self.playerItem = AVPlayerItem(url: url)
                            self.audioPlayer = AVPlayer(playerItem: self.playerItem)
                            self.currentSongIndex = 0
                            DispatchQueue.main.async {
                                self.previousTrackButton.alpha = 0.5
                                self.previousTrackButton.isEnabled = false
                            }
                        }
                    }
                }

            }
            catch let parseError {
                print("Error in parsing songs list: \(parseError.localizedDescription)")
            }
            let currentItemDurationAsCMTime:CMTime = (self.audioPlayer?.currentItem?.asset.duration)!
            if(!(currentItemDurationAsCMTime.seconds.isNaN||currentItemDurationAsCMTime.seconds.isInfinite)){
                DispatchQueue.main.async {
                    self.songDurationLabel.text = self.changeTimeIntervalToDisplayableString(time: currentItemDurationAsCMTime.seconds)
                    self.progressIndicator.minimumValue=0.0
                    self.progressIndicator.maximumValue=Float(currentItemDurationAsCMTime.seconds)
                }
                
            }
            if let metadataList = self.playerItem?.asset.metadata{
                for item in metadataList {
                    if item.commonKey != nil && item.value != nil {
                        if item.commonKey  == "title" {
                            DispatchQueue.main.async {
//                                print("title:\(item.stringValue!)")
                                self.songNameLabel.text = item.stringValue!
                                self.songNameLabel.translatesAutoresizingMaskIntoConstraints = false
                                //self.setupAutoLayout(label: self.songNameLabel)
                                if(self.songNameLabel.isTruncated()){
                                    self.startMarqueeLabelAnimation(label: self.songNameLabel)
                                }
                            }
                            
                        }
                        if item.commonKey   == "artist" {
                            DispatchQueue.main.async {
//                                print("artist:\(item.stringValue!)")
                                self.artistLabel.text = item.stringValue
                            }
                            
                        }
                        if item.commonKey  == "artwork" {
                            if let image = UIImage(data: (item.value as! NSData) as Data) {
                                DispatchQueue.main.async {
                                    self.playButton.setImage(image, for: .normal)
                                    self.playButton.layer.borderWidth = 2
                                    self.songImage = image
                                }
                            }
                        }
                    }
                }
            }
        })
        task.resume()
    }
    func getAllSongsMetaData(for songsArray:[NSDictionary]){
        songsModelArray.removeAll()
        for songDict in songsArray{
            guard let songPath = songDict["path"] as? String else { continue }
            guard let url = URL.init(string: "\(domain+songPath)") else { continue }
            let newPlayerItem:AVPlayerItem = AVPlayerItem(url: url)
            let metadataList = newPlayerItem.asset.metadata
            var songName:String = ""
            var artistName:String = ""
            var albumName:String = ""
            var imageData:Data = Data.init()
            let songsModel = SongsModel()
            songsModel.urlPath = songPath
            for item in metadataList {
                if item.commonKey != nil && item.value != nil {
                    if item.commonKey  == "title" {
                        songName = item.stringValue!
                        songsModel.title = songName
                    }
                    if item.commonKey   == "artist" {
                        artistName = item.stringValue!
                        songsModel.artist = artistName
                    }
                    if item.commonKey  == "artwork" {
                        imageData = (item.value as! NSData) as Data
                        songsModel.imageData = imageData
                    }
                    if item.commonKey == "albumName" {
                        albumName = item.stringValue!
                        songsModel.albumName = albumName
                    }
                }
            }
            songsModelArray.append(songsModel)
            listTableView.reloadData()
//            let songDetailsArray = [songName,artistName,imageData] as [Any]
//            allSongsDetails[songPath] = songDetailsArray
        }
    }
    func songSelectedFromCollectionView(_ sender: UIButton){
        sender.isHidden = true
        self.playButton.isHidden = true
        largeWhiteIndicator.isHidden = false
        largeWhiteIndicator.startAnimating()
        if(self.view.viewWithTag(2000+selectedSongIndex) != nil){
            self.view.viewWithTag(2000+selectedSongIndex)?.isHidden = false
        }
        selectedSongIndex = sender.tag-2000
        currentSongIndex = selectedSongIndex
        updatePlayerControlsUI()
        if let firstSongPath = self.songsModelArray[selectedSongIndex].urlPath as? String {
            let selectedSongString = "\(self.domain+firstSongPath).mp3"
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                self.changeCurrentPlayerItem(urlString: selectedSongString, songIndex:self.selectedSongIndex)
                self.audioPlayer?.play()
                DispatchQueue.main.async {
                    // Run UI Updates
                    self.playButton.setImage(UIImage(named: self.pauseName), for: .normal)
                    self.playButton.layer.borderWidth = 0
                    self.timer.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
                    self.playButton.isHidden = false
                    self.largeWhiteIndicator.stopAnimating()
                    self.largeWhiteIndicator.isHidden = true
                }
            }
        }
    }
    func playSongWithIndex(_ songIndex:Int) {
        self.playButton.isHidden = true
        largeWhiteIndicator.isHidden = false
        largeWhiteIndicator.startAnimating()
        if(self.view.viewWithTag(2000+songIndex) != nil){
            self.view.viewWithTag(2000+songIndex)?.isHidden = false
        }
        
        if let songPath:String = self.songsModelArray[songIndex].urlPath as? String{
            let selectedSongString = "\(self.domain+songPath).mp3"
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                self.changeCurrentPlayerItem(urlString: selectedSongString, songIndex:songIndex)
                self.audioPlayer?.play()
                DispatchQueue.main.async {
                    // Run UI Updates
                    self.playButton.setImage(UIImage(named: self.pauseName), for: .normal)
                    self.playButton.layer.borderWidth = 0
                    self.timer.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
                    self.playButton.isHidden = false
                    if let metaDataArray = self.audioPlayer?.currentItem?.asset.metadata{
                        for item in metaDataArray{
                            if item.commonKey  == "artwork" {
                                if let image = UIImage(data: (item.value as! NSData) as Data) {
                                    self.playButton.setImage(image, for: .normal)
                                    self.playButton.layer.borderWidth = 2
                                }
                            }
                        }
                    }
                    self.largeWhiteIndicator.stopAnimating()
                    self.largeWhiteIndicator.isHidden = true
                    self.startSpin()
                }
            }
        }
        
    }
    func changeCurrentPlayerItem(urlString:String,songIndex: Int){
        do {
            let url:URL = URL(string:urlString)!
            let newPlayerItem:AVPlayerItem = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(myNotification:)), name: .AVPlayerItemDidPlayToEndTime, object: newPlayerItem)
            
            audioPlayer?.replaceCurrentItem(with: newPlayerItem)
            let currentItemDurationAsCMTime:CMTime = (audioPlayer?.currentItem?.asset.duration)!
            if(!(currentItemDurationAsCMTime.seconds.isNaN||currentItemDurationAsCMTime.seconds.isInfinite)){
                DispatchQueue.main.async {
                    self.songDurationLabel.text = self.changeTimeIntervalToDisplayableString(time: currentItemDurationAsCMTime.seconds)
                    self.progressIndicator.minimumValue=0.0
                    self.progressIndicator.maximumValue=Float(currentItemDurationAsCMTime.seconds)
                }
                
            }
            DispatchQueue.main.async {
                // Run UI Updates
                let songDetails = self.songsModelArray[songIndex]
                self.songNameLabel.text = songDetails.title
                if(self.songNameLabel.isTruncated()){
                    self.startMarqueeLabelAnimation(label: self.songNameLabel)
                }
                self.artistLabel.text = songDetails.artist
            }
            
        }
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
extension HomeViewController :  UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    // MARK: CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if songsModelArray.count>0{
            return songsModelArray.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "songInfoCell"
        let cell:SongInfoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SongInfoCell
        cell.songThumbnailImage.tag = 3000+indexPath.item //3000 tag for song imageview
        cell.songCellPlayButton.tag = 2000+indexPath.item //2000 tag for play buttons in songsCollectionView cells
        cell.songCellPlayButton.addTarget(self, action: #selector(songSelectedFromCollectionView), for: .touchUpInside)
        let songDetails = self.songsModelArray[indexPath.item]
        cell.songName.text = songDetails.title
        cell.artistName.text = songDetails.artist
        if let imageData = songDetails.imageData {
            cell.songThumbnailImage.image = UIImage(data: imageData)
        }else {
            cell.songThumbnailImage.image = UIImage(named: "appBackgroundImage.png")
        }
        return cell;
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //highLightCellAtIndexPath(indexPath: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: songsCollectionView.frame.size.width, height: songsCollectionView.frame.size.height-100)
    }
    //ScrollView Methods
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == songsCollectionView {
            if previousOffset > scrollView.contentOffset.x {
                guard let indexPathOfFirstVisibleCell = songsCollectionView.indexPathsForVisibleItems.sorted().first else { return }
                songsCollectionView.scrollToItem(at: indexPathOfFirstVisibleCell, at: .centeredHorizontally, animated: true)
            }else {
                guard let indexPathOfLastVisibleCell = songsCollectionView.indexPathsForVisibleItems.sorted().last else { return }
                songsCollectionView.scrollToItem(at: indexPathOfLastVisibleCell, at: .centeredHorizontally, animated: true)
            }
            previousOffset = scrollView.contentOffset.x
        }
        
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == songsCollectionView && !decelerate{
            scrollViewDidEndDecelerating(scrollView)
        }
    }

}
extension HomeViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songsModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songsListTableViewCell", for: indexPath) as! SongsListTableViewCell
        let songDetails = self.songsModelArray[indexPath.row]
        if let imageData = songDetails.imageData {
            cell.songImage.image = UIImage(data: imageData)
        }else {
            cell.songImage.image = UIImage(named: "appBackgroundImage.png")
        }
        cell.songTitle.text = songDetails.title
        cell.songDetails.text = "\(songDetails.albumName) \n \(songDetails.artist)"
        if indexPath.row == currentSongIndex {
            spinViewWithAnimation(.beginFromCurrentState, _imageView: cell.songImage)
            cell.songTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold)
        }else{
            cell.songTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentSongIndex = indexPath.row
        playSongWithIndex(currentSongIndex)
        updatePlayerControlsUI()
        tableView.reloadData()
    }
}
