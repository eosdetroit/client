//
//  KBCatalogView.m
//  Keybase
//
//  Created by Gabriel on 1/16/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "KBCatalogView.h"
#import "AppDelegate.h"
#import "KBUserProfileView.h"
#import "KBWebView.h"
#import "KBKeyGenView.h"
#import "KBProveView.h"
#import "KBStyleGuideView.h"
#import "KBTestClientView.h"
#import "KBKeySelectView.h"
#import "KBDeviceSetupView.h"

@interface KBCatalogView ()
@property NSMutableArray *items;
@end

@implementation KBCatalogView

- (void)viewInit {
  [super viewInit];
  WKWebView *webView = [[WKWebView alloc] init];
  webView.navigationDelegate = self;
  [self addSubview:webView];

  [webView loadHTMLString:[AppDelegate loadFile:@"catalog.html"] baseURL:nil];

  self.viewLayout = [YOLayout fill:webView];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
  NSString *path = navigationAction.request.URL.absoluteString;
  if ([path isEqualTo:@"about:blank"]) {
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
  } else {
    decisionHandler(WKNavigationActionPolicyCancel);
  }

  if ([path isEqualTo:@"/test-client"]) [self showTestClientView];
  if ([path gh_startsWith:@"/replay/track"]) [self showTrackReplay:[path lastPathComponent]];

  if ([path gh_startsWith:@"/prompt/"]) [self prompt:[path lastPathComponent]];

  if ([path isEqualTo:@"/style-guide"]) [self showStyleGuide];

  if ([path isEqualTo:@"/prove-instructions"]) [self showProveInstructions];
  if ([path isEqualTo:@"/select-key"]) [self showSelectKey];
  if ([path isEqualTo:@"/device-setup"]) [self showDeviceSetupView];

  if ([path isEqualTo:@"/error"]) [self showError];
  if ([path isEqualTo:@"/error-fatal"]) [self showFatalError];
}

- (void)signupView:(KBSignupView *)signupView didSignupWithStatus:(KBRGetCurrentStatusRes *)status {
  [signupView.window close];
  AppDelegate.sharedDelegate.status = status;
}

- (void)loginView:(KBLoginView *)loginView didLoginWithStatus:(KBRGetCurrentStatusRes *)status {
  [loginView.window close];
  AppDelegate.sharedDelegate.status = status;
}

- (void)showTestClientView {
  KBTestClientView *testClientView = [[KBTestClientView alloc] init];
  [self openInWindow:testClientView size:CGSizeMake(360, 420) title:@"Test Client"];
}

- (void)showLogin {
  KBConnectView *connectView = [[KBConnectView alloc] init];
  connectView.loginView.delegate = self;
  connectView.signupView.delegate = self;
  [connectView showLogin:NO];
  [connectView openWindow:@"Keybase"];
}

- (void)showSignup {
  KBConnectView *connectView = [[KBConnectView alloc] init];
  connectView.loginView.delegate = self;
  connectView.signupView.delegate = self;
  [connectView showSignup:NO];
  [connectView openWindow:@"Keybase"];
}

- (void)showKeyGen:(BOOL)animated {
  KBKeyGenView *keyGenView = [[KBKeyGenView alloc] init];
  [self openInWindow:keyGenView size:CGSizeMake(360, 420) title:@"Keygen"];
}

- (void)showProve:(NSString *)type {
  KBProveView *view = [[KBProveView alloc] init];
  view.proveType = KBProveTypeForServiceName(type);
  [self openInWindow:view size:CGSizeMake(360, 420) title:@"Prove"];
}

- (NSWindow *)openInWindow:(NSView *)view size:(CGSize)size title:(NSString *)title {
  KBNavigationView *navigation = [[KBNavigationView alloc] initWithView:view];
  NSWindow *window = [KBWindow windowWithContentView:navigation size:size retain:YES];
  window.styleMask = window.styleMask | NSResizableWindowMask;
  navigation.titleView = [KBNavigationTitleView titleViewWithTitle:title navigation:navigation];
  [window makeKeyAndOrderFront:nil];
  return window;
}

- (void)prompt:(NSString *)type {
  if ([type isEqualTo:@"password"]) {
    [KBAlert promptForInputWithTitle:@"Your secret password" description:@"Williamsburg heirloom Carles. Meggings sriracha High Life keytar photo booth craft beer. Artisan keytar cliche, Pinterest mumblecore 8-bit hella kale chips" secure:YES style:NSCriticalAlertStyle buttonTitles:@[@"OK", @"Cancel"] view:nil completion:^(NSModalResponse response, NSString *password) {

    }];
  } else if ([type isEqualTo:@"yes_no"]) {
    [KBAlert promptWithTitle:@"Are you a hipster?" description:@"Flexitarian biodiesel locavore fingerstache. Craft beer brunch fashion axe bicycle rights, plaid messenger bag?" style:NSInformationalAlertStyle buttonTitles:@[@"Yes, Give me my Pabst", @"No"] view:self completion:^(NSModalResponse response) {

    }];
  } else if ([type isEqualTo:@"input"]) {
    [KBAlert promptForInputWithTitle:@"What's my favorite color?" description:@"Cold-pressed aesthetic yr fap locavore American Apparel, bespoke fanny pack." secure:NO style:NSInformationalAlertStyle buttonTitles:@[@"OK", @"Cancel"] view:nil completion:^(NSModalResponse response, NSString *input) {

    }];
  }
}

- (void)showTrack:(NSString *)username {
  //@"uid": [@"b7c2eaddcced7727bcb229751d91e800" na_dataFromHexString]
  KBRUser *user = [[KBRUser alloc] initWithDictionary:@{@"username": username} error:nil];

  KBUserProfileView *userProfileView = [[KBUserProfileView alloc] init];
  userProfileView.popup = YES;
  KBNavigationView *navigation = [[KBNavigationView alloc] initWithView:userProfileView];
  NSWindow *window = [KBWindow windowWithContentView:navigation size:CGSizeMake(420, 400) retain:YES];
  navigation.titleView = [KBNavigationTitleView titleViewWithTitle:user.username navigation:navigation];
  [window setLevel:NSFloatingWindowLevel];
  [window makeKeyAndOrderFront:nil];

  [userProfileView setUser:user editable:NO];
}

- (void)showTrackReplay:(NSString *)username {
  KBRUser *user = [[KBRUser alloc] initWithDictionary:@{@"username": username} error:nil];
  KBUserProfileView *userProfileView = [[KBUserProfileView alloc] init];
  userProfileView.popup = YES;
  userProfileView.mock = YES;
  KBNavigationView *navigation = [[KBNavigationView alloc] initWithView:userProfileView];
  NSWindow *window = [KBWindow windowWithContentView:navigation size:CGSizeMake(420, 400) retain:YES];
  navigation.titleView = [KBNavigationTitleView titleViewWithTitle:user.username navigation:navigation];
  [window setLevel:NSFloatingWindowLevel];
  [window makeKeyAndOrderFront:nil];

  [userProfileView setUser:user editable:NO];
  if (![AppDelegate.client replayRecordId:NSStringWithFormat(@"track/%@", username)]) KBDebugAlert(@"Nothing to replay; Did you unpack the recorded data (./record.sh unpack)?");
}

- (void)showSelectKey {
  NSArray *params = [AppDelegate.client paramsFromRecordId:@"signup/gbrl39" file:@"0003--keybase.1.gpgUi.selectKeyAndPushOption.json"];
  KBRSelectKeyAndPushOptionRequestParams *handler = [[KBRSelectKeyAndPushOptionRequestParams alloc] initWithParams:params];

  KBKeySelectView *selectView = [[KBKeySelectView alloc] init];
  [selectView.keysView setGPGKeys:handler.keys];
  __weak KBKeySelectView *gselectView = selectView;
  selectView.selectButton.targetBlock = ^{
    GHDebug(@"Selected key: %@", gselectView.keysView.selectedGPGKey.keyID);
  };
  [self openInWindow:selectView size:CGSizeMake(600, 400) title:@"Select Key"];
}

- (void)showStyleGuide {
  KBStyleGuideView *testView = [[KBStyleGuideView alloc] init];
  KBNavigationView *navigation = [[KBNavigationView alloc] initWithView:testView];
  NSWindow *window = [KBWindow windowWithContentView:navigation size:CGSizeMake(600, 400) retain:YES];
  navigation.titleView = [KBNavigationTitleView titleViewWithTitle:@"Style Guide" navigation:navigation];
  window.styleMask = window.styleMask | NSResizableWindowMask;
  [window makeKeyAndOrderFront:nil];
}

- (void)showProveInstructions {
  KBProveInstructionsView *instructionsView = [[KBProveInstructionsView alloc] init];
  KBRText *text = [[KBRText alloc] init];
  text.data = @"<p>Please <strong>publicly</strong> post the following to the internets, and name it <strong>hello.md</strong></p>";
  text.markup = 1;
  NSString *proofText = @"Seitan four dollar toast banh mi, ethical ugh umami artisan paleo brunch listicle synth try-hard pop-up. Next level mixtape selfies, freegan Schlitz bitters Echo Park semiotics. Gentrify sustainable farm-to-table, cliche crucifix biodiesel ennui taxidermy try-hard cold-pressed Brooklyn fixie narwhal Bushwick Pitchfork. Ugh Etsy chia 3 wolf moon, drinking vinegar street art yr stumptown cliche Thundercats Marfa umami beard shabby chic Portland. Skateboard Vice four dollar toast stumptown, salvia direct trade hoodie. Wes Anderson swag small batch vinyl, taxidermy biodiesel Shoreditch cray pickled kale chips typewriter deep v. Actually XOXO tousled, freegan Marfa squid trust fund cardigan irony.\n\nPaleo pork belly heirloom dreamcatcher gastropub tousled. Banjo bespoke try-hard, gentrify Pinterest pork belly Schlitz sartorial narwhal Odd Future biodiesel 8-bit before they sold out selvage. Brunch disrupt put a bird on it Neutra organic. Pickled dreamcatcher post-ironic sriracha, organic Austin Bushwick Odd Future Marfa. Narwhal heirloom Tumblr forage trust fund, roof party gentrify keffiyeh High Life synth kogi Banksy. Kitsch photo booth slow-carb pour-over Etsy, Intelligentsia raw denim lomo. Brooklyn PBR&B Kickstarter direct trade literally, jean shorts photo booth narwhal irony kogi.";
  [instructionsView setInstructions:text proofText:proofText];
  [self openInWindow:instructionsView size:CGSizeMake(360, 420) title:@"Instructions View"];
}

- (void)showDeviceSetupView {
  NSArray *params = [AppDelegate.client paramsFromRecordId:@"device_setup/gbrl49" file:@"0000--keybase.1.doctorUi.selectSigner.json"];
  KBRSelectSignerRequestParams *handler = [[KBRSelectSignerRequestParams alloc] initWithParams:params];

  KBDeviceSetupView *deviceSetupView = [[KBDeviceSetupView alloc] init];
  [deviceSetupView setDevices:handler.devices hasPGP:handler.hasPGP];
  [self openInWindow:deviceSetupView size:CGSizeMake(560, 420) title:@"Device Setup"];
}

- (void)showError {
  NSError *error = KBMakeError(-1, @"This is the error message.", @"This is the recovery suggestion.");
  [AppDelegate setError:error sender:self];
}

- (void)showFatalError {
  NSError *error = KBMakeError(-1, @"This is the fatal error message.", @"This is the recovery suggestion.");
  [AppDelegate.sharedDelegate setFatalError:error];
}

@end
