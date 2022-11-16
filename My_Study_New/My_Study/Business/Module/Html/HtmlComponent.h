//
//  HtmlComponent.h
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HtmlComponent : NSObject {
  @private
    NSString *text;
    NSString *tagLabel;
    NSMutableDictionary *attributes;
    int position;
    int componentIndex;
}

@property (nonatomic, assign) int componentIndex;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *displayText;
@property (nonatomic, copy) NSString *tagLabel;
@property (nonatomic, retain) NSMutableDictionary *attributes;
@property (nonatomic, assign) int position;

- (id)initWithString:(NSString *)aText
                 tag:(NSString *)aTagLabel
          attributes:(NSMutableDictionary *)theAttributes;

+ (id)componentWithString:(NSString *)aText
                      tag:(NSString *)aTagLabel
               attributes:(NSMutableDictionary *)theAttributes;

- (id)initWithTag:(NSString*)aTagLabel
         position:(int)aPosition
       attributes:(NSMutableDictionary*)theAttributes;

+ (id)componentWithTag:(NSString *)aTagLabel
              position:(int)aPosition
            attributes:(NSMutableDictionary *)theAttributes;

@end

NS_ASSUME_NONNULL_END
