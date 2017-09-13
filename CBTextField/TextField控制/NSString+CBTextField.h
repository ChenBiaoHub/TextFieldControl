//
//  NSString+CBTextField.h
//  MerchantsGroup
//
//  Created by 陈彪 on 2017/9/12.
//  Copyright © 2017年 tuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (CBTextField)


/**
 去除所有特殊字符（只留 中文 数字 字母）

 @param textField 输入框
 @param length 长度限制 -1 为不限制长度
 @return textField限制后文字
 */
+ (NSString *)refuseAllSpecialWorldTextField:(UITextField *)textField TextLength:(NSInteger)length;

/**
 去除所有表情
 
 @param textField 输入框
 @param length 长度限制 -1 为不限制长度
 @return textField限制后文字
 */
+ (NSString *)refuseOnlyEmojiTextField:(UITextField *)textField TextLength:(NSInteger)length;

/**
 去除特殊字符（保留自己定义的）
 
 @param specialWorld 需要保留的特殊字符
 @param textField 输入框
 @param length 长度限制 -1 为不限制长度
 @return textField限制后文字
 */
+ (NSString *)containSpecialWorld:(NSString *)specialWorld TextField:(UITextField *)textField TextLength:(NSInteger)length;
@end
