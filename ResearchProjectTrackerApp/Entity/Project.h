//
//  Project.h
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 29/09/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "office365-base-sdk/BaseEntity.h"

@interface Project : BaseEntity

@property (nonatomic) NSString *Name;
@property (nonatomic) NSString *Url;
@property (nonatomic) NSString *TimeLastModified;
@property (nonatomic) NSString *TimeCreated;
@property (nonatomic) int Size;

- (BaseEntity *)createFromJson:(NSDictionary *)data;

@end
