#import "EditReferenceViewController.h"
#import "ProjectClient.h"
#import "ProjectDetailsViewController.h"
#import "office365-base-sdk/OAuthentication.h"

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
    
    NSDictionary *dic =[self.selectedReference getData:@"URL"];
    
    self.referenceUrlTxt.text = [dic valueForKey:@"Url"];
    
    if(![[self.selectedReference getData:@"Comments"] isEqual:[NSNull null]]){
        self.referenceDescription.text = [self.selectedReference getData:@"Comments"];
    }else{
        self.referenceDescription.text = @"";
    }

    self.referenceTitle.text = [dic valueForKey:@"Description"];
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
        double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
        double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        [spinner startAnimating];
        
        
        ListItem* editedReference = [[ListItem alloc] init];
        
        NSDictionary* urlDic = [NSDictionary dictionaryWithObjects:@[self.referenceUrlTxt.text, self.referenceTitle.text] forKeys:@[@"Url",@"Description"]];
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[urlDic, self.referenceDescription.text, [self.selectedReference getData:@"Project"], self.selectedReference.Id] forKeys:@[@"URL",@"Comments",@"Project",@"Id"]];
        
        [editedReference initWithDictionary:dic];
        

        ProjectClient* client = [ProjectClient getClient:self.token];
        
        NSURLSessionTask* task = [client updateReference:editedReference callback:^(BOOL result, NSError *error) {
            if(error == nil && result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    ProjectDetailsViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                    [self.navigationController popToViewController:View animated:YES];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    NSString *errorMessage = (error) ? [@"Update Reference failed. Reason: " stringByAppendingString: error.description] : @"Invalid Url";
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



- (IBAction)deleteReference:(id)sender {
    [self deleteReference];
}
-(void)deleteReference{
    double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
    double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClient* client = [ProjectClient getClient:self.token];
    
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

@end
