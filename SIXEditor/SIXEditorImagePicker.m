//
//  SIXEditorImagePicker.m
//  SIXRichEditor
//
//  Created by 刘吉六 on 2023/6/16.
//  Copyright © 2023 liujiliu. All rights reserved.
//

#import "SIXEditorImagePicker.h"

@interface SIXEditorImagePicker() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *pickerController;
@property (nonatomic, copy) void (^selectImage) (UIImage *);

@end

@implementation SIXEditorImagePicker

- (UIImagePickerController *)pickerController {
    if (_pickerController) return _pickerController;
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.allowsEditing = YES;
    pickerController.delegate = self;
    _pickerController = pickerController;
    return  pickerController;
}

- (void)showWithCompletion:(void (^)(UIImage *))completion {
    _selectImage = completion;
    UIViewController *rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootController presentViewController:self.pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = nil;
    if ([picker allowsEditing]){ //获取用户编辑之后的图像
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else { // 照片的元数据参数
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    _selectImage(image);
    _selectImage = nil;
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    _selectImage(nil);
    _selectImage = nil;
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

@end
