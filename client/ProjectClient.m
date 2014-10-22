//
//  ProjectClient.m
//  ResearchProjectTrackerApp
//
//  Created by Lucas Damian Napoli on 01/10/14.
//  Copyright (c) 2014 microsoft. All rights reserved.
//

#import "ProjectClient.h"
#import "office365-base-sdk/Constants.h"
#import "office365-base-sdk/HttpConnection.h"
#import "office365-base-sdk/NSString+NSStringExtensions.h"
#import "office365-base-sdk/OAuthentication.h"
#import <ADALiOS/ADAuthenticationContext.h>
#import <ADALiOS/ADAuthenticationParameters.h>
#import <ADALiOS/ADAuthenticationSettings.h>
#import <ADALiOS/ADInstanceDiscovery.h>
#import <ADALiOS/ADLogger.h>
#import <office365-base-sdk/LoginClient.h>

@implementation ProjectClient

const NSString *apiUrl = @"/_api/lists";
const NSString *authority = @"https://login.windows.net/common";
const NSString *redirectUriString = @"http://android/complete";
const NSString *resourceId = @"https://foxintergen.sharepoint.com";
const NSString *clientId = @"13b04d26-95fc-4fb4-a67e-c850e07822a8";


- (NSURLSessionDataTask *)addProject:(ListItem *)listItem callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", self.Url , apiUrl, [@"Research Projects" urlencode]];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Title': '%@'}}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [listItem getTitle]];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential
                                                                         url:url
                                                                   bodyArray: jsonData];
    
    NSString *method = (NSString*)[[Constants alloc] init].Method_Post;
    
    return [connection execute:method callback:^(NSData  *data, NSURLResponse *reponse, NSError *error) {
        ListItem *list;
        
        if(error == nil){
            list = [[ListItem alloc] initWithJson:data];
        }
        
        callback(list, error);
    }];
}

- (NSURLSessionDataTask *)updateProject:(ListItem *)project callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", self.Url , apiUrl, [@"Research Projects" urlencode], project.Id];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Title': '%@'}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [project getTitle]];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    [theRequest setHTTPBody:jsonData];
    [self.Credential prepareRequest:theRequest];
    
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:theRequest
                                          returningResponse:&response
                                                      error:&error];
    
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                               options: NSJSONReadingMutableContainers
                                                                 error:nil];
    NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    callback((!jsonResult && [myString isEqualToString:@""]), error);

    return 0;
}

- (NSURLSessionDataTask *)updateReference:(ListItem *)reference callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items(%@)", self.Url , apiUrl, [@"Research References" urlencode], reference.Id];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'Comments': '%@', 'URL':{'Url':'%@', 'Description':'%@'}}";
    
    NSDictionary *dic =[reference getData:@"URL"];
    NSString *refUrl = [dic valueForKey:@"Url"];
    NSString *refTitle = [dic valueForKey:@"Description"];
    
    NSString *formatedJson = [NSString stringWithFormat:json, [reference getData:@"Comments"], refUrl, refTitle];
    
    NSData *jsonData = [formatedJson dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"MERGE" forHTTPHeaderField:@"X-HTTP-Method"];
    [theRequest setValue:@"*" forHTTPHeaderField:@"IF-MATCH"];
    [theRequest setHTTPBody:jsonData];
    [self.Credential prepareRequest:theRequest];
    
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:theRequest
                                          returningResponse:&response
                                                      error:&error];
    
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                               options: NSJSONReadingMutableContainers
                                                                 error:nil];
    NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    callback((!jsonResult && [myString isEqualToString:@""]), error);
    
    return 0;
}

- (NSURLSessionDataTask *)addReference:(ListItem *)reference callback:(void (^)(BOOL, NSError *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items", self.Url , apiUrl, [@"Research References" urlencode]];
    
    NSString *json = [[NSString alloc] init];
    json = @"{ 'URL': %@, 'Comments':'%@', 'Project':'%@'}";
    
    NSString *formatedJson = [NSString stringWithFormat:json, [reference getData:@"URL"], [reference getData:@"Comments"], [reference getData:@"Project"]];
    
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
}


- (NSURLSessionDataTask *)getReferencesByProjectId:(NSString *)projectId callback:(void (^)(NSMutableArray *listItems, NSError *error))callback{
    NSString *queryString = [NSString stringWithFormat:@"Project eq '%@'", projectId];
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items?$filter=%@", self.Url , apiUrl, [@"Research References" urlencode], [queryString urlencode]];
    HttpConnection *connection = [[HttpConnection alloc] initWithCredentials:self.Credential url:url];
    
    NSString *method = (NSString*)[[Constants alloc] init].Method_Get;
    
    return [connection execute:method callback:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data
                                                                   options: NSJSONReadingMutableContainers
                                                                     error:nil];
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSMutableArray *listsItemsArray =[self parseDataArray: data];
        for (NSDictionary* value in listsItemsArray) {
            [array addObject: [[ListItem alloc] initWithDictionary:value]];
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

- (NSURLSessionDataTask *)getProjectsAndCallback:(void (^)(NSMutableArray *listItems, NSError *))callback{
    
    NSString *aditionalParams = [NSString stringWithFormat:@"?$select=%@&$expand=Editor", [@"ID,Title,Modified,Editor/Title" urlencode]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/GetByTitle('%@')/Items%@", self.Url , apiUrl, [@"Research Projects" urlencode],aditionalParams];
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


+(ProjectClient*)getClient:(NSString *) token{
    OAuthentication* authentication = [OAuthentication alloc];
    [authentication setToken:token];
    
    return [[ProjectClient alloc] initWithUrl:@"https://foxintergen.sharepoint.com/ContosoResearchTracker"
                               credentials: authentication];
}

+(LoginClient*)getLoginClient{
    return [[LoginClient alloc] initWithParameters:clientId:redirectUriString:resourceId:authority];
}

@end
