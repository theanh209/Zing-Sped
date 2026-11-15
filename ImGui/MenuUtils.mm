#include "ImGuiDrawViewX.h"
#include "MenuUtils.h"
#include "../Mods.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

// [FIX] Khai báo Interface ẩn để gọi hàm updateIOWithTouchEvent: mà không bị compiler cảnh báo
@interface ImGuiDrawViewX (Private)
- (void)updateIOWithTouchEvent:(UIEvent *)event;
@end

@interface MenuUtils()
@property (nonatomic, strong) ImGuiDrawViewX *vna;
- (ImGuiDrawViewX*) GetImGuiView;
@end

static MenuUtils *extraInfo;
ImVec2 MenuOrigin = {(float)SCREEN_WIDTH - 400, 0};
ImVec2 MenuSize = {400, 260};

UIButton* InvisibleMenuButton;
UIButton* VisibleMenuButton;
MenuInteraction* menuTouchView;
UITextField* hideRecordTextfield;
UIView* hideRecordView;
bool StreamerMode = false;
bool MoveMenu = true;

extern NSString* baseimage; 

@interface MenuInteraction()
@end
@implementation MenuInteraction
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect touchableArea = CGRectMake(MenuOrigin.x, MenuOrigin.y, MenuSize.x, MenuSize.y);
    if (CGRectContainsPoint(touchableArea, point)) {
        return [super pointInside:point withEvent:event];
    }
    return NO;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[extraInfo GetImGuiView] updateIOWithTouchEvent:event];
}
@end


// Resolve the active app window through UIWindowScene (iOS 13+), with a safe fallback.
static UIWindow *ZSTargetWindow(void) {
    UIApplication *application = UIApplication.sharedApplication;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in application.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) return window;
            }
            for (UIWindow *window in windowScene.windows) {
                if (!window.hidden && window.alpha > 0.0) return window;
            }
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (application.keyWindow) return application.keyWindow;
#pragma clang diagnostic pop
    for (UIWindow *window in application.windows) {
        if (window.isKeyWindow) return window;
    }
    return application.windows.firstObject;
}

@implementation MenuUtils
bool isOpened = false;

- (ImGuiDrawViewX*) GetImGuiView
{
    return _vna;
}
+ (void)load
{
    [super load];
    // UIKit may not have created the foreground window when +load runs.
    timer(3){
        extraInfo = [MenuUtils new];
        [extraInfo initTapGes];
    });
}

-(void)initTapGes
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self initTapGes]; });
        return;
    }

    UIWindow *window = ZSTargetWindow();
    UIView *mainView = window.rootViewController.view;
    if (!window || !mainView) {
        // Retry while the app is transitioning into its first usable scene.
        timer(1){ [self initTapGes]; });
        return;
    }

    // Prevent duplicate overlays if initialization is retried.
    if (hideRecordView && hideRecordView.superview == window) return;

    hideRecordTextfield = [[UITextField alloc] initWithFrame:CGRectZero];
    hideRecordTextfield.secureTextEntry = YES;

    // Use a normal transparent host view. Do not depend on private UITextField
    // layer delegates: their implementation is not a stable UIKit API.
    hideRecordView = [[UIView alloc] initWithFrame:window.bounds];
    hideRecordView.backgroundColor = UIColor.clearColor;
    hideRecordView.userInteractionEnabled = NO; // Pass game touches through.
    hideRecordView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [hideRecordView addSubview:hideRecordTextfield];
    [window addSubview:hideRecordView];

    if (!_vna) {
        _vna = [[ImGuiDrawViewX alloc] init];
    }
    _vna.view.frame = window.bounds;
    _vna.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _vna.view.backgroundColor = UIColor.clearColor;
    _vna.view.userInteractionEnabled = NO; // MenuInteraction forwards menu touches.
    [ImGuiDrawViewX showChange:NO];
    [hideRecordView addSubview:_vna.view];

    menuTouchView = [[MenuInteraction alloc] initWithFrame:window.bounds];
    menuTouchView.backgroundColor = UIColor.clearColor;
    menuTouchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    menuTouchView.userInteractionEnabled = NO;
    [window addSubview:menuTouchView];
    // Keep the touch-forwarding view above the game, but below the floating controls.
    [window bringSubviewToFront:menuTouchView];

    NSData *data = [[NSData alloc] initWithBase64EncodedString:baseimage options:0];
    UIImage *menuIconImage = data ? [UIImage imageWithData:data] : nil;

    CGPoint initialCenter = CGPointMake(CGRectGetMidX(mainView.bounds), CGRectGetMidY(mainView.bounds));
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults objectForKey:@"zst_ButtonPosX"] != nil) {
        CGFloat posX = [defaults floatForKey:@"zst_ButtonPosX"];
        CGFloat posY = [defaults floatForKey:@"zst_ButtonPosY"];
        if (posX > 20 && posX < mainView.bounds.size.width - 20 &&
            posY > 20 && posY < mainView.bounds.size.height - 20) {
            initialCenter = CGPointMake(posX, posY);
        }
    }

    InvisibleMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    InvisibleMenuButton.frame = CGRectMake(0, 0, 50, 50);
    InvisibleMenuButton.center = initialCenter;
    InvisibleMenuButton.backgroundColor = UIColor.clearColor;
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [InvisibleMenuButton addTarget:self action:@selector(buttonDragStarted:) forControlEvents:UIControlEventTouchDown];
    [InvisibleMenuButton addTarget:self action:@selector(showMenuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:InvisibleMenuButton];

    VisibleMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    VisibleMenuButton.frame = CGRectMake(0, 0, 50, 50);
    VisibleMenuButton.center = initialCenter;
    VisibleMenuButton.backgroundColor = UIColor.clearColor;
    VisibleMenuButton.layer.cornerRadius = 25.0;
    VisibleMenuButton.layer.masksToBounds = YES;
    VisibleMenuButton.layer.borderWidth = 2.0;
    VisibleMenuButton.layer.borderColor = [UIColor colorWithRed:0.2f green:0.85f blue:1.0f alpha:0.85f].CGColor;
    if (menuIconImage) [VisibleMenuButton setBackgroundImage:menuIconImage forState:UIControlStateNormal];
    VisibleMenuButton.layer.opacity = mods.IconOpacity > 0.1f ? mods.IconOpacity : 0.7f;
    VisibleMenuButton.hidden = !mods.ShowFloatingIcon;
    InvisibleMenuButton.hidden = !mods.ShowFloatingIcon;
    VisibleMenuButton.userInteractionEnabled = NO; // Invisible button receives taps.
    [window addSubview:VisibleMenuButton];
    [window bringSubviewToFront:InvisibleMenuButton];

    UITapGestureRecognizer *threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreeFingerTap:)];
    threeFingerTap.numberOfTouchesRequired = 3;
    [window addGestureRecognizer:threeFingerTap];
}

-(void)showMenuButtonTapped:(UIButton *)button {
    [ImGuiDrawViewX showChange:![ImGuiDrawViewX isMenuShowing]];
}

-(void)handleThreeFingerTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded && mods.GestureShortcut) {
        TriggerHaptic(0);
        PlayBeepSound(1104);
        [ImGuiDrawViewX showChange:![ImGuiDrawViewX isMenuShowing]];
    }
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            VisibleMenuButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];

        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            VisibleMenuButton.transform = CGAffineTransformIdentity;
        } completion:nil];

        [ImGuiDrawViewX showChange:![ImGuiDrawViewX isMenuShowing]];
    }
}

- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];

    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;

    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);

    UIWindow *window = ZSTargetWindow();
    CGRect mainFrame = window.rootViewController.view.bounds;
    if (!window) return;
    if (button.center.x < 0) button.center = CGPointMake(0, button.center.y);
    if (button.center.y < 0) button.center = CGPointMake(button.center.x, 0);
    if (button.center.y > mainFrame.size.height) button.center = CGPointMake(button.center.x, mainFrame.size.height);
    if (button.center.x > mainFrame.size.width) button.center = CGPointMake(mainFrame.size.width, button.center.y);

    VisibleMenuButton.center = button.center;
    VisibleMenuButton.frame = button.frame;
    VisibleMenuButton.layer.opacity = 1.0;
}

- (void)buttonDragStarted:(UIButton *)button {
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
        VisibleMenuButton.transform = button.transform;
    }];
}

- (void)buttonDragEnded:(UIButton *)button {
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformIdentity;
        VisibleMenuButton.transform = button.transform;
        VisibleMenuButton.layer.opacity = 0.7;
    }];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:button.center.x forKey:@"zst_ButtonPosX"];
    [defaults setFloat:button.center.y forKey:@"zst_ButtonPosY"];
    [defaults synchronize];
}

@end

void UpdateFloatingIcon(float size, float opacity) {
    if (VisibleMenuButton && InvisibleMenuButton) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGPoint center = VisibleMenuButton.center;
            VisibleMenuButton.frame = CGRectMake(0, 0, size, size);
            VisibleMenuButton.center = center;
            VisibleMenuButton.layer.cornerRadius = size * 0.5f;
            VisibleMenuButton.layer.masksToBounds = YES;
            VisibleMenuButton.layer.opacity = opacity;
            VisibleMenuButton.hidden = !mods.ShowFloatingIcon;

            InvisibleMenuButton.frame = CGRectMake(0, 0, size, size);
            InvisibleMenuButton.center = center;
            InvisibleMenuButton.hidden = !mods.ShowFloatingIcon;
        });
    }
}

