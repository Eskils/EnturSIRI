//
//  EnturAPIFetch.m
//  EnturAPIFetch
//
//  Created by Eskil Sviggum on 02/01/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//
//Rutedata frå Entur.

#import "EnturAPIFetch.h"

@implementation EnturAPIFetch
NSString *APIURL = @"https://api.entur.org/journeyplanner/2.0/index/graphql";
NSString *PLASSCOMPURL_original = @"https://api.entur.org/api/geocoder/1.1/autocomplete?text=";
NSString *PLASSCOMPURL = @"https://api.entur.org/api/geocoder/1.1/autocomplete?text=";
NSString *query = @"{trip(from: {[#*FROM*#]}, to: {[#*TO*#]}, modes: [bus], numTripPatterns: 20) { tripPatterns { startTime, endTime, duration, legs { distance, transportSubmode, situations, {stopPlaces {name, id, description, latitude, longitude }}}}}}";



- (void)FinnBusstiderFra: (NSString*)OpprFra Til:(NSString*)OpprTil completion:(void (^)(NSDictionary *data))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        
    
    [self finnPlass:OpprFra lofteHandler:^(NSData *data) {
        NSDictionary *fraDict = [self MekkTilPlassDictionary:data];
        
        [self finnPlass:OpprTil lofteHandler:^(NSData *data2) {
            NSDictionary *tilDict = [self MekkTilPlassDictionary:data2];
            
            NSString *fra = [self MekkTilQueryString:fraDict];
            NSString *til = [self MekkTilQueryString:tilDict];
            
            query = [query stringByReplacingOccurrencesOfString:@"[#*FROM*#]" withString:fra];
            query = [query stringByReplacingOccurrencesOfString:@"[#*TO*#]" withString:til];
            
            
            [self lastNedJSON:APIURL lofteHandler:^(NSData *data) {
                NSDictionary *JSONDict = [self MekkTilDictionaryFraData:data];
                completion(JSONDict);
            }];
        }];
    }];
    
    });
    
    
    
    
}

- (NSString*) MekkTilQueryString: (NSDictionary*)Dict {
    NSString *streng = [NSString stringWithFormat:@"place: \"%@\", coordinates: {latitude:%@, longitude:%@}",[Dict objectForKey:@"NSR"],[Dict objectForKey:@"Latitude"],[Dict objectForKey:@"Longditude"]];
    return streng;
}

- (NSDictionary*) MekkTilDictionaryFraData: (NSData*)data {
    NSError *convertError;
    NSString *hentadataStreng = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData * hentaData = [hentadataStreng dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDict = [NSJSONSerialization JSONObjectWithData:hentaData options:NSJSONReadingAllowFragments error:&convertError];
    return JSONDict;
}

- (NSDictionary*) MekkTilPlassDictionary : (NSData*)data {
    NSDictionary *JSONDict = [self MekkTilDictionaryFraData:data];
    NSString *NSRid = [[JSONDict valueForKeyPath:@"features.properties"][0] objectForKey:@"id"];
    NSArray *LongLat = [[JSONDict valueForKeyPath:@"features.geometry"][0] objectForKey:@"coordinates"];
    NSDictionary *Dict = @{@"NSR":NSRid,
                           @"Latitude":LongLat[1],
                           @"Longditude":LongLat[0]};
    return Dict;
}

- (void)finnPlass: (NSString*)plass lofteHandler:(void (^)(NSData *data))lofteHandler{
    
    PLASSCOMPURL = [NSString stringWithFormat:@"%@%@", PLASSCOMPURL_original, plass];
    NSString* escapedUrlString = [PLASSCOMPURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *api = [NSURL URLWithString:escapedUrlString];
    NSURLRequest *apireq = [NSURLRequest requestWithURL:api];
    NSMutableURLRequest *mutapireq = [apireq mutableCopy];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:apireq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        
        lofteHandler(data);
        
    }] resume];
    
}



- (void)lastNedJSON: (NSString*)urlstreng lofteHandler:(void (^)(NSData *data))lofteHandler{
    NSDictionary *HEADERS = @{@"Accept":@"application/json",
                              @"Content-Type":@"application/json",
                              @"User-Agent":@"SIGABRT-RouteFetcher",
                              @"ET-Client-Name":@"SIGABRT-RouteFetcher",
                              @"ET-Client-ID":@"RouteFetcher"};
    NSArray * HeaderKeys = [HEADERS allKeys];
    NSArray * HeaderValues = [HEADERS allValues];
    
    NSURL *api = [NSURL URLWithString:urlstreng];
    NSURLRequest *apireq = [NSURLRequest requestWithURL:api];
    NSMutableURLRequest *MutApiReq = [apireq mutableCopy];
    
    for (NSInteger i = 0; i < HeaderKeys.count; i++) {
        [MutApiReq addValue:HeaderValues[i] forHTTPHeaderField:HeaderKeys[i]];
    }
    [MutApiReq setHTTPMethod:@"POST"];
    NSDictionary *vars = @{};
    NSDictionary *POSTDict = @{@"query":query,
                               @"variables":vars};
    NSError *convertError;
    NSData *PostData = [NSJSONSerialization dataWithJSONObject:POSTDict options:0 error:&convertError];
    NSString *streng = [[NSString alloc] initWithData:PostData encoding:NSUTF8StringEncoding];
    NSData *Postdata2 = [streng dataUsingEncoding:NSUTF8StringEncoding];
    [MutApiReq setHTTPBody: Postdata2];
    
    apireq = [MutApiReq copy];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:apireq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        lofteHandler(data);
        
    }] resume];
    
}


@end
