//
//  BlockAlertView.m
//
//

#import "BlockAlertView.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@implementation BlockAlertView

@synthesize view = _view;
@synthesize backgroundImage = _backgroundImage;
@synthesize vignetteBackground = _vignetteBackground;
@synthesize tintColor = _tintColor;
@synthesize textColor = _textColor;
@synthesize messageFont = _messageFont;
@synthesize allButtonInLine = _allButtonInLine;

static UIImage *background = nil;
static UIImage *backgroundlandscape = nil;
static UIFont *titleFont = nil;
static UIFont *messageFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize {
  if (self == [BlockAlertView class]) {
    background = [UIImage imageNamed:kAlertViewBackground];
    background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight] retain];

    backgroundlandscape = [UIImage imageNamed:kAlertViewBackgroundLandscape];
    backgroundlandscape =
        [[backgroundlandscape stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight] retain];

    titleFont = [kAlertViewTitleFont retain];
    messageFont = [kAlertViewMessageFont retain];
    buttonFont = [kAlertViewButtonFont retain];
  }
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message {
  return [[[BlockAlertView alloc] initWithTitle:title message:message tintColor:nil textColor:nil] autorelease];
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title
                           message:(NSString *)message
                         tintColor:(UIColor *)tintColor
                         textColor:(UIColor *)textColor {
  return [
      [[BlockAlertView alloc] initWithTitle:title message:message tintColor:tintColor textColor:textColor] autorelease];
}

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message {
  BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:title message:message tintColor:nil textColor:nil];
  [alert setCancelButtonWithTitle:NSLocalizedString(@"Dismiss", nil) block:nil];
  [alert show];
  [alert release];
}

+ (void)showErrorAlert:(NSError *)error {
  BlockAlertView *alert = [[BlockAlertView alloc]
      initWithTitle:NSLocalizedString(@"Operation Failed", nil)
            message:[NSString
                        stringWithFormat:NSLocalizedString(@"The operation did not complete successfully: %@", nil),
                                         error]
          tintColor:nil
          textColor:nil];
  [alert setCancelButtonWithTitle:@"Dismiss" block:nil];
  [alert show];
  [alert release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (void)addComponents:(CGRect)frame {
  if (_title) {
    CGSize size = [_title sizeWithFont:titleFont
                     constrainedToSize:CGSizeMake(frame.size.width - kAlertViewBorder * 2, 1000)
                         lineBreakMode:NSLineBreakByWordWrapping];

    UILabel *labelView = [[UILabel alloc]
        initWithFrame:CGRectMake(kAlertViewBorder, _height, frame.size.width - kAlertViewBorder * 2, size.height)];
    labelView.font = titleFont;
    labelView.numberOfLines = 0;
    labelView.lineBreakMode = NSLineBreakByWordWrapping;
    labelView.textColor = _textColor ? _textColor : kAlertViewTitleTextColor;
    labelView.backgroundColor = [UIColor clearColor];
    labelView.textAlignment = NSTextAlignmentCenter;
    labelView.shadowColor = kAlertViewTitleShadowColor;
    labelView.shadowOffset = kAlertViewTitleShadowOffset;
    labelView.text = _title;
    [_view addSubview:labelView];
    [labelView release];

    _height += size.height + kAlertViewBorder;
  }

  if (_message) {
    CGSize size = [_message sizeWithFont:self.messageFont
                       constrainedToSize:CGSizeMake(frame.size.width - kAlertViewBorder * 2, 1000)
                           lineBreakMode:NSLineBreakByWordWrapping];

    UILabel *labelView = [[UILabel alloc]
        initWithFrame:CGRectMake(kAlertViewBorder, _height, frame.size.width - kAlertViewBorder * 2, size.height)];
    labelView.font = self.messageFont;
    labelView.numberOfLines = 0;
    labelView.lineBreakMode = NSLineBreakByWordWrapping;
    labelView.textColor = _textColor ? _textColor : kAlertViewMessageTextColor;
    labelView.backgroundColor = [UIColor clearColor];
    labelView.textAlignment = NSTextAlignmentCenter;
    labelView.shadowColor = kAlertViewMessageShadowColor;
    labelView.shadowOffset = kAlertViewMessageShadowOffset;
    labelView.text = _message;
    [_view addSubview:labelView];
    [labelView release];

    _height += size.height + kAlertViewBorder;
  }
}

- (void)setupDisplay {
  [[_view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj removeFromSuperview];
  }];

  UIWindow *parentView = [BlockBackground sharedInstance];
  CGRect frame = parentView.bounds;
  frame.origin.x = floorf((frame.size.width - background.size.width) * 0.5);
  frame.size.width = background.size.width;

  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    frame.size.width += 150;
    frame.origin.x -= 75;
  }

  _view.frame = frame;

  _height = kAlertViewBorder + 15;

  if (NeedsLandscapePhoneTweaks) {
    _height -= 15;  // landscape phones need to trimmed a bit
  }

  [self addComponents:frame];

  if (_shown) [self show];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
  return [self initWithTitle:title message:message tintColor:nil textColor:nil];
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
          tintColor:(UIColor *)tintColor
          textColor:(UIColor *)textColor {
  self = [super init];

  if (self) {
    _title = [title copy];
    _message = [message copy];

    _view = [[UIScrollView alloc] init];

    _view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                             UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    _blocks = [[NSMutableArray alloc] init];

    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedDescending) {
      // don't register for notification, rotation is handled by iOS on 8+
    } else {
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(setupDisplay)
                                                   name:UIApplicationDidChangeStatusBarOrientationNotification
                                                 object:nil];
    }

    self.messageFont = messageFont;
    if ([self class] == [BlockAlertView class]) [self setupDisplay];
    _tintColor = [tintColor retain];
    _textColor = [textColor retain];
    _vignetteBackground = NO;
  }

  return self;
}

- (void)dealloc {
  [_title release];
  [_message release];
  [_backgroundImage release];
  [_view release];
  [_blocks release];
  [_messageFont release];
  [_tintColor release];
  [_textColor release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title color:(NSString *)color block:(void (^)())block {
  [_blocks addObject:[NSArray arrayWithObjects:block ? [[block copy] autorelease] : [NSNull null], title, color, nil]];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
  [self addButtonWithTitle:title color:@"gray" block:block];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block {
  [self addButtonWithTitle:title color:@"black" block:block];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block {
  [self addButtonWithTitle:title color:@"red" block:block];
}

- (void)addButtonWithTitle:(NSString *)title imageIdentifier:(NSString *)identifier block:(void (^)())block {
  [self addButtonWithTitle:title color:identifier block:block];
}

- (void)show {
  _shown = YES;

  BOOL isSecondButton = NO;
  NSUInteger index = 0;
  for (NSUInteger i = 0; i < _blocks.count; i++) {
    NSArray *block = [_blocks objectAtIndex:i];
    NSString *title = [block objectAtIndex:1];
    NSString *color = [block objectAtIndex:2];

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button.png", color]];
    image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width + 1) >> 1 topCapHeight:0];

    UIImage *highlightedImage =
        [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button-highlighted.png", color]];

    highlightedImage =
        [highlightedImage stretchableImageWithLeftCapWidth:(int)(highlightedImage.size.width + 1) >> 1 topCapHeight:0];

    CGFloat width = _view.bounds.size.width - kAlertViewBorder * 2;
    CGFloat xOffset = kAlertViewBorder;
    if (_allButtonInLine) {
      width = floorf((_view.bounds.size.width - kAlertViewBorder * (_blocks.count + 1)) / _blocks.count);
      xOffset = i * width + kAlertViewBorder * (i + 1);
      isSecondButton = (i < _blocks.count - 1);
    } else {
      CGFloat maxHalfWidth = floorf((_view.bounds.size.width - kAlertViewBorder * 3) * 0.5);
      if (isSecondButton) {
        width = maxHalfWidth;
        xOffset = width + kAlertViewBorder * 2;
        isSecondButton = NO;
      } else if (i + 1 < _blocks.count) {
        // In this case there's another button.
        // Let's check if they fit on the same line.
        CGSize size = [title sizeWithFont:buttonFont
                              minFontSize:10
                           actualFontSize:nil
                                 forWidth:_view.bounds.size.width - kAlertViewBorder * 2
                            lineBreakMode:NSLineBreakByClipping];

        if (size.width < maxHalfWidth - kAlertViewBorder) {
          // It might fit. Check the next Button
          NSArray *block2 = [_blocks objectAtIndex:i + 1];
          NSString *title2 = [block2 objectAtIndex:1];
          size = [title2 sizeWithFont:buttonFont
                          minFontSize:10
                       actualFontSize:nil
                             forWidth:_view.bounds.size.width - kAlertViewBorder * 2
                        lineBreakMode:NSLineBreakByClipping];

          if (size.width < maxHalfWidth - kAlertViewBorder) {
            // They'll fit!
            isSecondButton = YES;  // For the next iteration
            width = maxHalfWidth;
          }
        }
      } else if (_blocks.count == 1) {
        // In this case this is the ony button. We'll size according to the text
        CGSize size = [title sizeWithFont:buttonFont
                              minFontSize:10
                           actualFontSize:nil
                                 forWidth:_view.bounds.size.width - kAlertViewBorder * 2
                            lineBreakMode:NSLineBreakByClipping];

        size.width = MAX(size.width, 80);
        if (size.width + 2 * kAlertViewBorder < width) {
          width = size.width + 2 * kAlertViewBorder;
          xOffset = floorf((_view.bounds.size.width - width) * 0.5);
        }
      }
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(xOffset, _height, width, kAlertButtonHeight);
    button.titleLabel.font = buttonFont;
    if (IOS_LESS_THAN_6) {
#pragma clan diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      button.titleLabel.minimumFontSize = 10;
#pragma clan diagnostic pop
    } else {
      button.titleLabel.adjustsFontSizeToFitWidth = YES;
      button.titleLabel.adjustsLetterSpacingToFitWidth = YES;
      button.titleLabel.minimumScaleFactor = 0.1;
    }
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.shadowOffset = kAlertViewButtonShadowOffset;
    button.backgroundColor = [UIColor clearColor];
    button.tag = i + 1;

    [button setBackgroundImage:image forState:UIControlStateNormal];
    if (highlightedImage) {
      [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    [button setTitleColor:kAlertViewButtonTextColor forState:UIControlStateNormal];
    [button setTitleShadowColor:kAlertViewButtonShadowColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.accessibilityLabel = title;

    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [_view addSubview:button];

    if (!isSecondButton) _height += kAlertButtonHeight + kAlertViewBorder;

    index++;
  }

  //_height += 10;  // Margin for the shadow // not sure where this came from, but it's making things look strange (I
  // don't see a shadow, either)
  if (_height < background.size.height) {
    CGFloat offset = background.size.height - _height;
    _height = background.size.height;
    CGRect frame;
    for (NSUInteger i = 0; i < _blocks.count; i++) {
      UIButton *btn = (UIButton *)[_view viewWithTag:i + 1];
      frame = btn.frame;
      frame.origin.y += offset;
      btn.frame = frame;
    }
  }

  // Ragta: aggiungo qua:
  CGFloat heightBackground = _height;
  UIWindow *parentView = [BlockBackground sharedInstance];
  if (_height > parentView.bounds.size.height) {
    CGSize csize = _view.contentSize;
    csize.height = _height;
    _view.contentSize = csize;
    _height = parentView.bounds.size.height;
  }

  CGRect frame = _view.frame;
  frame.origin.y = -_height;
  frame.size.height = _height;
  _view.frame = frame;

  // UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
  UIImageView *modalBackground =
      [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, heightBackground)];

  if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    modalBackground.image = backgroundlandscape;
  else
    modalBackground.image = background;

  if (_tintColor) {
    modalBackground.image = [modalBackground.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    modalBackground.tintColor = _tintColor;
  }
  // fine Ragta

  modalBackground.contentMode = UIViewContentModeScaleToFill;
  modalBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [_view insertSubview:modalBackground atIndex:0];
  [modalBackground release];

  if (_backgroundImage) {
    [BlockBackground sharedInstance].backgroundImage = _backgroundImage;
    [_backgroundImage release];
    _backgroundImage = nil;
  }

  [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
  [[BlockBackground sharedInstance] addToMainWindow:_view];

  __block CGPoint center = _view.center;
  center.y = floorf([BlockBackground sharedInstance].bounds.size.height * 0.5) + kAlertViewBounce;

  _cancelBounce = NO;

  [UIView animateWithDuration:0.4
      delay:0.0
      options:UIViewAnimationOptionCurveEaseOut
      animations:^{
        [BlockBackground sharedInstance].alpha = 1.0f;
        _view.center = center;
      }
      completion:^(BOOL finished) {
        if (_cancelBounce) return;

        [UIView animateWithDuration:0.1
            delay:0.0
            options:0
            animations:^{
              center.y -= kAlertViewBounce;
              _view.center = center;
            }
            completion:^(BOOL finished) {
              [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertViewFinishedAnimations" object:self];
            }];
      }];

  [self retain];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
  _shown = NO;

  [[NSNotificationCenter defaultCenter] removeObserver:self];

  if (buttonIndex >= 0 && buttonIndex < [_blocks count]) {
    id obj = [[_blocks objectAtIndex:buttonIndex] objectAtIndex:0];
    if (![obj isEqual:[NSNull null]]) {
      ((void (^)())obj)();
    }
  }

  if (animated) {
    [UIView animateWithDuration:0.1
        delay:0.0
        options:0
        animations:^{
          CGPoint center = _view.center;
          center.y += 20;
          _view.center = center;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.4
              delay:0.0
              options:UIViewAnimationOptionCurveEaseIn
              animations:^{
                CGRect frame = _view.frame;
                frame.origin.y = -frame.size.height;
                _view.frame = frame;
                [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
              }
              completion:^(BOOL finished) {
                [[BlockBackground sharedInstance] removeView:_view];
                [_view release];
                _view = nil;
                [self autorelease];
              }];
        }];
  } else {
    [[BlockBackground sharedInstance] removeView:_view];
    [_view release];
    _view = nil;
    [self autorelease];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)buttonClicked:(id)sender {
  /* Run the button's block */
  int buttonIndex = [(UIButton *)sender tag] - 1;
  [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
