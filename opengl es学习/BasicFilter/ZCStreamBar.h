//
//  ZCStreamBar.h
//  opengl es学习
//
//  Created by 张葱 on 2021/6/8.
//

#import <UIKit/UIKit.h>

@class ZCStreamBar;
@protocol ZCStreamBarDelegate <NSObject>

- (void)streamBar:(ZCStreamBar *)streamBar selectIndex:(NSInteger)index;

@end

@interface ZCStreamBar : UIView
@property (nonatomic, strong)NSArray *filters;
@property (nonatomic, weak)id <ZCStreamBarDelegate>delegate;
@end


