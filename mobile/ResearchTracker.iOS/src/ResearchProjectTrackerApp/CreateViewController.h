#import <UIKit/UIKit.h>

@interface CreateViewController : UIViewController

- (IBAction)createProject:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *FileNameTxt;
@property NSString* token;

@end
