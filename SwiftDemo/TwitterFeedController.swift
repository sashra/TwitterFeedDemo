//
//  TwitterFeedController.swift
//  SwiftDemo
//
//  Created by Shivani Ashra on 22/03/17.
//  Copyright (c) 2017 Shivani Ashra. All rights reserved.
//

import UIKit

class TwitterFeedController: UITableViewController, TwitterFeedDelegate {
    
    var serviceWrapper: TwitterServiceWrapper = TwitterServiceWrapper()
    var twitterFeedArray = [TwitterFeedModel]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Twitter Feed"
        serviceWrapper.delegate = self
        activityIndicator.startAnimating()
        self.refreshControl!.addTarget(self, action: #selector(TwitterFeedController.pullToRefreshAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        serviceWrapper.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?q=%40@FlohNetwork")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = twitterFeedArray.count
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let follower = twitterFeedArray[indexPath.row] as TwitterFeedModel
        let imageUrl = NSURL(string: follower.profileURL!)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 11.0)
        cell.textLabel?.text = follower.name
        cell.imageView?.setImageWithURL(imageUrl!)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let follower = (twitterFeedArray[indexPath.row] as TwitterFeedModel).name
        let font = UIFont(name: "HelveticaNeue-Thin", size: 11.0)
        var height = heightForView(follower!, font: font!, width: tableView.frame.width)
        if height < 50 {
            height = 50
        }
        return height
    }
    
    // MARK: - TwitterFeedDelegate methods
    
    func finishedDownloading(model: TwitterFeedModel) {
       dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.twitterFeedArray.append(model)
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        })
    }
    
    // MARK : - Refresh Action Selector
    func pullToRefreshAction(refreshControl: UIRefreshControl) {
        twitterFeedArray.removeAll()
        serviceWrapper.getResponseForRequest("https://api.twitter.com/1.1/search/tweets.json?q=%40@FlohNetwork")
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func heightForView(text:String,font:UIFont,width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
}

extension UIImageView {
    
    func setImageWithURL(url:NSURL){
        self.image = UIImage(named: "placeholder")
        getDataFromUrl(url) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if data != nil {
                    self.image = UIImage(data: data!)
                    self.clipsToBounds = true
                    self.contentMode = .ScaleAspectFit
                }
            }
        }
    }
    
    private func getDataFromUrl(url: NSURL, completion:(data: NSData?,response: NSURLResponse?,error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            NSURLSession.sharedSession().dataTaskWithURL(url){
                (data, response, error) in
                completion(data: data, response: response, error: error)
            }.resume()
        })
    }

}
