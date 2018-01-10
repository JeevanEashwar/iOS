//
//  SongInfoCell.swift
//  jMusic
//
//  Created by Jeevan on 03/08/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit

class SongInfoCell: UICollectionViewCell {
    
    @IBOutlet var songName: UILabel!
    @IBOutlet var artistName: UILabel!
    @IBOutlet weak var songCellPlayButton: UIButton!
    @IBOutlet weak var songThumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.songCellPlayButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
        self.songThumbnailImage.layer.cornerRadius = self.songThumbnailImage.frame.width/4.0
        self.songThumbnailImage.clipsToBounds = true
    }
    
}
