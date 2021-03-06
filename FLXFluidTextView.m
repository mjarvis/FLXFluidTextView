//
//  FLXFluidTextView.m
//
//  Copyright (c) 2013 Oliver White (github.com/oliverwhite). All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "FLXFluidTextView.h"

NSString * const FLXFluidTextViewHeightConstraintDidChangeNotification = @"FLXFluidTextViewHeightConstraintDidChangeNotification";

@interface FLXFluidTextView ()

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation FLXFluidTextView

CG_INLINE CGFloat padding(UITextView *textView)
{
    return textView.textContainerInset.top + textView.textContainerInset.bottom;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:0.0];
        [self addConstraint:self.heightConstraint];
    }
    return self;
}

- (void)setMaximumNumberOfLines:(NSUInteger)maximumNumberOfLines
{
    NSAssert(self.font != nil, @"font property is equal to nil, cannot calculate maximum height");

    _maximumNumberOfLines = maximumNumberOfLines;

    CGFloat maximumHeight = [self.font lineHeight] * maximumNumberOfLines + padding(self);
    self.maximumHeight = ceilf(maximumHeight);
}

- (void)setMinimumNumberOfLines:(NSUInteger)minimumNumberOfLines
{
    NSAssert(self.font != nil, @"font property is equal to nil, cannot calculate minimum height");

    _minimumNumberOfLines = minimumNumberOfLines;

    CGFloat minimumHeight = [self.font lineHeight] * minimumNumberOfLines + padding(self);
    self.minimumHeight = ceilf(minimumHeight);
}

#pragma mark - UIScrollView -

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];

    self.heightConstraint.constant = MAX(self.minimumHeight, MIN(self.contentSize.height, self.maximumHeight));

    [[NSNotificationCenter defaultCenter] postNotificationName:FLXFluidTextViewHeightConstraintDidChangeNotification
                                                        object:self];

    if (self.frame.size.height < self.contentSize.height
        && [self offsetFromPosition:self.endOfDocument
                         toPosition:self.selectedTextRange.end] == 0)
    {
        CGPoint point = self.contentOffset;
        point.y = self.contentSize.height - self.frame.size.height;

        self.contentOffset = point;
    }
}

@end
