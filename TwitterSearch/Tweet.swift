//
//  Tweet.swift
//  TwitterSearch
//
//  Created by Suhit P on 30/06/16.
//  Copyright © 2016 Suhit Patil. All rights reserved.
//

import UIKit

struct Tweet {
  let id: Int
  let text: String
  let user: User
}

extension Tweet {
  
  init?(json: [String: AnyObject]) {
    
    self.id = json["id"] as! Int
    self.text = json["text"] as! String
    self.user = User(json: json["user"] as! [String: AnyObject])
    
    guard !text.isEmpty else {
      return nil
    }
    
  }
  
}