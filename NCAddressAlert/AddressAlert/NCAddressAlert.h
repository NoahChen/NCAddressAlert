//
//  NCAddressAlert.h
//  NCAddressAlert
//
//  Created by 陈方舟 on 2018/10/22.
//  Copyright © 2018年 陈方舟. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AddressBlock)(NSDictionary *provice, NSDictionary *city, NSDictionary *district);

@interface NCAddressAlert : UIView

@property (nonatomic, copy) AddressBlock block;
/** 是否是显示状态 */
@property (nonatomic, assign) BOOL isShow;

+ (id)alert;

/** 显示 */
- (void)showView;

/** 隐藏 */
- (void)hideView;

/** 传入已选择的地址数据 */
- (void)selectedAddress:(NSArray *)selectAddresses;

/** 选择完成返回的地址数据 */
- (void)returnAddress:(AddressBlock)block;

@end

NS_ASSUME_NONNULL_END
