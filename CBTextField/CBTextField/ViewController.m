//
//  ViewController.m
//  CBTextField
//
//  Created by 陈彪 on 2017/9/13.
//  Copyright © 2017年 小黑屋. All rights reserved.
//

#import "ViewController.h"
#import "NSString+CBTextField.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *testTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注意 这里状态别写错了 使用的是 UIControlEventEditingChanged
    [self.testTextField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
}


- (void)textFieldChange:(UITextField *)textField {
    
//    //去除所有表情
//    [NSString refuseOnlyEmojiTextField:textField TextLength:10];

//    //去除所有特殊字符（只留 中文 数字 字母）
//    [NSString refuseAllSpecialWorldTextField:textField TextLength:-1];
    
    //去除特殊字符（保留自己定义的）
    [NSString containSpecialWorld:@"-=,." TextField:textField TextLength:10];
}
@end
