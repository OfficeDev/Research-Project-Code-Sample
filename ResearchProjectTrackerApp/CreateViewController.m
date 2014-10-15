#import "CreateViewController.h"

#import "office365-base-sdk/OAuthentication.h"
#import "ProjectClient.h"

@implementation CreateViewController

-(void)viewDidLoad{
    [super viewDidLoad];
}

- (IBAction)createProject:(id)sender {
    [self createProject];
}

-(void)createProject{
    if(![self.FileNameTxt.text isEqualToString:@""]){
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        
        [spinner startAnimating];
        
        ProjectClient* client = [self getClient];
        
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

-(ProjectClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ProjectClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                                  credentials: authentication];
}
@end