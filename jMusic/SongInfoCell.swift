//
//  SongInfoCell.swift
//  jMusic
//
//  Created by Jeevan on 03/08/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit

class SongInfoCell: UICollectionViewCell {

    @IBOutlet weak var songCellPlayButton: UIButton!
    @IBOutlet weak var songThumbnailImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.songCellPlayButton.setImage(UIImage(named: "playIcon.png"), for: UIControlState.normal)
        self.songThumbnailImage.layer.cornerRadius = self.songThumbnailImage.frame.width/2.0
        self.songThumbnailImage.clipsToBounds = true
    }

}
