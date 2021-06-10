//
//  CubeViewController.m
//  opengl es学习
//
//  Created by 张葱 on 2021/5/31.
//

#import "CubeViewController.h"
#import "ZCCubeView.h"

@interface CubeViewController ()

@end

@implementation CubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"立方体相册";
    ZCCubeView *zcView = [[ZCCubeView alloc]initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, self.view.bounds.size.width)];
    [self.view addSubview:zcView];
    // Do any additional setup after loading the view.
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
