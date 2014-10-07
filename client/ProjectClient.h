//
//  ProjectClient.h
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 01/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "office365-lists-sdk/ListClient.h"
#import "office365-lists-sdk/ListItem.h"
#import "Reference.h"

@interface ProjectClient : ListClient

- (NSURLSessionDataTask *)addProject:(NSString *)name item:(ListItem *)listItem callback: (void (^)(BOOL success, NSError *error))callback;
- (NSURLSessionDataTask *)getProjectReferences:(NSString *)name projectId:(NSString *)projectId callback:(void (^)(NSMutableArray *listItems, NSError *error))callback;
- (NSURLSessionDataTask *)addReference:(NSString *)name item:(Reference *)reference callback: (void (^)(BOOL success, NSError *error))callback;
- (NSURLSessionDataTask *)deleteListItem:(NSString *)name itemId:(NSString *)itemId callback:(void (^)(BOOL result, NSError *error))callback;
- (NSURLSessionDataTask *)updateProject:(NSString *)name item:(ListItem *)listItem callback:(void (^)(BOOL, NSError *))callback;
- (NSURLSessionDataTask *)updateReference:(NSString *)name item:(Reference *)reference callback:(void (^)(BOOL, NSError *))callback;

@end
