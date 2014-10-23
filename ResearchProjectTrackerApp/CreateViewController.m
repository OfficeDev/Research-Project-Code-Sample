
#import "CreateViewController.h"
#import "ProjectClient.h"
#import "office365-base-sdk/OAuthentication.h"

@implementation CreateViewController

-(void)viewDidLoad{
    [super viewDidLoad];
}

- (IBAction)createProject:(id)sender {
    [self createProject];
}

-(void)createProject{
    if(![self.FileNameTxt.text isEqualToString:@""]){
        double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
        double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        [spinner startAnimating];
        
        ProjectClient* client = [ProjectClient getClient:self.token];
        
        ListItem* newProject = [[ListItem alloc] init];
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[@"Title",self.FileNameTxt.text] forKeys:@[@"_metadata",@"Title"]];
        [newProject initWithDictionary:dic];
        
        NSURLSessionTask* task = [client addProject:newProject callback:^(BOOL success, NSError *error) {
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                NSString *errorMessage = [@"Add Project failed. Reason: " stringByAppendingString: error.description];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
                [alert show];
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