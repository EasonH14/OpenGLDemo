//
//  ViewController.m
//  SplitScreenDemo
//
//  Created by hys on 2019/6/25.
//  Copyright © 2019 hys. All rights reserved.
//

#import "ViewController.h"
#import "FilterBar.h"
#import "SplitView.h"

@interface ViewController ()<FilterBarDelegate>

@property (nonatomic, weak) SplitView *splitView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupFilterBar];
    [self setupSplitView];
}


- (void)setupFilterBar {
    
    CGFloat filterBarWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat filterBarHeight = 100.f;
    CGFloat filterBarY = [UIScreen mainScreen].bounds.size.height - filterBarHeight;
    FilterBar *filterBar = [[FilterBar alloc] initWithFrame:CGRectMake(0, filterBarY, filterBarWidth, filterBarHeight)];
    filterBar.delegate = self;
    [self.view addSubview:filterBar];
    
    filterBar.itemList = @[@"无", @"分屏_2", @"分屏_3", @"分屏_4", @"分屏_6", @"分屏_9"];
    
}

- (void)setupSplitView {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat splitViewY = (screenHeight - screenWidth - 100.f) / 2.0;
    
    SplitView *splitView = [[SplitView alloc] initWithFrame:CGRectMake(0, splitViewY, screenWidth, screenWidth)];
    
    [self.view addSubview:splitView];
    
    self.splitView = splitView;
    
}

- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index {
    
    NSString *name = [NSString stringWithFormat:@"SplitScreen_%lu", index+1];
    
    [self.splitView renderWithName:name];
    
}

@end
