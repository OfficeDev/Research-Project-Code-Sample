#import "ProjectDetailsViewController.h"

#import "office365-base-sdk/OAuthentication.h"
#import "ProjectClient.h"

@implementation ProjectDetailsViewController

-(void)viewDidLoad{
    self.projectName.text = self.project.getTitle;
    self.navigationItem.title = self.project.getTitle;
    self.navigationItem.rightBarButtonItem.title = @"Done";
    self.projectNameField.hidden = true;
    
    
    [self loadData];
}

-(void)loadData{
    //Create and add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClient* client = [self getClient];
    
    NSURLSessionTask* task = [client getList:@"Research References" callback:^(ListEntity *list, NSError *error) {
        
        //If list doesn't exists, create one with name Research References
        if(list){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getReferences:spinner];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createReferencesList:spinner];
            });
        }
        
    }];
    [task resume];
    
}


-(void)getReferences:(UIActivityIndicatorView *) spinner{
    ProjectClient* client = [self getClient];
    
    NSURLSessionTask* listReferencesTask = [client getProjectReferences:@"Research References" projectId:self.project.Id callback:^(NSMutableArray *listItems, NSError *error) {
            self.references = listItems;
            [spinner stopAnimating];
        }];

    [listReferencesTask resume];
    
}

-(void)createReferencesList:(UIActivityIndicatorView *) spinner{
    ProjectClient* client = [self getClient];
    
    ListEntity* newList = [[ListEntity alloc ] init];
    [newList setTitle:@"Research References"];
    
    NSURLSessionTask* createProjectListTask = [client createList:newList :^(ListEntity *list, NSError *error) {
        [spinner stopAnimating];
    }];
    [createProjectListTask resume];
}

- (IBAction)CreateReference:(id)sender {
    [self CreateFile];
}

-(ProjectClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ProjectClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                               credentials: authentication];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end