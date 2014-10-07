//
//  CreateReferenceViewController.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 02/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "CreateReferenceViewController.h"
#import "ProjectClient.h"
#import "Reference.h"
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
        
        ProjectClient* client = [self getClient];
        
        Reference* newReference = [[Reference alloc] init];
        newReference.title = @"";
        newReference.url = self.referenceUrlTxt.text;
        newReference.comments = self.referenceDescription.text;
        
        NSURLSessionTask* task = [client addReference:@"Research References" item:newReference callback:^(BOOL success, NSError *error) {
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                NSString *errorMessage = [@"Add Reference failed. Reason: " stringByAppendingString: error.description];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
                [alert show];
            }
        }];
        [task resume];
    }
}

-(ProjectClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ProjectClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                                  credentials: authentication];
}

@end
