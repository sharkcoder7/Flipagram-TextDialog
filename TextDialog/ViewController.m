//
//  ViewController.m
//  TextDialog
//
//  Created by Bin Jin on 12/19/14.
//  Copyright (c) 2014 Bin Jin. All rights reserved.
//

#import "ViewController.h"
#import "ZDStickerView.h"

@interface ViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, ZDStickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIView *viewToolbar;
@property (strong, nonatomic) IBOutlet UIView *viewColor;
@property (strong, nonatomic) IBOutlet UITableView *tableViewFont;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewColor;

@property (strong, nonatomic) NSArray *fontNames;
@property (strong, nonatomic) ZDStickerView *editTextView;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) BOOL isOpen;
@property (assign, nonatomic) BOOL isOpenKeyboard;

- (void)initUI;
- (IBAction)keyboardAction:(id)sender;
- (IBAction)fontAction:(id)sender;
- (IBAction)colorAction:(id)sender;
- (IBAction)done:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didHideKeyboard:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    self.fontNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    self.selectedIndex = 0;
    self.isOpen = NO;
    self.isOpenKeyboard = NO;
    
	self.viewColor.backgroundColor = [UIColor blackColor];
	self.viewColor.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.viewColor.layer.borderWidth = 1;
	self.viewColor.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	self.imageViewColor.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.imageViewColor.layer.borderWidth = 1;
    
    UITextView *textView = [[UITextView alloc] init];
    [textView setFont:[UIFont fontWithName:self.fontNames[0] size:40]];
    [textView setTextColor:[UIColor blackColor]];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.text = @"Hello";
    textView.delegate = self;
    textView.selectable = NO;
    textView.editable = YES;
    textView.scrollEnabled = NO;

    NSString *text = textView.text;
    CGSize textSize = [text sizeWithAttributes:textView.typingAttributes];
    textSize.width += 20;
    textSize.height += 15;
    CGSize newSize = CGSizeMake(textSize.width + (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2) * 2, textSize.height + (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2) * 2);
    
    CGRect rt = CGRectMake((self.view.frame.size.width - newSize.width) / 2, 100, newSize.width, newSize.height);
    
    self.editTextView = [[ZDStickerView alloc] initWithFrame:rt];
    self.editTextView.contentView = textView;
    self.editTextView.preventsPositionOutsideSuperview = NO;
    self.editTextView.delegate = self;
    [self.editTextView showEditingHandles];
    [self.editTextView.contentView becomeFirstResponder];

    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)];
    [self.editTextView addGestureRecognizer:singleTap];
    
    [self.view addSubview:self.editTextView];
    [self.view setNeedsDisplay];
}

-(void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if (self.editing == NO)
    {
        [self.editTextView showEditingHandles];
        [self.editTextView.contentView becomeFirstResponder];
    }
}

- (IBAction)keyboardAction:(id)sender
{
    [self.tableViewFont setHidden:NO];
    [self.viewColor setHidden:YES];
    [self.editTextView.contentView becomeFirstResponder];
}

- (IBAction)fontAction:(id)sender
{
    [self.editTextView.contentView resignFirstResponder];
    [self.tableViewFont setHidden:NO];
    [self.viewColor setHidden:YES];
}

- (IBAction)colorAction:(id)sender
{
    [self.editTextView.contentView resignFirstResponder];
    [self.tableViewFont setHidden:YES];
    [self.viewColor setHidden:NO];
}

- (IBAction)done:(id)sender
{
    self.isOpen = NO;
    [self.editTextView hideEditingHandles];
    if (self.isOpenKeyboard)
    {
        [self.editTextView.contentView resignFirstResponder];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewToolbar setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        } completion:^(BOOL finished) {
            self.isOpen = NO;
        }];
    }
}

- (void)populateColorsForPoint:(CGPoint)point
{
    if (CGRectContainsPoint(self.imageViewColor.frame, point))
    {
        [self.editTextView.contentView setTextColor:[self colorOfPoint:point]];
    }
}

- (UIColor *)colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	
    CGContextTranslateCTM(context, -point.x, -point.y);
	
    [self.imageViewColor.layer renderInContext:context];
	
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
	
    return color;
}

- (void)willShowKeyboard:(NSNotification *)notification
{
    self.isOpenKeyboard = YES;
    if (self.isOpen == NO)
    {
        [self.editTextView showEditingHandles];
        NSDictionary *info = [notification userInfo];
        [UIView animateWithDuration:[[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0 options:[[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
            [self.viewToolbar setFrame:CGRectMake(0, self.view.frame.size.height - 260, self.view.frame.size.width, self.view.frame.size.height)];
        } completion:^(BOOL finished){
            self.isOpen = YES;
        }];
    }
    else
    {
        [UIView setAnimationsEnabled:NO];        
    }
}

- (void)didShowKeyboard:(NSNotification *)notification {
    if (self.isOpen)
        [UIView setAnimationsEnabled:YES];
}

- (void)willHideKeyboard:(NSNotification *)notification {
    self.isOpenKeyboard = NO;
    if (self.isOpen == NO)
    {
        NSDictionary *info = [notification userInfo];
        [UIView animateWithDuration:[[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0 options:[[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
            [self.viewToolbar setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        } completion:^(BOOL finished){
            self.isOpen = NO;
        }];
    }
    else
    {
        [UIView setAnimationsEnabled:NO];
    }
}

- (void)didHideKeyboard:(NSNotification *)notification {
    if (self.isOpen)
        [UIView setAnimationsEnabled:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.fontNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"FontCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.textLabel setText:self.fontNames[indexPath.row]];
    [cell.textLabel setFont:[UIFont fontWithName:self.fontNames[indexPath.row] size:17]];

    if (self.selectedIndex == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.editTextView.contentView setFont:[UIFont fontWithName:self.fontNames[indexPath.row] size:40]];
    self.selectedIndex = indexPath.row;
    [self.tableViewFont reloadData];
    
    NSString *text = self.editTextView.contentView.text;
    CGSize textSize = [text sizeWithAttributes:self.editTextView.contentView.typingAttributes];
    textSize.width += 20;
    textSize.height += 15;
    CGSize newSize = CGSizeMake(textSize.width + (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2) * 2, textSize.height + (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2) * 2);
    CGRect rt = self.editTextView.frame;
    rt.size = newSize;
    [self.editTextView setFrame:rt];
}

#pragma mark - Touch Detection -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.imageViewColor];
	[self populateColorsForPoint:locationPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint locationPoint = [[touches anyObject] locationInView:self.imageViewColor];
	[self populateColorsForPoint:locationPoint];
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = self.editTextView.contentView.text;
    CGSize textSize = [text sizeWithAttributes:self.editTextView.contentView.typingAttributes];
    textSize.width += 20;
    textSize.height += 15;
    CGSize newSize = CGSizeMake(textSize.width + (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2) * 2, textSize.height + (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2) * 2);
    CGRect rt = self.editTextView.frame;
    rt.size = newSize;
    [self.editTextView setFrame:rt];
}

#pragma mark - ZDStickerView Delegate

- (void)stickerViewDidClose:(ZDStickerView *)sticker
{
    self.isOpen = NO;
    [self.editTextView hideEditingHandles];
    if (self.isOpenKeyboard)
    {
        [self.editTextView.contentView resignFirstResponder];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            [self.viewToolbar setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        } completion:^(BOOL finished) {
            self.isOpen = NO;
        }];
    }
}

- (void)moveToLeft:(CGFloat)dx Top:(CGFloat)dy
{
    CGFloat left = self.editTextView.frame.origin.x + dx;
    CGFloat top = self.editTextView.frame.origin.y + dy;
    
    [self.editTextView setFrame:CGRectMake(left, top, self.editTextView.frame.size.width, self.editTextView.frame.size.height)];
}

- (void)stickerViewDidSizeChanged
{
    for (int i = 8 ; i < 100 ; i ++) {
        NSString *text = self.editTextView.contentView.text;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont fontWithName:self.fontNames[self.selectedIndex] size:i]};
        CGSize textSize = [text sizeWithAttributes:attribute];
        textSize.width += 20;
        textSize.height += 10;
        if (self.editTextView.contentView.frame.size.width < textSize.width || self.editTextView.contentView.frame.size.height < textSize.height)
        {
            self.editTextView.contentView.font = [UIFont fontWithName:self.fontNames[self.selectedIndex] size:i];
            break;
        }
    }
}

@end
