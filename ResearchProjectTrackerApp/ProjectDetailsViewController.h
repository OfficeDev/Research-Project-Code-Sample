//
//  CreateViewController.h
//  file-app
//
//  Created by Lagash on 6/24/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface ProjectDetailsViewController : UIViewController

- (IBAction)CreateReference:(id)sender;

@property NSString* token;
@property Project* project;
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UITextField *projectNameField;
@property (weak, nonatomic) IBOutlet UILabel *referenceLbl;
@property (weak, nonatomic) IBOutlet UIButton *addReferenceBtn;
@property (weak, nonatomic) IBOutlet UITableView *refencesTable;
@property (assign) BOOL createProject;


@end
