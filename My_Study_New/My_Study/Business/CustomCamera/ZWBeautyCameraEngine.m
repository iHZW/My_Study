#import "ZWBeautyCameraEngine.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>

@interface ZWBeautyCameraEngine () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@property (atomic, strong, readwrite) CIImage *previewImage;
@property (nonatomic, strong, readwrite) CIContext *context;
@property (nonatomic, strong, readwrite) id<MTLDevice> device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *microphoneInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) VNDetectFaceRectanglesRequest *faceRequest;
@property (nonatomic, copy) NSArray<VNFaceObservation *> *faces;
@property (nonatomic, strong) CIKernel *beautyKernel;
@property (atomic, readwrite) NSUInteger detectedFaceCount;
@property (atomic, readwrite) BOOL torchEnabled;
@property (nonatomic) NSUInteger frameIndex;
@property (atomic) BOOL wantsRunning;
@property (atomic) BOOL microphoneRequestPending;
@property (nonatomic) BOOL recording;
@property (nonatomic) BOOL finishing;
@property (nonatomic) BOOL audioSessionActive;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic) CMTime startTime;
@property (nonatomic) NSUInteger writtenFrames;
@end

@implementation ZWBeautyCameraEngine

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.mystudy.beauty.capture", DISPATCH_QUEUE_SERIAL);
        _device = MTLCreateSystemDefaultDevice();
        _context = _device ? [CIContext contextWithMTLDevice:_device options:@{kCIContextCacheIntermediates: @NO}] : [CIContext contextWithOptions:@{kCIContextCacheIntermediates: @NO}];
        _faceRequest = [VNDetectFaceRectanglesRequest new];
        _smoothing = 0.65;
        _whitening = 0.45;
        _maximumDuration = 60;
        // 小半径双边估计只调整亮度纹理，保留色度与部分原始细节；
        // 方差抑制轮廓处理，美白只增益中间调，避免抬黑与灰白蒙层。
        // 在旧版系统同样可运行，无需额外的美颜 SDK 或模型下载。
        if (@available(iOS 15.0,*)) {
            if (_device.supportsDynamicLibraries) {
                NSString *source =
                @"#include <metal_stdlib>\n#include <CoreImage/CoreImage.h>\n"
                 "using namespace metal; namespace coreimage {"
                 "[[stitchable]] float4 beauty(sampler source, sampler faceMask, float smoothing, float whitening, float stepSize, destination dest) {"
                 " float2 p = dest.coord(); float4 src = source.sample(source.transform(p));"
                 " float3 perceptual = pow(max(src.rgb,float3(0.0)),float3(0.454545));"
                 " float cb = 0.5 - 0.168736*perceptual.r - 0.331264*perceptual.g + 0.5*perceptual.b;"
                 " float cr = 0.5 + 0.5*perceptual.r - 0.418688*perceptual.g - 0.081312*perceptual.b;"
                 " float skin = smoothstep(0.26,0.34,cb)*(1.0-smoothstep(0.52,0.58,cb));"
                 " skin *= smoothstep(0.49,0.55,cr)*(1.0-smoothstep(0.73,0.81,cr));"
                 " skin *= smoothstep(0.045,0.12,dot(perceptual,float3(0.299,0.587,0.114)));"
                 " float face = faceMask.sample(faceMask.transform(p)).r;"
                 " float amount = skin*(0.55+0.45*face);"
                 " float total = 1.0; float sourceY=dot(perceptual,float3(0.299,0.587,0.114)); float firstMoment=sourceY; float secondMoment=sourceY*sourceY;"
                 " for(int y=-2;y<=2;y++) { for(int x=-2;x<=2;x++) {"
                 "   float2 offset = float2(float(x),float(y));"
                 "   float3 c = source.sample(source.transform(p+offset*stepSize)).rgb;"
                 "   float3 delta = pow(max(c,float3(0.0)),float3(0.454545))-perceptual;"
                 "   float weight = exp(-dot(offset,offset)/4.0-dot(delta,delta)/0.012);"
                 "   float sampleY=dot(pow(max(c,float3(0.0)),float3(0.454545)),float3(0.299,0.587,0.114)); firstMoment+=sampleY*weight; secondMoment+=sampleY*sampleY*weight; total += weight;"
                 " }}"
                 " float meanY=firstMoment/total;"
                 " float deviation=sqrt(max(0.0,secondMoment/total-meanY*meanY));"
                 " float edgeProtection=1.0-smoothstep(0.025,0.085,deviation);"
                 " float targetY=mix(sourceY,meanY,smoothing*0.62*amount*edgeProtection);"
                 " float midtones=smoothstep(0.12,0.35,sourceY)*(1.0-smoothstep(0.75,0.96,sourceY));"
                 " targetY*=1.0+whitening*0.18*amount*midtones;"
                 " float3 result=perceptual*(targetY/max(sourceY,0.001));"
                 " return float4(pow(clamp(result,0.0,1.0),float3(2.2)),src.a);"
                 "}}";
                _beautyKernel = [CIKernel kernelsWithMetalString:source error:nil].firstObject;
            }
        }
        // 模拟器及不支持动态 Metal 库的旧设备使用同一算法，不能降级成全图模糊。
        if (!_beautyKernel) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _beautyKernel = [CIKernel kernelWithString:
                @"kernel vec4 beauty(sampler source, sampler faceMask, float smoothing, float whitening, float stepSize) {"
                 " vec2 p=destCoord(); vec4 src=sample(source,samplerTransform(source,p));"
                 " vec3 perceptual=pow(max(src.rgb,vec3(0.0)),vec3(0.454545));"
                 " float cb=0.5-0.168736*perceptual.r-0.331264*perceptual.g+0.5*perceptual.b;"
                 " float cr=0.5+0.5*perceptual.r-0.418688*perceptual.g-0.081312*perceptual.b;"
                 " float skin=smoothstep(0.26,0.34,cb)*(1.0-smoothstep(0.52,0.58,cb));"
                 " skin*=smoothstep(0.49,0.55,cr)*(1.0-smoothstep(0.73,0.81,cr));"
                 " skin*=smoothstep(0.045,0.12,dot(perceptual,vec3(0.299,0.587,0.114)));"
                 " float face=sample(faceMask,samplerTransform(faceMask,p)).r;"
                 " float amount=skin*(0.55+0.45*face); float total=1.0; float sourceY=dot(perceptual,vec3(0.299,0.587,0.114)); float firstMoment=sourceY; float secondMoment=sourceY*sourceY;"
                 " for(int y=-2;y<=2;y++){for(int x=-2;x<=2;x++){"
                 " vec2 offset=vec2(float(x),float(y));"
                 " vec3 c=sample(source,samplerTransform(source,p+offset*stepSize)).rgb;"
                 " vec3 delta=pow(max(c,vec3(0.0)),vec3(0.454545))-perceptual;"
                 " float weight=exp(-dot(offset,offset)/4.0-dot(delta,delta)/0.012);"
                 " float sampleY=dot(pow(max(c,vec3(0.0)),vec3(0.454545)),vec3(0.299,0.587,0.114)); firstMoment+=sampleY*weight; secondMoment+=sampleY*sampleY*weight; total+=weight; }}"
                 " float meanY=firstMoment/total;"
                 " float deviation=sqrt(max(0.0,secondMoment/total-meanY*meanY));"
                 " float edgeProtection=1.0-smoothstep(0.025,0.085,deviation);"
                 " float targetY=mix(sourceY,meanY,smoothing*0.62*amount*edgeProtection);"
                 " float midtones=smoothstep(0.12,0.35,sourceY)*(1.0-smoothstep(0.75,0.96,sourceY));"
                 " targetY*=1.0+whitening*0.18*amount*midtones;"
                 " vec3 result=perceptual*(targetY/max(sourceY,0.001));"
                 " return vec4(pow(clamp(result,0.0,1.0),vec3(2.2)),src.a); }"];

#pragma clang diagnostic pop
        }
        _startTime = kCMTimeInvalid;
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:self selector:@selector(sessionInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:nil];
        [center addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:nil];
        [center addObserver:self selector:@selector(sessionFailed:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_videoOutput setSampleBufferDelegate:nil queue:NULL];
    [_audioOutput setSampleBufferDelegate:nil queue:NULL];
}

- (void)report:(NSString *)message ready:(BOOL)ready {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.statusHandler) self.statusHandler(message, ready);
    });
}

- (void)start {
    self.wantsRunning = YES;
    if (!self.device) {
        [self report:@"当前设备不支持实时美颜预览" ready:NO];
        return;
    }
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (weakSelf.wantsRunning) [weakSelf start];
        }];
        return;
    }
    if (status != AVAuthorizationStatusAuthorized) {
        [self report:@"相机未授权，请在系统设置中允许访问相机" ready:NO];
        return;
    }
    dispatch_async(self.queue, ^{
        if (!self.wantsRunning) return;
        if (!self.session && ![self configureSession]) return;
        if (!self.session.running) [self.session startRunning];
        NSString *message = !self.session.running ? @"相机启动失败，请重试" : self.beautyKernel ? @"美颜已开启 · 按住对比查看原图" : @"美颜内核不可用，当前显示原始画面";
        [self report:message ready:self.session.running];
    });
}

- (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position {
    return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
}

- (BOOL)configureSession {
    NSError *error = nil;
    AVCaptureDevice *camera = [self cameraAtPosition:AVCaptureDevicePositionFront] ?: [self cameraAtPosition:AVCaptureDevicePositionBack];
    if (!camera) {
        [self report:@"未检测到摄像头，请使用 iPhone 真机拍摄" ready:NO];
        return NO;
    }
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    AVCaptureSession *session = [AVCaptureSession new];
    session.automaticallyConfiguresApplicationAudioSession = NO;
    [session beginConfiguration];
    session.sessionPreset = AVCaptureSessionPreset1280x720;
    AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    if (!input || ![session canAddInput:input] || ![session canAddOutput:output]) {
        [session commitConfiguration];
        [self report:error.localizedDescription ?: @"摄像头配置失败" ready:NO];
        return NO;
    }
    [session addInput:input];
    [session addOutput:output];
    [output setSampleBufferDelegate:self queue:self.queue];
    self.cameraInput = input;
    self.videoOutput = output;
    self.session = session;
    [self configureVideoConnection];
    [session commitConfiguration];
    return YES;
}

- (void)configureVideoConnection {
    AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (@available(iOS 17.0, *)) {
        if ([connection isVideoRotationAngleSupported:90]) connection.videoRotationAngle = 90;
    } else {
        if (connection.supportsVideoOrientation) connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    if (connection.supportsVideoMirroring) {
        connection.automaticallyAdjustsVideoMirroring = NO;
        connection.videoMirrored = self.cameraInput.device.position == AVCaptureDevicePositionFront;
    }
    AVCaptureDevice *camera = self.cameraInput.device;
    if ([camera lockForConfiguration:nil]) {
        for (AVFrameRateRange *range in camera.activeFormat.videoSupportedFrameRateRanges) {
            if (range.minFrameRate <= 30 && range.maxFrameRate >= 30) {
                camera.activeVideoMinFrameDuration = CMTimeMake(1, 30);
                camera.activeVideoMaxFrameDuration = CMTimeMake(1, 30);
                break;
            }
        }
        [camera unlockForConfiguration];
    }
}

- (void)stop {
    self.wantsRunning = NO;
    dispatch_async(self.queue, ^{
        [self finishRecordingOnQueue];
        AVCaptureDevice *camera = self.cameraInput.device;
        if (camera.hasTorch && [camera lockForConfiguration:nil]) {
            camera.torchMode = AVCaptureTorchModeOff;
            [camera unlockForConfiguration];
        }
        self.torchEnabled = NO;
        [self.session stopRunning];
        self.previewImage = nil;
        [self deactivateAudio];
    });
}

- (void)switchCamera {
    dispatch_async(self.queue, ^{
        if (self.recording || self.finishing || !self.session.running) return;
        AVCaptureDevicePosition next = self.cameraInput.device.position == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
        AVCaptureDevice *device = [self cameraAtPosition:next];
        NSError *error = nil;
        AVCaptureDeviceInput *input = device ? [AVCaptureDeviceInput deviceInputWithDevice:device error:&error] : nil;
        if (!input) {
            [self report:error.localizedDescription ?: @"该镜头不可用" ready:YES];
            return;
        }
        [self.session beginConfiguration];
        AVCaptureDeviceInput *old = self.cameraInput;
        if (old.device.hasTorch && [old.device lockForConfiguration:nil]) {
            old.device.torchMode = AVCaptureTorchModeOff;
            [old.device unlockForConfiguration];
        }
        self.torchEnabled = NO;
        [self.session removeInput:old];
        if ([self.session canAddInput:input]) {
            [self.session addInput:input];
            self.cameraInput = input;
        } else {
            [self.session addInput:old];
        }
        self.faces = nil;
        self.previewImage = nil;
        self.frameIndex = 0;
        [self configureVideoConnection];
        [self.session commitConfiguration];
    });
}

- (void)toggleTorch {
    dispatch_async(self.queue, ^{
        AVCaptureDevice *camera = self.cameraInput.device;
        if (!camera.hasTorch || !camera.torchAvailable) {
            [self report:@"当前镜头不支持闪光灯，请切换后置镜头" ready:self.session.running];
            return;
        }
        NSError *error = nil;
        if ([camera lockForConfiguration:&error]) {
            BOOL next = !self.torchEnabled;
            BOOL changed = YES;
            if (next) changed = [camera setTorchModeOnWithLevel:0.6 error:&error];
            else camera.torchMode = AVCaptureTorchModeOff;
            if (changed) self.torchEnabled = next;
            [camera unlockForConfiguration];
        }
        [self report:error.localizedDescription ?: (self.torchEnabled ? @"闪光灯已开启" : @"闪光灯已关闭") ready:self.session.running];
    });
}

- (void)setZoom:(CGFloat)zoom {
    dispatch_async(self.queue, ^{
        AVCaptureDevice *camera = self.cameraInput.device;
        if ([camera lockForConfiguration:nil]) {
            camera.videoZoomFactor = MAX(1,MIN(zoom,camera.activeFormat.videoMaxZoomFactor));
            [camera unlockForConfiguration];
        }
    });
}

- (CIImage *)cropForOutput:(CIImage *)image {
    CGFloat ratio = self.outputAspectRatio;
    CGRect extent = image.extent;
    if (ratio <= 0 || !isfinite(ratio)) return image;
    CGFloat width = extent.size.width, height = extent.size.height;
    if (width/height > ratio) width = height*ratio;
    else height = width/ratio;
    // H.264 采用偶数尺寸；预览、照片和录像共用裁切后的画幅。
    width = MAX(2,floor(width/2)*2);
    height = MAX(2,floor(height/2)*2);
    CGRect crop = CGRectMake(floor((extent.size.width-width)/2),floor((extent.size.height-height)/2),width,height);
    CIImage *result = [image imageByCroppingToRect:crop];
    return [result imageByApplyingTransform:CGAffineTransformMakeTranslation(-crop.origin.x,-crop.origin.y)];
}

- (CIImage *)processImage:(CIImage *)image {
    if (self.original) return image;
    CGFloat smooth = self.smoothing, white = self.whitening;
    CGRect extent = image.extent;
    if ((self.frameIndex++ % 6) == 0) {
        CGFloat scale = MIN(1,320/MAX(extent.size.width,extent.size.height));
        CIImage *small = [image imageByApplyingTransform:CGAffineTransformMakeScale(scale,scale)];
        VNImageRequestHandler *request = [[VNImageRequestHandler alloc] initWithCIImage:small options:@{}];
        NSError *error = nil;
        self.faces = [request performRequests:@[self.faceRequest] error:&error] ? self.faceRequest.results : @[];
        self.detectedFaceCount = self.faces.count;
    }
    if (smooth > 0 || white > 0 || self.rosiness > 0 || self.clarity > 0) {
        CIImage *mask = [[CIImage imageWithColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:1]] imageByCroppingToRect:extent];
        for (VNFaceObservation *face in self.faces) {
            CGRect rect = VNImageRectForNormalizedRect(face.boundingBox,(size_t)extent.size.width,(size_t)extent.size.height);
            CGFloat radius = MAX(rect.size.width, rect.size.height) * 0.55;
            CIImage *gradient = [CIFilter filterWithName:@"CIRadialGradient" withInputParameters:@{
                @"inputCenter": [CIVector vectorWithX:CGRectGetMidX(rect) Y:CGRectGetMidY(rect)],
                @"inputRadius0": @(radius * 0.45), @"inputRadius1": @(radius),
                @"inputColor0": [CIColor colorWithRed:1 green:1 blue:1 alpha:1],
                @"inputColor1": [CIColor colorWithRed:0 green:0 blue:0 alpha:1]
            }].outputImage;
            mask = [[gradient imageByCroppingToRect:extent] imageByApplyingFilter:@"CIMaximumCompositing" withInputParameters:@{kCIInputBackgroundImageKey:mask}];
        }
        CGFloat step = (0.75 + smooth*0.85)*MAX(0.5,extent.size.height/1280);
        CIImage *processed = [self.beautyKernel applyWithExtent:extent roiCallback:^CGRect(int index, CGRect rect) {
            return index == 0 ? CGRectInset(rect,-step*2,-step*2) : rect;
        } arguments:@[[image imageByClampingToExtent],mask,@(smooth),@(white),@(step)]];
        if (processed) image = processed;
        // 内核异常时保留原始细节，不再用全局模糊、曝光补偿掩盖失败。
        // 红润与清晰只在已识别人脸区域混合，不改变背景色彩和锐度。
        if (self.faces.count && (self.rosiness > 0 || self.clarity > 0)) {
            CIImage *adjusted = image;
            if (self.rosiness > 0) {
                CGFloat amount = self.rosiness;
                adjusted = [adjusted imageByApplyingFilter:@"CIColorMatrix" withInputParameters:@{
                    @"inputRVector":[CIVector vectorWithX:1 Y:0 Z:0 W:0],
                    @"inputGVector":[CIVector vectorWithX:0 Y:1 Z:0 W:0],
                    @"inputBVector":[CIVector vectorWithX:0 Y:0 Z:1 W:0],
                    @"inputAVector":[CIVector vectorWithX:0 Y:0 Z:0 W:1],
                    @"inputBiasVector":[CIVector vectorWithX:amount*0.025 Y:-amount*0.006 Z:amount*0.004 W:0]
                }];
            }
            if (self.clarity > 0) adjusted = [adjusted imageByApplyingFilter:@"CISharpenLuminance" withInputParameters:@{kCIInputSharpnessKey:@(self.clarity*0.65)}];
            image = [adjusted imageByApplyingFilter:@"CIBlendWithMask" withInputParameters:@{kCIInputBackgroundImageKey:image,kCIInputMaskImageKey:mask}];
        }
    }
    switch (self.filterIndex) {
        case 1: image = [image imageByApplyingFilter:@"CIColorControls" withInputParameters:@{kCIInputSaturationKey:@0.88,kCIInputBrightnessKey:@0.025,kCIInputContrastKey:@0.98}]; break;
        case 2: image = [image imageByApplyingFilter:@"CITemperatureAndTint" withInputParameters:@{@"inputNeutral":[CIVector vectorWithX:6500 Y:0],@"inputTargetNeutral":[CIVector vectorWithX:5800 Y:8]}]; break;
        case 3: image = [image imageByApplyingFilter:@"CIPhotoEffectNoir" withInputParameters:@{}]; break;
        default: break;
    }
    return [image imageByCroppingToRect:extent];
}

- (void)takePhoto:(void (^)(UIImage *))completion {
    dispatch_async(self.queue, ^{
        CIImage *image = self.previewImage;
        CGImageRef cgImage = image ? [self.context createCGImage:image fromRect:image.extent] : NULL;
        UIImage *photo = cgImage ? [UIImage imageWithCGImage:cgImage] : nil;
        if (cgImage) CGImageRelease(cgImage);
        dispatch_async(dispatch_get_main_queue(), ^{ completion(photo); });
    });
}

- (BOOL)configureAudio {
    if (self.microphoneInput) return YES;
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *input = device ? [AVCaptureDeviceInput deviceInputWithDevice:device error:&error] : nil;
    AVCaptureAudioDataOutput *output = [AVCaptureAudioDataOutput new];
    [self.session beginConfiguration];
    BOOL valid = input && [self.session canAddInput:input];
    if (valid) {
        [self.session addInput:input];
        valid = [self.session canAddOutput:output];
        if (valid) {
            [self.session addOutput:output];
            [output setSampleBufferDelegate:self queue:self.queue];
            self.microphoneInput = input;
            self.audioOutput = output;
        } else {
            [self.session removeInput:input];
        }
    }
    [self.session commitConfiguration];
    if (!valid) [self report:error.localizedDescription ?: @"麦克风不可用，无法录制有声视频" ready:YES];
    return valid;
}

- (void)deactivateAudio {
    // 结束录像后释放采集输入，拍照和普通预览阶段不持续占用麦克风。
    if (self.microphoneInput) {
        [self.session beginConfiguration];
        [self.audioOutput setSampleBufferDelegate:nil queue:NULL];
        [self.session removeOutput:self.audioOutput];
        [self.session removeInput:self.microphoneInput];
        self.audioOutput = nil;
        self.microphoneInput = nil;
        [self.session commitConfiguration];
    }
    if (!self.audioSessionActive) return;
    [AVAudioSession.sharedInstance setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    self.audioSessionActive = NO;
}

- (void)startRecording {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        if (self.microphoneRequestPending) return;
        self.microphoneRequestPending = YES;
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            weakSelf.microphoneRequestPending = NO;
            // 首次授权可能使页面暂时失活，交还用户再次点击，避免后台意外开始录制。
            [weakSelf report:granted ? @"麦克风已开启，请再次点击录制" : @"麦克风未授权，请在系统设置中开启" ready:YES];
        }];
        return;
    }
    if (status != AVAuthorizationStatusAuthorized) {
        [self report:@"麦克风未授权，请在系统设置中开启" ready:YES];
        return;
    }
    dispatch_async(self.queue, ^{
        if (self.recording || self.finishing || !self.wantsRunning || !self.session.running || !self.previewImage) return;
        NSError *error = nil;
        if (![AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeVideoRecording options:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error] ||
            ![AVAudioSession.sharedInstance setActive:YES error:&error]) {
            [self report:error.localizedDescription ?: @"录音启动失败" ready:YES];
            return;
        }
        self.audioSessionActive = YES;
        if (![self configureAudio]) { [self deactivateAudio]; return; }
        self.movieURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"beauty-%@.mp4", NSUUID.UUID.UUIDString]]];
        self.writer = [AVAssetWriter assetWriterWithURL:self.movieURL fileType:AVFileTypeMPEG4 error:&error];
        CGSize size = self.previewImage.extent.size;
        self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{
            AVVideoCodecKey:AVVideoCodecTypeH264, AVVideoWidthKey:@((NSInteger)size.width), AVVideoHeightKey:@((NSInteger)size.height),
            AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:@4000000,AVVideoMaxKeyFrameIntervalKey:@30}
        }];
        self.videoInput.expectsMediaDataInRealTime = YES;
        self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:@{AVFormatIDKey:@(kAudioFormatMPEG4AAC),AVSampleRateKey:@44100,AVNumberOfChannelsKey:@1,AVEncoderBitRateKey:@64000}];
        self.audioInput.expectsMediaDataInRealTime = YES;
        self.adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:@{
            (NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
            (NSString *)kCVPixelBufferWidthKey:@((NSInteger)size.width),(NSString *)kCVPixelBufferHeightKey:@((NSInteger)size.height),
            (NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}
        }];
        if (!self.writer || ![self.writer canAddInput:self.videoInput] || ![self.writer canAddInput:self.audioInput]) {
            [self recordingFailed:error ?: [NSError errorWithDomain:@"ZWBeautyCamera" code:1 userInfo:@{NSLocalizedDescriptionKey:@"无法创建视频编码器"}]];
            return;
        }
        [self.writer addInput:self.videoInput];
        [self.writer addInput:self.audioInput];
        if (![self.writer startWriting]) { [self recordingFailed:self.writer.error]; return; }
        self.startTime = kCMTimeInvalid;
        self.writtenFrames = 0;
        self.recording = YES;
        dispatch_async(dispatch_get_main_queue(), ^{ if (self.recordingHandler) self.recordingHandler(YES); });
    });
}

- (void)finishRecording {
    dispatch_async(self.queue, ^{ [self finishRecordingOnQueue]; });
}

- (void)finishRecordingOnQueue {
    if (!self.recording || self.finishing) return;
    self.recording = NO;
    self.finishing = YES;
    dispatch_async(dispatch_get_main_queue(), ^{ if (self.recordingHandler) self.recordingHandler(NO); });
    if (!self.writtenFrames || self.writer.status != AVAssetWriterStatusWriting) {
        [self recordingFailed:self.writer.error ?: [NSError errorWithDomain:@"ZWBeautyCamera" code:2 userInfo:@{NSLocalizedDescriptionKey:@"录制时间太短，请重新录制"}]];
        return;
    }
    [self.videoInput markAsFinished];
    [self.audioInput markAsFinished];
    AVAssetWriter *writer = self.writer;
    NSURL *url = self.movieURL;
    [writer finishWritingWithCompletionHandler:^{
        dispatch_async(self.queue, ^{
            NSError *error = writer.status == AVAssetWriterStatusCompleted ? nil : writer.error ?: [NSError errorWithDomain:@"ZWBeautyCamera" code:3 userInfo:@{NSLocalizedDescriptionKey:@"视频保存失败"}];
            [self resetWriter];
            [self deactivateAudio];
            if (error) [NSFileManager.defaultManager removeItemAtURL:url error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{ if (self.movieHandler) self.movieHandler(error ? nil : url, error); });
        });
    }];
}

- (void)recordingFailed:(NSError *)error {
    [self.writer cancelWriting];
    if (self.movieURL) [NSFileManager.defaultManager removeItemAtURL:self.movieURL error:nil];
    [self resetWriter];
    [self deactivateAudio];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.recordingHandler) self.recordingHandler(NO);
        if (self.movieHandler) self.movieHandler(nil, error ?: [NSError errorWithDomain:@"ZWBeautyCamera" code:4 userInfo:@{NSLocalizedDescriptionKey:@"视频编码失败，请重试"}]);
    });
}

- (void)resetWriter {
    self.recording = NO;
    self.finishing = NO;
    self.writer = nil;
    self.videoInput = nil;
    self.audioInput = nil;
    self.adaptor = nil;
    self.movieURL = nil;
    self.startTime = kCMTimeInvalid;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        if (!self.wantsRunning) return;
        CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if (output == self.audioOutput) {
            if (self.recording && CMTIME_IS_VALID(self.startTime) && CMTimeCompare(time,self.startTime) >= 0 && self.audioInput.readyForMoreMediaData) {
                if (![self.audioInput appendSampleBuffer:sampleBuffer]) [self recordingFailed:self.writer.error];
            }
            return;
        }
        CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (!buffer) return;
        CIImage *image = [self processImage:[self cropForOutput:[CIImage imageWithCVPixelBuffer:buffer]]];
        self.previewImage = image;
        if (!self.recording) return;
        if (!CMTIME_IS_VALID(self.startTime)) {
            [self.writer startSessionAtSourceTime:time];
            self.startTime = time;
        }
        if (CMTimeGetSeconds(CMTimeSubtract(time,self.startTime)) >= self.maximumDuration) {
            [self finishRecordingOnQueue];
            return;
        }
        if (!self.videoInput.readyForMoreMediaData) return;
        CVPixelBufferRef target = NULL;
        CVPixelBufferPoolRef pool = self.adaptor.pixelBufferPool;
        if (pool && CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault,pool,&target) == kCVReturnSuccess) {
            [self.context render:image toCVPixelBuffer:target];
            BOOL appended = [self.adaptor appendPixelBuffer:target withPresentationTime:time];
            CVPixelBufferRelease(target);
            if (appended) self.writtenFrames++;
            else [self recordingFailed:self.writer.error];
        } else {
            [self recordingFailed:[NSError errorWithDomain:@"ZWBeautyCamera" code:5 userInfo:@{NSLocalizedDescriptionKey:@"视频缓冲区不足，请重试"}]];
        }
    }
}

- (void)sessionInterrupted:(NSNotification *)note {
    if (note.object != self.session) return;
    dispatch_async(self.queue, ^{ [self finishRecordingOnQueue]; });
    [self report:@"相机暂时被中断，恢复后可继续拍摄" ready:NO];
}

- (void)sessionInterruptionEnded:(NSNotification *)note {
    if (note.object == self.session && self.wantsRunning) [self start];
}

- (void)sessionFailed:(NSNotification *)note {
    if (note.object != self.session) return;
    dispatch_async(self.queue, ^{ [self finishRecordingOnQueue]; });
    NSError *error = note.userInfo[AVCaptureSessionErrorKey];
    [self report:error.localizedDescription ?: @"相机运行失败，请退出后重试" ready:NO];
}
@end
