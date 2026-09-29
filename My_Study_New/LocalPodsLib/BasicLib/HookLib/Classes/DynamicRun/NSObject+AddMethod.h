//
//  NSObject+AddMethod.h
//  AFNetworking

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Aspects.h"

/*
 * 函数签名 类型简介
 * char -> c
 * int -> i
 * short -> s
 * long -> q
 * long long -> q
 * unsigned long long -> Q
 * unsigned char -> C
 * unsigned int -> I
 * unsigned short -> S
 * unsigned long -> Q
 * float -> f
 * double -> d
 * BOOL -> c
 * bool -> B
 * boolean -> C
 * boolean_t -> I
 * NSInteger -> q
 * NSUInteger -> Q
 * CGFLoat -> d
 * CGSize -> {CGSize=dd}
 * CGRect -> {CGRect={CGPoint=dd}{CGSize=dd}}
 * CGPoint -> {CGPoint=dd}
 * UIEdgeInsets -> {UIEdgeInsets=dddd}
 * NSRange -> {_NSRange=QQ}
 * SEL -> :
 * Class -> #
 * char * -> *
 */

/*
 * 示例代码如下：
 * 假设 Foo 是要增加函数方法 类名
  #1 实例方法添加
     [Foo addMethodForSelector:@selector(unsigneditreturnWithParams:val2:) typed:"I@:ii" implementation:^(id<AspectInfo> instance, int tmp, int tmp2) {
        unsigned int retval = tmp + tmp2;
         // return retval;
        [NSObject changeReturnVal:instance.originalInvocation val:@(retval)];
     }];

     [Foo addMethodForSelector:@selector(sizeWithParams:val2:) typed:"{CGSize=dd}@:ii" implementation:^(id<AspectInfo> instance, int tmp1, int tmp2) {
        CGSize sz = CGSizeMake(tmp1, tmp2);
         // return sz;
        [NSObject changeReturnVal:instance.originalInvocation val:NSStringFromCGSize(sz)];
     }];

     CGSize sz = [foo sizeWithParams:100 val2:200];

  #2 类方法添加
     unsigned int tmp = [foo unsigneditreturnWithParams:200 val2:22];
     NSLog(@"retVal:%@", @(tmp));
 
     [Foo addClassMethodForSelector:@selector(idReturnVal:v2:) typed:"@@:@@" implementation:^(id<AspectInfo> instance, NSString *str1, NSString *str2) {
         NSString *retval = [NSString stringWithFormat:@"%@%@", str1, str2];
         // return retval;
        [NSObject changeReturnVal:instance.originalInvocation val:retval];
     }];
     
     NSString *str = [Foo idReturnVal:@"你好-" v2:@"这是类方法"];
     NSLog(@"class method:%@", str);
 
 ============================================================================
 R              The property is read-only (readonly).
 C              The property is a copy of the value last assigned (copy).
 &              The property is a reference to the value last assigned (retain).
 N              The property is non-atomic (nonatomic).
 G<name>        The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
 S<name>        The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
 D              The property is dynamic (@dynamic).
 W              The property is a weak reference (__weak).
 P              The property is eligible for garbage collection.
 T<encoding>    Specifies the type using old-style encoding.
 V              属性对应的实例变量Ivar
 
 @property char charDefault;                            -> Tc,V_charDefault
 @property double doubleDefault;                        -> Td,V_doubleDefault
 @property enum FooManChu enumDefault;                  -> Ti,V_enumDefault
 @property float floatDefault;                          -> Tf,V_floatDefault
 @property int intDefault;                              -> Ti,V_intDefault
 @property long longDefault;                            -> Tl,V_longDefault
 @property short shortDefault;                          -> Ts,V_shortDefault
 @property signed signedDefault;                        -> Ti,V_signedDefault
 @property struct YorkshireTeaStruct structDefault;     -> T{YorkshireTeaStruct="pot"i"lady"c},V_structDefault
 @property YorkshireTeaStructType typedefDefault;       -> T{YorkshireTeaStruct="pot"i"lady"c},V_typedefDefault
 @property union MoneyUnion unionDefault;               -> T(MoneyUnion="alone"f"down"d),V_unionDefault
 @property unsigned unsignedDefault;                    -> TI,V_unsignedDefault
 @property int (*functionPointerDefault)(char *);       -> T^?,V_functionPointerDefault

 Note: the compiler warns: "no 'assign', 'retain', or 'copy' attribute is specified - 'assign' is assumed"
 @property id idDefault;                                -> T@,V_idDefault
 @property int *intPointer;                             -> T^i,V_intPointer
 @property void *voidPointerDefault;                    -> T^v,V_voidPointerDefault
 @property int intSynthEquals;                          -> Ti,V_intSynthEquals
 @property(getter=intGetFoo, setter=intSetFoo:) int intSetterGetter;    -> Ti,GintGetFoo,SintSetFoo:,V_intSetterGetter
 @property(readonly) int intReadonly;                   -> Ti,R,VintReadonly
 @property(getter=isIntReadOnlyGetter, readonly) int intReadonlyGetter; -> Ti,R,GisIntReadOnlyGetter
 @property(readwrite) int intReadwrite;                 -> Ti,V_intReadwrite
 @property(assign) int intAssign;                       -> Ti,V_intAssign
 @property(retain) id idRetain;                         -> T@,&,V_idRetain
 @property(copy) id idCopy;                             -> T@,C,V_idCopy
 @property(nonatomic) int intNonatomic;                 -> Ti,V_intNonatomic
 @property(nonatomic, readonly, copy) id idReadonlyCopyNonatomic;   -> T@,R,C,V_idReadonlyCopyNonatomic
 @property(nonatomic, readonly, retain) id idReadonlyRetainNonatomic;   ->T@,R,&,V_idReadonlyRetainNonatomic
 
 添加属性示例代码
 Class cls = [AppDelegate Class];
 
 // 给类AppDelegate 添加 @property (nonatomic, copy) NSString *strAddStrProperty;
 [NSObject addPropertyWithTarget:cls propertyName:@"strAddStrProperty" propertyAttrs:@"T@\"NSString\",C,N,V_strAddStrProperty" setterTypes:"v@:@" getterTypes:"@@:"];
 
 // 给类AppDelegate 添加 @property (nonatomic)int intValueTest;
 [NSObject addPropertyWithTarget:cls propertyName:@"intValueTest" propertyAttrs:@"Ti,N,V_intValueTest" setterTypes:"v@:i" getterTypes:"i@:"];
 */

#define kDynamicRunErrorDomain @"com.pingan.DynamicRunErrorDomain"

typedef NS_ENUM(NSInteger, DynamicRunErrorType) {
    DynamicRunError_ParameterNotMatch   = 1000,     // 参数不匹配
    DynamicRunError_MemoryAllocFailed   = 1001,     // 内存分配失败
};

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AddMethod)

@property (nonatomic, strong) NSMutableDictionary *customerPropertyDict;

/// 通过NSInvocation 变更返回值
/// @param invocation invocation对象
/// @param val 返回对象值
+ (void)changeReturnVal:(NSInvocation *)invocation val:(id)val;

/// 对象 weak 处理
+ (__weak instancetype)weakObjectAction:(id)obj;

/// weak对象 strong处理
+ (__strong instancetype)strongObjectAction:(id)weakObj;

/// 给类添加实例方法
/// @param selector 方法名
/// @param types 方法返回值和参数类型
/// @param blockPtr 回调block
+ (BOOL)addMethodForSelector:(SEL)selector types:(const char*)types implementation:(id)blockPtr;

/// 给类添加类方法
/// @param selector 方法名
/// @param types 方法返回值和参数类型
/// @param blockPtr 回调block
+ (BOOL)addClassMethodForSelector:(SEL)selector types:(const char*)types implementation:(id)blockPtr;

/// 给已有类动态添加属性
/// @param targetClass 目标类
/// @param propertyName 属性名称
/// @param propertyAttrs 属性签名描述
/// @param setterTypes set方法签名描述
/// @param getterTypes get方法签名描述
+ (BOOL)addPropertyWithTarget:(Class)targetClass propertyName:(NSString *)propertyName propertyAttrs:(NSString *)propertyAttrs setterTypes:(const char*)setterTypes getterTypes:(const char *)getterTypes;

/// Obj-C通过参数数组形式模拟不定参数调用处理方法
/// @param invocation NSInvocation对象
/// @param arguments 参数数组信息
/// @param error 错误信息
/// @return 返回 Obj-C 对象
+ (nullable id)callVariableArgument:(NSInvocation **)invocation arguments:(nullable NSArray *)arguments error:(NSError **)error;

/// 实例方法不定参数Obj-C通过参数数组形式调用
/// @param instance 实例对象
/// @param selector 方法名称
/// @param parameters 参数数组信息
+ (nullable id)callInstanceMethodWithVariableArgument:(nullable id)instance selector:(nullable SEL)selector parameters:(nullable NSArray *)parameters;

/// 类方法不定参数Obj-C通过参数数组形式调用
/// @param class 类名称
/// @param selector 方法名称字符串，可以通过NSSelectorFromString 转换为selector
/// @param parameters 参数数组信息
+ (nullable id)callClassMehtodWithVariableArgument:(nullable Class)class selector:(nullable SEL)selector parameters:(nullable NSArray *)parameters;

@end

NS_ASSUME_NONNULL_END
