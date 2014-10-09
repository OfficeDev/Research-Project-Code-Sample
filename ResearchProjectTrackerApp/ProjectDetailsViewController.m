#import "ProjectDetailsViewController.h"
#import "office365-base-sdk/OAuthentication.h"
#import "ProjectClient.h"
#import "ReferencesTableViewCell.h"
#import "ReferenceDetailsViewController.h"
#import "CreateReferenceViewController.h"
#import "EditProjectViewController.h"

@implementation ProjectDetailsViewController

//ViewController actions
-(void)viewDidLoad{
    self.projectName.text = self.project.getTitle;
    self.navigationItem.title = self.project.getTitle;
    self.navigationItem.rightBarButtonItem.title = @"Done";
    self.selectedReference = false;
    self.projectNameField.hidden = true;
    
    
    [self loadData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}



//Loading References
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
    
    NSURLSessionTask* listReferencesTask = [client getReferencesByProjectId:self.project.Id callback:^(NSMutableArray *listItems, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.references = [listItems copy];
                [self.refencesTable reloadData];
                [spinner stopAnimating];
            });
        
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

-(ProjectClient*)getClient{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:self.token];
    
    return [[ProjectClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                                  credentials: authentication];
}


//Table actions
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"referencesListCell";
    ReferencesTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    ListItem *item = [self.references objectAtIndex:indexPath.row];
    NSDictionary *dic =[item getData:@"URL"];
    cell.titleField.text = [dic valueForKey:@"Description"];
    cell.urlField.text = [dic valueForKey:@"Url"];
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.references count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedReference= [self.references objectAtIndex:indexPath.row];    
    [self performSegueWithIdentifier:@"referenceDetail" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"createReference"]){
        CreateReferenceViewController *controller = (CreateReferenceViewController *)segue.destinationViewController;
        controller.project = self.project;
        controller.token = self.token;
    }else if([segue.identifier isEqualToString:@"referenceDetail"]){
        ReferenceDetailsViewController *controller = (ReferenceDetailsViewController *)segue.destinationViewController;
        controller.selectedReference = self.selectedReference;
        controller.token = self.token;
    }else if([segue.identifier isEqualToString:@"editProject"]){
        EditProjectViewController *controller = (EditProjectViewController *)segue.destinationViewController;
        controller.project = self.project;
        controller.token = self.token;
    }
    self.selectedReference = false;
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return ([identifier isEqualToString:@"referenceDetail"] && self.selectedReference) || [identifier isEqualToString:@"createReference"] || [identifier isEqualToString:@"editProject"];
}



@end