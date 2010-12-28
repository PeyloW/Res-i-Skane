//
//  CWUIExtensions.m
//  ResaISkane
//
//  Created by Fredrik Olsson on 2009-12-29.
//  Copyright 2009 Fredrik Olsson. All rights reserved.
//

#import "CWUIExtensions.h"


@implementation CWPoint (CWUIExtensions)

-(UIImage*)imageForType;
{
	return [UIImage imageNamed:[NSString stringWithFormat:@"point-%d.png", self.type]];	  
}

-(UITableViewCellAccessoryType)accessoryType;
{
  return UITableViewCellAccessoryNone;
//	return self.type == CWPointTypeStopArea ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
}

@end

@implementation UIColor (CWExtensions)

+(UIColor*)tableViewCellDetailColor;
{
	return [UIColor colorWithRed:0.196f green:0.31f blue:0.522f alpha:1.f];
}

@end
