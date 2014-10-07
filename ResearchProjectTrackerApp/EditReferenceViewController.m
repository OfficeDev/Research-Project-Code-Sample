//
//  CreateReferenceViewController.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 02/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "EditReferenceViewController.h"
#import "ProjectClient.h"
#import "Reference.h"
#import "office365-base-sdk/OAuthentication.h"
#import "ProjectDetailsViewController.h"

@interface EditReferenceViewController ()

@end

@implementation EditReferenceViewController

//ViewController actions
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
    self.navigationController.title = @"Edit Reference";
    
    self.navigationController.view.backgroundColor = nil;
    self.referenceUrlTxt.text = self.selectedReference.url;
    self.referenceDescription.text = self.selectedReference.description;
    self.referenceTitle.text = self.selectedReference.title;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)editReference:(id)sender {
    [self updateReference];
}
-(void)updateReference{
    if((![self.referenceUrlTxt.text isEqualToString:@""]) && (![self.referenceDescription.text isEqualToString:@""]) && (![self.referenceTitle.text isEqualToString:@""])){
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        
        [spinner startAnimating];
        
        self.selectedReference.title = self.referenceTitle.text;
        self.selectedReference.comments = self.referenceDescription.text;
        self.selectedReference.url = self.referenceUrlTxt.text;
        
        ProjectClient* client = [self getClient];
        
        NSURLSessionTask* task = [client updateReference:@"Research References" item:self.selectedReference callback:^(BOOL result, NSError *error) {
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                NSString *errorMessage = [@"Update Project failed. Reason: " stringByAppendingString: error.description];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
                [alert show];
            }
        }];
        [task resume];
    }
}



- (IBAction)deleteReference:(id)sender {
    [self deleteReference];
}
-(void)deleteReference{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    
    [spinner startAnimating];
    
    ProjectClient* client = [self getClient];
    
    NSURLSessionTask* task = [client deleteListItem:@"Research References" itemId:self.selectedReference.Id callback:^(BOOL result, NSError *error) {
        if(error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                ProjectDetailsViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                [self.navigationController popToViewController:View animated:YES];
            });
        }else{
            NSString *errorMessage = [@"Delete Reference failed. Reason: " stringByAppendingString: error.description];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
            [alert show];
        }
    }];
    
    [task resume];
}


-(ProjectClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ProjectClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                                  credentials: authentication];
}

@end
