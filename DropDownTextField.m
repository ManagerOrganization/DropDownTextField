//
//  DropDownTextField.m
//
//  Created by CJ Gehin-Scott on 2/26/16.
//  Copyright © 2016 Segue Technologies, Inc. All rights reserved.
//  Original swift code written by  Ziyang Tan as ZTDropDownTextField
//

#import "DropDownTextField.h"
#import <POP/POP.h>

@interface DropDownTextField() <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSLayoutConstraint *heightConstraint;
@end

@implementation DropDownTextField

@synthesize dropDownTableView,dropDownTableViewHeight,rowHeight,animationStyle,heightConstraint,dropDownDataSourceDelegate;

#pragma mark - Init Methods
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupTextField];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTextField];
    }
    return self;
}

#pragma mark - Setup Methods
-(void)setupTextField{
    [self addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
}

-(void)setupTableView{
    dropDownTableViewHeight = 150.0;
    rowHeight = 50.0;
    if (dropDownTableView == nil) {
        dropDownTableView = [[UITableView alloc]init];
        dropDownTableView.backgroundColor = [UIColor whiteColor];
        dropDownTableView.layer.cornerRadius = 10.0;
        dropDownTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        dropDownTableView.layer.borderWidth = 1.0;
        dropDownTableView.dataSource = self;
        dropDownTableView.delegate = self;
        dropDownTableView.showsVerticalScrollIndicator = NO;
        dropDownTableView.estimatedRowHeight = rowHeight;
        
        [self.superview addSubview:dropDownTableView];
        [self.superview bringSubviewToFront:dropDownTableView];
        
        [dropDownTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        heightConstraint = [NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:dropDownTableViewHeight];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:dropDownTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:1];
        [NSLayoutConstraint activateConstraints:[NSArray<NSLayoutConstraint *> arrayWithObjects:leftConstraint,rightConstraint,heightConstraint,topConstraint, nil]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.cancelsTouchesInView = false;
        [self.superview addGestureRecognizer:tapGesture];
    }
}

-(void)tableViewAppearanceChange:(BOOL)appear{
    switch (animationStyle) {
        case kBasic:
        {
            POPBasicAnimation *basicAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
            basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            basicAnimation.toValue = appear ? @(1) : @(0);
            [dropDownTableView pop_addAnimation:basicAnimation forKey:@"basic"];
        }
            break;
        case kSlide:
        {
            POPBasicAnimation *slideAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
            slideAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            slideAnimation.toValue = appear ? @(dropDownTableViewHeight) : @(0);
            [heightConstraint pop_addAnimation:slideAnimation forKey:@"heightConstraint"];
        }
            break;
        case kExpand:
        {
            POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
            springAnimation.springSpeed = dropDownTableViewHeight / 100;
            springAnimation.springBounciness = 10.0;
            int width = appear ? CGRectGetWidth(self.superview.frame) : 0;
            int height = appear ? dropDownTableViewHeight : 0;
            springAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(width, height)];
            [dropDownTableView pop_addAnimation:springAnimation forKey:@"expand"];
        }
            break;
        case kFlip:
        {
            CATransform3D identity = CATransform3DIdentity;
            identity.m34 = -1.0/1000;
            CGFloat angle = appear ? 1.0 : M_PI_2;
            [UIView animateWithDuration:0.5 animations:^{
                dropDownTableView.layer.transform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0);
            }];
        }
            break;
        default:
            break;
    }
}


#pragma mark - Target Methods
-(void)editingChanged:(UITextField*)textField{
    if ([textField.text length] > 0) {
        [self setupTableView];
        [self tableViewAppearanceChange:YES];
    }else{
        if (dropDownTableView != nil) {
            [self tableViewAppearanceChange:NO];
        }
    }
}

-(void)tapped:(UIGestureRecognizer*)gesture{
    CGPoint location = [gesture locationInView:self.superview];
    if (!CGRectContainsPoint(dropDownTableView.frame, location)) {
        if (dropDownTableView != nil) {
            [self tableViewAppearanceChange:NO];
        }
    }
}

#pragma mark - UITableviewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (dropDownDataSourceDelegate) {
        if ([dropDownDataSourceDelegate respondsToSelector:@selector(dropDownTextfield:numberOfRowsInSection:)]) {
            return [dropDownDataSourceDelegate dropDownTextfield:self numberOfRowsInSection:section];
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (dropDownDataSourceDelegate) {
        if ([dropDownDataSourceDelegate respondsToSelector:@selector(dropDownTextField:cellForRowAtIndexPath:)]) {
            return [dropDownDataSourceDelegate dropDownTextField:self cellForRowAtIndexPath:indexPath];
        }
    }
    return [[UITableViewCell alloc]init];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (dropDownDataSourceDelegate) {
        if ([dropDownDataSourceDelegate respondsToSelector:@selector(dropdDownTextField:didSelectRowAtIndexPath:)]) {
            [dropDownDataSourceDelegate dropdDownTextField:self didSelectRowAtIndexPath:indexPath];
        }
    }
    [self tableViewAppearanceChange:NO];
}

@end
