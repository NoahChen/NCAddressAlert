//
//  ViewController.m
//  NCAddressAlert
//
//  Created by 企鹅iOS陈方舟 on 2018/12/7.
//  Copyright © 2018 cfz. All rights reserved.
//

#import "ViewController.h"
#import "NCAddressAlert.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel * label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(150, 150, 100, 50)];
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"请选择地址" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickAddressButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 30)];
    self.label.textColor = [UIColor blackColor];
    [self.view addSubview:self.label];
}

- (void)clickAddressButton {
    NCAddressAlert *alert = [NCAddressAlert alert];
    [alert returnAddress:^(NSDictionary * _Nonnull provice, NSDictionary * _Nonnull city, NSDictionary * _Nonnull district) {
        self.label.text = [NSString stringWithFormat:@"%@ %@ %@", provice[@"address"], city[@"address"], district[@"address"]];
    }];
}


@end
