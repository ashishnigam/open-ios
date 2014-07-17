//
//  CTSAuthLayer.h
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 23/05/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSRestLayer.h"
#import "CTSOauthTokenRes.h"
#import "CTSRestRegister.h"
#import "RestLayerConstants.h"
#import "CTSAuthLayerConstants.h"
#import "CTSRestIntergration.h"

@protocol CTSAuthenticationProtocol
/**
 *  reports sign in respose
 *
 *  @param isSuccessful  status
 *  @param userName     username that was used for signin
 *  @param error        error,nil in case of success.
 */
- (void)signin:(BOOL)isSuccessful
    forUserName:(NSString*)userName
          error:(NSError*)error;

/**
 *  reports sign up reply
 *
 *  @param isSuccessful
 *  @param error
 */
- (void)signUp:(BOOL)isSuccessful error:(NSError*)error;

@end

@interface CTSAuthLayer : CTSRestIntergration<CTSRestLayerProtocol> {
  int seedState;
  NSString* userNameSignIn, *userNameSignup, *passwordSignUp, *mobileSignUp;
  ;
  BOOL wasSignupCalled;
}
@property(nonatomic, strong) id<CTSAuthenticationProtocol> delegate;

- (void)requestSigninWithUsername:(NSString*)userName
                         password:(NSString*)password;
- (void)requestSignUpWithEmail:(NSString*)email
                        mobile:(NSString*)mobile
                      password:(NSString*)password;
- (void)requestChangePassword:(NSString*)userNameArg;

@end
