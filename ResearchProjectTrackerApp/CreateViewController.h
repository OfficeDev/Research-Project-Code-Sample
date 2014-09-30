#import <UIKit/UIKit.h>

@interface CreateViewController : UIViewController

- (IBAction)CreateFile:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *FileNameTxt;
@property (weak, nonatomic) IBOutlet UITextView *ContentText;
@property NSString* token;

@end
