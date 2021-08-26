//
//  PhotoInfo.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

struct PhotoInfo: Decodable {
    let photo: Photo?
    
}
/*
 {
    "photo":{
       "id":"51403173555",
       "secret":"f9e80d2507",
       "server":"65535",
       "farm":66,
       "dateuploaded":"1629917444",
       "isfavorite":0,
       "license":0,
       "safety_level":0,
       "rotation":0,
       "originalsecret":"7a104e0b0b",
       "originalformat":"png",
       "owner":{
          "nsid":"193786693@N08",
          "username":"sergcom1998",
          "realname":"asd asd",
          "location":"",
          "iconserver":0,
          "iconfarm":0,
          "path_alias":""
       },
       "title":{
          "_content":"AppIcon"
       },
       "description":{
          "_content":""
       },
       "visibility":{
          "ispublic":1,
          "isfriend":0,
          "isfamily":0
       },
       "dates":{
          "posted":"1629917444",
          "taken":"2021-08-25 11:50:29",
          "takengranularity":0,
          "takenunknown":1,
          "lastupdate":"1629917444"
       },
       "permissions":{
          "permcomment":3,
          "permaddmeta":2
       },
       "views":0,
       "editability":{
          "cancomment":1,
          "canaddmeta":1
       },
       "publiceditability":{
          "cancomment":1,
          "canaddmeta":0
       },
       "usage":{
          "candownload":1,
          "canblog":1,
          "canprint":1,
          "canshare":1
       },
       "comments":{
          "_content":0
       },
       "notes":{
          "note":[
             
          ]
       },
       "people":{
          "haspeople":0
       },
       "tags":{
          "tag":[
             
          ]
       },
       "urls":{
          "url":[
             {
                "type":"photopage",
                "_content":"https:\/\/www.flickr.com\/photos\/193786693@N08\/51403173555\/"
             }
          ]
       },
       "media":"photo"
    },
    "stat":"ok"
 }
 */
