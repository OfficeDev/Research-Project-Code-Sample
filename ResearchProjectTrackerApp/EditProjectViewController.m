#import "EditProjectViewController.h"

#import "office365-base-sdk/OAuthentication.h"
#import "ProjectClient.h"
#import "ProjectTableViewController.h"

@implementation EditProjectViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.ProjectNameTxt.text = [self.project getTitle];
    self.navigationController.title = @"Edit Project";
}

- (IBAction)editProject:(id)sender {
    [self updateProject];
}

- (IBAction)deleteProject:(id)sender {
    [self deleteProject];
}

-(void)updateProject{
    if(![self.ProjectNameTxt.text isEqualToString:@""]){
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.view addSubview:spinner];
        spinner.hidesWhenStopped = YES;
        
        [spinner startAnimating];
        
        ListItem* editedProject = [[ListItem alloc] init];
        
        NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[@"Title",self.ProjectNameTxt.text, self.project.Id] forKeys:@[@"_metadata",@"Title",@"Id"]];
        [editedProject initWithDictionary:dic];
        
        ProjectClient* client = [self getClient];
        
        NSURLSessionTask* task = [client updateProject:editedProject callback:^(BOOL result, NSError *error) {
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    ProjectTableViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                    [self.navigationController popToViewController:View animated:YES];
                });
            }else{
                NSString *errorMessage = [@"Update Project failed. Reason: " stringByAppendingString: error.description];
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

-(void)deleteProject{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    
    [spinner startAnimating];
    
    ProjectClient* client = [self getClient];

    NSURLSessionTask* task = [client deleteListItem:@"Research Projects" itemId:self.project.Id callback:^(BOOL result, NSError *error) {
        if(error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                
                ProjectTableViewController *View = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
                [self.navigationController popToViewController:View animated:YES];
            });
        }else{
            NSString *errorMessage = [@"Delete Project failed. Reason: " stringByAppendingString: error.description];
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