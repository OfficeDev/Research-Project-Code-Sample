//
//  Reference.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 02/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "Reference.h"

@implementation Reference
- (NSString*) getTitle{
    return (NSString*)[self getData : @"Title"];
}

-(NSUUID*) getComments{
    return (NSUUID*)[self getData: @"Comments"];
}

-(NSUUID*) getUrl{
    return (NSUUID*)[self getData: @"Url"];
}

- (BaseEntity *)createFromJson:(NSDictionary *)data{
    self.title = [[data valueForKey: @"URL"] valueForKey:@"Description"];
    self.comments = [data valueForKey: @"Comments"];
    self.url = [[data valueForKey: @"URL"] valueForKey:@"Url"];
    
    return [super createFromJson:data];
}
@end
