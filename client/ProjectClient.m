//
//  ProjectClient.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 01/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "ProjectClient.h"
#import "Reference.h"
#import "office365-base-sdk/HttpConnection.h"
#import "office365-base-sdk/Constants.h"
#import "office365-base-sdk/NSString+NSStringExtensions.h"

@implementation ProjectClient

const NSString *apiUrl = @"/_api/lists";

- (NSURLSessionDataTask *)addProject:(NSString *)name item:(ListItem *)listItem callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", self.Url , apiUrl, [name urlencode]];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Title': '%@'}}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [listItem getTitle]];
    
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
    }];
    return 0;
}

- (NSURLSessionDataTask *)updateProject:(NSString *)name item:(ListItem *)listItem callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", self.Url , apiUrl, [name urlencode], listItem.Id];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Title': '%@'}}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [listItem getTitle]];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:theRequest
                                          returningResponse:&response
                                                      error:&error];
    
    ListEntity *list;
    callback(list, error);

    
    /*HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential
                                                                         url:url
                                                                   bodyArray: jsonData];
    
    NSString *method = (NSString*)[[Constants alloc] init].Method_Post;
    
    return [connection execute:method callback:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        
        ListEntity *list;
        
        if(error == nil){
            list = [[ListEntity alloc] initWithJson:data];
        }
        
        callback(list, error);
    }];*/
    return 0;
}

- (NSURLSessionDataTask *)updateReference:(NSString *)name item:(Reference *)reference callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", self.Url , apiUrl, [name urlencode], reference.Id];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'URL': {'Url':'%@'}}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, reference.url];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    //HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential
                                                                         //url:url
                                                                   //bodyArray: jsonData];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json;odata=verbose" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:theRequest
                                          returningResponse:&response
                                                      error:&error];
    
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                               options: NSJSONReadingMutableContainers
                                                                 error:nil];
    
    NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    ListEntity *list;
    callback(list, error);
    
    
    /*NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    //NSString *method = (NSString*)[[Constants alloc] init].Method_Post;
    
    theConnection
    
    return [connection execute:method callback:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        
        ListEntity *list;
        
        if(error == nil){
            list = [[ListEntity alloc] initWithJson:data];
        }
        
        callback(list, error);
    }];*/
    return 0;
}

- (NSURLSessionDataTask *)addReference:(NSString *)name item:(Reference *)reference callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", self.Url , apiUrl, [name urlencode]];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'URL': {'Url':'%@'}}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, reference.url, reference.description];
    
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
    }];
    return 0;
}


- (NSURLSessionDataTask *)getProjectReferences:(NSString *)name projectId:(NSString *)projectId callback:(void (^)(NSMutableArray *listItems, NSError *error))callback{
    NSString *queryString = [NSString stringWithFormat:@"filter=Project eq '%@'", projectId];
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items?%@", self.Url , apiUrl, [name urlencode], [queryString urlencode]];
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential url:url];
    
    NSString *method = (NSString*)[[Constants alloc] init].Method_Get;
    
    return [connection execute:method callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        
        NSMutableArray *listsItemsArray =[self parseDataArray: data];
        for (NSDictionary* value in listsItemsArray) {
            [array addObject: [[Reference alloc] initWithDictionary:value]];
        }
        
        callback(array ,error);
    }];
}



- (NSURLSessionDataTask *)deleteListItem:(NSString *)name itemId:(NSString *)itemId callback:(void (^)(BOOL result, NSError *error))callback{
    
    //NSString *queryString = [NSString stringWithFormat:@"filter=Id eq '%@'", itemId];
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", self.Url , apiUrl, [name urlencode], itemId];
    
    
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential
                                                                         url:url
                                                                   bodyArray: nil];
    
    NSString *method = (NSString*)[[Constants alloc] init].Method_Delete;
    
    return [connection execute:method callback:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        
        BOOL result = FALSE;
        
        if(error == nil && [data length] == 0 ){
            result = TRUE;
        }
        
        callback(result, error);
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
