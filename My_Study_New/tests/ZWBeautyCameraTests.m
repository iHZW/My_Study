#import "../My_Study/Business/CustomCamera/ZWBeautyCameraEngine.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>
#include <assert.h>

@interface ZWBeautyCameraEngine (Tests)
- (CIImage *)processImage:(CIImage *)image;
- (CIImage *)cropForOutput:(CIImage *)image;
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sample fromConnection:(AVCaptureConnection *)connection;
@end

/// 用确定的人脸区域隔离检测器的不确定性，检验处理与编码结果。
@interface BeautyTestFace : VNFaceObservation
@end
@implementation BeautyTestFace
- (CGRect)boundingBox { return CGRectMake(0.25,0.25,0.5,0.5); }
@end

static void Pixel(CIContext *context, CIImage *image, NSInteger x, NSInteger y, uint8_t *bytes) {
    CGColorSpaceRef color = CGColorSpaceCreateDeviceRGB();
    [context render:image toBitmap:bytes rowBytes:4 bounds:CGRectMake(x,y,1,1) format:kCIFormatRGBA8 colorSpace:color];
    CGColorSpaceRelease(color);
}

int main(void) {
    @autoreleasepool {
        ZWBeautyCameraEngine *engine = [ZWBeautyCameraEngine new];
        CIImage *input = [[CIImage imageWithColor:[CIColor colorWithRed:0.35 green:0.22 blue:0.16 alpha:1]] imageByCroppingToRect:CGRectMake(0,0,64,64)];
        uint8_t base[4], center[4], corner[4];
        Pixel(engine.context,input,32,32,base);
        engine.original = YES;
        assert([engine processImage:input] == input);
        engine.original = NO;
        assert([engine valueForKey:@"beautyKernel"] != nil);
        [engine setValue:@1 forKey:@"frameIndex"];
        [engine setValue:@[] forKey:@"faces"];
        CIImage *noFace = [engine processImage:input];
        Pixel(engine.context,noFace,32,32,center);
        assert(center[0] > base[0]+3);
        [engine setValue:@1 forKey:@"frameIndex"];
        [engine setValue:@[[BeautyTestFace new]] forKey:@"faces"];
        engine.whitening = 1;
        CIImage *beauty = [engine processImage:input];
        assert(CGRectEqualToRect(beauty.extent,input.extent));
        Pixel(engine.context,beauty,32,32,center);
        Pixel(engine.context,beauty,0,0,corner);
        assert(center[0] > base[0]+5);
        assert(center[0] > corner[0]+3);
        // 美白保留黑位及肤色通道比例，避免抬黑、去饱和造成白色蒙层。
        assert(fabs((double)center[0]/MAX(1,center[1])-(double)base[0]/MAX(1,base[1])) < 0.07);
        CIImage *black = [[CIImage imageWithColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:1]] imageByCroppingToRect:input.extent];
        uint8_t blackAfter[4];
        Pixel(engine.context,[engine processImage:black],32,32,blackAfter);
        assert(blackAfter[0] <= 1 && blackAfter[1] <= 1 && blackAfter[2] <= 1);
        CIImage *blue = [[CIImage imageWithColor:[CIColor colorWithRed:0.05 green:0.15 blue:0.8 alpha:1]] imageByCroppingToRect:input.extent];
        uint8_t blueBefore[4], blueAfter[4];
        Pixel(engine.context,blue,32,32,blueBefore);
        Pixel(engine.context,[engine processImage:blue],32,32,blueAfter);
        assert(abs(blueBefore[0]-blueAfter[0]) <= 2 && abs(blueBefore[2]-blueAfter[2]) <= 2);
        // 红润独立调节，关闭后恢复原值，且不改变输出画幅。
        engine.smoothing = 0;
        engine.whitening = 0;
        engine.rosiness = 1;
        [engine setValue:@1 forKey:@"frameIndex"];
        CIImage *rosy = [engine processImage:input];
        Pixel(engine.context,rosy,32,32,center);
        assert(CGRectEqualToRect(rosy.extent,input.extent));
        assert(center[0] > base[0]);
        engine.rosiness = 0;
        [engine setValue:@1 forKey:@"frameIndex"];
        Pixel(engine.context,[engine processImage:input],32,32,center);
        assert(abs(center[0]-base[0]) <= 1);
        engine.outputAspectRatio = 0.46;
        CIImage *cropped = [engine cropForOutput:input];
        assert(cropped.extent.size.width == 28 && cropped.extent.size.height == 64);
        assert(cropped.extent.origin.x == 0 && cropped.extent.origin.y == 0);
        engine.outputAspectRatio = 0;

        // 有噪声的肤色块必须实际变平滑，避免只验证亮度而漏掉磨皮失效。
        NSMutableData *noise = [NSMutableData dataWithLength:64*64*4];
        uint8_t *pixels = noise.mutableBytes;
        for (int y=0;y<64;y++) for(int x=0;x<64;x++) {
            int index = (y*64+x)*4;
            int delta = ((x*13+y*7)%11)-5;
            pixels[index] = 155+delta*3;
            pixels[index+1] = 112+delta*3;
            pixels[index+2] = 90+delta*3;
            pixels[index+3] = 255;
        }
        CGColorSpaceRef color = CGColorSpaceCreateDeviceRGB();
        CIImage *textured = [CIImage imageWithBitmapData:noise bytesPerRow:256 size:CGSizeMake(64,64) format:kCIFormatRGBA8 colorSpace:color];
        CGColorSpaceRelease(color);
        engine.whitening = 0;
        engine.smoothing = 1;
        [engine setValue:@1 forKey:@"frameIndex"];
        CIImage *smoothed = [engine processImage:textured];
        double before = 0, after = 0;
        for(int y=24;y<40;y++) for(int x=24;x<40;x++) {
            uint8_t p[4], q[4];
            Pixel(engine.context,textured,x,y,p);
            Pixel(engine.context,smoothed,x,y,q);
            before += pow(p[0]-155,2);
            after += pow(q[0]-155,2);
        }
        assert(after < before*0.8);
        engine.filterIndex = 3;
        CIImage *noir = [engine processImage:input];
        Pixel(engine.context,noir,32,32,center);
        assert(abs(center[0]-center[1]) <= 2 && abs(center[1]-center[2]) <= 2);
        NSLog(@"通过：原图旁路、肤色兜底、人脸增强、非肤色保护、噪声下降、全屏偶数裁切及黑白滤镜。");

        // 直接给真实编码管线喂合成帧，无需摄像头权限，验证保存的确为处理后图像。
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID.UUID.UUIDString stringByAppendingString:@".mp4"]]];
        NSError *error = nil;
        AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:&error];
        assert(writer && !error);
        AVAssetWriterInput *video = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{AVVideoCodecKey:AVVideoCodecTypeH264,AVVideoWidthKey:@64,AVVideoHeightKey:@64}];
        video.expectsMediaDataInRealTime = YES;
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:video sourcePixelBufferAttributes:@{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),(NSString *)kCVPixelBufferWidthKey:@64,(NSString *)kCVPixelBufferHeightKey:@64,(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}}];
        [writer addInput:video];
        AVAssetWriterInput *audio = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:@{AVFormatIDKey:@(kAudioFormatMPEG4AAC),AVSampleRateKey:@44100,AVNumberOfChannelsKey:@1,AVEncoderBitRateKey:@64000}];
        audio.expectsMediaDataInRealTime = YES;
        [writer addInput:audio];
        assert([writer startWriting]);
        AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
        AVCaptureAudioDataOutput *audioOutput = [AVCaptureAudioDataOutput new];
        [engine setValue:output forKey:@"videoOutput"];
        [engine setValue:audioOutput forKey:@"audioOutput"];
        [engine setValue:audio forKey:@"audioInput"];
        [engine setValue:writer forKey:@"writer"];
        [engine setValue:video forKey:@"videoInput"];
        [engine setValue:adaptor forKey:@"adaptor"];
        [engine setValue:url forKey:@"movieURL"];
        [engine setValue:@YES forKey:@"recording"];
        [engine setValue:@YES forKey:@"wantsRunning"];
        engine.smoothing = 0;
        engine.whitening = 0;
        for (int i=0; i<8; i++) {
            CVPixelBufferRef buffer = NULL;
            assert(CVPixelBufferCreate(kCFAllocatorDefault,64,64,kCVPixelFormatType_32BGRA,(__bridge CFDictionaryRef)@{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}},&buffer) == kCVReturnSuccess);
            [engine.context render:input toCVPixelBuffer:buffer];
            CMVideoFormatDescriptionRef format = NULL;
            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault,buffer,&format);
            CMSampleTimingInfo timing = {CMTimeMake(1,30),CMTimeMake(i,30),kCMTimeInvalid};
            CMSampleBufferRef sample = NULL;
            CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault,buffer,format,&timing,&sample);
            [engine captureOutput:output didOutputSampleBuffer:sample fromConnection:nil];
            CFRelease(sample);
            CFRelease(format);
            CVPixelBufferRelease(buffer);
            AudioStreamBasicDescription description = {0};
            description.mSampleRate = 44100;
            description.mFormatID = kAudioFormatLinearPCM;
            description.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
            description.mBytesPerPacket = 2;
            description.mFramesPerPacket = 1;
            description.mBytesPerFrame = 2;
            description.mChannelsPerFrame = 1;
            description.mBitsPerChannel = 16;
            CMAudioFormatDescriptionRef audioFormat = NULL;
            assert(CMAudioFormatDescriptionCreate(kCFAllocatorDefault,&description,0,NULL,0,NULL,NULL,&audioFormat) == noErr);
            CMBlockBufferRef data = NULL;
            assert(CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,NULL,2940,kCFAllocatorDefault,NULL,0,2940,0,&data) == noErr);
            CMBlockBufferFillDataBytes(0,data,0,2940);
            CMSampleTimingInfo audioTiming = {CMTimeMake(1,44100),CMTimeMake(i,30),kCMTimeInvalid};
            size_t sampleSize = 2;
            CMSampleBufferRef audioSample = NULL;
            assert(CMSampleBufferCreateReady(kCFAllocatorDefault,data,audioFormat,1470,1,&audioTiming,1,&sampleSize,&audioSample) == noErr);
            [engine captureOutput:audioOutput didOutputSampleBuffer:audioSample fromConnection:nil];
            CFRelease(audioSample);
            CFRelease(data);
            CFRelease(audioFormat);
        }
        __block BOOL finished = NO;
        __weak ZWBeautyCameraEngine *weakEngine = engine;
        engine.movieHandler = ^(NSURL *result, NSError *failure) {
            assert(result && !failure);
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:result options:nil];
            assert([asset tracksWithMediaType:AVMediaTypeVideo].count == 1);
            assert([asset tracksWithMediaType:AVMediaTypeAudio].count == 1);
            assert(CMTimeGetSeconds(asset.duration) > 0);
            AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
            AVAssetReaderTrackOutput *track = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[asset tracksWithMediaType:AVMediaTypeVideo].firstObject outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
            [reader addOutput:track];
            assert([reader startReading]);
            CMSampleBufferRef sample = [track copyNextSampleBuffer];
            assert(sample);
            CIImage *decoded = [CIImage imageWithCVPixelBuffer:CMSampleBufferGetImageBuffer(sample)];
            uint8_t decodedPixel[4];
            Pixel(weakEngine.context,decoded,32,32,decodedPixel);
            assert(abs(decodedPixel[0]-decodedPixel[1]) < 8 && abs(decodedPixel[1]-decodedPixel[2]) < 8);
            CFRelease(sample);
            [reader cancelReading];
            [NSFileManager.defaultManager removeItemAtURL:result error:nil];
            finished = YES;
        };
        [engine finishRecording];
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:15];
        while (!finished && deadline.timeIntervalSinceNow > 0) [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
        assert(finished);
        engine.movieHandler = nil;
        [engine stop];
        NSLog(@"通过：处理后帧写入 MP4、视频与 AAC 音频双轨、时长、解码后滤镜仍生效、结束录制回调。");
    }
    return 0;
}
