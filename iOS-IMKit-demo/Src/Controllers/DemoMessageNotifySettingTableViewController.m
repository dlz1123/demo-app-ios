//
//  DemoMessageNotifySettingTableViewController.m
//  iOS-IMKit-demo
//
//  Created by Liv on 15/2/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCIM.h"
#import "DemoMessageNotifySettingTableViewController.h"
#import "AppDelegate.h"

@interface DemoMessageNotifySettingTableViewController ()
@property (nonatomic, strong) NSIndexPath* indexPath;
@property (nonatomic, strong) UISwitch* swch;
@end

@implementation DemoMessageNotifySettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                     NSFontAttributeName : [UIFont boldSystemFontOfSize:18] };
    self.title = @"免打扰设置";

    self.tableView.tableFooterView = [UIView new];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSIndexPath* startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath* endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell* startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
    UITableViewCell* endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];

    NSString* startTime = startCell.detailTextLabel.text;
    NSString* endTime = endCell.detailTextLabel.text;
    if (startTime.length == 0 || endTime.length == 0) {
        return;
    }

    NSDateFormatter* formatterE = [[NSDateFormatter alloc] init];
    [formatterE setDateFormat:@"HH:mm:ss"];
    NSDate* startDate = [formatterE dateFromString:startTime];
    NSDate* endDate = [formatterE dateFromString:endTime];
    double timeDiff = [endDate timeIntervalSinceDate:startDate];
    int timeDif = timeDiff / 60;

    [[RCIM sharedRCIM] setConversationNotificationQuietHours:startTime spanMins:timeDif SuccessCompletion:^{
        NSLog(@"设置成功!");
    } errorCompletion:^(RCErrorCode status) {
        NSLog(@"设置失败!");
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0)
        return 1;

    return 4;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        return 250;
    }
    return 44;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellReuseIdentifier"];

    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCellReuseIdentifier"];
    }

    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIDatePicker* datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        [datePicker setDate:[NSDate date]];
        //        datePicker.datePickerMode = UIDatePickerModeTime;
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:datePicker];
    }
    else {
        //initial setting
        _swch = [[UISwitch alloc] init];

        switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"开始时间";
        } break;
        case 1: {
            cell.textLabel.text = @"结束时间";
        } break;
        case 2: {
            cell.textLabel.text = @"解除屏蔽";

        } break;
        default: {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"屏蔽所有消息";
            [_swch setFrame:CGRectMake(self.view.frame.size.width - _swch.frame.size.width - 15, 6, 0, 0)];
            [_swch addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:_swch];

        } break;
        }

        [[RCIM sharedRCIM] getConversationNotificationQuietHours:^(NSString* startTime, int spansMin) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"HH:mm:ss"];
                        NSString *endString = nil;
                        if (startTime && startTime.length != 0) {
                            NSDate *startDate = [dateFormatter dateFromString:startTime];
                            NSDate *endDate = [startDate dateByAddingTimeInterval:spansMin * 60];
                            endString = [dateFormatter stringFromDate:endDate];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            switch (indexPath.row) {
                                case 0:
                                {
                                    if (startTime.length == 0 || startTime == nil) {
                                        NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
                                        [formatterE setDateFormat:@"HH:mm:ss"];
                                        NSString *startDate = [formatterE stringFromDate:[NSDate date]];
                                        cell.detailTextLabel.text = startDate;

                                    }
                                    else
                                        cell.detailTextLabel.text = startTime;
                                }
                                    break;
                                case 1:
                                {
                                    cell.detailTextLabel.text = endString;
                                }
                                    break;
                                default:
                                {
                                    if (spansMin == 1439) {
                                        [_swch setOn:YES];
                                    }
                                    
                                }
                                    break;
                            }
                        });

        } errorCompletion:^(RCErrorCode status){

        }];
    }
    return cell;
}

#pragma mark - Table view Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2) {
        [[RCIM sharedRCIM] setAppNotDistrubState:0];

        [_swch setOn:NO];
        [[RCIM sharedRCIM] removeConversationNotificationQuietHours:^{
            NSLog(@"解除成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
                startCell.detailTextLabel.text = @"";
                endCell.detailTextLabel.text = @"";

            });

        } errorCompletion:^(RCErrorCode status){

        }];
    }
    else if ((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 1)) {
        _indexPath = indexPath;
    }
}

#pragma mark - datePickerValueChanged
- (void)datePickerValueChanged:(UIDatePicker*)datePicker
{
    [_swch setOn:NO];
    [self.tableView selectRowAtIndexPath:_indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString* currentDateStr = [dateFormatter stringFromDate:datePicker.date];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text = currentDateStr;

    NSIndexPath* startIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath* endIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell* startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
    UITableViewCell* endCell = [self.tableView cellForRowAtIndexPath:endIndexPath];
    NSDate* startTime = [dateFormatter dateFromString:startCell.detailTextLabel.text];
    NSDate* endTime = [dateFormatter dateFromString:endCell.detailTextLabel.text];

    if (startTime == nil || endTime == nil) {
        return;
    }
    NSDate* laterTime = [startTime laterDate:endTime];
    if ([laterTime isEqualToDate:startTime]) {
        startCell.detailTextLabel.text = @"";
        [self.tableView selectRowAtIndexPath:startIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:startIndexPath];

        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"开始时间不能大于等于结束时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
}

#pragma mark - setSwitchState

- (void)setSwitchState:(UISwitch*)swich
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionTop];

    if (swich.on) {
        NSString* startTime = @"00:00:00";
        [[RCIM sharedRCIM] setConversationNotificationQuietHours:startTime spanMins:1439 SuccessCompletion:^{
            NSLog(@"设置成功!");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *startIndexPath    = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath      = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell     = [self.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell       = [self.tableView cellForRowAtIndexPath:endIndexPath];
                startCell.detailTextLabel.text = @"00:00:00";
                endCell.detailTextLabel.text   = @"23:59:59";

            });

        } errorCompletion:^(RCErrorCode status){

        }];
    }
    else {
        [[RCIM sharedRCIM] removeConversationNotificationQuietHours:^{
            NSLog(@"关闭成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *startIndexPath    = [NSIndexPath indexPathForRow:0 inSection:1];
                NSIndexPath *endIndexPath      = [NSIndexPath indexPathForRow:1 inSection:1];
                UITableViewCell *startCell     = [self.tableView cellForRowAtIndexPath:startIndexPath];
                UITableViewCell *endCell       = [self.tableView cellForRowAtIndexPath:endIndexPath];
                startCell.detailTextLabel.text = @"";
                endCell.detailTextLabel.text   = @"";

            });

        } errorCompletion:^(RCErrorCode status) {
            NSLog(@"关闭失败");

        }];
    }


}


@end
