//
//  User.swift
//  TwitterSearch
//
//  Created by Suhit P on 30/06/16.
//  Copyright © 2016 Suhit Patil. All rights reserved.
//

import UIKit

struct User {
  let name: String
  let profileImageUrl: String
  let screenName: String
  
  init(json: [String: AnyObject]) {
    self.name = json["name"] as! String
    self.profileImageUrl = json["profile_image_url_https"] as! String
    self.screenName = json["screen_name"] as! String
  }
}
