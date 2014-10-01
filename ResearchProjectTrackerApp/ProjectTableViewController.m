#import "ProjectTableViewController.h"
#import "ProjectTableViewCell.h"
#import "office365-lists-sdk/ListClient.h"
#import "office365-lists-sdk/ListItem.h"
#import "ProjectDetailsViewController.h"
#import "office365-base-sdk/OAuthentication.h"

@implementation ProjectTableViewController

UIView* popUpView;
UILabel* popUpLabel;
UIView* blockerPanel;
ListItem* currentEntity;
NSURLSessionDownloadTask* task;

- (void)Cancel{
    [task cancel];
    [self disposeBlockerPanel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.projectsList = [[NSMutableArray alloc] init];
    
    [self loadData];
}

-(void)disposeBlockerPanel{
    blockerPanel.hidden = true;
    popUpView = nil;
    blockerPanel = nil;
    self.tableView.scrollEnabled = true;
    self.navigationController.navigationItem.backBarButtonItem.Enabled = true;
}

-(void)loadData{
    //Create and add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ListClient* client = [self getClient];
    
   NSURLSessionTask* task = [client getList:@"Research Projects" callback:^(ListEntity *list, NSError *error) {
        
    //If list doesn't exists, create one with name ProjectList
   if(list){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getProjectsFromList:spinner];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createProjectList:spinner];
            });
        }
        
    }];
    [task resume];
    
}

-(void)getProjectsFromList:(UIActivityIndicatorView *) spinner{
    ListClient* client = [self getClient];
    
    NSURLSessionTask* listProjectsTask = [client getListItems:@"Research Projects" callback:^(NSMutableArray *listItems, NSError *error) {
        if(!error){
            self.projectsList = listItems;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [spinner stopAnimating];
            });
        }
    }];
    [listProjectsTask resume];
}


-(void)createProjectList:(UIActivityIndicatorView *) spinner{
    ListClient* client = [self getClient];
    
    ListEntity* newList = [[ListEntity alloc ] init];
    [newList setTitle:@"Research Projects"];
    
    NSURLSessionTask* createProjectListTask = [client createList:newList :^(ListEntity *list, NSError *error) {
        [spinner stopAnimating];
    }];
    [createProjectListTask resume];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"ProjectListCell";
    ProjectTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    ListItem *item = [self.projectsList objectAtIndex:indexPath.row];
    cell.ProjectName.text = [item getTitle];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectsList count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"newProject"]){
        CreateViewController *controller = (CreateViewController *)segue.destinationViewController;
        controller.token = self.token;
    }else{
        ProjectDetailsViewController *controller = (ProjectDetailsViewController *)segue.destinationViewController;
        controller.project = currentEntity;
        controller.token = self.token;
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (IBAction)Download:(id)sender {
    
    [self createBlockerPanel];
    
    //__weak typeof(self) weakSelf = self;
    
  //  task = [[self getClient] download:currentEntity.Id delegate: (id)weakSelf];
    [task resume];
}

/*-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Temporary File :%@\n", location);
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSURL *docsDirURL = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:currentEntity.getTitle]];
    if ([fileManager moveItemAtURL:location toURL:docsDirURL error: &err])
    {
        NSLog(@"File is saved to =%@",docsDir);
    }
    else
    {
        NSLog(@"failed to move: %@",[err userInfo]);
    }
    
    [self disposeBlockerPanel];
}*/

/*-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSInteger size = currentEntity.Size;
    popUpLabel.text = [NSString stringWithFormat: @"Downloaded: %lld of %ld bytes.", totalBytesWritten, (long)size];
    [popUpView addSubview:popUpLabel];
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastSelected = [self.projectsList indexOfObject:currentEntity];
    
    if(lastSelected != NSIntegerMax){
        //NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:lastSelected inSection:0];
        //ProjectTableViewCell* lastCell = (ProjectTableViewCell*)[tableView cellForRowAtIndexPath:oldIndexPath];
    }
    
    //ProjectTableViewCell* cell =(ProjectTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    currentEntity= [self.projectsList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"detail" sender:self];
}

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ListEntity* listToDelete = [self.projectsList objectAtIndex:indexPath.row];
        UIActivityIndicatorView* spinner = [self loadingProgress];
        
      NSURLSessionDataTask* task = [[self getClient] deleteList:listToDelete :^(BOOL success, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              [self.projectsList removeObject:listToDelete];
              [self.tableView reloadData];
              
              self.tableView.scrollEnabled = true;
              [spinner stopAnimating];
              blockerPanel.hidden = true;
                });
            }];
      
        [task resume];
    }
}*/

-(UIActivityIndicatorView*)loadingProgress{
    
    int y = self.tableView.contentOffset.y;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
    
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    self.tableView.scrollEnabled = false;
    spinner.hidesWhenStopped = YES;
    
    blockerPanel = [[UIView alloc] initWithFrame:CGRectMake(0,y,width,height)];
    blockerPanel.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.7];
    [blockerPanel addSubview:spinner];
    
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    [self.view addSubview:blockerPanel];
    [spinner startAnimating];
    return spinner;
}

-(ListClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ListClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                               credentials: authentication];
}

-(void)createBlockerPanel{
    
    [self.navigationController.navigationItem.backBarButtonItem setEnabled:false];
    [self.navigationItem.rightBarButtonItem  setTitle: @"Cancel"];
    
    int y = self.tableView.contentOffset.y;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
    
    blockerPanel = [[UIView alloc] initWithFrame:CGRectMake(0,y,width,height)];
    blockerPanel.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.7];
    
    popUpView = [[UIView alloc]initWithFrame:CGRectMake(40, 50, 250, 80)];
    popUpView.backgroundColor = [UIColor whiteColor];
    popUpView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    popUpView.layer.borderWidth = 1.0f;
    popUpView.layer.shadowColor = [UIColor grayColor].CGColor;
    popUpView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    popUpView.layer.shadowOpacity =1.0f;
    
    popUpLabel= [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 190, 60)];
    popUpLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    popUpLabel.lineBreakMode = NSLineBreakByWordWrapping;
    popUpLabel.numberOfLines = 2;
    
    blockerPanel.hidden = true;
    
    [blockerPanel addSubview:popUpView];
    [self.view addSubview:blockerPanel];
    
    self.tableView.scrollEnabled = false;
    blockerPanel.hidden = false;
}

@end