//
//  KVOBaseUsesViewController.m
//  KVO
//

//


//https://www.jianshu.com/p/d33252b99a58
//https://www.jianshu.com/p/6c6f3a24b1ef

#import "KVOBaseUsesViewController.h"

@interface KVOBaseUsesViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView  *baseV;
@property (nonatomic,strong)NSArray  *sourcesArr;
@end

@implementation KVOBaseUsesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
}
-(NSArray*)sourcesArr{
    if(_sourcesArr==nil){
        _sourcesArr = @[
                        @"1.观察者的添加和移除观察者",
                        @"2.观察者监听的方法",
                        @"3.手动发送通知",
                        @"4.监听集合属性",
                        @"5.不重复发送通知",
                        @"6.一个属性改变,发送多个通知",
                        @"7.手动执行NSKeyValueChange",
                        @"8.属性依赖",
                        @"9.获取监听对象的内部信息",
                        @"10.重复添加监听",
                        @"11.防止过多移除监听对象_1",
                        @"12.防止过多移除监听对象_2",
                        @"13.防止过多移除/添加监听对象_3",
                        @"14.三方库KVOController的使用"
                        ];
    }
    return _sourcesArr;
}
-(void)setUpUI{
    self.baseV = [UITableView new];
    [self.view addSubview:self.baseV];
    self.baseV.frame = self.view.bounds;
    self.baseV.delegate =self;
    self.baseV.dataSource = self;
    [self.baseV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"KVOBaseUsesViewController"];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourcesArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KVOBaseUsesViewController" forIndexPath:indexPath];
    if(cell==nil){
        cell = [[UITableViewCell  alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KVOBaseUsesViewController"];
    }
    cell.textLabel.text = self.sourcesArr[indexPath.row];
    return  cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Class  cls  = NSClassFromString([NSString stringWithFormat:@"KVOBaseUsesViewController_%ld",indexPath.row+1]);
    UIViewController *vc = (UIViewController*) [cls new];
    vc.title =  self.sourcesArr[indexPath.row];
    vc.view.backgroundColor  = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
    
}
@end
