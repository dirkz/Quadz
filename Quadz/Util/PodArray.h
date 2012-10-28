//
//  PodArray.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/27/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PodArray : NSObject

@property (nonatomic, readonly) const void * elements;
@property (nonatomic, readonly) size_t count;

- (id)initWithElementSize:(size_t)elementSize;
- (void)addElement:(void *)data;
- (void *)elementAt:(size_t)index;

@end
