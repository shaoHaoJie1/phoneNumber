//
//  ViewController.m
//  phoneNumber
//
//  Created by 邵浩杰 on 2019/7/1.
//  Copyright © 2019 邵浩杰. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextFieldDelegate>
{
    
    NSString    *_previousTextFieldContent;
    UITextRange *_previousSelection;
    
    //手机运营商
    UILabel *phoneTypeLab;
}


@property(nonatomic,strong)UITextField *phoneTextfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.phoneTextfield = [[UITextField alloc]initWithFrame:CGRectMake(25, 100, 200, 32)];
    self.phoneTextfield.placeholder = @"请输入手机号";
    
    self.phoneTextfield.delegate = self;
    
    
    self.phoneTextfield.font = [UIFont systemFontOfSize:19];
    
    self.phoneTextfield.keyboardType = UIKeyboardTypeNumberPad;
    //实时更新输入框内容
    [self.phoneTextfield addTarget:self action:@selector(phoneNum_tfChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:self.phoneTextfield];
    
    
    phoneTypeLab = [[UILabel alloc]initWithFrame:CGRectMake(250, 100, 100, 32)];
    
    phoneTypeLab.textColor = [UIColor blackColor];
    
    [self.view addSubview:phoneTypeLab];
    
    
}
#pragma mark - 实时更新输入框
- (void)phoneNum_tfChange:(UITextField *)textField
{
    /**
     *  判断正确的光标位置
     */
    NSUInteger targetCursorPostion = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    NSString *phoneNumberWithoutSpaces = [self removeNonDigits:textField.text andPreserveCursorPosition:&targetCursorPostion];
    
    if([phoneNumberWithoutSpaces length]>11)
    {
        /**
         *  避免超过11位的输入
         */
        
        [textField setText:_previousTextFieldContent];
        textField.selectedTextRange = _previousSelection;
        
        return;
    }
    if ([phoneNumberWithoutSpaces length]>=11)
    {
        
        [textField resignFirstResponder];
        
        phoneTypeLab.hidden = NO;
        
        /**
         *  此处运营商类型  填写后台判断返回的数据
         */
        // phoneTypeLab.text = [HJHelper judgePhoneNumTypeOfMobileNum:[self.phoneTextfield.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
        phoneTypeLab.text = @"上海移动";
        
    }
    //号码小于11位
    else
    {
        
        phoneTypeLab.hidden = YES;
    }
    
    
    NSString *phoneNumberWithSpaces = [self insertSpacesEveryFourDigitsIntoString:phoneNumberWithoutSpaces andPreserveCursorPosition:&targetCursorPostion];
    
    textField.text = phoneNumberWithSpaces;
    UITextPosition *targetPostion = [textField positionFromPosition:textField.beginningOfDocument offset:targetCursorPostion];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPostion toPosition:targetPostion]];
}

/**
 *  除去非数字字符，确定光标正确位置
 *
 *  @param string         当前的string
 *  @param cursorPosition 光标位置
 *
 *  @return 处理过后的string
 */
- (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSUInteger originalCursorPosition =*cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    
    for (NSUInteger i=0; i<string.length; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        
        if(isdigit(characterToAdd)) {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if(i<originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    return digitsOnlyString;
}

/**
 *  将空格插入我们现在的string 中，并确定我们光标的正确位置，防止在空格中
 *
 *  @param string         当前的string
 *  @param cursorPosition 光标位置
 *
 *  @return 处理后有空格的string
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    
    for (NSUInteger i=0; i<string.length; i++) {
        if(i>0)
        {
            if(i==3 || i==7) {
                [stringWithAddedSpaces appendString:@" "];
                
                if(i<cursorPositionInSpacelessString) {
                    (*cursorPosition)++;
                }
            }
        }
        
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    return stringWithAddedSpaces;
}

#pragma mark - UITextFieldDelegate 判断输入框是否还可以编辑
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _previousSelection = textField.selectedTextRange;
    _previousTextFieldContent = textField.text;
    
    if(range.location==0) {
        if(string.integerValue >1)
        {
            return NO;
        }
    }
    
    return YES;
}


@end



