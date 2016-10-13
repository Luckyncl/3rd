

#import "MASExampleViewController.h"
#import "MASExampleBasicView.h"

@interface MASExampleViewController ()

@property (nonatomic, strong) Class viewClass;

@end

@implementation MASExampleViewController

- (id)initWithTitle:(NSString *)title viewClass:(Class)viewClass {
    self = [super init];
    if (!self) return nil;
    
    self.title = title;
    self.viewClass = viewClass;
    
    return self;
}


// 重写加载view的方法 然后进行替换
- (void)loadView {
    self.view = self.viewClass.new;
    self.view.backgroundColor = [UIColor whiteColor];
}





// 只适配ios8 以上
// 取消全屏布局

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}



- (void)dealloc
{
    
}


@end
