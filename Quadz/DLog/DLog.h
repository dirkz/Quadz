/*
 *  DLog.h
 *  NetHack HD
 *
 *  Created by Dirk Zimmermann on 11/15/10.
 *  Dirk Zimmermann. All rights reserved.
 *
 */

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

#ifndef ___DLOG___

#define ___DLOG___

#ifdef __OBJC__
#ifndef DLog
#if defined(DEBUG) || defined(DLOG)
#define DLog(...) NSLog(__VA_ARGS__)

// use NSStringFromCG{Point|Size|Rect} instead
//#define DRect(s, r) NSLog(s@" %.01f,%.01f %.01fx%.01f", r.origin.x, r.origin.y, r.size.width, r.size.height);
//#define DPoint(s, p) NSLog(s@" %.01f,%.01f", p.x, p.y);
//#define DSize(s, p) NSLog(s@" %.01f,%.01f", p.width, p.height);

#else // DEBUG
#define DLog(...) /* */
#endif // DEBUG
#endif // DLOG
#endif // __OBJC__

// Catch run-time GL errors
#if defined(DEBUG) || defined(DLOG)
#define glCheckError() { \
GLenum err = glGetError(); \
if (err != GL_NO_ERROR) { \
fprintf(stderr, "glCheckError: x%04x caught at %s:%u\n", err, __FILE__, __LINE__); \
assert(0); \
} \
}
#else
#define glCheckError()
#endif

#endif // ___DLOG___