//
//  NSObject+SafeSetValue.m
//  ZXBaseTableView
//
//  Created by 李兆祥 on 2018/8/20.
//  Copyright © 2018年 李兆祥. All rights reserved.
//

#import "NSObject+SafeSetValue.h"
#import <objc/runtime.h>
@implementation NSObject (SafeSetValue)
-(NSMutableArray *)getAllPropertyNames{
    NSMutableArray *propertyNamesArr = [NSMutableArray array];
    u_int count;
    objc_property_t *properties  = class_copyPropertyList([self class],&count);
    for(NSUInteger i = 0;i < count;i++){
        const char *propertyNameChar = property_getName(properties[i]);
        NSString *propertyNameStr = [NSString stringWithUTF8String: propertyNameChar];
        [propertyNamesArr addObject:propertyNameStr];
        
    }
    return propertyNamesArr;
}
-(NSMutableArray *)getAllValues{
    NSMutableArray *valuesArr = [NSMutableArray array];
    u_int count;
    objc_property_t *properties  = class_copyPropertyList([self class],&count);
    for(NSUInteger i = 0;i < count;i++){
        const char *propertyNameChar = property_getName(properties[i]);
        NSString *propertyNameStr = [NSString stringWithUTF8String: propertyNameChar];
        id obj = [self valueForKeyPath:propertyNameStr];
        if(obj){
            [valuesArr addObject:obj];
        }else{
            [valuesArr addObject:@""];
        }
        
    }
    return valuesArr;
}
-(void)safeSetValue:(id)value forKey:(NSString *)key{
    if([[self getAllPropertyNames] containsObject:key]){
        [self setValue:value forKey:key];
    }
}
-(void)safeSetValue:(id)value forKeyPath:(NSString *)key{
    if([[self getAllPropertyNames] containsObject:key]){
        [self setValue:value forKeyPath:key];
    }
}
-(instancetype)safeValueForKey:(NSString *)key{
    if([[self getAllPropertyNames] containsObject:key]){
        return [self valueForKey:key];
    }else{
        return nil;
    }
}
-(instancetype)safeValueForKeyPath:(NSString *)key{
    if([[self getAllPropertyNames] containsObject:key]){
        return [self valueForKeyPath:key];
    }else{
        return nil;
    }
}
@end
