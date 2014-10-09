#import <UIKit/UIKit.h>
#import "office365-lists-sdk/ListItem.h"

@interface ProjectDetailsViewController : UIViewController <UITableViewDataSource>

@property NSString* token;
@property ListItem* project;
@property ListItem* selectedReference;
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UITextField *projectNameField;
@property (weak, nonatomic) IBOutlet UILabel *referenceLbl;
@property (weak, nonatomic) IBOutlet UITableView *refencesTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *projectDetailsDoneButton;
@property (strong, nonatomic) IBOutlet NSMutableArray *references;

@end
