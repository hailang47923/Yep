//
//  ContactsViewController.swift
//  Yep
//
//  Created by NIX on 15/3/16.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import RealmSwift

class ContactsViewController: UIViewController {

    @IBOutlet weak var contactsTableView: UITableView!

    let cellIdentifier = "ContactsCell"

    lazy var friends = normalUsers()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contactsTableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        contactsTableView.rowHeight = 80

        YepUserDefaults.nickname.bindListener("ContactsViewController.Nickname") { _ in
            self.reloadContactsTableView()
        }

        YepUserDefaults.avatarURLString.bindListener("ContactsViewController.Avatar") { _ in
            self.reloadContactsTableView()
        }
    }

    func reloadContactsTableView() {
        contactsTableView.reloadData()
    }

    // MARK: Actions

    @IBAction func presentAddFriends(sender: UIBarButtonItem) {
        performSegueWithIdentifier("presentAddFriends", sender: nil)
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            let vc = segue.destinationViewController as! ProfileViewController

            if let user = sender as? User {
                vc.profileUser = ProfileUser.UserType(user)
            }

            vc.hidesBottomBarWhenPushed = true
        }
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(friends.count)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ContactsCell

        let friend = friends[indexPath.row]

        let radius = min(CGRectGetWidth(cell.avatarImageView.bounds), CGRectGetHeight(cell.avatarImageView.bounds)) * 0.5

        AvatarCache.sharedInstance.roundAvatarOfUser(friend, withRadius: radius) { roundImage in
            dispatch_async(dispatch_get_main_queue()) {
                cell.avatarImageView.image = roundImage
            }
        }

        cell.nameLabel.text = friend.nickname
        cell.joinedDateLabel.text = friend.introduction
        cell.lastTimeSeenLabel.text = friend.createdAt.timeAgo

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // 去往 Profile
        let friend = friends[indexPath.row]
        performSegueWithIdentifier("showProfile", sender: friend)
   }
}