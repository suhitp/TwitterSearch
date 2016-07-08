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
    var maxId: Int?
    var isLoadingTweets = false
    var cache = NSCache()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let refreshControl = UIRefreshControl()
    var coreDataController: CoreDataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tweets"
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.hidden = true
        
        let tweetEntity = NSEntityDescription.entityForName("Tweet", inManagedObjectContext: coreDataController.managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = tweetEntity
        
        // Initialize Asynchronous Fetch Request
        let asynchFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asynchFetchResult) in
            if let result = asynchFetchResult.finalResult where result.count > 0 {
                self.tweets = result as! [Tweet]
                self.tableView.hidden = false
                self.tableView.reloadData()
            } else {
                self.loadTweets()
            }
        }
        
        do {
            // Execute Asynchronous Fetch Request
            let asynchFetchResult = try coreDataController.managedObjectContext.executeRequest(asynchFetchRequest)
            print(asynchFetchResult)
            
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
    }
    
    //MARK: LoadTweets for #iOS tag
    func loadTweets() {
        spinner.center = self.view.center
        spinner.color = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        self.view.addSubview(spinner)
        tableView.hidden = true
        refreshTweets()
    }
    
    func refreshTweets()  {
    
        let apiClient = NetworkAPIClient(coreDataController: coreDataController)
        isLoadingTweets = true
        
        apiClient.loadTweetsForHashtag("#iOS", maxId: maxId) { [unowned self] (result) in
            self.tableView.hidden = false
            self.tableView.tableFooterView = nil
            if result != nil {
                self.spinner.stopAnimating()
                self.isLoadingTweets = false
                if self.maxId == nil {
                    self.tweets = result!
                    self.tableView.reloadData()
                } else {
                    let count = self.tweets.count
                    self.tweets.appendContentsOf(result!)
                    
                    var arrayWithIndexPaths:[NSIndexPath] = []
                    for index in count..<self.tweets.count {
                        arrayWithIndexPaths.append(NSIndexPath(forRow: index, inSection: 0))
                    }
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths(arrayWithIndexPaths, withRowAnimation: .Automatic)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    //MARK: UItableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TweetCell
        let tweet = tweets[indexPath.row]
        cell.nameLabel.text = tweet.user!.name
        cell.screenNameLbl.text = "@\(tweet.user!.screenName)"
        cell.tweetLabel.text = tweet.text
        cell.profileImageView.image = UIImage(named: "twitter-logo.png")
        
        let imageUrl = tweet.user!.profileImageUrl
        
        if (self.cache.objectForKey(imageUrl!) != nil){
            cell.profileImageView.image = self.cache.objectForKey(imageUrl!) as? UIImage
        } else {
            let url = NSURL(string: imageUrl!)!
            NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (location, response, error) -> Void in
                if let data = NSData(contentsOfURL: url){
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if cell == tableView.cellForRowAtIndexPath(indexPath) {
                            let image:UIImage = UIImage(data: data)!
                            cell.profileImageView.image = image
                            self.cache.setObject(image, forKey:imageUrl!)
                        }
                    })
                }
            }).resume()
        }
        
        if indexPath.row == tweets.count - 1 {
            if (tweets.count > 0) {
                maxId = Int(tweet.id!) - 1
            }
            loadMoreTweets()
        }
        
        return cell
    }
    
    private func loadMoreTweets() {
        
        let footer = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        footer.frame = CGRectMake(0, 0, tableView.bounds.width, 44)
        footer.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        footer.color = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1)
        footer.hidesWhenStopped = true
        footer.startAnimating()
        tableView.tableFooterView = footer
        
        refreshTweets()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 44))
        footerView.backgroundColor = UIColor.whiteColor()
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isLoadingTweets == false {
            return 0
        }
        return 44.0
    }
    
}


