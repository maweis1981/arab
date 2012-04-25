/*
 * (C) Copyright 2010, Stefan Arentz, Arentz Consulting.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Book.h"

@implementation Book

@synthesize title = title_;
@synthesize author = author_;
@synthesize fileName = fileName_;

- (id) initWithCoder: (NSCoder*) coder
{
	if ((self = [super init]) != nil) {
		title_ = [[coder decodeObjectForKey: @"title"] retain];
		author_ = [[coder decodeObjectForKey: @"author"] retain];
		fileName_ = [[coder decodeObjectForKey: @"fileName"] retain];
	}
	return self;
}

- (void) dealloc
{
	[title_ release];
	[author_ release];
	[fileName_ release];
	[super dealloc];
}

- (void) encodeWithCoder: (NSCoder*) coder
{
	[coder encodeObject: title_ forKey: @"title"];
	[coder encodeObject: author_ forKey:@"author"];
	[coder encodeObject: fileName_ forKey:@"fileName"];
}

@end