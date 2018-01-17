//
//  WLDatePickerView.h
//  DatePicker
//
//  Created by wangli on 2018/1/16.
//  Copyright © 2018年 wangli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLDatePickerView : UIView

@property (nonatomic, strong) UIPickerView *pickerView;

/**
 *selectedDateString: 默认选中的时间
 *    fromDateString: 限制最早的时间 -- 可以为nil,表示最早时间不加限制
 *      toDateString: 限制最晚的时间 -- 可以为nil,表示最晚时间不加限制
 
 */
- (void)reloadPickerViewWithSelectedString:(NSString *)selectedDateString
                            fromDateString:(NSString *)fromDateString
                              toDateString:(NSString *)toDateString;


/*选中的时间字符串格式:2017-12-25*/
- (NSString *)choiceOfTimeString;

/*取消*/
- (void)cancelChoice;

@end
