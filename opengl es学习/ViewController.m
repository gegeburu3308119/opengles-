//
//  ViewController.m
//  opengl es学习
//
//  Created by 张葱 on 2021/5/27.
//

#import "ViewController.h"
#import "CubeViewController.h"
#import "ZCBasicFilterController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"滤镜学习";
    // Do any additional setup after loading the view.
}


/// 基础二维平面滤镜
- (IBAction)BasicClick:(id)sender {
    ZCBasicFilterController *filterVC = [[ZCBasicFilterController alloc]init];
    [self.navigationController pushViewController:filterVC animated:YES];
}

/// 立方体旋转
- (IBAction)CubeSpinClick:(id)sender {
    CubeViewController *cubeVc = [[CubeViewController alloc]init];
    [self.navigationController pushViewController:cubeVc animated:YES];
}


/// 金字塔
- (IBAction)pyramidClick:(id)sender {
    
    
}

/// 长腿
- (IBAction)LonglegCLick:(id)sender {
    
    
}

@end
