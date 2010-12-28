//
//  CWUIExtensions.h
//  ResaISkane
//
//  Created by Fredrik Olsson on 2009-12-29.
//  Copyright 2009 Fredrik Olsson. All rights reserved.
//

#import "CWPoint.h"


@interface CWPoint (CWUIExtensions)

-(UIImage*)imageForType;
-(UITableViewCellAccessoryType)accessoryType;

@end

@interface UIColor (CWExtensions)

+(UIColor*)tableViewCellDetailColor;

@end
