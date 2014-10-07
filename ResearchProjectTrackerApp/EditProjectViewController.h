#import <UIKit/UIKit.h>
#import "office365-lists-sdk/ListItem.h"

@interface EditProjectViewController : UIViewController

- (IBAction)editProject:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *ProjectNameTxt;
@property NSString* token;
@property ListItem* project;

@end
