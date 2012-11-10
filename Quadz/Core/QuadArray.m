//
//  QuadArray.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/28/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

//
// Copyright 2012 Dirk Zimmermann
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "QuadArray.h"

@implementation QuadArray

- (id)init
{
    if (self = [super initWithElementSize:sizeof(Quad)]) {
    }
    return self;
}

- (void)addElement:(Quad)quad
{
    [super addElement:&quad];
}

- (Quad)elementAt:(size_t)index
{
    Quad *quad = [super elementAt:index];
    return *quad;
}

- (void)replaceElementAt:(size_t)index withElement:(Quad)quad
{
    [super replaceElementAt:index withElement:&quad];
}

@end
