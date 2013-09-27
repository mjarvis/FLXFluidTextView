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

NSString * const FLXFluidTextViewFrameDidChangeNotification = @"FLXFluidTextViewFrameDidChangeNotification";

@implementation FLXFluidTextView

CG_INLINE CGFloat padding(UITextView *textView)
{
    return ([textView respondsToSelector:@selector(textContainerInset)]) ?
        textView.textContainerInset.top + textView.textContainerInset.bottom :
              textView.contentInset.top + textView.contentInset.bottom;
}

- (void)setMaximumNumberOfLines:(NSUInteger)maximumNumberOfLines
{
    NSAssert(self.font != nil, @"font property is equal to nil, cannot calculate maximum height");

    _maximumNumberOfLines = maximumNumberOfLines;

    CGFloat maximumHeight = [self.font lineHeight] * maximumNumberOfLines + padding(self);
    self.maximumHeight = maximumHeight;
}

- (void)setMinimumNumberOfLines:(NSUInteger)minimumNumberOfLines
{
    NSAssert(self.font != nil, @"font property is equal to nil, cannot calculate minimum height");

    _minimumNumberOfLines = minimumNumberOfLines;

    CGFloat minimumHeight = [self.font lineHeight] * minimumNumberOfLines + padding(self);
    self.minimumHeight = minimumHeight;
}

#pragma mark - UIScrollView -

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];

    CGRect frame = self.frame;
    frame.size.height = MAX(self.minimumHeight, MIN(self.contentSize.height, self.maximumHeight));

    self.frame = frame;

    [[NSNotificationCenter defaultCenter] postNotificationName:FLXFluidTextViewFrameDidChangeNotification
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
