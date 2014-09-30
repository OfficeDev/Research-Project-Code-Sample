#import <UIKit/UIKit.h>
#import "office365-lists-sdk/ListItem.h"

@interface ProjectDetailsViewController : UIViewController

- (IBAction)CreateReference:(id)sender;

@property NSString* token;
@property ListItem* project;
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UITextField *projectNameField;
@property (weak, nonatomic) IBOutlet UILabel *referenceLbl;
@property (weak, nonatomic) IBOutlet UIButton *addReferenceBtn;
@property (weak, nonatomic) IBOutlet UITableView *refencesTable;
@property (assign) BOOL createProject;


@end
