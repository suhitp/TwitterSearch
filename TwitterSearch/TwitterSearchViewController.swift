//
//  TwitterSearchViewController.swift
//  TwitterSearch
//
//  Created by Suhit P on 29/06/16.
//  Copyright © 2016 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit


class TwitterSearchViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  let reuseIdentifier = "TweetCell"
  var tweets = [Tweet]()
  var isLoadingTweets = false
  var cache = NSCache()
  let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Tweets"
    tableView.estimatedRowHeight = 140
    tableView.rowHeight = UITableViewAutomaticDimension
    loadTweets()
  }
  
  //MARK: LoadTweets for #iOS tag
  func loadTweets() {
    spinner.center = self.view.center
    self.view.addSubview(spinner)
    spinner.startAnimating()
    let apiClient = NetworkAPIClient()
    apiClient.loadTweetsForHashtag("#iOS") { (result) in
      if result != nil {
        self.spinner.stopAnimating()
        self.tweets = result!
        self.tableView.reloadData()
      }
    }
    
  }
  
  //MARK: UItableViewDataSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return self.tweets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TweetCell
    let tweet = tweets[indexPath.row]
    cell.nameLabel.text = tweet.name
    cell.screenNameLbl.text = "@\(tweet.screenName)"
    cell.tweetLabel.text = tweet.text
    cell.profileImageView.image = UIImage(named: "twitter.png")
    
    if (self.cache.objectForKey(tweet.profileImageUrl) != nil){
      cell.profileImageView.image = self.cache.objectForKey(tweet.profileImageUrl) as? UIImage
    } else {
      let url:NSURL! = NSURL(string: tweet.profileImageUrl)
      NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (location, response, error) -> Void in
        if let data = NSData(contentsOfURL: url){
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if cell == tableView.cellForRowAtIndexPath(indexPath) {
              let image:UIImage = UIImage(data: data)!
              cell.profileImageView.image = image
              self.cache.setObject(image, forKey:tweet.profileImageUrl)
            }
          })
        }
      }).resume()
    }
    
    return cell
  }
 
}


