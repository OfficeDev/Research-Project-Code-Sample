#import "ViewController.h"

@interface EditReferenceViewController : ViewController
@property (weak, nonatomic) IBOutlet UITextField *referenceUrlTxt;
@property (weak, nonatomic) IBOutlet UITextField *referenceDescription;
@property (weak, nonatomic) IBOutlet UITextField *referenceTitle;
@property NSString* token;
@property NSDictionary* selectedReference;
@end
