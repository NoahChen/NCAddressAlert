//
//  NCAddressModel.m
//  NCAddressAlert
//
//  Created by 陈方舟 on 2018/11/4.
//  Copyright © 2018年 陈方舟. All rights reserved.
//

#import "NCAddressModel.h"

@implementation NCAddressModel

+ (id)modelWithDictionary:(NSDictionary *)dic {
    NCAddressModel *model = [[NCAddressModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
