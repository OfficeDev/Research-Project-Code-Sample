//
//  Reference.h
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 02/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "office365-base-sdk/BaseEntity.h"

@interface Reference : BaseEntity

@property NSString* title;
@property NSString* comments;
@property NSString* url;

@end
