//
//  ViewController.m
//  DatePicker
//
//  Created by wangli on 2017/12/18.
//  Copyright © 2017年 wangli. All rights reserved.
//

#import "ViewController.h"
#import "WLDatePickerView.h"

@interface ViewController ()
//时间选择器
@property (nonatomic, strong) WLDatePickerView *datePickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.datePickerView];
    
    // 1, 默认选中时间2017-6-25, 选择时间的范围限制在2016-6-25 到 2018-6-25 之间
     [_datePickerView reloadPickerViewWithSelectedString:@"2017-6-25" fromDateString:@"2016-6-25" toDateString:@"2018-6-25"];
    
    // 2, 默认选中时间2017-6-25, 选择时间的范围限制在 2018-6-25 之前
    // [_datePickerView reloadPickerViewWithSelectedString:@"2017-6-25" fromDateString:nil toDateString:@"2018-6-25"];
    
    // 3, 默认选中时间2017-6-25, 选择时间的范围限制在 2016-6-25 之后
//    [_datePickerView reloadPickerViewWithSelectedString:@"2017-6-25" fromDateString:@"2016-6-25" toDateString:nil];
    
    // 4, 默认选中时间2017-6-25, 不加范围限制
//    [_datePickerView reloadPickerViewWithSelectedString:@"2017-6-25" fromDateString:nil toDateString:nil];
}

- (IBAction)sureAction:(id)sender {
    NSString *timeString = [self.datePickerView choiceOfTimeString];
    NSLog(@"选择的日期:%@", timeString);
}

- (IBAction)cancelAction:(id)sender {
    [self.datePickerView cancelChoice];
}

- (WLDatePickerView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[WLDatePickerView alloc] initWithFrame:CGRectMake(50, 100, 300, 200)];
    }
    return _datePickerView;
}


@end
