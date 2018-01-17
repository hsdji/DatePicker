//
//  WLDatePickerView.m
//  DatePicker
//
//  Created by wangli on 2018/1/16.
//  Copyright © 2018年 wangli. All rights reserved.
//

#import "WLDatePickerView.h"

@interface WLDatePickerView() <UIPickerViewDataSource, UIPickerViewDelegate>

    //记录当前选中的年月日
@property (nonatomic, copy) NSString *year; //年
@property (nonatomic, copy) NSString *month;//月
@property (nonatomic, copy) NSString *day;  //日

    //保存年,月,日的数组
@property (nonatomic, strong) NSMutableArray *yearsArray;
@property (nonatomic, strong) NSMutableArray *monthsArray;
@property (nonatomic, strong) NSMutableArray *daysArray;

    //每个分区,当前选中的行
@property (nonatomic) NSInteger selectedYearNumber;
@property (nonatomic) NSInteger selectedMonthNumber;
@property (nonatomic) NSInteger selectedDayNumber;

    //计算每个月的天数
@property (nonatomic) NSInteger daysNumber;

    //是否需要更新某个月的天数
@property (nonatomic) BOOL isReloadDayNumber;

@property (nonatomic, copy) NSString *fromDateString;
@property (nonatomic, copy) NSString *toDateString;

@end

@implementation WLDatePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.pickerView];
        
    }
    return self;
}

    //取消选择
- (void)cancelChoice {
    [self removeFromSuperview];
}

    //返回选中的时间字符串
- (NSString *)choiceOfTimeString {
    return [NSString stringWithFormat:@"%@-%@-%@", self.year, self.month, self.day];
}

#pragma mark -- UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    switch (component) {
        case 0:
            return [self.yearsArray count];
            break;
        case 1:
            return [self.monthsArray count];
            break;
        case 2:
            return [self.daysArray count];
            break;
        default:
            break;
    }
    return 0;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return self.yearsArray[row];
            break;
        case 1:
            return self.monthsArray[row];
            break;
        case 2:
            return self.daysArray[row];
            break;
        default:
            break;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
        //获取选择的日期,赋值
    if (component == 0) {
        _isReloadDayNumber = YES;
        self.year = _yearsArray[row];
        self.selectedYearNumber = row;
        [pickerView reloadComponent:0];
    } else if (component == 1) {
        _isReloadDayNumber = YES;
        self.month = _monthsArray[row];
        self.selectedMonthNumber = row;
        [pickerView reloadComponent:1];
    } else if(component == 2) {
        self.day = _daysArray[row];
        self.selectedDayNumber = row;
        [pickerView reloadComponent:2];
    }
    
    if (_isReloadDayNumber) {//需要更新天数
        [self calculateDayWithMonth:self.selectedMonthNumber + 1 year:self.selectedYearNumber + 1];
        _isReloadDayNumber = NO;
        [pickerView reloadComponent:2];
    }
        //比较时间:
    [self compareWithComponent:component];
}


    //比较时间:
- (void)compareWithComponent:(NSInteger)component{
    if (self.fromDateString == nil && self.toDateString == nil) {
        return;
    }
        //现在时间
    NSDate *fromDate = [self changeWithDateString:self.fromDateString];
        //预期时间
    NSDate *toDate = [self changeWithDateString:self.toDateString];
        //选择时间
    NSString *string = [NSString stringWithFormat:@"%@-%@-%@", self.year, self.month, self.day];
    NSDate *selectedTime = [self changeWithDateString:string];
    
        //比较时间
        //选择时间和现在比较
    NSComparisonResult result1 = [selectedTime compare:fromDate];
        //选择时间和预期时间比较
    NSComparisonResult result2 = [selectedTime compare:toDate];
    NSInteger row0 = 0;
    NSInteger row1 = 0;
    NSInteger row2 = 0;
    //if (model == TimeBarModelBefore) {//选择出生日期,选择时间只能比现在早
    //当有前后时间限制时,选中的时间需要在限制时间之内
    if (self.fromDateString.length > 1 && self.toDateString.length > 1) {
        if (result1 == NSOrderedDescending) {//如果选择的时间,在未来的某个时刻, 在前时间的后面,需要滚动到现在
            if (result2 == NSOrderedDescending) {//也在后时间的后面
                
                NSDateComponents *p = [self calendarWithDate:toDate];
                
                    //滚动到指定位置
                [self.pickerView selectRow:p.year - 1 inComponent:0 animated:YES];
                [self.pickerView selectRow:p.month - 1 inComponent:1 animated:YES];
                [self.pickerView selectRow:p.day - 1 inComponent:2 animated:YES];
                [self.pickerView reloadAllComponents];
                
                    //更新数据
                self.year = [@(p.year) stringValue];
                self.month = [@(p.month) stringValue];
                self.day = [@(p.day) stringValue];
                
                    //重新滚动一次,防止显示的row和选中的row不是同一行,会造成row的颜色异常
                row0 = [self.pickerView selectedRowInComponent:0];
                row1 = [self.pickerView selectedRowInComponent:1];
                row2 = [self.pickerView selectedRowInComponent:2];
                [self pickerView:self.pickerView didSelectRow:row0 inComponent:0];
                [self pickerView:self.pickerView didSelectRow:row1 inComponent:1];
                [self pickerView:self.pickerView didSelectRow:row2 inComponent:2];
            }
        }
            //} else if (model == TimeBarModelAfter) {//选择预产期,选择的时间在未来的某个时间段内
        if (result2 == NSOrderedAscending) {//选择时间比现在早,需要滚动到现在
            if (result1 == NSOrderedAscending) {
                
                NSDateComponents *p = [self calendarWithDate:fromDate];
                [self.pickerView selectRow:p.year - 1 inComponent:0 animated:YES];
                [self.pickerView selectRow:p.month - 1 inComponent:1 animated:YES];
                [self.pickerView selectRow:p.day - 1 inComponent:2 animated:YES];
                [self.pickerView reloadAllComponents];
                self.year = [@(p.year) stringValue];
                self.month = [@(p.month) stringValue];
                self.day = [@(p.day) stringValue];
                row0 = [self.pickerView selectedRowInComponent:0];
                row1 = [self.pickerView selectedRowInComponent:1];
                row2 = [self.pickerView selectedRowInComponent:2];
                [self pickerView:self.pickerView didSelectRow:row0 inComponent:0];
                [self pickerView:self.pickerView didSelectRow:row1 inComponent:1];
                [self pickerView:self.pickerView didSelectRow:row2 inComponent:2];
            }
        }
    }
    
    //当只有前时间限制,没有后时间限制时
    if (self.fromDateString.length > 1 && self.toDateString.length < 1) {
        if (result1 == NSOrderedAscending) {
            NSDateComponents *p = [self calendarWithDate:fromDate];
            
                //滚动到指定位置
            [self.pickerView selectRow:p.year - 1 inComponent:0 animated:YES];
            [self.pickerView selectRow:p.month - 1 inComponent:1 animated:YES];
            [self.pickerView selectRow:p.day - 1 inComponent:2 animated:YES];
            [self.pickerView reloadAllComponents];
            
                //更新数据
            self.year = [@(p.year) stringValue];
            self.month = [@(p.month) stringValue];
            self.day = [@(p.day) stringValue];
            
                //重新滚动一次,防止显示的row和选中的row不是同一行,会造成row的颜色异常
            row0 = [self.pickerView selectedRowInComponent:0];
            row1 = [self.pickerView selectedRowInComponent:1];
            row2 = [self.pickerView selectedRowInComponent:2];
            [self pickerView:self.pickerView didSelectRow:row0 inComponent:0];
            [self pickerView:self.pickerView didSelectRow:row1 inComponent:1];
            [self pickerView:self.pickerView didSelectRow:row2 inComponent:2];
        }
    }
    
    //当没有前时间限制,只有后时间限制时
    if (self.fromDateString.length < 1 && self.toDateString.length > 1) {
        if (result2 == NSOrderedDescending) {
            NSDateComponents *p = [self calendarWithDate:toDate];
            
                //滚动到指定位置
            [self.pickerView selectRow:p.year - 1 inComponent:0 animated:YES];
            [self.pickerView selectRow:p.month - 1 inComponent:1 animated:YES];
            [self.pickerView selectRow:p.day - 1 inComponent:2 animated:YES];
            [self.pickerView reloadAllComponents];
            
                //更新数据
            self.year = [@(p.year) stringValue];
            self.month = [@(p.month) stringValue];
            self.day = [@(p.day) stringValue];
            
                //重新滚动一次,防止显示的row和选中的row不是同一行,会造成row的颜色异常
            row0 = [self.pickerView selectedRowInComponent:0];
            row1 = [self.pickerView selectedRowInComponent:1];
            row2 = [self.pickerView selectedRowInComponent:2];
            [self pickerView:self.pickerView didSelectRow:row0 inComponent:0];
            [self pickerView:self.pickerView didSelectRow:row1 inComponent:1];
            [self pickerView:self.pickerView didSelectRow:row2 inComponent:2];
        }
    }
}

    //改变选中文字的颜色
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* titleLabel = (UILabel*)view;
    if (!titleLabel){
        titleLabel = [[UILabel alloc] init];
        titleLabel.minimumScaleFactor = 8;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont systemFontOfSize:15]];
            //被选中的row,改变颜色
        UIColor *color = [UIColor colorWithRed: 249 / 255.0 green:164 / 255.0 blue:202 / 255.0 alpha:1.0];
        if (component == 0 && self.selectedYearNumber == row) {
            titleLabel.textColor = color;
        }else if (component==1 && self.selectedMonthNumber == row){
            titleLabel.textColor = color;
        }else if(component == 2 && self.selectedDayNumber == row){
            titleLabel.textColor = color;
        }
    }
    
        //获取选中行的文字
    titleLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return titleLabel;
}

    //获取当前日历
- (NSDateComponents *)calendarWithDate:(NSDate *)data {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:data];
    return dateComponents;
}

    //把当前日期转化为包含年月日的时间,(因为时间比较的时候,时分秒会有差异,为了方便比较日期,只比较年月日)
- (NSDate *)changeWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:date];
    NSDate *selectedTime = [self changeWithDateString:dateString];
    return selectedTime;
}

    //把年月日字符串转化为时间
- (NSDate *)changeWithDateString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *selectedTime = [formatter dateFromString:dateString];
    return selectedTime;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:self.bounds];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (void)reloadPickerViewWithSelectedString:(NSString *)selectedDateString
                            fromDateString:(NSString *)fromDateString
                              toDateString:(NSString *)toDateString {
    self.fromDateString = fromDateString;
    self.toDateString = toDateString;
    
    NSInteger year, month, day;
        //如果之前选择过出生日期,就会有存储的数据传过来,如果没有,就显示当前的时间数据
    if (selectedDateString) {//存储的时间数据
        NSArray *dateStringArray = [selectedDateString componentsSeparatedByString:@"-"];
        year = [dateStringArray[0] integerValue];
        month = [dateStringArray[1] integerValue];
        day = [dateStringArray[2] integerValue];
    } else {//没有存储时间数据,显示当前时间
        NSDateComponents *components = [self calendarWithDate:[NSDate date]];
        year = [components year];
        month = [components month];
        day = [components day];
    }
    self.year = [@(year) stringValue];
    self.month = [@(month) stringValue];
    self.day = [@(day) stringValue];
        //年月日都拿到了,现在需要获取每个月的天数
    [self calculateDayWithMonth:month year:year];
        //选择数组中第几个数据
    self.selectedYearNumber = year - 1;
    self.selectedMonthNumber = month - 1;
    self.selectedDayNumber = day - 1;
    
    [self.pickerView selectRow:self.selectedYearNumber inComponent:0 animated:NO];
    [self.pickerView selectRow:self.selectedMonthNumber inComponent:1 animated:NO];
    [self.pickerView selectRow:self.selectedDayNumber inComponent:2 animated:NO];
    [self.pickerView reloadAllComponents];
}
    //获取指定月份的天数
- (void)calculateDayWithMonth:(NSInteger)month year:(NSInteger)year {
    BOOL isLeapYear;//是否是闰年
    if (year % 400 == 0) {
            //是闰年
        isLeapYear = YES;
    } else if (year % 100 != 0 && year % 4 == 0) {
            //闰年
        isLeapYear = YES;
    } else {
        isLeapYear = NO;
    }
    
    switch (month) {
        case 2:
            if (isLeapYear) {//闰年
                _daysNumber = 29;
            } else {//非闰年
                _daysNumber = 28;
            }
            break;
        case 4:
            _daysNumber = 30;
            break;
        case 6:
            _daysNumber = 30;
            break;
        case 9:
            _daysNumber = 30;
            break;
        case 11:
            _daysNumber = 30;
            break;
            
        default: //除2,4,6,9,11 一个月都是31天
            _daysNumber = 31;
            break;
    }
    [self daysOfNumber:_daysNumber];//将每个月的天数从新赋值
}


    //年数据
- (NSMutableArray *)yearsArray {
    if (!_yearsArray) {
        _yearsArray = [NSMutableArray array];
        NSDateComponents *components = [self calendarWithDate:[NSDate date]];
        NSInteger year = [components year];
        for (NSInteger years = 1; years <= year + 5; years++) {
            [_yearsArray addObject:[NSString stringWithFormat:@"%ld", years]];
        }
    }
    return _yearsArray;
}

    //日数据
- (void)daysOfNumber:(NSInteger)dayNumber {
    if (self.selectedDayNumber >= dayNumber) {
        self.selectedDayNumber = dayNumber-1;
    }
    if (self.daysArray.count) {
        [self.daysArray removeAllObjects];
    }
    for (NSInteger i = 1; i <= dayNumber; i++) {
        [_daysArray addObject:[NSString stringWithFormat:@"%ld", i]];
    }
}

    //月数据
- (NSMutableArray *)monthsArray {
    if (!_monthsArray) {
        _monthsArray = [NSMutableArray array];
        for (NSInteger i = 1; i <= 12; i++) {
            [_monthsArray addObject:[@(i) stringValue]];
        }
    }
    return _monthsArray;
}

- (NSMutableArray *)daysArray {
    if (!_daysArray) {
        _daysArray = [NSMutableArray array];
    }
    return _daysArray;
}

@end
