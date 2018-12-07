//
//  NCAddressModel.h
//  NCAddressAlert
//
//  Created by 陈方舟 on 2018/11/4.
//  Copyright © 2018年 陈方舟. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCAddressModel : NSObject

@property (nonatomic, copy) NSString *areaId;
@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, strong) NSArray *areas;

+ (id)modelWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
