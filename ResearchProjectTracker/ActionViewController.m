//
//  ActionViewController.m
//  ResearchProjectTracker
//
//  Created by Lucas Damian Napoli on 08/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//
#import "ProjectTableExtensionViewCell.h"
#import "office365-base-sdk/Credentials.h"
#import <office365-base-sdk/LoginClient.h>
#import <office365-base-sdk/OAuthentication.h>
#import "ProjectClientEx.h"
#import <office365-lists-sdk/ListItem.h>
#import <office365-lists-sdk/ListEntity.h>
#import <QuartzCore/QuartzCore.h>
#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

ADAuthenticationContext* authContext;
NSString* authority;
NSString* redirectUriString;
NSString* resourceId;
NSString* clientId;
Credentials* credentials;
NSString* token;
ListItem* currentEntity;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    token = [NSString alloc];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                
                __weak ActionViewController *sself = self;
                
                [itemProvider loadItemForTypeIdentifier: (NSString *) kUTTypeURL
                                                options: 0
                                      completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
                                          
                                          if (item != nil) {
                                              NSURL *url = item;
                                              sself.sharedUrl = [url absoluteString];
                                              
                                              [sself.urlTxt performSelectorOnMainThread : @ selector(setText : ) withObject:[url absoluteString] waitUntilDone:YES];
                                    
                                          }
                                          
                                      }];
                
            }
        }
    }
    
    [self performLogin:FALSE];
}

- (void) performLogin : (BOOL) clearCache{
    
    LoginClient *client = [ProjectClientEx getLoginClient];
    [client login:clearCache completionHandler:^(NSString *t, NSError *e) {
        if(e == nil)
        {
            token = t;
            
            [self loadData];
        }
        else
        {
            self.projectTable.hidden = true;
            self.selectProjectLbl.hidden = true;
            self.successMsg.hidden = false;
            self.successMsg.text = @"Login from the Research Project Tracker App before adding a Reference";
            self.successMsg.textColor = [UIColor redColor];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}


-(void)loadData{
    //Create and add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    ProjectClientEx *client = [ProjectClientEx getClient: token];
    
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
    ProjectClientEx *client = [ProjectClientEx getClient: token];
    
    NSURLSessionTask* listProjectsTask = [client getListItems:@"Research Projects" callback:^(NSMutableArray *listItems, NSError *error) {
        if(!error){
            self.projectsList = listItems;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.projectTable reloadData];
                [spinner stopAnimating];
            });
        }
    }];
    [listProjectsTask resume];
}


-(void)createProjectList:(UIActivityIndicatorView *) spinner{
    ProjectClientEx *client = [ProjectClientEx getClient: token];
    
    ListEntity* newList = [[ListEntity alloc ] init];
    [newList setTitle:@"Research Projects"];
    
    NSURLSessionTask* createProjectListTask = [client createList:newList :^(ListEntity *list, NSError *error) {
        [spinner stopAnimating];
    }];
    [createProjectListTask resume];
}

- (IBAction)Login:(id)sender {
    [self performLogin:FALSE];
}

- (IBAction)Clear:(id)sender {
    NSError *error;
    LoginClient *client = [[LoginClient alloc] initWithParameters: clientId: redirectUriString:resourceId :authority];
    
    [client clearCredentials: &error];
}



//Table actions
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"ProjectListCell";
    ProjectTableExtensionViewCell *cell =[tableView dequeueReusableCellWithIdentifier: identifier ];
    
    ListItem *item = [self.projectsList objectAtIndex:indexPath.row];
    cell.ProjectName.text = [item getTitle];
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectsList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    
    [spinner startAnimating];
    
    currentEntity= [self.projectsList objectAtIndex:indexPath.row];
    
    NSString* obj = [NSString stringWithFormat:@"{'Url':'%@', 'Description':'%@'}", self.urlTxt.text, @""];
    NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[obj, @"", [NSString stringWithFormat:@"%@", currentEntity.Id]] forKeys:@[@"URL", @"Comments", @"Project"]];
    
    ListItem* newReference = [[ListItem alloc] initWithDictionary:dic];
    
    __weak ActionViewController *sself = self;
    
    ProjectClientEx *client = [ProjectClientEx getClient: token];
    
    NSURLSessionTask* task =[client addReference:newReference callback:^(BOOL success, NSError *error) {
        if(error == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                sself.projectTable.hidden = true;
                sself.selectProjectLbl.hidden = true;
                sself.successMsg.hidden = false;
                sself.successMsg.text = [NSString stringWithFormat:@"Reference added successfully to the %@ Project.", [currentEntity getTitle]];
                [spinner stopAnimating];
            });
        }
    }];
    
    [task resume];
}

@end
