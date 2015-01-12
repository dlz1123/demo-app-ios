//
//  DemoBlacklistViewController.m
//  iOS-IMKit-demo
//
//  Created by Liv on 15/1/6.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "DemoBlacklistViewController.h"

#import "RCIM.h"
#import "AppDelegate.h"

#import "RCSelectPersonViewController.h"
#define CellIdentifier @"Cell"

@interface DemoBlacklistViewController ()<UITableViewDataSource,UITableViewDelegate,RCSelectPersonViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *blacklist;
@property (nonatomic, strong) NSMutableArray *blacklistIds;
@end

@implementation DemoBlacklistViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(selectPerson:)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
    titleLabel.text = @"黑名单";
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    self.blacklist = [NSMutableArray new];
    self.blacklistIds = [NSMutableArray new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.rowHeight = 66.0f;
    __weak typeof(self) weakSelf = self;
    [[RCIM sharedRCIM] getBlacklist:^(NSArray *blockUserIds) {
        if (blockUserIds == nil) {
            /*dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"暂无数据"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            });*/
        }else{
            self.blacklistIds = [NSMutableArray arrayWithArray:blockUserIds];
            for (NSString *str in self.blacklistIds) {
                for (RCUserInfo *user in [(AppDelegate*)[UIApplication sharedApplication].delegate friendList]) {
                    if ([user.userId isEqualToString:str]) {
                        [weakSelf.blacklist addObject:user];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    } error:^(RCErrorCode status) {
        
    }];
}

//选择联系人
-(void) selectPerson : (id) sender
{
    //跳转好友列表界面，可是是融云提供的UI组件，也可以是自己实现的UI
    RCSelectPersonViewController *slcVC = [[RCSelectPersonViewController alloc]init];
    //控制多选
    slcVC.isMultiSelect = NO;
    slcVC.portaitStyle = RCUserAvatarCycle;
    slcVC.delegate = self;
    slcVC.preSelectedUserIds = self.blacklistIds;
    
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:slcVC];
    //导航和的配色保持一直
    UIImage *image= [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark -RCSelectPersonViewControllerDelegate
-(void)didSelectedPersons:(NSArray*)selectedArray viewController:(RCSelectPersonViewController *)viewController
{
    if(selectedArray == nil || selectedArray.count != 1) return;

    __weak typeof(&*self)weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.rongcloud.addToBlacklist", NULL);
    
    dispatch_async(queue, ^{
        
        RCUserInfo *_selectedUserInfo = [selectedArray objectAtIndex:0];
        NSString *_selectedUserId = _selectedUserInfo.userId;
        
        [[RCIM sharedRCIM]addToBlacklist:_selectedUserId completion:^{
            
            [weakSelf.blacklist addObjectsFromArray:selectedArray];
            [weakSelf.blacklistIds addObject:_selectedUserId];
            NSLog(@"addToBlockList success blacklist>>%@, weakSelf.blacklistIds>%@", weakSelf.blacklist,weakSelf.blacklistIds);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        } error:^(RCErrorCode status) {
            NSLog(@"addToblockList Failed %d", (int)status);
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.blacklist.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    RCUserInfo *user = self.blacklist[indexPath.row];
    cell.textLabel.text = user.name;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RCUserInfo *_removedUser = self.blacklist[indexPath.row];
        
        __weak typeof(&*self) weakself = self;
        dispatch_queue_t queue = dispatch_queue_create("com.rongcloud.removeFromBlacklist", NULL);
        dispatch_async(queue, ^{
           [[RCIM sharedRCIM]removeFromBlacklist:_removedUser.userId completion:^{
               dispatch_async(dispatch_get_main_queue(), ^{
                   NSLog(@"before weakself.blacklistIds>%@, _removeduserId>>%@", weakself.blacklistIds, _removedUser.userId);
                   [weakself.blacklistIds removeObject:_removedUser.userId];
                   [weakself.blacklist removeObjectAtIndex:indexPath.row];
                   
                   
                   // Delete the row from the data source.
                   [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                   NSLog(@"removeFromBlockList success weakself.blacklist>>%@, weakSelf.blacklistIds>%@",weakself.blacklist, weakself.blacklistIds);
               });
           } error:^(RCErrorCode status) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                       message:@"删除黑名单失败"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                   [alertView show];
               });
           }];
        });
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}



@end
