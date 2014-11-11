#import <UIKit/UIKit.h>

@interface EditProjectViewController : UIViewController

- (IBAction)editProject:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *ProjectNameTxt;
@property NSString* token;
@property NSDictionary* project;

@end
