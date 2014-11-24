#import "ViewController.h"

@interface CreateReferenceViewController : ViewController
@property (weak, nonatomic) IBOutlet UITextField *referenceTitle;
@property (weak, nonatomic) IBOutlet UITextField *referenceUrlTxt;
@property (weak, nonatomic) IBOutlet UITextField *referenceDescription;
@property NSString* token;
@property NSDictionary* project;
@end
