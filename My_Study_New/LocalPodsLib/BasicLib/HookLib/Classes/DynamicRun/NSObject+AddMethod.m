//
//  NSObject+AddMethod.m
//  AFNetworking

#import "NSObject+AddMethod.h"
#import <objc/runtime.h>

static NSMutableDictionary *g_customerPropertyDict;
static const char *CustomerPropertyDictKey = "CustomerPropertyDictKey";


/// 不定参数获取基础类型
/// @param argType 参数签名
/// @param paramObj 不定参数
/// @param retVal 参数返回值
static void GetBasicParametersOfType(const char *argType, id paramObj, void *retVal)
{
    if (!retVal) return;

    // Skip const type qualifier.
    if (argType[0] == _C_CONST) argType++;

    id obj = [paramObj isKindOfClass:[NSNull class]] ? nil : paramObj;
    
    if (strcmp(argType, @encode(char)) == 0) {
        *((char *)retVal) = [obj charValue];
    } else if (strcmp(argType, @encode(int)) == 0) {
        *((int *)retVal) = [obj intValue];
    } else if (strcmp(argType, @encode(short)) == 0) {
        *(short *)retVal = [obj shortValue];
    } else if (strcmp(argType, @encode(long)) == 0) {
        *(long *)retVal = [obj longValue];
    } else if (strcmp(argType, @encode(long long)) == 0) {
        *(long long *)retVal = [obj longLongValue];
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        *(unsigned char *)retVal = [obj unsignedCharValue];
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        *(unsigned int *)retVal = [obj unsignedIntValue];
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        *(unsigned short *)retVal = [obj unsignedShortValue];
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        *(unsigned long *)retVal = [obj unsignedLongValue];
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        *(unsigned long long *)retVal = [obj unsignedLongLongValue];
    } else if (strcmp(argType, @encode(float)) == 0) {
        *(float *)retVal = [obj floatValue];
    } else if (strcmp(argType, @encode(double)) == 0) {
        *(double *)retVal = [obj doubleValue];
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        *(BOOL *)retVal = [obj boolValue];
    } else if (strcmp(argType, @encode(bool)) == 0) {
        *(bool *)retVal = [obj boolValue];
    }
}

/// 通过参数类型和参数 void* 进行 对象输出
/// @param argType 参数类型
/// @param argBuf 参数void * 类型数据
static id GetObjValueFromBasicParameters(const char *argType, void *argBuf)
{
    id retVal = nil;
    
    // Skip const type qualifier.
    if (argType[0] == _C_CONST) {
        argType++;
    }

    if (strcmp(argType, @encode(char)) == 0 || strcmp(argType, @encode(int)) == 0 ||
        strcmp(argType, @encode(short)) == 0 || strcmp(argType, @encode(unsigned short)) == 0 ||
        strcmp(argType, @encode(unsigned int)) == 0 || strcmp(argType, @encode(unsigned char)) == 0 ||
        strcmp(argType, @encode(bool)) == 0 || strcmp(argType, @encode(BOOL)) == 0) {
        retVal = @(*((int *)argBuf));
    } else if (strcmp(argType, @encode(long)) == 0 || strcmp(argType, @encode(unsigned long)) == 0) {
        retVal = @(*((long *)argBuf));
    } else if (strcmp(argType, @encode(long long)) == 0 || strcmp(argType, @encode(unsigned long long)) == 0) {
        retVal = @(*((long long *)argBuf));
    } else if (strcmp(argType, @encode(float)) == 0 || strcmp(argType, @encode(double)) == 0) {
        retVal = @(*((double *)argBuf));
    } else if (strcmp(argType, @encode(char *)) == 0) {
        retVal = [NSString stringWithFormat:@"%s", argBuf];
    }
    
    return retVal;
}

static void SetInvocationWithParams(NSInvocation **invocation, NSArray *arguments, NSError **error)
{
    if (!invocation || *invocation == nil) {
        if (!error) {
            *error = [NSError errorWithDomain:kDynamicRunErrorDomain code:DynamicRunError_ParameterNotMatch userInfo:@{NSLocalizedDescriptionKey : @"参数不匹配"}];
        }
        return;
    }
    
    NSMethodSignature *methodSignature = (*invocation).methodSignature;
    // 签名中方法参数的个数，内部包含了self和_cmd，所以参数从第3个开始
    NSInteger signatureParamCount = methodSignature.numberOfArguments - 2;
    
    if (signatureParamCount != arguments.count) {
        if (!error) {
            *error = [NSError errorWithDomain:kDynamicRunErrorDomain code:DynamicRunError_ParameterNotMatch userInfo:@{NSLocalizedDescriptionKey : @"参数不匹配"}];
        }
        return;
    }
    
    void *argBuf = NULL;
    NSInteger resultParamCount = MIN(signatureParamCount, arguments.count);
    
    for (NSInteger i = 0; i < resultParamCount; i++) {
        const char *type = [methodSignature getArgumentTypeAtIndex:2 + i];
        id obj = arguments[i];
        
        // 需要做参数类型判断然后解析成对应类型
        if (strcmp(type, "@") == 0 ||
            strcmp(type, "@?") == 0) {   // 函数参数类型为OC对象处理 或 Block 对象
            if ([obj isKindOfClass:[NSNull class]]) {
                obj = nil;
            }
            [*invocation setArgument:&obj atIndex:2+i];
        } else {    // 基础数据类型处理
            NSUInteger argSize;
            NSGetSizeAndAlignment(type, &argSize, NULL);
            if (!(argBuf = reallocf(argBuf, argSize))) {
                *error = [NSError errorWithDomain:kDynamicRunErrorDomain code:DynamicRunError_MemoryAllocFailed userInfo:@{NSLocalizedDescriptionKey : @"内存分配失败"}];
                return;
            }
            
            GetBasicParametersOfType(type, obj, argBuf);
            [*invocation setArgument:argBuf atIndex:2+i];
        }
    }
    
    [*invocation retainArguments];  // retain 所有参数， 防止参数被释放
    
    if (argBuf) {
        free(argBuf);
    }
}

@implementation NSObject (AddMethod)

- (NSMutableDictionary *)customerPropertyDict
{
    id val = objc_getAssociatedObject(self, CustomerPropertyDictKey);
    return val;
}

- (void)setCustomerPropertyDict:(NSMutableDictionary *)dictVal
{
    objc_setAssociatedObject(self, CustomerPropertyDictKey, dictVal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/// 通过NSInvocation 变更返回值
/// @param invocation invocation对象
/// @param val 返回对象值
+ (void)changeReturnVal:(NSInvocation *)invocation val:(id)val
{
    NSMethodSignature *methodSignature = invocation.methodSignature;
    const char *argType = methodSignature.methodReturnType;
    
    if (strcmp(argType, @encode(id)) == 0 ||
        strcmp(argType, @encode(Class)) == 0 ||
        strcmp(argType, @encode(SEL)) == 0 ||
        strcmp(argType, "@?") == 0) {
        [invocation setReturnValue:&val];
    } else if (strcmp(argType, @encode(char *)) == 0) {
        if ([val isKindOfClass:[NSString class]]) {
            char *tmp = (char *)[val UTF8String];
            [invocation setReturnValue:&tmp];
        }
    } else if (strcmp(argType, @encode(CGPoint)) == 0) {
        if ([val isKindOfClass:[NSString class]]) {
            CGPoint pt = CGPointFromString(val);
            [invocation setReturnValue:&pt];
        }
    } else if (strcmp(argType, @encode(CGSize)) == 0) {
        if ([val isKindOfClass:[NSString class]]) {
            CGSize sz = CGSizeFromString(val);
            [invocation setReturnValue:&sz];
        }
    } else if (strcmp(argType, @encode(CGRect)) == 0) {
        if ([val isKindOfClass:[NSString class]]) {
            CGRect rt = CGRectFromString(val);
            [invocation setReturnValue:&rt];
        }
    } else if (strcmp(argType, @encode(UIEdgeInsets)) == 0) {
        if ([val isKindOfClass:[NSString class]]) {
            UIEdgeInsets edgeInset = UIEdgeInsetsFromString(val);
            [invocation setReturnValue:&edgeInset];
        }
    } else if (strcmp(argType, @encode(NSRange)) == 0) {
        if ([val isKindOfClass:[NSString class]]) {
            NSRange rg = NSRangeFromString(val);
            [invocation setReturnValue:&rg];
        }
    } else if (strcmp(argType, @encode(void)) != 0) {
        NSUInteger argSize = methodSignature.methodReturnLength;
        void *retBuf = NULL;
        
        if (!(retBuf = reallocf(retBuf, argSize))) {
            return;
        }
        
        GetBasicParametersOfType(argType, val, retBuf);
        [invocation setReturnValue:retBuf];
        
        if (retBuf) {
            free(retBuf);
        }
    }
}

/// 对象 weak 处理
+ (__weak instancetype)weakObjectAction:(id)obj
{
    __weak __typeof(obj)weakSelf = obj;
    return weakSelf;
}

/// weak对象 strong处理
+ (__strong instancetype)strongObjectAction:(id)weakObj
{
    __strong __typeof(weakObj)strongObj = weakObj;
    return strongObj;
}

/// 给类添加实例方法
/// @param selector 方法名
/// @param types 方法返回值和参数类型
/// @param blockPtr 回调block
+ (BOOL)addMethodForSelector:(SEL)selector types:(const char*)types implementation:(id)blockPtr
{
    BOOL bRet = NO;

    if(!blockPtr){
        blockPtr = ^(){};
    }
    if (selector && types) {
        Method origninalMethod = class_getInstanceMethod([self class], selector);

        if (!origninalMethod) { // 判断函数方法是否存在， 不存在再进行添加
            bRet = class_addMethod(self, selector, class_getMethodImplementation(self, selector), types);
            [self aspect_hookSelector:selector withOptions:AspectPositionInstead usingBlock:blockPtr error:nil];
        }
    }
    
    return bRet;
}

/// 给类添加类方法
/// @param selector 方法名
/// @param types 方法返回值和参数类型
/// @param blockPtr 回调block
+ (BOOL)addClassMethodForSelector:(SEL)selector types:(const char*)types implementation:(id)blockPtr
{
    BOOL bRet = NO;
    if(!blockPtr){
        blockPtr = ^(){};
    }
    if (selector && types) {
        Method origninalMethod = class_getClassMethod([self class], selector);
        
        if (!origninalMethod) { // 判断函数方法是否存在， 不存在再进行添加
            Class metaClass = object_getClass([self class]);
            
            if (metaClass) {
                bRet = class_addMethod(metaClass, selector, class_getMethodImplementation(self, selector), types);
                [self aspect_hookClassSelector:selector withOptions:AspectPositionInstead usingBlock:blockPtr error:nil];
            }
        }
    }
    
    return bRet;
}

/// 将字符串首字母大写
/// @param value 输入字符串
+ (NSString *)upperCaseFirstCharacter:(NSString *)value
{
    NSString *retVal = nil;
    
    if (value.length > 0) {
        NSString *strHead = [[value substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        retVal = [value stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:strHead];
    }
    
    return retVal;
}

/// 给已有类动态添加属性
/// @param targetClass 目标类
/// @param propertyName 属性名称
/// @param propertyAttrs 属性签名描述
/// @param setterTypes set方法签名描述
/// @param getterTypes get方法签名描述
+ (BOOL)addPropertyWithTarget:(Class)targetClass propertyName:(NSString *)propertyName propertyAttrs:(NSString *)propertyAttrs setterTypes:(const char*)setterTypes getterTypes:(const char *)getterTypes
{
    BOOL bRet = NO;
    
    // 判断属性是否存在，不存在添加
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (!ivar && setterTypes && getterTypes && propertyName.length > 0) {
        NSArray *attrList = [propertyAttrs componentsSeparatedByString:@","];
        
        if (attrList.count > 0) {
            objc_property_attribute_t attrs[attrList.count];
            
            for (NSInteger i = 0; i < attrList.count; i++) {
                NSString *item = attrList[i];
                
                if ([item hasPrefix:@"T"] || [item hasPrefix:@"V"] || [item hasPrefix:@"G"] || [item hasPrefix:@"S"]) {
                    NSString *subName = [item substringToIndex:1];
                    NSString *subVal = [item substringFromIndex:1];
                    objc_property_attribute_t tmpAttr = { [subName cStringUsingEncoding:NSUTF8StringEncoding], [subVal cStringUsingEncoding:NSUTF8StringEncoding] };
                    
                    if (tmpAttr.name && tmpAttr.value) {
                        attrs[i] = tmpAttr;
                    }
                } else {
                    objc_property_attribute_t tmpAttr = { [item cStringUsingEncoding:NSUTF8StringEncoding], "" };
                    attrs[i] = tmpAttr;
                }
            }
            
            if (class_addProperty(targetClass, [propertyName UTF8String], attrs, attrList.count)) { // 属性添加成功后 添加get和set方法
                [targetClass addMethodForSelector:NSSelectorFromString(propertyName) types:getterTypes implementation:^(id<AspectInfo> instance) {
                    NSObject *obj = (NSObject *)instance.instance;
                    id val = [obj.customerPropertyDict objectForKey:propertyName];
                    [NSObject changeReturnVal:instance.originalInvocation val:val];
                }];

                [targetClass addMethodForSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:",[[self class] upperCaseFirstCharacter:propertyName]]) types:setterTypes implementation:^(id<AspectInfo> instance) {
                    NSObject *obj = (NSObject *)instance.instance;
                    if (!obj.customerPropertyDict) {
                        obj.customerPropertyDict = [NSMutableDictionary dictionaryWithCapacity:0];
                    }
                    
                    NSMethodSignature *singature = instance.originalInvocation.methodSignature;
                    NSInteger signatureParamCount = singature.numberOfArguments - 2;
                    
                    if (signatureParamCount > 0) {
                        const char *type = [singature getArgumentTypeAtIndex:2];
                        
                        if (strcmp(type, "@") == 0 || strcmp(type, "@?") == 0) {    // 对象类型
                            __unsafe_unretained id argument;
                            [instance.originalInvocation getArgument:&argument atIndex:2];
                            [obj.customerPropertyDict setValue:argument forKey:propertyName];
                        } else {    // 基础类型
                            void *argBuf = NULL;
                            NSUInteger argSize;
                            NSGetSizeAndAlignment(type, &argSize, NULL);
                            
                            if ((argBuf = reallocf(argBuf, argSize))) {
                                [instance.originalInvocation getArgument:argBuf atIndex:2];
                                id paramObj = GetObjValueFromBasicParameters(type, argBuf);
                                [obj.customerPropertyDict setValue:paramObj forKey:propertyName];
                                free(argBuf);
                            }
                        }
                    }
                }];

                bRet = YES;
            }
        }
    }
    
    return bRet;
}

/// Obj-C通过参数数组形式模拟不定参数调用处理方法
/// @param invocation NSInvocation对象
/// @param arguments 参数数组信息
/// @param error 错误信息
/// @return 返回 Obj-C 对象
+ (nullable id)callVariableArgument:(NSInvocation **)invocation arguments:(nullable NSArray *)arguments error:(NSError **)error
{
    id retVal = nil;
    SetInvocationWithParams(invocation, arguments, error);
    [*invocation invoke];
    
    NSMethodSignature *methodSignature = (*invocation).methodSignature;
    
    // 获取函数签名返回值类型
    const char *argType = methodSignature.methodReturnType;
    
    if (argType && strcmp(argType, @encode(void)) != 0) {  // 有返回值
        if (strcmp(methodSignature.methodReturnType, "@") == 0) {
            [*invocation getReturnValue:&retVal];
        } else if (strcmp(methodSignature.methodReturnType, "v") != 0){    // 基础类型
            NSUInteger argSize;
            void *retBuf = NULL;
            NSGetSizeAndAlignment(argType, &argSize, NULL);
            if (!(retBuf = reallocf(retBuf, argSize))) {
                *error = [NSError errorWithDomain:kDynamicRunErrorDomain code:DynamicRunError_MemoryAllocFailed userInfo:@{NSLocalizedDescriptionKey : @"内存分配失败"}];
                return retVal;
            }
            
            [*invocation getReturnValue:retBuf];
            retVal = GetObjValueFromBasicParameters(argType, retBuf);
            
            if (retBuf) {
                free(retBuf);
            }
        }
    }
    
    return retVal;
}

/// 实例方法不定参数Obj-C通过参数数组形式调用
/// @param instance 实例对象
/// @param selector 方法名称
/// @param parameters 参数数组信息
+ (nullable id)callInstanceMethodWithVariableArgument:(nullable id)instance selector:(nullable SEL)selector parameters:(nullable NSArray *)parameters
{
    id retVal = nil;
    
    if (instance && selector && [instance respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [[instance class] instanceMethodSignatureForSelector:selector];
        if (methodSignature) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:instance];
            [invocation setSelector:selector];
            
            NSError *error;
            retVal = [[self class] callVariableArgument:&invocation arguments:parameters error:&error];
        }
    }
    
    return retVal;
}

/// 类方法不定参数Obj-C通过参数数组形式调用
/// @param class 类名称
/// @param selector 方法名称字符串，可以通过NSSelectorFromString 转换为selector
/// @param parameters 参数数组信息
+ (nullable id)callClassMehtodWithVariableArgument:(nullable Class)class selector:(nullable SEL)selector parameters:(nullable NSArray *)parameters
{
    id retVal = nil;
    
    if (class && selector && [class respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
        if (methodSignature) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:class];
            [invocation setSelector:selector];
            
            NSError *error;
            retVal = [[self class] callVariableArgument:&invocation arguments:parameters error:&error];
        }
    }
    
    return retVal;
}

@end
