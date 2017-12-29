//
//  RecordingCustomTVCell.swift
//  jMusic
//
//  Created by Brillio Mac Mini 3 on 28/12/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit

class RecordingCustomTVCell: UITableViewCell {

    @IBOutlet weak var recordingName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slider.isUserInteractionEnabled = false
    }

}
