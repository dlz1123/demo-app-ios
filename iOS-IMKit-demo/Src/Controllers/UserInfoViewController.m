//
//  UserInfoViewController.m
//  iOS-IMKit-demo
//
//  Created by xugang on 8/21/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "UserInfoViewController.h"
#import "RCIM.h"
#import "UserDataModel.h"
@interface UserInfoViewController ()

@property (nonatomic,strong) UIBarButtonItem *addItem;
@property (nonatomic,strong) UIBarButtonItem *replyItem;

@property (nonatomic,strong) UIButton *btn ;


@end

@implementation UserInfoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(50,100 , 220, 50)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationTitle:@"用户资料"];
    
    [self.view addSubview:self.nameLabel];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 35)];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    
    [leftButton addTarget:self action:@selector(didCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    self.navigationItem.leftBarButtonItem=left;
    
    
    self.btn = [UIButton new];
    [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn setBackgroundColor:[UIColor redColor]];
    self.btn.layer.cornerRadius = 3.5;
    [self.btn setFrame:CGRectMake(10, self.view.bounds.size.height - 300, self.view.bounds.size.width - 20, 35)];
    [self.view addSubview:self.btn];

    //查看是否已经在黑名单，并更新UI
    [self setBtnState];
}

-(void) setBtnState
{
    //查看是否已经在黑名单，并更新UI
    __weak typeof(self) weakSelf = self;
    [[RCIM sharedRCIM] getBlacklist:^(NSArray *blockUserIds) {
        
        if([[UserManager shareMainUser].mainUser.userId isEqualToString:weakSelf.targetId])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.btn setTitle:@"不能添加自己黑名单" forState:UIControlStateNormal];
                
            });
            return;
            
        }

        for (NSString *ids in blockUserIds) {
            if([ids isEqualToString:weakSelf.targetId] )
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.btn.enabled = YES;
                    [weakSelf.btn setTitle:@"移出黑名单" forState:UIControlStateNormal];
                    [weakSelf.btn addTarget:weakSelf action:@selector(removeFromBlackList:) forControlEvents:UIControlEventTouchUpInside];

                });
                return;
                
            }
            
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.btn.enabled = YES;
            [weakSelf.btn setTitle:@"加入黑名单" forState:UIControlStateNormal];
            [weakSelf.btn addTarget:weakSelf action:@selector(addToBlackList:) forControlEvents:UIControlEventTouchUpInside];
        });


    } error:NULL];
}

/**
 *  加入黑名单
 *
 *  @param sender sender description
 */
-(void) addToBlackList : (id) sender
{
    __weak typeof(self) weakSelf = self;
    [[RCIM sharedRCIM] addToBlacklist:self.targetId completion:^{
        [weakSelf setBtnState];
    } error:^(RCErrorCode status) {
        DebugLog(@"test is %ld",(long)status);
    }];
}

/**
 *  移除黑名单
 *
 *  @param sender sender description
 */
-(void) removeFromBlackList:(id) sender
{
    __weak typeof(self) weakSelf = self;
    [[RCIM sharedRCIM] removeFromBlacklist:self.targetId completion:^{
        [weakSelf setBtnState];
    } error:NULL];
}

-(void)didCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNavigationTitle:(NSString *)title
{
    UILabel* titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLab.font = [UIFont systemFontOfSize:18];
    [titleLab setBackgroundColor:[UIColor clearColor]];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.tag = 1000;
    //[self.navigationController.navigationBar addSubview:titleLab];
    self.navigationItem.titleView=titleLab;
    
    titleLab.text = title;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
