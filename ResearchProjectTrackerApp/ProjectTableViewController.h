#import <UIKit/UIKit.h>
#import "CreateViewController.h"

@interface ProjectTableViewController : UIViewController

@property NSMutableArray *projectsList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSString* token;
@end