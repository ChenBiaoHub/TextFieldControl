//
//  NSString+CBTextField.m
//  MerchantsGroup
//
//  Created by 陈彪 on 2017/9/12.
//  Copyright © 2017年 tuan. All rights reserved.
//

#import "NSString+CBTextField.h"

@implementation NSString (CBTextField)


+ (NSString *)refuseAllSpecialWorldTextField:(UITextField *)textField TextLength:(NSInteger)length {
    
    NSString * resultStr = [NSString settingTextField:textField TextLength:length MyBlock:^BOOL(NSString *str) {
        return [str isHaveSpecialWorld];
    }];
    return resultStr;
}

+ (NSString *)refuseOnlyEmojiTextField:(UITextField *)textField TextLength:(NSInteger)length {

    NSString * resultStr = [NSString settingTextField:textField TextLength:length MyBlock:^BOOL(NSString *str) {
        return [str containEmoji];
    }];

    return resultStr;
}

+ (NSString *)containSpecialWorld:(NSString *)specialWorld TextField:(UITextField *)textField TextLength:(NSInteger)length {
    NSString * resultStr = [NSString settingTextField:textField TextLength:length MyBlock:^BOOL(NSString *str) {
        return [str customizeSpecialWorld:specialWorld];
    }];
    
    return resultStr;
}



/**
 限制输入框输入特殊字符

 @param textField 被限制的输入框
 @param length 长度限制 -1 就是没有长度限制
 @return 限制后输入框中的文字
 */
+ (NSString *)settingTextField:(UITextField *)textField TextLength:(NSInteger)length MyBlock:(BOOL(^)(NSString * str))myBlock{
    
    NSString *toBeString = textField.text;

    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字
    if (!position) {
        
        if (toBeString.length > 0) {
            
            //有特殊字符
            while (myBlock(toBeString)) {
                if (toBeString.length <= 1) {
                    toBeString = @"";
                    //因为@""也当做特殊字符了，这里不break就会一直在这里递归 出不去了
                    break;
                } else {
                    
                    NSRange range;
                    if ([toBeString containEmoji]) {
                        //如果有表情 则需要删除两个字节长度 因为表情都是长度为2
                        range = NSMakeRange(0, toBeString.length - 2);
                    } else {
                        range = NSMakeRange(0, toBeString.length - 1);
                    }
                    
                    toBeString = [toBeString substringWithRange:range];
                }
            }
            
            if (length > 0) {
                //长度超过length
                if (toBeString.length > length) {
                    NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:length];
                    if (rangeIndex.length == 1) {
                        toBeString = [toBeString substringToIndex:length];
                    } else {
                        NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, length)];
                        toBeString = [toBeString substringWithRange:rangeRange];
                    }
                }
            }
            
        }
        textField.text = toBeString;
    }
    
    return toBeString;
}




- (BOOL)customizeSpecialWorld:(NSString *)specialWorld {
    NSString *pattern = [NSString stringWithFormat:@"^[\u4E00-\u9FA5A-Za-z0-9%@]+$",specialWorld];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    
    return !isMatch;
}


/**
 是否含有特殊字符 （汉字 大小写字母 数字 以外的字符）
 */
- (BOOL)isHaveSpecialWorld {
    NSString *pattern = @"^[\u4E00-\u9FA5A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    
    return !isMatch;
}



- (BOOL)containEmoji
{
    NSUInteger len = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (len < 3) {// 大于2个字符需要验证Emoji(有些Emoji仅三个字符)
        return NO;
    }// 仅考虑字节长度为3的字符,大于此范围的全部做Emoji处理
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];Byte *bts = (Byte *)[data bytes];
    Byte bt;
    short v;
    for (NSUInteger i = 0; i < len; i++) {
        bt = bts[i];
        
        if ((bt | 0x7F) == 0x7F) {// 0xxxxxxxASIIC编码
            continue;
        }
        if ((bt | 0x1F) == 0xDF) {// 110xxxxx两个字节的字符
            i += 1;
            continue;
        }
        if ((bt | 0x0F) == 0xEF) {// 1110xxxx三个字节的字符(重点过滤项目)
            // 计算Unicode下标
            v = bt & 0x0F;
            v = v << 6;
            v |= bts[i + 1] & 0x3F;
            v = v << 6;
            v |= bts[i + 2] & 0x3F;
            
            // NSLog(@"%02X%02X", (Byte)(v >> 8), (Byte)(v & 0xFF));
            if ([self emojiInSoftBankUnicode:v] || [self emojiInUnicode:v]) {
                return YES;
            }
            
            i += 2;
            continue;
        }
        if ((bt | 0x3F) == 0xBF) {// 10xxxxxx10开头,为数据字节,直接过滤
            continue;
        }
        
        return YES; // 不是以上情况的字符全部超过三个字节,做Emoji处理
    }return NO;
}

- (BOOL)emojiInSoftBankUnicode:(short)code
{
    return ((code >> 8) >= 0xE0 && (code >> 8) <= 0xE5 && (Byte)(code & 0xFF) < 0x60);
}

- (BOOL)emojiInUnicode:(short)code
{
    if (code == 0x0023
        || code == 0x002A
        || (code >= 0x0030 && code <= 0x0039)
        || code == 0x00A9
        || code == 0x00AE
        || code == 0x203C
        || code == 0x2049
        || code == 0x2122
        || code == 0x2139
        || (code >= 0x2194 && code <= 0x2199)
        || code == 0x21A9 || code == 0x21AA
        || code == 0x231A || code == 0x231B
        || code == 0x2328
        || code == 0x23CF
        || (code >= 0x23E9 && code <= 0x23F3)
        || (code >= 0x23F8 && code <= 0x23FA)
        || code == 0x24C2
        || code == 0x25AA || code == 0x25AB
        || code == 0x25B6
        || code == 0x25C0
        || (code >= 0x25FB && code <= 0x25FE)
        || (code >= 0x2600 && code <= 0x2604)
        || code == 0x260E
        || code == 0x2611
        || code == 0x2614 || code == 0x2615
        || code == 0x2618
        || code == 0x261D
        || code == 0x2620
        || code == 0x2622 || code == 0x2623
        || code == 0x2626
        || code == 0x262A
        || code == 0x262E || code == 0x262F
        || (code >= 0x2638 && code <= 0x263A)
        || (code >= 0x2648 && code <= 0x2653)
        || code == 0x2660
        || code == 0x2663
        || code == 0x2665 || code == 0x2666
        || code == 0x2668
        || code == 0x267B
        || code == 0x267F
        || (code >= 0x2692 && code <= 0x2694)
        || code == 0x2696 || code == 0x2697
        || code == 0x2699
        || code == 0x269B || code == 0x269C
        || code == 0x26A0 || code == 0x26A1
        || code == 0x26AA || code == 0x26AB
        || code == 0x26B0 || code == 0x26B1
        || code == 0x26BD || code == 0x26BE
        || code == 0x26C4 || code == 0x26C5
        || code == 0x26C8
        || code == 0x26CE
        || code == 0x26CF
        || code == 0x26D1
        || code == 0x26D3 || code == 0x26D4
        || code == 0x26E9 || code == 0x26EA
        || (code >= 0x26F0 && code <= 0x26F5)
        || (code >= 0x26F7 && code <= 0x26FA)
        || code == 0x26FD
        || code == 0x2702
        || code == 0x2705
        || (code >= 0x2708 && code <= 0x270D)
        || code == 0x270F
        || code == 0x2712
        || code == 0x2714
        || code == 0x2716
        || code == 0x271D
        || code == 0x2721
        || code == 0x2728
        || code == 0x2733 || code == 0x2734
        || code == 0x2744
        || code == 0x2747
        || code == 0x274C
        || code == 0x274E
        || (code >= 0x2753 && code <= 0x2755)
        || code == 0x2757
        || code == 0x2763 || code == 0x2764
        || (code >= 0x2795 && code <= 0x2797)
        || code == 0x27A1
        || code == 0x27B0
        || code == 0x27BF
        || code == 0x2934 || code == 0x2935
        || (code >= 0x2B05 && code <= 0x2B07)
        || code == 0x2B1B || code == 0x2B1C
        || code == 0x2B50
        || code == 0x2B55
        || code == 0x3030
        || code == 0x303D
        || code == 0x3297
        || code == 0x3299
        // 第二段
        || code == 0x23F0) {
        return YES;
    }
    return NO;
}
@end
