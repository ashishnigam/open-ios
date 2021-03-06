//
//  ChangePasswordViewController.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 16/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UIUtility.h"

#define REGEX_USER_NAME_LIMIT @"^.{3,10}$"
#define REGEX_USER_NAME @"[A-Za-z0-9]{3,10}"
#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define REGEX_PASSWORD_LIMIT @"^.{8,16}$"
#define REGEX_PASSWORD @"[A-Za-z0-9!@#$%"@"^&*]{8,16}"
#define REGEX_PHONE_DEFAULT @"[0-9]{3}\\-[0-9]{3}\\-[0-9]{4}"
#define REGEX_PHONE_DEFAULT_LIMIT @"^.{12,12}$"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize usernameTextField, oldPasswordTextField, passwordTextField, confirmPasswordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NSString *username = [self getLastUser];
    self.usernameTextField.text = username;
    
    
    [self setupTextFieldValidation];

    //
    [self initialize];

}

//
- (void)initialize {
    authLayer = [[CTSAuthLayer alloc] init];
}


-(void)setupTextFieldValidation{
    [self.usernameTextField addRegx:REGEX_EMAIL withMsg:@"Enter valid email."];

    [self.oldPasswordTextField addRegx:REGEX_PASSWORD withMsg:@"Password must contain alpha numeric characters."];
    [self.oldPasswordTextField addRegx:REGEX_PASSWORD_LIMIT withMsg:@"8 to 16 with at least one alphabet and one "
     @"number. Special characters allowed - (! @ # $ % " @"^ & *)." tag:2 location:16];
    
    [self.passwordTextField addRegx:REGEX_PASSWORD withMsg:@"Password must contain alpha numeric characters."];
    [self.passwordTextField addRegx:REGEX_PASSWORD_LIMIT withMsg:@"8 to 16 with at least one alphabet and one "
     @"number. Special characters allowed - (! @ # $ % " @"^ & *)." tag:3 location:16];
    
    [self.confirmPasswordTextField addConfirmValidationTo:self.passwordTextField withMsg:@"Confirm password didn't match."];
}

-(IBAction)changePasswordAction:(id)sender
{
    if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    }else if ([self.oldPasswordTextField isFirstResponder]) {
        [self.oldPasswordTextField resignFirstResponder];
    }else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }else if ([self.confirmPasswordTextField isFirstResponder]) {
        [self.confirmPasswordTextField resignFirstResponder];
    }

    [self requestChangePassword];
}

- (NSString*)getLastUser {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs valueForKey:LAST_USER];
}


-(void)requestChangePassword
{
    
    if([self.usernameTextField validate] & [self.oldPasswordTextField validate] & [self.passwordTextField validate])
    {
        [UIUtility didPresentLoadingAlertView:@"Requesting" withActivity:YES];

        [authLayer requestChangePasswordUserName:self.usernameTextField.text
                               oldPassword:(NSString*)self.oldPasswordTextField.text
                               newPassword:(NSString*)self.passwordTextField.text
                      completionHandler:^(NSError* error) {
                          LogTrace(@"error %@ ", error);
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              // Update the UI
                              [UIUtility dismissLoadingAlertView:YES];
                              if (error == nil  && error.code != ServerErrorWithCode) {
                                  
                                  [UIUtility didPresentInfoAlertView:@"Your password has been updated successfully!"];
#if !defined (CTS_iOS_GUISdk)
                                  if ([self.oldPasswordTextField text]) {
                                      self.oldPasswordTextField.text = @"";
                                  }
                                  if ([self.passwordTextField text]) {
                                      self.passwordTextField.text = @"";
                                  }
                                  if ([self.confirmPasswordTextField text]) {
                                      self.confirmPasswordTextField.text = @"";
                                  }
#endif
                              }else{
                                  [UIUtility didPresentErrorAlertView:error];
                              }
                          });
                      }];
    }else{
        [UIUtility didPresentInfoAlertView:@"Please enter valid input."];
    }

}


#pragma mark - UITextField delegates

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self changePasswordAction:nil];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
