//
//  HtmlComponent.m
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HtmlComponent.h"

@implementation HtmlComponent
@synthesize text;
@synthesize tagLabel;
@synthesize attributes;
@synthesize position;
@synthesize componentIndex;

- (id)initWithString:(NSString *)aText
                 tag:(NSString *)aTagLabel
          attributes:(NSMutableDictionary *)theAttributes {
    self = [super init];
    if (self) {
        text       = [aText copy];
        tagLabel   = [aTagLabel copy];
        attributes = theAttributes;
    }
    return self;
}

+ (id)componentWithString:(NSString *)aText
                      tag:(NSString *)aTagLabel
               attributes:(NSMutableDictionary *)theAttributes {
    return [[self alloc] initWithString:aText tag:aTagLabel attributes:theAttributes];
}

- (id)initWithTag:(NSString *)aTagLabel
         position:(int)aPosition
       attributes:(NSMutableDictionary *)theAttributes {
    self = [super init];
    if (self) {
        tagLabel   = [aTagLabel copy];
        position   = aPosition;
        attributes = theAttributes;
    }
    return self;
}

+ (id)componentWithTag:(NSString *)aTagLabel
              position:(int)aPosition
            attributes:(NSMutableDictionary *)theAttributes {
    return [[self alloc] initWithTag:aTagLabel position:aPosition attributes:theAttributes];
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"text: %@", self.text];
    [desc appendFormat:@", position: %i", self.position];
    if (self.tagLabel) [desc appendFormat:@", tag: %@", self.tagLabel];
    if (self.attributes) [desc appendFormat:@", attributes: %@", self.attributes];
    return desc;
}
@end
