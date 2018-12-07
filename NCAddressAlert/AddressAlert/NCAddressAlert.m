//
//  NCAddressAlert.m
//  NCAddressAlert
//
//  Created by 陈方舟 on 2018/10/22.
//  Copyright © 2018年 陈方舟. All rights reserved.
//

#import "NCAddressAlert.h"
#import "NCAddressModel.h"
#import <objc/runtime.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define VIEW_HEIGHT 442
#define k_ButtonCenter_Space 80

typedef enum : NSUInteger {
    LOAD_PROVICE,
    LOAD_CITY,
    LOAD_DISTRICT,
} AddressType;

@interface NCAddressAlert () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CALayer *lineLayer;

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *proviceArr;
@property (nonatomic, strong) NSArray *cityArr;
@property (nonatomic, strong) NSArray *districtArr;

@property (nonatomic, strong) NSDictionary *selectedProvinceDic;
@property (nonatomic, strong) NSDictionary *selectedCityDic;
@property (nonatomic, strong) NSDictionary *selectedDistrictDic;

@end

@implementation NCAddressAlert

+ (id)alert {
    NCAddressAlert *alert = [[NCAddressAlert alloc] init];
    [alert showView];
    return alert;
}

- (instancetype)init {
    if (self = [super init]) {
        self.isShow = NO;
        [self createUI];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    return self;
}

- (void)showView {
    if (!self.isShow) {
        CGRect viewFrame = self.frame;
        viewFrame.origin.y = 0;
        self.frame = viewFrame;
        
        CGRect alertFrame = self.alertView.frame;
        alertFrame.origin.y = self.frame.size.height-VIEW_HEIGHT;
        [UIView animateWithDuration:0.3 animations:^{
            self.alertView.frame = alertFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                self.isShow = YES;
            }
        }];
    }
}

- (void)hideView {
    if (self.isShow) {
        CGRect alertFrame = self.alertView.frame;
        alertFrame.origin.y = SCREEN_HEIGHT;
        [UIView animateWithDuration:0.3 animations:^{
            self.alertView.frame = alertFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                CGRect viewFrame = self.frame;
                viewFrame.origin.y = SCREEN_HEIGHT;
                self.frame = viewFrame;
                
                self.isShow = NO;
                
                [self removeFromSuperview];
            }
        }];
    }
}

- (void)returnAddress:(AddressBlock)block {
    self.block = block;
}

- (void)selectedAddress:(NSArray *)selectAddresses {
    if (selectAddresses.count == 0) {
        return;
    }
    for (int i = 0; i<3; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:100+i];
        btn.userInteractionEnabled = YES;
        [btn setTitle:selectAddresses[i][@"address"] forState:UIControlStateNormal];
        if (i == 0) {
            self.selectedProvinceDic = selectAddresses[0];
        }
        if (i == 1) {
            self.selectedCityDic = selectAddresses[1];
        }
        if (i == 2) {
            self.selectedDistrictDic = selectAddresses[2];
        }
    }
    CGPoint linePosition = self.lineLayer.position;
    linePosition.x = 40 + 2*k_ButtonCenter_Space;
    self.lineLayer.position = linePosition;
    
    NSDictionary *jsonDic = [self loadJson];
    NSArray *dataArr = jsonDic[@"data"][@"areas"];
    NSMutableArray *pArr = [NSMutableArray array];
    for (NSDictionary *dic in dataArr) {
        [pArr addObject:[NCAddressModel modelWithDictionary:dic]];
    }
    self.proviceArr = pArr;
    for (int i = 0; i<dataArr.count; i++) {
        if ([dataArr[i][@"areaId"] isEqualToString:self.selectedProvinceDic[@"id"]]) {
            NSArray *citys = dataArr[i][@"areas"];
            NSMutableArray *cArr = [NSMutableArray array];
            for (NSDictionary *dic in citys) {
                [cArr addObject:[NCAddressModel modelWithDictionary:dic]];
            }
            self.cityArr = cArr;
            if (citys) {
                for (int j = 0; j<citys.count; j++) {
                    if ([citys[j][@"areaId"] isEqualToString:self.selectedCityDic[@"id"]]) {
                        NSArray *districts = citys[j][@"areas"];
                        if (districts) {
                            NSLog(@"区域数组---%@", districts);
                            NSMutableArray *arr = [NSMutableArray array];
                            for (NSDictionary *dic in districts) {
                                [arr addObject:[NCAddressModel modelWithDictionary:dic]];
                            }
                            self.districtArr = arr;
                            self.dataArr = arr;
                            [self.tableView reloadData];
                        }
                        break;
                    }
                }
            }
            break;
        }
    }
}

#pragma mark - UI
- (void)createUI {
    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0];
    self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    //mask
    self.maskView = [[UIView alloc] initWithFrame:self.bounds];
    self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:self.maskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView:)];
    [self.maskView addGestureRecognizer:tap];
    
    //alertView
    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, VIEW_HEIGHT)];
    self.alertView.backgroundColor = [UIColor whiteColor];
    [self insertSubview:self.alertView aboveSubview:self.maskView];
    
    //取消按钮 & 确定按钮
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    bgView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    [self.alertView addSubview:bgView];
    
    //取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 62, bgView.frame.size.height)];
    cancelBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cancelBtn];
    
    //确定按钮
    UIButton *defineBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-62, 0, 62, bgView.frame.size.height)];
    defineBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [defineBtn setTitle:@"确定" forState:UIControlStateNormal];
    [defineBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:162/255.0 blue:0/255.0 alpha:1] forState:UIControlStateNormal];
    [defineBtn addTarget:self action:@selector(defineButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:defineBtn];
    
    //标题栏
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height, SCREEN_WIDTH, 46)];
    [self.alertView addSubview:self.topView];
    CALayer *bottomLayer = [CALayer layer];
    bottomLayer.frame = CGRectMake(0, self.topView.frame.size.height-0.5, SCREEN_WIDTH, 0.5);
    bottomLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.topView.layer addSublayer:bottomLayer];
    
    //顶部按钮
    CGFloat btnWidth = 80;
    CGFloat btnHeight = 45;
    for (int i = 0; i<3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth*i, 0, btnWidth, btnHeight)];
        btn.tag = 100+i;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        if (i == 0) {
            [btn setTitle:@"请选择" forState:UIControlStateNormal];
        } else {
            btn.userInteractionEnabled = NO;
        }
        [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:btn];
    }
    
    //顶部滑动Layer
    self.lineLayer = [CALayer layer];
    self.lineLayer.bounds = CGRectMake(0, 0, 50, 1);
    self.lineLayer.anchorPoint = CGPointMake(0.5, 0);
    self.lineLayer.position = CGPointMake(btnWidth/2, btnHeight);
    self.lineLayer.backgroundColor = [UIColor orangeColor].CGColor;
    [self.topView.layer addSublayer:self.lineLayer];
    
    //tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height+self.topView.frame.size.height, SCREEN_WIDTH, self.alertView.frame.size.height-bgView.frame.size.height-self.topView.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 44;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.alertView addSubview:self.tableView];
    
    [self loadDataWithTag:100 row:0];
}

#pragma mark - 手势
- (void)tapMaskView:(UITapGestureRecognizer *)tap {
    [self hideView];
}

#pragma mark - 按钮点击事件
- (void)topBtnClick:(UIButton *)sender {
    CGPoint linePosition = self.lineLayer.position;
    if (linePosition.x == sender.center.x) return;
    
    if (sender.tag == 100) {
        self.dataArr = self.proviceArr;
    }
    else if (sender.tag == 101) {
        self.dataArr = self.cityArr;
    }
    else {
        self.dataArr = self.districtArr;
    }
    [self.tableView reloadData];
    
    linePosition.x = sender.center.x;
    [UIView animateWithDuration:0.2 animations:^{
        self.lineLayer.position = linePosition;
    }];
}

//取消
- (void)cancelButtonClick {
    [self hideView];
}

//确定
- (void)defineButtonClick {
    if (self.selectedProvinceDic && self.selectedCityDic && self.selectedDistrictDic) {
        [self hideView];
        if (self.block) {
            self.block(self.selectedProvinceDic, self.selectedCityDic, self.selectedDistrictDic);
        }
    } else {
        NSLog(@"请完成区域选择");
    }
}

- (void)loadDataWithTag:(NSInteger)tag row:(NSInteger)row {
    switch (tag) {
        case 100:
//            NSLog(@"刷新:省");
            [self loadAddressDataWithType:LOAD_PROVICE index:row];
            break;
        case 101:
//            NSLog(@"刷新:市");
            [self loadAddressDataWithType:LOAD_CITY index:row];
            break;
        case 102:
//            NSLog(@"刷新:区");
            [self loadAddressDataWithType:LOAD_DISTRICT index:row];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"数组元素个数---%lu", (unsigned long)self.dataArr.count);
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"NCAddressAlertCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NCAddressModel *model = self.dataArr[indexPath.row];
    cell.textLabel.text = model.areaName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (UIButton *btn in self.topView.subviews) {
        if (btn.center.x == self.lineLayer.position.x) {
            NCAddressModel *model = self.dataArr[indexPath.row];
            [btn setTitle:model.areaName forState:UIControlStateNormal];
            
            NSDictionary *selectedAddress = @{
                                              @"address": model.areaName,
                                              @"id": model.areaId
                                              };
            switch (btn.tag) {
                case 100:
                    self.selectedProvinceDic = selectedAddress;
                    self.selectedCityDic = nil;
                    self.selectedDistrictDic = nil;
                    break;
                case 101:
                    self.selectedCityDic = selectedAddress;
                    self.selectedDistrictDic = nil;
                    break;
                case 102:
                    self.selectedDistrictDic = selectedAddress;
                    break;
                default:
                    break;
            }
            break;
        }
    }
    
    if (self.lineLayer.position.x < 200) {
        CGPoint linePosition = self.lineLayer.position;
        linePosition.x += k_ButtonCenter_Space;
        [UIView animateWithDuration:0.2 animations:^{
            self.lineLayer.position = linePosition;
        }];
        
        for (UIButton *btn in self.topView.subviews) {
            if (btn.center.x == linePosition.x) {
                btn.userInteractionEnabled = YES;
                [btn setTitle:@"请选择" forState:UIControlStateNormal];
                if (btn.tag == 101) {
                    UIButton *nextBtn = (UIButton *)[self viewWithTag:btn.tag+1];
                    [nextBtn setTitle:@"" forState:UIControlStateNormal];
                    nextBtn.userInteractionEnabled = NO;
                }
                [self loadDataWithTag:btn.tag row:indexPath.row];
                break;
            }
        }
    }
}

#pragma mark - JSON Data
- (NSDictionary *)loadJson {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
}

- (void)loadAddressDataWithType:(AddressType)type index:(NSInteger)index {
    NSArray *dataArr = @[];
    if (type == LOAD_PROVICE) {
        NSDictionary *jsonDic = [self loadJson];
        dataArr = jsonDic[@"data"][@"areas"];
    }
    else {
        NCAddressModel *model = self.dataArr[index];
        dataArr = model.areas;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in dataArr) {
        [arr addObject:[NCAddressModel modelWithDictionary:dic]];
    }
    self.dataArr = arr;
    
    if (type == LOAD_PROVICE) {
        self.proviceArr = arr;
    }
    else if (type == LOAD_CITY) {
        self.cityArr = arr;
    }
    else {
        self.districtArr = arr;
    }
}

#pragma mark - Service Data
- (void)loadServiceData:(AddressType)type {
    
}

@end
