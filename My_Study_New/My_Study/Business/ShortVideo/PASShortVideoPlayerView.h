//
//  PASShortVideoPlayerView.h
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/11/24.
//

#import <UIKit/UIKit.h>
//#import "PASConsultingInfoDataLoader.h"
#import "PASShortVideoResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PASShortVideoPlayerDelegate <NSObject>

- (void)shortVideoPlayerFinished:(PASShortVideoItemModel *)videoModel;

- (void)shortVideoPlayerError:(PASShortVideoItemModel *)videoModel;

- (void)shareShortVideo:(PASShortVideoItemModel *)videoModel completion:(void(^)(BOOL success))block;

- (void)commentShortVideo:(PASShortVideoItemModel *)videoModel;

- (void)upperShortVideo:(PASShortVideoItemModel *)videoModel isAgree:(BOOL)value;

@end

@interface PASShortVideoPlayerView : UIView

//@property (nonatomic, strong) PASConsultingInfoDataLoader *dataLoader;

@property (nonatomic, weak) id<PASShortVideoPlayerDelegate> delegate;

- (void)playWithVideoData:(PASShortVideoItemModel *)videoModel;

- (void)startPlay;

- (void)stopPlay;

- (void)playOrPause:(BOOL)play;

- (void)updateCommentView:(NSInteger)count;

- (void)destoryPlayer;

- (void)shortVideoBackgroundMonitor:(BOOL)value;

@end

NS_ASSUME_NONNULL_END
