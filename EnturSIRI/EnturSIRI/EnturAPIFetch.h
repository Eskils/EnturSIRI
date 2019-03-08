//
//  EnturAPIFetch.h
//  EnturAPIFetch
//
//  Created by Eskil Sviggum on 02/01/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnturAPIFetch : NSObject
- (void)FinnBusstiderFra: (NSString*)OpprFra Til:(NSString*)OpprTil completion:(void (^)(NSDictionary *data))completion;
- (NSDictionary*) MekkTilDictionaryFraData: (NSData*)data;
@end
