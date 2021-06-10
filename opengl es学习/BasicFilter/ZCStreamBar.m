//
//  ZCStreamBar.m
//  opengl es学习
//
//  Created by 张葱 on 2021/6/8.
//

#import "ZCStreamBar.h"

@interface ZCStreamBarCell : UICollectionViewCell
@property (nonatomic, strong) NSString *filterString;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, assign) BOOL isSelect;
@end


@implementation ZCStreamBarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.contentView.backgroundColor = [UIColor blackColor];
    UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 12;
    label.textAlignment =NSTextAlignmentCenter;
    [label setFont:[UIFont systemFontOfSize:22]];
    label.textColor = [UIColor whiteColor];
    _contentLabel = label;
    [self.contentView addSubview:label];
}

- (void)setFilterString:(NSString *)filterString {
    _filterString = filterString;
    _contentLabel.text = filterString;
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    _contentLabel.backgroundColor = isSelect ? [UIColor lightGrayColor] : [UIColor blackColor];
  
}


@end

@interface ZCStreamBar()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;

@end
@implementation ZCStreamBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor blackColor];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;

    CGFloat itemW = 100;
    CGFloat itemH = CGRectGetHeight(self.frame);
    flowLayout.itemSize = CGSizeMake(itemW, itemH);
    
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[self bounds] collectionViewLayout:flowLayout];
    _collectionView = collectionView;
    [self addSubview:_collectionView];
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[ZCStreamBarCell class] forCellWithReuseIdentifier:@"ZCStreamBarCell"];
}

#pragma mark - setter

- (void)setFilters:(NSArray *)filters {
    _filters = filters;
    [_collectionView reloadData];
}

- (void)selectIndex:(NSIndexPath *)indexPath {
    
    _currentIndex = indexPath.row;
    [_collectionView reloadData];
    
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(streamBar:selectIndex:)]) {
        [self.delegate streamBar:self selectIndex:indexPath.row];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_filters count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZCStreamBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZCStreamBarCell" forIndexPath:indexPath];
    cell.filterString = self.filters[indexPath.row];
    cell.isSelect = indexPath.row == _currentIndex;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self selectIndex:indexPath];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
