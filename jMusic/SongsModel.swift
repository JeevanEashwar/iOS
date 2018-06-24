//
//  SongsModel.swift
//  jMusic
//
//  Created by Jeevan on 24/06/18.
//  Copyright © 2018 personal. All rights reserved.
//

import Foundation

class SongsModel: Equatable{
    var urlPath:String = ""
    var title:String = ""
    var artist:String = ""
    var albumName:String = ""
    var imageData:Data? = Data()
    public static func == (lhs:SongsModel, rhs:SongsModel) -> Bool {
        return
            lhs.urlPath == rhs.urlPath &&
            lhs.title == rhs.title &&
            lhs.artist == rhs.artist &&
            lhs.albumName == rhs.albumName &&
            lhs.imageData == rhs.imageData
    }
}
