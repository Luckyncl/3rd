#import <Foundation/Foundation.h>

// 实际上这就是模型而已


/**
    模型用于记录数据
 */
@interface KxMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action;

@end


// kxMenu 继承于NSObject 适用于管理展示菜单的
@interface KxMenu : NSObject

// 展示相关
+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems;


+ (void) dismissMenu;


//  颜色相关
+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

@end
