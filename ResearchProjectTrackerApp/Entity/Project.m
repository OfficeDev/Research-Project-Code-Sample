//
//  Project.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 29/09/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "Project.h"

@implementation Project

- (BaseEntity *)createFromJson:(NSDictionary *)data{
    
    NSDictionary *metadata = [data valueForKey : @"__metadata"];
    
    [super createMetadata : metadata];
    
    self.Id = [data valueForKey : @"Id"];
    self.Name = [data valueForKey : @"Name"];
    self.references = [NSMutableArray alloc];
    
    return self;
}


@end
