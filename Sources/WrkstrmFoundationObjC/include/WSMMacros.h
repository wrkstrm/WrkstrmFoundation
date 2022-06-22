//
//  WSMMacros.h
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 12/11/13.
//
//

#ifndef wrkstrm_mac_WSMMacros_h
#define wrkstrm_mac_WSMMacros_h

#ifdef __OBJC__

/**
 Simply returns the number of seconds in a day
 */
#define WSM_SECONDS_PER_DAY 86400

/**
 Creates a basic singleton.
 */

#define WSM_SINGLETON_WITH_NAME(sharedInstanceName) + (instancetype)sharedInstanceName { \
                                                        static id sInstance; \
                                                        static dispatch_once_t onceToken; \
                                                        dispatch_once(&onceToken, ^{ \
                                                            sInstance = self.new; \
                                                        }); \
                                                        return sInstance; \
                                                    }

/**
 Wrapper around the DISPATCH_AFTER marcro.
 */

#define WSM_DISPATCH_AFTER(time, block) do { NSTimeInterval delayInSeconds = time; \
        dispatch_time_t popTime = \
            dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC)); \
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){ block ; }); } while (0)

/**
 Awesomeness. Lazy instantiation as a function
 */

#define WSM_LAZY(variable, assignment) (variable = variable ?: assignment)


/**
 Standard increasing order comparitor.
 */

#define WSM_COMPARATOR(boolean) do{ if (boolean) { \
                                        return NSOrderedAscending; \
                                    } else { \
                                        return NSOrderedDescending; \
                                    }\
                                    return NSOrderedSame;\
                                    } while (0)

/**
 Expands to getter and setter methods backed by runtime associated objects.
 @param Type The type of the property to synthesize, e.g. `NSString *`
 @param GetterName The name of the property's getter method.
 @param SetterName The name of the property's setter method, including the trailing colon.
 @param AssociationType The OBJC_ASSOCIATION_* policy to use for the runtime association.
 */
#define WSMRuntimeSynthesize(Type, GetterName, SetterName, AssociationType, Assignment) \
- (Type)GetterName {\
    if (!objc_getAssociatedObject(self, @selector(GetterName))) { \
        objc_setAssociatedObject(self, @selector(GetterName), \
                                 Assignment, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    }\
    return objc_getAssociatedObject(self, @selector(GetterName));\
}\
\
- (void)SetterName(Type)object {\
objc_setAssociatedObject(self, @selector(GetterName), object, AssociationType);\
}
#endif
#endif
