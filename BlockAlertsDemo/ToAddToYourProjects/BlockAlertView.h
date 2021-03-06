//
//  BlockAlertView.h
//
//

#import <UIKit/UIKit.h>

@interface BlockAlertView : NSObject {
@protected
    UIScrollView *_view;
    NSMutableArray *_blocks;
    NSMutableArray *_completionBlocks;
    CGFloat _height;
    NSString *_title;
    NSString *_message;
    BOOL _shown;
    BOOL _cancelBounce;
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (BlockAlertView *)alertWithTitle:(NSString *)title
                           message:(NSString *)message
                         tintColor:(UIColor *)tintColor
                         textColor:(UIColor *)textColor;

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showErrorAlert:(NSError *)error;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
          tintColor:(UIColor *)tintColor
          textColor:(UIColor *)textColor;

// Add button with block
- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

// Add button with block and animation completion block
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block completion:(void (^)())completionBlock;
- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block completion:(void (^)())completionBlock;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block completion:(void (^)())completionBlock;

// Images should be named in the form "alert-IDENTIFIER-button.png"
- (void)addButtonWithTitle:(NSString *)title imageIdentifier:(NSString *)identifier block:(void (^)())block;

- (void)addComponents:(CGRect)frame;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

- (void)setupDisplay;

@property(nonatomic, retain) UIImage *backgroundImage;
@property(nonatomic, readonly) UIScrollView *view;
@property(nonatomic, readwrite) BOOL vignetteBackground;
@property(nonatomic, retain) UIColor *tintColor;
@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, retain) UIFont *messageFont;
@property(nonatomic) BOOL allButtonInLine;

@end
