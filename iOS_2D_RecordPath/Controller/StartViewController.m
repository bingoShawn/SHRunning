//
//  StartViewController.m
//  iOS_2D_RecordPath
//
//  Created by Shawn on 2018/12/25.
//  Copyright © 2018年 FENGSHENG. All rights reserved.
//

#import "StartViewController.h"
#import "MainViewController.h"
#import "CDZPicker.h"

//屏幕宽高
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)
@interface StartViewController ()
@property(nonatomic,strong)UIButton *startBtn;
@property(nonatomic,strong)UIButton *weightBtn;
@property(nonatomic,strong)UILabel *weightLabel;


@property(nonatomic,strong)NSMutableArray *weightArray;
@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *weightArray = [[NSMutableArray alloc] init];
    for (int i = 30; i < 131; i++) {
        [weightArray addObject:[NSString stringWithFormat:@"%i",i]];
    }
    self.weightArray = weightArray;
    
    self.title = @"开始跑步";

    
    self.weightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.weightBtn.frame = CGRectMake((WIDTH-280)/2, HEIGHT*0.37, 280, 40);
    self.weightBtn.layer.cornerRadius = 10;
    [self.weightBtn setTitle:@"点击设置体重,用于计算卡路里" forState:UIControlStateNormal];
    [self.weightBtn addTarget:self action:@selector(setWeight) forControlEvents:UIControlEventTouchUpInside];
    self.weightBtn.backgroundColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1.00];
    [self.view addSubview:self.weightBtn];
    
    NSString *weightRecord = [[NSUserDefaults standardUserDefaults] objectForKey:@"userWeight"];
    
    
     self.weightLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH-50)/2, CGRectGetMaxY(self.weightBtn.frame)+40, 50, 40)];
    self.weightLabel.text = [NSString stringWithFormat:@"%@ kg", weightRecord];
    self.weightLabel.hidden = YES;
    [self.view addSubview:self.weightLabel];
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startBtn.frame = CGRectMake((WIDTH-120)/2, CGRectGetMaxY(self.weightLabel.frame)+40, 120, 40);
    self.startBtn.layer.cornerRadius = 10;
    self.startBtn.hidden = YES;
    self.startBtn.userInteractionEnabled = NO;
    [self.startBtn setTitle:@"开始跑步" forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(goStart) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.startBtn];

    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *weightRecord = [[NSUserDefaults standardUserDefaults] objectForKey:@"userWeight"];
    self.weightLabel.text = [NSString stringWithFormat:@"%@ kg", weightRecord];
    self.weightBtn.hidden = NO;
    self.weightBtn.userInteractionEnabled = YES;
    if (weightRecord||weightRecord != nil) {
        self.weightLabel.hidden = NO;
        self.startBtn.hidden = NO;
        self.startBtn.userInteractionEnabled = YES;
    }else{
        self.weightLabel.hidden = YES;
        self.startBtn.hidden = YES;
        self.startBtn.userInteractionEnabled = NO;
    }
    
}


- (void)setWeight{
    [CDZPicker showMultiPickerInView:self.view withBuilder:nil stringArrays:@[self.weightArray,@[@"kg"]] confirm:^(NSArray<NSString *> * _Nonnull strings, NSArray<NSNumber *> * _Nonnull indexs) {
        [[NSUserDefaults standardUserDefaults] setObject:strings[0] forKey:@"userWeight"];
         self.weightLabel.text = [strings componentsJoinedByString:@""];
        self.weightLabel.hidden = NO;
        self.startBtn.hidden = NO;
        self.startBtn.userInteractionEnabled = YES;
        NSLog(@"strings:%@ indexs:%@",strings,indexs);
    } cancel:^{
        // your code
    }];
}



- (void)goStart{
    self.weightBtn.hidden = YES;
    self.weightBtn.userInteractionEnabled = NO;
    self.startBtn.hidden = YES;
    self.weightLabel.text = @"";
    self.startBtn.userInteractionEnabled = NO;
    MainViewController *vc = [[MainViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
