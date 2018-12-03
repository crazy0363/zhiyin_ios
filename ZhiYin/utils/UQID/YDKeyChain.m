//
//  IWKeyChain.h
//  KeyChainTest
//
//  Created by HouYadi on 16/3/21.
//  Copyright © 2016年 侯亚迪 All rights reserved.
//

#import "YDKeyChain.h"

#define BUNDLE_ID [[NSBundle mainBundle] bundleIdentifier]

@implementation YDKeyChain

+ (void)saveObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    [mDic setValuesForKeysWithDictionary:(NSMutableDictionary *)[SaveKeyChain load:BUNDLE_ID]];
    [mDic setObject:object forKey:key];
    [SaveKeyChain save:BUNDLE_ID data:mDic];
}

+ (id)readObjectForKey:(NSString *)key {
    NSMutableDictionary *mDic = (NSMutableDictionary *)[SaveKeyChain load:BUNDLE_ID];
    return [mDic objectForKey:key];
}

+ (void)deleteObjectForKey:(NSString *)key {
    NSMutableDictionary *mDic = (NSMutableDictionary *)[SaveKeyChain load:BUNDLE_ID];
    [mDic removeObjectForKey:key];
    [SaveKeyChain save:BUNDLE_ID data:mDic];
}

+ (void)deleteAllObject {
    [SaveKeyChain delete:BUNDLE_ID];
}

@end

@implementation SaveKeyChain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
}

@end
