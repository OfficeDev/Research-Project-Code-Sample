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

//ViewController actions
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = nil;
    
    self.projectsList = [[NSMutableArray alloc] init];
    
    [self loadData];
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation button was pressed. Do some stuff
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.view.backgroundColor = [UIColor clearColor];
    }
    [super viewWillDisappear:animated];
}
- (void)Cancel{
    [task cancel];
    [self disposeBlockerPanel];
}
-(void)disposeBlockerPanel{
    blockerPanel.hidden = true;
    popUpView = nil;
    blockerPanel = nil;
    self.tableView.scrollEnabled = true;
    self.navigationController.navigationItem.backBarButtonItem.Enabled = true;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}




//Loading Projects
-(void)loadData{
    //Create and add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ListClient* client = [self getClient];
    
   NSURLSessionTask* task = [client getList:@"Research Projects" callback:^(ListEntity *list, NSError *error) {
        
    //If list doesn't exists, create one with name Research Projects
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

- (IBAction)backToLogin:(id)sender{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

-(ListClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ListClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                               credentials: authentication];
}





//Table actions
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentEntity= [self.projectsList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"detail" sender:self];
}

@end