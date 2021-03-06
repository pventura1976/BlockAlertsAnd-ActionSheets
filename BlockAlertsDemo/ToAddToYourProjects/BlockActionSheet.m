//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@implementation BlockActionSheet

@synthesize view = _view;
@synthesize vignetteBackground = _vignetteBackground;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize {
    if (self == [BlockActionSheet class]) {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:kActionSheetBackgroundCapHeight] retain];
        titleFont = [kActionSheetTitleFont retain];
        buttonFont = [kActionSheetButtonFont retain];
    }
}

+ (id)sheetWithTitle:(NSString *)title {
    return [[[BlockActionSheet alloc] initWithTitle:title tintColor:nil textColor:nil] autorelease];
}

+ (id)sheetWithTitle:(NSString *)title tintColor:(UIColor *)tintColor textColor:(UIColor *)textColor {
    return [[[BlockActionSheet alloc] initWithTitle:title tintColor:tintColor textColor:textColor] autorelease];
}

- (id)initWithTitle:(NSString *)title tintColor:(UIColor *)tintColor textColor:(UIColor *)textColor {
    if ((self = [super init])) {
        UIWindow *parentView = [BlockBackground sharedInstance];
        CGRect frame = parentView.bounds;
        
        _view = [[UIView alloc] initWithFrame:frame];
        
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        _blocks = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;
        _tintColor = [tintColor retain];
        if (title) {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width - kActionSheetBorder * 2, 1000)
                                lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel *labelView =
            [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, _height,
                                                      frame.size.width - kActionSheetBorder * 2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = NSLineBreakByWordWrapping;
            if (textColor)
            labelView.textColor = textColor;
            else
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.shadowColor = kActionSheetTitleShadowColor;
            labelView.shadowOffset = kActionSheetTitleShadowOffset;
            labelView.text = title;
            
            labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            [_view addSubview:labelView];
            [labelView release];
            
            _height += size.height + 5;
        }
        _vignetteBackground = NO;
    }
    
    return self;
}

- (void) dealloc
{
    [_view release];
    [_blocks release];
    [_completionBlocks release];
    [_tintColor release];
    [super dealloc];
}

- (NSUInteger)buttonCount {
    return _blocks.count;
}

#pragma mark - Add buttons

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block atIndex:(NSInteger)index
{
    [self addButtonWithTitle:title
                       color:color
                       block:block
                     atIndex:index
                  completion:nil];
}

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block atIndex:(NSInteger)index completion:(void (^)())completionBlock
{
    if (index >= 0)
    {
        [_blocks insertObject:[NSArray arrayWithObjects:
                               block ? [[block copy] autorelease] : [NSNull null],
                               title,
                               color,
                               nil]
                      atIndex:index];
        [_blocks insertObject:[NSArray arrayWithObjects:
                               completionBlock ? [[completionBlock copy] autorelease] : [NSNull null],
                               title,
                               color,
                               nil]
                      atIndex:index];
    }
    else
    {
        [_blocks addObject:[NSArray arrayWithObjects:
                            block ? [[block copy] autorelease] : [NSNull null],
                            title,
                            color,
                            nil]];
        [_completionBlocks addObject:[NSArray arrayWithObjects:
                                      completionBlock ? [[completionBlock copy] autorelease] : [NSNull null],
                                      title,
                                      color,
                                      nil]];
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block {
    [self addButtonWithTitle:title color:@"red" block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block {
    [self addButtonWithTitle:title color:@"black" block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block {
    [self addButtonWithTitle:title color:@"red" block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block {
    [self addButtonWithTitle:title color:@"black" block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block {
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:index];
}

#pragma mark - Add button with block and animation completion block

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block completion:(void (^)())completionBlock
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:-1 completion:completionBlock];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block completion:(void (^)())completionBlock
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:-1 completion:completionBlock];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block completion:(void (^)())completionBlock
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:-1 completion:completionBlock];
}

#pragma mark - Add button at index with block and animation completion block

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block completion:(void (^)())completionBlock
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:index completion:completionBlock];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block completion:(void (^)())completionBlock
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:index completion:completionBlock];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block completion:(void (^)())completionBlock
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:index completion:completionBlock];
}

# pragma mark - Show / Hide

- (void)showInView:(UIView *)view
{
    NSUInteger i = 1;
    for (NSArray *block in _blocks)
    {
        NSString *title = [block objectAtIndex:1];
        NSString *color = [block objectAtIndex:2];
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"action-%@-button.png", color]];
        image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];
        
        UIImage *highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"action-%@-button-highlighted.png", color]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kActionSheetBorder, _height, _view.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
        button.titleLabel.font = buttonFont;
        if (IOS_LESS_THAN_6) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            button.titleLabel.minimumFontSize = 10;
#pragma clang diagnostic pop
        }
        else {
            button.titleLabel.minimumScaleFactor = 0.1;
        }
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.shadowOffset = kActionSheetButtonShadowOffset;
        button.backgroundColor = [UIColor clearColor];
        button.tag = i++;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        if (highlightedImage)
        {
            [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        }
        [button setTitleColor:kActionSheetButtonTextColor forState:UIControlStateNormal];
        [button setTitleShadowColor:kActionSheetButtonShadowColor forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [_view addSubview:button];
        _height += kActionSheetButtonHeight + kActionSheetBorder;
    }
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    modalBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];
    CGRect frame = _view.frame;
    frame.origin.y = [BlockBackground sharedInstance].bounds.size.height;
    frame.size.height = _height + kActionSheetBounce;
    _view.frame = frame;
    
    __block CGPoint center = _view.center;
    center.y -= _height + kActionSheetBounce;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         _view.center = center;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              center.y += kActionSheetBounce;
                                              _view.center = center;
                                          } completion:nil];
                     }];
    
    [self retain];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    // Block Execution
    if (buttonIndex >= 0 && buttonIndex < [_blocks count])
    {
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
        CGPoint center = _view.center;
        center.y += _view.bounds.size.height;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _view.center = center;
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                         } completion:^(BOOL finished) {
                             
                             //Completion block execution
                             if (buttonIndex >= 0 && buttonIndex < [_completionBlocks count])
                             {
                                 id obj = [[_completionBlocks objectAtIndex: buttonIndex] objectAtIndex:0];
                                 if (![obj isEqual:[NSNull null]])
                                 {
                                     ((void (^)())obj)();
                                 }
                             }
                             
                             // Release
                             [[BlockBackground sharedInstance] removeView:_view];
                             [_view release]; _view = nil;
                             [self autorelease];
                             
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        [_view release]; _view = nil;
        [self autorelease];
    }
}

#pragma mark - Action

- (void)buttonClicked:(id)sender
{
    /* Run the button's block */
    NSInteger buttonIndex = [(UIButton *)sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
