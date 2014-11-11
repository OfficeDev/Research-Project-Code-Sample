#import <Foundation/Foundation.h>
#import <ADALiOS/ADAuthenticationContext.h>
#import <ADALiOS/ADAuthenticationParameters.h>
#import <ADALiOS/ADAuthenticationSettings.h>
#import <ADALiOS/ADLogger.h>
#import <ADALiOS/ADInstanceDiscovery.h>
#import "ProjectClientEx.h"
#import <UIKit/UIKit.h>

@interface ActionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *urlTxt;
@property (weak, nonatomic) IBOutlet UITableView *projectTable;
@property (weak, nonatomic) IBOutlet UILabel *successMsg;
@property (weak, nonatomic) IBOutlet UILabel *selectProjectLbl;
@property NSString* sharedUrl;
@property NSMutableArray *projectsList;
@end
