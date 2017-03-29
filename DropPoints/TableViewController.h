//
//  TableViewController.h
//  DropPoints
//
//  Created by Yaniv Hasbani on 3/25/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewObject;

@end

