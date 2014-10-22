//
//  CreateReferenceViewController.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 02/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "CreateReferenceViewController.h"
#import "ProjectClient.h"
#import "office365-base-sdk/OAuthentication.h"

@interface CreateReferenceViewController ()

@end

@implementation CreateReferenceViewController


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
    self.navigationController.view.backgroundColor = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)createReference:(id)sender {
    [self createReference];
}

-(void)createReference{
    if((![self.referenceUrlTxt.text isEqualToString:@""]) && (![self.referenceDescription.text isEqualToString:@""]) && (![self.referenceTitle.text isEqualToString:@""])){
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        
        [spinner startAnimating];
        
        ProjectClient* client = [ProjectClient getClient:self.token];
        
        NSString* obj = [NSString stringWithFormat:@"{'Url':'%@', 'Description':'%@'}", self.referenceUrlTxt.text, self.referenceTitle.text];
        NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[obj, self.referenceDescription.text, [NSString stringWithFormat:@"%@", self.project.Id]] forKeys:@[@"URL", @"Comments", @"Project"]];
        
        ListItem* newReference = [[ListItem alloc] initWithDictionary:dic];
        
        NSURLSessionTask* task = [client addReference:newReference callback:^(BOOL success, NSError *error) {
            if(error == nil && success){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    NSString *errorMessage = (error) ? [@"Add Reference failed. Reason: " stringByAppendingString: error.description] : @"Invalid Url";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                });
            }
        }];
        [task resume];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Complete all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}

@end
