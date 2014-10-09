//
//  ProjectClient.h
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 01/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "office365-lists-sdk/ListClient.h"
#import "office365-lists-sdk/ListItem.h"

@interface ProjectClientEx : ListClient


- (NSURLSessionDataTask *)addReference:(ListItem *)reference callback: (void (^)(BOOL success, NSError *error))callback;

@end
