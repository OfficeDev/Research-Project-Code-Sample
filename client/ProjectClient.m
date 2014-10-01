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
#import "office365-base-sdk/NSString+NSStringExtensions.h"

@implementation ProjectClient

const NSString *apiUrl = @"/_api/lists";

- (NSURLSessionDataTask *)addProject:(NSString *)name item:(ListItem *)listItem callback:(void (^)(BOOL, NSError *))callback
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

- (NSURLSessionDataTask *)getProjectReferences:(NSString *)name projectId:(NSString *)projectId callback:(void (^)(NSMutableArray *listItems, NSError *error))callback{
    NSString *queryString = [NSString stringWithFormat:@"?filter=Project eq '%@'", projectId];
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items%@", self.Url , apiUrl, [name urlencode], [queryString urlencode]];
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential url:url];
    
    NSString *method = (NSString*)[[Constants alloc] init].Method_Get;
    
    return [connection execute:method callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        
        NSMutableArray *listsItemsArray =[self parseDataArray: data];
        for (NSDictionary* value in listsItemsArray) {
            [array addObject: [[ListItem alloc] initWithDictionary:value]];
        }
        
        callback(array ,error);
    }];
}

- (NSMutableArray *)parseDataArray:(NSData *)data{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSError *error ;
    
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:[self sanitizeJson:data]
                                                               options: NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSArray *jsonArray = [[jsonResult valueForKey : @"d"] valueForKey : @"results"];
    
    if(jsonArray != nil){
        for (NSDictionary *value in jsonArray) {
            [array addObject: value];
        }
    }else{
        NSDictionary *jsonItem =[jsonResult valueForKey : @"d"];
        
        if(jsonItem != nil){
            [array addObject:jsonItem];
        }
    }
    
    return array;
}

- (NSData*) sanitizeJson : (NSData*) data{
    NSString * dataString = [[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString* replacedDataString = [dataString stringByReplacingOccurrencesOfString:@"E+308" withString:@"E+127"];
    
    NSData* bytes = [replacedDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    return bytes;
}

@end
