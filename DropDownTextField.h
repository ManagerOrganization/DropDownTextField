//
//  DropDownTextField.h
//
//  Created by CJ Gehin-Scott on 2/26/16.
//  Copyright © 2016 Segue Technologies, Inc. All rights reserved.
//  Original swift code written by  Ziyang Tan as ZTDropDownTextField
//

#import <UIKit/UIKit.h>

#pragma mark - Animation Style Enum
typedef enum {
    kBasic,kSlide,kExpand,kFlip
}DropDownAnimationStyle;
@protocol DropDownTextFieldDataSourceDelegate;

@interface DropDownTextField : UITextField
@property (nonatomic,strong)UITableView *dropDownTableView;
@property (nonatomic)CGFloat rowHeight;
@property (nonatomic)CGFloat dropDownTableViewHeight;
@property (nonatomic)DropDownAnimationStyle animationStyle;
@property (weak) id<DropDownTextFieldDataSourceDelegate> dropDownDataSourceDelegate;
@end

@protocol DropDownTextFieldDataSourceDelegate <NSObject>
-(NSInteger)dropDownTextfield:(DropDownTextField*)dropDownTextfield numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell*)dropDownTextField:(DropDownTextField*)dropDownTextField cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)dropdDownTextField:(DropDownTextField*)dropDownTextField didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
@end
