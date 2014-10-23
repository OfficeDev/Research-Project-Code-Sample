#import "ProjectClient.h"
#import "ProjectDetailsViewController.h"
#import "ProjectTableViewCell.h"
#import "ProjectTableViewController.h"
#import "office365-base-sdk/OAuthentication.h"
#import "office365-lists-sdk/ListClient.h"
#import "office365-lists-sdk/ListItem.h"

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
    self.navigationController.view.tintColor = [UIColor colorWithRed:98.0/255.0 green:4.0/255.0 blue:126.0/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:98.0/255.0 green:4.0/255.0 blue:126.0/255.0 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    self.projectsList = [[NSMutableArray alloc] init];
    currentEntity = nil;
    
    //[self loadData];
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
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
    currentEntity = nil;
    [self loadData];
}




//Loading Projects
-(void)loadData{
    //Create and add a spinner
    double x = ((self.navigationController.view.frame.size.width) - 20)/ 2;
    double y = ((self.navigationController.view.frame.size.height) - 150)/ 2;
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(x, y, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    //spinner.center = self.navigationController.view.center;
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClient* client = [ProjectClient getClient:self.token];
    
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
    ProjectClient* client = [ProjectClient getClient:self.token];
    
    NSURLSessionTask* listProjectsTask = [client getProjectsAndCallback:^(NSMutableArray *listItems, NSError *error) {
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
    ProjectClient* client = [ProjectClient getClient:self.token];
    
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





//Table actions
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"ProjectListCell";
    ProjectTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    ListItem *item = [self.projectsList objectAtIndex:indexPath.row];
    cell.ProjectName.text = [item getTitle];
    
    NSDictionary *editorInfo =[item getData:@"Editor"];
    NSString *editName = [item getData:@"Modified"];
    cell.lastModifier.text =[NSString stringWithFormat:@"Last modified by %@ on %@", [editorInfo valueForKey:@"Title"],[editName substringToIndex:10]];
    
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentEntity= [self.projectsList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"detail" sender:self];
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return ([identifier isEqualToString:@"detail"] && currentEntity) || [identifier isEqualToString:@"newProject"];
}


@end