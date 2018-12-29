//
//  CDZPicker.m
//  CDZPickerViewDemo
//
//  Created by Nemocdz on 2016/11/18.
//  Copyright © 2016年 Nemocdz. All rights reserved.

#import "CDZPicker.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define BACKGROUND_BLACK_COLOR [UIColor colorWithRed:0.412 green:0.412 blue:0.412 alpha:0.7]
static const NSInteger CDZPickerViewDefaultHeight = 248;
static const NSInteger CDZToolBarHeight = 44;

@implementation CDZPickerComponentObject
- (instancetype)init{
    return [self initWithText:@"" subArray:[NSMutableArray array]];
}

- (instancetype)initWithText:(NSString *)text{
    return [self initWithText:text subArray:[NSMutableArray array]];
}


- (instancetype)initWithText:(NSString *)text subArray:(NSMutableArray *)array{
    if (self = [super init]) {
        _text = text;
        _subArray = array;
    }
    return self;
}

@end

@implementation CDZPickerBuilder

- (instancetype)init{
    if (self = [super init]) {
        _showMask = YES;
        _defaultIndex = 0;
        _pickerHeight = CDZPickerViewDefaultHeight;
    }
    return self;
}
@end


@interface CDZPicker()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, assign, getter=isLinkage) BOOL linkage;
@property (nonatomic, assign) NSInteger numberOfComponents;
@property (nonatomic, strong) CDZPickerBuilder *builder;
@property (nonatomic, copy) NSArray<CDZPickerComponentObject *> *componets;
@property (nonatomic, copy) CDZConfirmBlock confirmBlock;
@property (nonatomic, copy) CDZCancelBlock cancelBlock;
@property (nonatomic, copy) NSArray<NSArray <NSString*> *> *stringArrays;
@property (nonatomic, strong) NSMutableArray<NSMutableArray <CDZPickerComponentObject *> *> *rows;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation CDZPicker

#pragma mark - setup

- (void)config{
    if (!self.isLinkage) {
        self.numberOfComponents = self.stringArrays.count;
    }
    else{
        self.rows = [NSMutableArray array];
        CDZPickerComponentObject *object = self.componets.firstObject;
        [self.rows setObject:[NSMutableArray arrayWithArray:self.componets] atIndexedSubscript:0];
        for (self.numberOfComponents = 1;; self.numberOfComponents++) {
            [self.rows setObject:object.subArray atIndexedSubscript:self.numberOfComponents];
            object = [self objectAtIndex:0 inObject:object];
            if (!object) {
                break;
            }
        }
    }
    [self setupViews];
}


+ (void)showSinglePickerInView:(UIView *)view
                   withBuilder:(CDZPickerBuilder *)builder
                       strings:(NSArray<NSString *> *)strings
                       confirm:(CDZConfirmBlock)confirmBlock
                        cancel:(CDZCancelBlock)cancelBlcok{
    CDZPicker *pickerView = [[CDZPicker alloc]initWithFrame:view.frame];
    
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:strings.count];
    for (NSString *string in strings) {
        CDZPickerComponentObject *object = [[CDZPickerComponentObject alloc]initWithText:string];
        [tmp addObject:object];
    }
    pickerView.linkage = YES;
    pickerView.componets = [tmp copy];
    pickerView.confirmBlock = confirmBlock;
    pickerView.cancelBlock = cancelBlcok;
    pickerView.builder = builder ?:[CDZPickerBuilder new];
    [pickerView config];
    [view addSubview:pickerView];
}

+ (void)showMultiPickerInView:(UIView *)view
                  withBuilder:(CDZPickerBuilder *)builder
                 stringArrays:(NSArray<NSArray<NSString *> *> *)arrays
                      confirm:(CDZConfirmBlock)confirmBlock cancel:(CDZCancelBlock)cancelBlcok{
    CDZPicker *pickerView = [[CDZPicker alloc]initWithFrame:view.frame];
    pickerView.linkage = NO;
    pickerView.stringArrays = arrays;
    pickerView.confirmBlock = confirmBlock;
    pickerView.cancelBlock = cancelBlcok;
    pickerView.builder = builder ?:[CDZPickerBuilder new];
    [pickerView config];
    [view addSubview:pickerView];
}


+ (void)showLinkagePickerInView:(UIView *)view
                    withBuilder:(CDZPickerBuilder *)builder
                     components:(NSArray<CDZPickerComponentObject *> *)components
                        confirm:(CDZConfirmBlock)confirmBlock
                         cancel:(CDZCancelBlock)cancelBlcok{
    CDZPicker *pickerView = [[CDZPicker alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    pickerView.linkage = YES;
    pickerView.componets = components;
    pickerView.confirmBlock = confirmBlock;
    pickerView.cancelBlock = cancelBlcok;
    pickerView.builder = builder ?:[CDZPickerBuilder new];
    [pickerView config];
    [view addSubview:pickerView];
}

- (void)setupViews{
    self.backgroundColor = self.builder.isShowMask ? BACKGROUND_BLACK_COLOR : UIColor.clearColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissView)];
    [self addGestureRecognizer:tap];
    [self addSubview:self.containerView];
    
    [self.containerView addSubview:self.pickerView];
    [self.containerView addSubview:self.confirmButton];
    [self.containerView addSubview:self.cancelButton];
    NSInteger defaultIndex =  (self.builder.defaultIndex < self.numberOfComponents && self.builder.defaultIndex > 0) ? self.builder.defaultIndex : 30;
    [self.pickerView selectRow:defaultIndex inComponent:0 animated:NO];
}


#pragma mark - event response

- (void)confirm:(UIButton *)button{
    if (self.confirmBlock){
        NSMutableArray<NSString *> *resultStrings = [NSMutableArray arrayWithCapacity:self.numberOfComponents];
        NSMutableArray<NSNumber *> *resultIndexs = [NSMutableArray arrayWithCapacity:self.numberOfComponents];
        if ([self configResultStrings:resultStrings indexs:resultIndexs]) {
            self.confirmBlock([resultStrings copy],[resultIndexs copy]);
        }
    }
    [self removeFromSuperview];
}

- (void)dissView{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self removeFromSuperview];
}

- (void)cancel:(UIButton *)button{
    [self dissView];
}


#pragma mark - private

- (BOOL)configResultStrings:(NSMutableArray <NSString *> *)strings indexs:(NSMutableArray <NSNumber *> *)indexs{
    if (!strings || !indexs) {
        return NO;
    }
    
    [strings removeAllObjects];
    [indexs removeAllObjects];
    
    if (!self.isLinkage) {
        for (NSInteger index = 0; index < self.numberOfComponents; index++) {
            NSInteger indexRow = [self.pickerView selectedRowInComponent:index];
            [indexs addObject:@(indexRow)];
            NSArray<NSString *> *tmp = self.stringArrays[index];
            if (tmp.count > 0) {
                [strings addObject:tmp[indexRow]];
            }
        }
    }
    else{
        for (NSInteger index = 0; index < self.numberOfComponents; index++) {
            NSInteger indexRow = [self.pickerView selectedRowInComponent:index];
            [indexs addObject:@(indexRow)];
            NSMutableArray<CDZPickerComponentObject *> *tmp = self.rows[index];
            if (tmp.count > 0) {
                [strings addObject:tmp[indexRow].text];
            }
        }
    }
    return YES;
}

- (CDZPickerComponentObject *)objectAtIndex:(NSInteger)index inObject:(CDZPickerComponentObject *)object{
    if (object.subArray.count > index) {
        return object.subArray[index];
    }
    return nil;
}


#pragma mark - PickerDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.numberOfComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (!self.isLinkage) {
        return self.stringArrays[component].count;
    }
    else{
        return self.rows[component].count;
    }
}



#pragma mark - PickerDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (!self.isLinkage) {
        return;
    }
    
    if (component < (self.numberOfComponents - 1)) {
        NSMutableArray<CDZPickerComponentObject *> *tmp = self.rows[component];
        if (tmp.count > 0) {
            tmp = tmp[row].subArray;
        }
        [self.rows setObject:((tmp.count > 0) ? tmp : [NSMutableArray array])  atIndexedSubscript:component + 1];
        
        [self pickerView:pickerView didSelectRow:0 inComponent:component + 1];
        [pickerView selectRow:0 inComponent:component + 1 animated:NO];
    }
    [pickerView reloadComponent:component];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews){
        if (singleLine.frame.size.height < 1){
            singleLine.backgroundColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1.00];
        }
    }
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.font = [UIFont systemFontOfSize:23.0];
    genderLabel.textColor = self.builder.pickerTextColor ?: UIColor.blackColor;
    
    if (!self.isLinkage) {
        NSArray<NSString *> *tmp = self.stringArrays[component];
        if (tmp.count > 0) {
            genderLabel.text = tmp[row];
        }
    }
    else{
        NSArray<CDZPickerComponentObject *> *tmp = self.rows[component];
        if (tmp.count > 0) {
            genderLabel.text = tmp[row].text;
        }
    }
    return genderLabel;
}



#pragma mark - getter

- (UIView *)containerView{
    if (!_containerView) {
        CGFloat pickerViewHeight = self.builder.pickerHeight > CDZToolBarHeight ? self.builder.pickerHeight : CDZPickerViewDefaultHeight;
        _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - pickerViewHeight, SCREEN_WIDTH, pickerViewHeight)];
        _containerView.backgroundColor = self.builder.pickerColor ?: UIColor.whiteColor;
    }
    return _containerView;
}



- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -70, 10, 40, 30)];
        _confirmButton.backgroundColor = UIColor.clearColor;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title = self.builder.confirmText.length ? self.builder.confirmText : @"确定";
        [_confirmButton setTitle:title forState:UIControlStateNormal];
        UIColor *color = self.builder.confirmTextColor ?: UIColor.blueColor;
        [_confirmButton setTitleColor:color forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 10, 40, 30)];
        _cancelButton.backgroundColor = UIColor.clearColor;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title = self.builder.cancelText.length ? self.builder.cancelText : @"取消";
        [_cancelButton setTitle:title forState:UIControlStateNormal];
        UIColor *color = self.builder.cancelTextColor ?: UIColor.blueColor;
        [_cancelButton setTitleColor:color forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}


- (UIPickerView *)pickerView{
    if (!_pickerView) {
        CGFloat pickerViewHeight = self.builder.pickerHeight > CDZToolBarHeight ? self.builder.pickerHeight : CDZPickerViewDefaultHeight;
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,CDZToolBarHeight, SCREEN_WIDTH, pickerViewHeight - CDZToolBarHeight)];
        _pickerView.backgroundColor = UIColor.clearColor;
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

@end

