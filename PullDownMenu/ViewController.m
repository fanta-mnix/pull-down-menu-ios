//
//  ViewController.m
//  PullDownMenu
//
//  Created by Rafael Fantini da Costa on 9/19/15.
//  Copyright © 2015 Rafael Fantini da Costa. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UICollisionBehavior *collision;
@property (nonatomic) UIAttachmentBehavior *attachment;
@property (nonatomic) UIGravityBehavior *gravity;
@property (nonatomic) UIPushBehavior *push;

@property (nonatomic) UIPanGestureRecognizer *pan;
@property (nonatomic) BOOL isMenuBeingOpened;

@property (nonatomic) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    
    CGRect collectionViewFrame = CGRectInset(self.view.bounds, 20, 20);
    CGSize collectionViewSize = collectionViewFrame.size;
    collectionViewSize.height -= 50;
    collectionViewFrame.size = collectionViewSize;
    self.collectionView = [[UICollectionView alloc]
                           initWithFrame:collectionViewFrame collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];

    UIView *effectView = [self createViewWithContent:self.collectionView];
    [self.view addSubview:effectView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[effectView]];
    self.gravity.gravityDirection = CGVectorMake(0.0f, -1.0f); // up
    [self.animator addBehavior:self.gravity];
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:@[effectView]];
    [self.collision setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(effectView.frame.origin.y, 0, 0, 0)];
    [self.animator addBehavior:self.collision];
    
    self.attachment = [[UIAttachmentBehavior alloc] initWithItem:effectView attachedToAnchor:effectView.center];
    
    self.push = [[UIPushBehavior alloc] initWithItems:@[effectView] mode:UIPushBehaviorModeInstantaneous];
    [self.animator addBehavior:self.push];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [effectView addGestureRecognizer:self.pan];
    // Do any additional setup after loading the view, typically from a nib.
}

- (UIView *)createViewWithContent:(UIView * _Nonnull)content {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = CGRectMake(0, -height + 64, width, height);
    
    UIView *contentHolder = [[UIView alloc] initWithFrame:effectView.bounds];
    contentHolder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.5f];
    [contentHolder addSubview:content];
    [effectView.contentView addSubview:contentHolder];
    
    return effectView;
}

- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint anchor = [gestureRecognizer locationInView:self.view];
    anchor.x = CGRectGetMidX(gestureRecognizer.view.frame);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.gravity];
        
        self.attachment.anchorPoint = anchor;
        [self.animator addBehavior:self.attachment];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.attachment.anchorPoint = anchor;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.attachment];
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        
        if (velocity.y > 0) { // moving down
            self.isMenuBeingOpened = YES;
            self.gravity.gravityDirection = CGVectorMake(0.0f, 1.0f);
        } else {
            self.isMenuBeingOpened = NO;
            self.gravity.gravityDirection = CGVectorMake(0.0f, -1.0f);
        }
        
        [self.animator addBehavior:self.gravity];
        self.push.pushDirection = CGVectorMake(0.0f, velocity.y * 0.05f);
        self.push.active = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    return  cell;
}

@end
