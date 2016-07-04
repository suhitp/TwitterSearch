//
//  TwitterSearchViewController.swift
//  TwitterSearch
//
//  Created by Suhit P on 29/06/16.
//  Copyright © 2016 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit


class TwitterSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let reuseIdentifier = "TweetCell"
    var tweets = [Tweet]()
    var isLoadingTweets = false
    var cache = NSCache()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tweets"
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.tintColor = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1)
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(TwitterSearchViewController.refreshTweets), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        loadTweets()
    }
    
    //MARK: LoadTweets for #iOS tag
    func loadTweets() {
        
        spinner.center = self.view.center
        spinner.color = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        self.view.addSubview(spinner)
        
        refreshTweets()
    }
    
    func refreshTweets()  {
        
        let apiClient = NetworkAPIClient()
        apiClient.loadTweetsForHashtag("#iOS") { (result) in
            if result != nil {
                self.spinner.stopAnimating()
                self.tweets += result!
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
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
        cell.nameLabel.text = tweet.user.name
        cell.screenNameLbl.text = "@\(tweet.user.screenName)"
        cell.tweetLabel.text = tweet.text
        cell.profileImageView.image = UIImage(named: "twitter-logo.png")
        
        let imageUrl = tweet.user.profileImageUrl
        
        if (self.cache.objectForKey(imageUrl) != nil){
            cell.profileImageView.image = self.cache.objectForKey(imageUrl) as? UIImage
        } else {
            let url = NSURL(string: imageUrl)!
            NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (location, response, error) -> Void in
                if let data = NSData(contentsOfURL: url){
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if cell == tableView.cellForRowAtIndexPath(indexPath) {
                            let image:UIImage = UIImage(data: data)!
                            cell.profileImageView.image = image
                            self.cache.setObject(image, forKey:imageUrl)
                        }
                    })
                }
            }).resume()
        }
        return cell
    }
    
}


