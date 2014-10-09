//
//  ReferenceDetailsViewController.h
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 02/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "ViewController.h"
#import "office365-lists-sdk/ListItem.h"

@interface ReferenceDetailsViewController : ViewController <UITableViewDataSource>
@property NSString* token;
@property (weak, nonatomic) IBOutlet UITableView *urlTableCell;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;
@property ListItem* selectedReference;
@end
