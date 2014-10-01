#import "CreateViewController.h"

#import "office365-base-sdk/OAuthentication.h"
#import "office365-lists-sdk/ListClient.h"

@implementation CreateViewController

-(void)viewDidLoad{
    self.ContentText.layer.borderWidth = 0.5f;
    self.ContentText.layer.cornerRadius = 8;
    self.ContentText.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (IBAction)CreateFile:(id)sender {
    [self CreateFile];
}

-(void)CreateFile{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    
    [spinner startAnimating];
    
    ListClient* client = [self getClient];
    
    ListEntity* newProject = [[ListEntity alloc] init];
    [newProject setTitle: self.FileNameTxt.text];
    
   NSURLSessionTask* task = [client createList:newProject :^(ListEntity *list, NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [spinner stopAnimating];
           [self.navigationController popViewControllerAnimated:YES];
       });
   }];
    
    [task resume];
}

-(ListClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ListClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                               credentials: authentication];
}
@end