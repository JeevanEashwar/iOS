//
//  SongsListTableViewCell.swift
//  jMusic
//
//  Created by Jeevan on 24/06/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit

class SongsListTableViewCell: UITableViewCell {

    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songDetails: UILabel!
    //this method overrides the cell frame to add horizontal padding
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            super.frame = CGRect.init(x: newFrame.origin.x+10, y: newFrame.origin.y+5, width: newFrame.width-20, height: newFrame.height-10)
            self.addShadow()
        }
    }
    func addShadow(){
        let shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                   y: 0,
                                                   width: self.frame.size.width,
                                                   height: self.frame.size.height))
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowColor = updateColorsAccordingToTheme().1.cgColor
        self.layer.opacity = 0.65
        self.layer.shadowRadius = 4
        self.layer.cornerRadius = 4
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
        songImage.layer.cornerRadius = 8
        songImage.layer.masksToBounds = true
        songTitle.textColor = updateColorsAccordingToTheme().1
        songDetails.textColor = updateColorsAccordingToTheme().1
        contentView.backgroundColor = updateColorsAccordingToTheme().0
    }
    override func layoutIfNeeded() {
        addShadow()
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
        songImage.layer.cornerRadius = 8
        songImage.layer.masksToBounds = true
        songTitle.textColor = updateColorsAccordingToTheme().1
        songDetails.textColor = updateColorsAccordingToTheme().1
        contentView.backgroundColor = updateColorsAccordingToTheme().0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func updateColorsAccordingToTheme() -> (UIColor,UIColor){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var vcBGColor:UIColor
        var vcTextColor:UIColor
        vcBGColor = UIColor.white
        vcTextColor = UIColor.black
        if(appDelegate.appTheme == .ApplicationThemeStyleDark){
            vcBGColor = UIColor.black
            vcTextColor = UIColor.white
        }
        else if(appDelegate.appTheme == .ApplicationThemeStyleDefault){
            vcBGColor = UIColor.white
            vcTextColor = UIColor.black
        }
        return (vcBGColor,vcTextColor)
    }
    
}
