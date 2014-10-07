//
//  ReferenceDetailsViewController.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 02/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "ReferenceDetailsViewController.h"
#import "ReferenceDetailTableCellTableViewCell.h"
#import "EditReferenceViewController.h"

@interface ReferenceDetailsViewController ()

@end

@implementation ReferenceDetailsViewController


//ViewControllerActions
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = nil;
    
    if(![self.selectedReference.comments isEqual:[NSNull null]]){
        self.descriptionLbl.text = self.selectedReference.comments;
    }else{
        self.descriptionLbl.text = @"";
    }
    self.urlTableCell.scrollEnabled = NO;
    self.navigationItem.title = self.selectedReference.title;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//Table actions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = @"referenceDetailsTableCell";
    ReferenceDetailTableCellTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    cell.urlContentLBL.text = self.selectedReference.url;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [NSURL URLWithString:self.selectedReference.url];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editReference"]){
        EditReferenceViewController *controller = (EditReferenceViewController *)segue.destinationViewController;
        controller.token = self.token;
        controller.selectedReference = self.selectedReference;
    }
}

@end
