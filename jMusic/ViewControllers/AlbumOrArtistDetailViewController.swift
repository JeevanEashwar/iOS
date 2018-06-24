//
//  AlbumOrArtistDetailViewController.swift
//  jMusic
//
//  Created by Jeevan on 24/06/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit
protocol AlbumArtistSongSelectedDelegate {
    func albumOrArtistSongSelected(_ songModel:SongsModel)
}
class AlbumOrArtistDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var songsModelArray = [SongsModel]()
    var currentSongIndex = -1
    var delegate:AlbumArtistSongSelectedDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "SongsListTableViewCell", bundle: nil), forCellReuseIdentifier: "songsListTableViewCell")
        // Do any additional setup after loading the view.
        if let imageData = songsModelArray.first?.imageData {
            detailImageView.image = UIImage(data: imageData)
        }
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    func spinViewWithAnimation(_ options:UIViewAnimationOptions, _imageView:UIImageView){
        _imageView.transform = .identity
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            _imageView.transform = _imageView.transform.scaledBy(x: 1.05, y: 1.05)
            
        }, completion:{finished in
            if(finished){
                _imageView.transform = .identity
                self.spinViewWithAnimation(.beginFromCurrentState, _imageView: _imageView)
                
            }
        })
    }
}
extension AlbumOrArtistDetailViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsModelArray.count
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
        delegate?.albumOrArtistSongSelected(songsModelArray[indexPath.row])
        tableView.reloadData()
    }
    
}
