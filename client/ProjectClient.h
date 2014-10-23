#import "office365-lists-sdk/ListClient.h"
#import "office365-lists-sdk/ListItem.h"
#import <office365-base-sdk/LoginClient.h>


@interface ProjectClient : ListClient

- (NSURLSessionDataTask *)addProject:(ListItem *)listItem callback: (void (^)(BOOL success, NSError *error))callback;
- (NSURLSessionDataTask *)getReferencesByProjectId:(NSString *)projectId callback:(void (^)(NSMutableArray *listItems, NSError *error))callback;
- (NSURLSessionDataTask *)addReference:(ListItem *)reference callback: (void (^)(BOOL success, NSError *error))callback;
- (NSURLSessionDataTask *)deleteListItem:(NSString *)name itemId:(NSString *)itemId callback:(void (^)(BOOL result, NSError *error))callback;
- (NSURLSessionDataTask *)updateProject:(ListItem *)project callback:(void (^)(BOOL, NSError *))callback;
- (NSURLSessionDataTask *)updateReference:(ListItem *)reference callback:(void (^)(BOOL, NSError *))callback;
- (NSURLSessionDataTask *)getProjectsAndCallback:(void (^)(NSMutableArray *listItems, NSError *))callback;


+(ProjectClient*)getClient:(NSString *) token;
+(LoginClient*)getLoginClient;

@end
