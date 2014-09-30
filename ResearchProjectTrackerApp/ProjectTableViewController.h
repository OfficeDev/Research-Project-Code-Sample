#import <UIKit/UIKit.h>
#import "CreateViewController.h"

@interface ProjectTableViewController : UITableViewController

@property NSMutableArray *projectsList;
@property NSString* token;

- (IBAction)Download:(id)sender;

@end