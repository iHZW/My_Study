//
//  CMNotificationCenter.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMNotificationCenter.h"
#import <pthread.h>
#import "GCDCommon.h"

@interface CMNotificationObserverRecord : NSObject
{
//    id __unsafe_unretained object;      // anonymous object of interest id observer; // anonymous observer
    SEL selector;   // selector to call
}

@property (readwrite, weak) id object;
@property (readwrite, weak) id observer;
@property (readwrite, assign) SEL selector;

@end


@implementation CMNotificationObserverRecord
@synthesize object;
@synthesize observer;
@synthesize selector;

- (void)dealloc
{
    self.object     = nil;
    self.observer   = nil;
    self.selector   = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end


@interface CMNotificationCenter ()
{
    pthread_mutex_t _mutexLock;
}

@property (readwrite, strong) NSMutableDictionary *observersDictionary;
@property (nonatomic) dispatch_queue_t queue;   /* 指定的dispatch queue */

@end


@implementation CMNotificationCenter
+ (id)defaultCenter
{   
    // The shared "default" instance created as needed
    static id sharedNotificationCenter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNotificationCenter = [[CMNotificationCenter alloc] init];
    });
    
    return sharedNotificationCenter;
}

// Designated initializer
- (id)init
{
    self = [super init];
    
    if (self) {
        _queue                   = dispatch_queue_create("CMNotificationCenterQueue", DISPATCH_QUEUE_CONCURRENT);
        self.observersDictionary = [NSMutableDictionary dictionary];
        pthread_mutex_init(&_mutexLock, NULL);
    }
    
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutexLock);
#if !__has_feature(objc_arc)
    self.observersDictionary = nil;
    [super dealloc];
#endif
}

/**
 *  添加观察者
 *
 *  @param notificationObserver 观察者对象
 *  @param notificationSelector 执行方法
 *  @param notificationName     注册通知名称
 *  @param objectOfInterest     引用对象
 */
- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)objectOfInterest
{
    if (!notificationObserver || !notificationSelector)
        return;
    
    performBarrierBlock(_queue, YES, ^{
        // This class requires a non-nil notificationName, NSNotification
        // has no corresponding restriction.
        if (notificationName) {
            NSString *observerId = [NSString stringWithFormat:@"%p", notificationObserver];
            CMNotificationObserverRecord *newRecord = [[CMNotificationObserverRecord alloc] init];
            [newRecord setObject:objectOfInterest];
            [newRecord setObserver:notificationObserver];
            [newRecord setSelector:notificationSelector];
            
            pthread_mutex_lock(&self->_mutexLock);
            // There is an array of observer records for each notification name
            NSMutableDictionary *observers = [self->_observersDictionary objectForKey:notificationName];
            
            if (nil != observers) {
                [observers setObject:newRecord forKey:observerId];
            } else {
                // This is the first observer record for notificationName so
                // create the array to store this observer record and all
                // future observer records for the same notificationName.
                observers = [NSMutableDictionary dictionaryWithCapacity:0];
                [observers setObject:newRecord forKey:observerId];
                [self->_observersDictionary setObject:observers forKey:notificationName];
            }
            pthread_mutex_unlock(&self->_mutexLock);
            
#if !__has_feature(objc_arc)
            [newRecord release];
#endif
        }
    });
}

/**
 *  移除观察者对象
 *
 *  @param notificationObserver 观察者对象
 */
- (void)removeObserver:(id)notificationObserver
{
    if (!notificationObserver) return;
    
    NSString *observerId = [NSString stringWithFormat:@"%p", notificationObserver];
    [self removerObserverId:observerId name:nil object:nil];
}

/**
 *  移除指定注册通知名称的观察者对象
 *
 *  @param notificationObserver 观察者对象
 *  @param notificationName     注册通知名称
 */
- (void)removeObserver:(id)notificationObserver name:(NSString *)notificationName
{
    if (!notificationObserver) return;
    
    NSString *observerId = [NSString stringWithFormat:@"%p", notificationObserver];
    [self removerObserverId:observerId name:notificationName object:nil];
}

/**
 *  移除指定注册通知名称的观察者对象
 *
 *  @param notificationObserver 观察者对象
 *  @param notificationName     注册通知名称
 *  @param objectOfInterest     引用对象
 */
- (void)removeObserver:(id)notificationObserver name:(NSString *)notificationName object:(id)objectOfInterest
{
    if (!notificationObserver) return;
    
    NSString *observerId = [NSString stringWithFormat:@"%p", notificationObserver];
    [self removerObserverId:observerId name:notificationName object:objectOfInterest];
}

/**
 移除指定注册通知名称的观察者对象
 
 @param observerId 观察者对象
 @param notificationName 注册通知名称
 @param objectOfInterest 引用对象
 */
- (void)removerObserverId:(NSString *)observerId name:(NSString *)notificationName object:(id)objectOfInterest
{
    if (!observerId) return;
    
    performBarrierBlock(_queue, YES, ^{
        pthread_mutex_lock(&self->_mutexLock);
        
        if (notificationName) {
            NSMutableDictionary *observers = [self.observersDictionary objectForKey:notificationName];
            CMNotificationObserverRecord *currentObserverRecord = observers[observerId];
            
            if (!objectOfInterest || objectOfInterest == currentObserverRecord.object) {
                [observers removeObjectForKey:observerId];
            }
            
            if (observers.allKeys.count <= 0) {
                [self.observersDictionary removeObjectForKey:notificationName];
            }
        } else {
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.observersDictionary];
            
            [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSMutableDictionary *observers = [self.observersDictionary objectForKey:key];
                [observers removeObjectForKey:observerId];
                
                if (observers.allKeys.count <= 0) {
                    [self.observersDictionary removeObjectForKey:key];
                }
            }];
        }
        
        pthread_mutex_unlock(&self->_mutexLock);
    });
}

/**
 *  消息通知观察者
 *
 *  @param aNotification NSNotification类型参数
 */
- (void)postNotification:(NSNotification *)aNotification
{
    NSString *notifiName = [[aNotification name] mutableCopy];
    if (aNotification && [notifiName isKindOfClass:[NSString class]]) {
        pthread_mutex_lock(&_mutexLock);
        NSMutableDictionary *observers = [_observersDictionary objectForKey:notifiName];
        NSMutableDictionary *tmpObservers = [NSMutableDictionary dictionaryWithDictionary:observers];
        pthread_mutex_unlock(&_mutexLock);
        
        [tmpObservers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id currentObserverRecord = observers[key];
            id observer = [currentObserverRecord observer];
            
            if (observer) {
                // observer is either interested in notifications for all
                // objects or at least this object.
                //                CMLogDebug(LogBusinessBasicLib, @"====[currentObserverRecord observer]:%@ sel:%@", observer, NSStringFromSelector([currentObserverRecord selector]));
                if ([observer respondsToSelector:[currentObserverRecord selector]]) {
                    IMP doAction = [observer methodForSelector:[currentObserverRecord selector]];
                    void (*func)(id, SEL, id) = (void *)doAction;
                    func(observer, [currentObserverRecord selector], aNotification);
                    //                [observer performSelector:[currentObserverRecord selector] withObject:aNotification];
                }
            }
        }];
    }
#if !__has_feature(objc_arc)
    [notifiName release];
#endif
}

/**
 *  消息通知观察者
 *
 *  @param aName            注册通知名称
 *  @param objectOfInterest 引用对象
 *  @param userInfo         自定义参数
 */
- (void)postNotificationName:(NSString *)aName object:(id)objectOfInterest userInfo:(NSDictionary *)userInfo
{
    // This method creates a suitable NSNotification instances and
    // then posts it.
#if !__has_feature(objc_arc)
    NSNotification *newNotification = [[[NSNotification alloc] initWithName:aName object:objectOfInterest userInfo:userInfo] autorelease];
#else
    NSNotification *newNotification = [[NSNotification alloc] initWithName:aName object:objectOfInterest userInfo:userInfo];
#endif
    [self postNotification:newNotification];
}

@end
