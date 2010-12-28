//
//  CWHorizontalLayoutView.m
//  SharedComponents
//
//  Copyright 2009-2010 Jayway. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License. 
//  You may obtain a copy of the License at 
// 
//  http://www.apache.org/licenses/LICENSE-2.0 
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, 
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CWHorizontalLayoutView.h"


@implementation CWHorizontalLayoutView

@synthesize indexOfFlexibleView = _indexOfFlexibleView;

-(void)awakeFromNib;
{
	_indexOfFlexibleView = self.tag;
}

-(void)layoutSubviews;
{
  int subViewCount = [[self subviews] count];
	CGFloat width = 0;
	for (int i = 0; i < subViewCount; i++) {
		if (i != _indexOfFlexibleView) {
      UIView* view = [[self subviews] objectAtIndex:i];
      if (view.autoresizingMask & UIViewAutoresizingFlexibleWidth) {
				[view sizeToFit];
      }
      width += view.bounds.size.width;
    }
  }
  width = MAX(self.bounds.size.width - (width + (subViewCount - 1) * CWHorizontalLayoutViewPadding), 0);
  CGFloat x = 0;
  for (int i = 0; i < subViewCount; i++) {
    UIView* view = [[self subviews] objectAtIndex:i];
		CGRect frame = view.frame;
		frame.origin.x = x;
    if (i == _indexOfFlexibleView) {
    	frame.size.width = width;
    }
    view.frame = frame;
    x += frame.size.width + CWHorizontalLayoutViewPadding;
  }
}

@end
