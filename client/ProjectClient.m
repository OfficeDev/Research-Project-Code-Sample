//
//  ProjectClient.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 01/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "ProjectClient.h"
#import "office365-base-sdk/HttpConnection.h"
#import "office365-base-sdk/Constants.h"

@implementation ProjectClient

const NSString *apiUrl = @"/_api/lists";

- (NSURLSessionDataTask *)addItemToList:(NSString *)name item:(ListItem *)listItem callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.Url , apiUrl];
    
    
    NSString *json = [[NSString alloc] init];
    /*json =  @"{'AllowContentTypes': %@,'BaseTemplate': %@,";
    json = [json stringByAppendingString: @"'ContentTypesEnabled': %@, 'Description': '%@', 'Title': '%@'}"];
    
    NSString *formatedJson = [NSString stringWithFormat:json, @"true",@"104" , @"true" , newList.description, newList.title];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential
                                                                         url:url
                                                                   bodyArray: jsonData];
    
    NSString *method = (NSString*)[[Constants alloc] init].Method_Post;
    
    return [connection execute:method callback:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        ListEntity *list;
        
        if(error == nil){
            list = [[ListEntity alloc] initWithJson:data];
        }
        
        callback(list, error);
    }];*/
    return 0;
}

@end
