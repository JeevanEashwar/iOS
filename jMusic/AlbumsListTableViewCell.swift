//
//  AlbumsListTableViewCell.swift
//  jMusic
//
//  Created by Jeevan on 24/06/18.
//  Copyright © 2018 personal. All rights reserved.
//

import UIKit

class AlbumsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
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
        self.layer.shadowOpacity = 1
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowColor = updateColorsAccordingToTheme().1.cgColor
        self.layer.shadowRadius = 4
        self.layer.cornerRadius = 16
    }
    override func layoutIfNeeded() {
        addShadow()
        albumName.textColor = updateColorsAccordingToTheme().1
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        albumImage.layer.masksToBounds = true

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
