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
    
    NSDictionary *dic =[self.selectedReference getData:@"URL"];
    
    if(![[self.selectedReference getData:@"Comments"] isEqual:[NSNull null]]){
        self.descriptionLbl.text = [self.selectedReference getData:@"Comments"];
    }else{
        self.descriptionLbl.text = @"";
    }
    self.urlTableCell.scrollEnabled = NO;
    self.navigationItem.title = [dic valueForKey:@"Description"];
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
    
    NSDictionary *dic =[self.selectedReference getData:@"URL"];
    
    cell.urlContentLBL.text = [dic valueForKey:@"Url"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic =[self.selectedReference getData:@"URL"];
    NSURL *url = [NSURL URLWithString:[dic valueForKey:@"Url"]];
    
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
