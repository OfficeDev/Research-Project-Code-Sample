#import "ProjectDetailsViewController.h"

#import "office365-base-sdk/OAuthentication.h"
#import "office365-files-sdk/FileClient.h"

@implementation ProjectDetailsViewController

-(void)viewDidLoad{
    self.projectName.text = self.project.getTitle;
    self.navigationItem.title = self.project.getTitle;
    self.navigationItem.rightBarButtonItem.title = @"Done";
    self.projectNameField.hidden = true;
}

- (IBAction)CreateReference:(id)sender {
    [self CreateFile];
}

-(void)CreateFile{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    
    [spinner startAnimating];
    
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
          /* NSURLSessionTask* task = [client createEmptyFile:fileName
                                              folder:nil callback:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(),
                                                               ^{
                                                                   [spinner stopAnimating];
                                                                   [self.navigationController popViewControllerAnimated:YES];
                                                               });
                                              }
    ];
   */
    /*NSURLSessionTask* task = [client createFile:fileName overwrite:true body:data folder:nil :^(FileEntity *file, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //  [self.tableView reloadData];
            [spinner stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];*/
    
    
   /* [client createFile:fileName overwrite :true body:data folder:nil
                                       callback:^(NSData * data, NSURLResponse * response, NSError * error) {
                                           //NSError* parseError = nil;
                                           
                                          //[client parseData : data];
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               //  [self.tableView reloadData];
                                               [spinner stopAnimating];
                                               [self.navigationController popViewControllerAnimated:YES];
                                           });
                                       }];*/
   
    //[task resume];
}
@end