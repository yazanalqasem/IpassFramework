//
//  RGLRecognizeConfig.h
//  DocumentReader
//
//  Created by Serge Rylko on 12.07.23.
//  Copyright © 2023 Regula. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DocumentReader/RGLBaseConfig.h>
#import "RGLMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@class RGLImageInput;

NS_SWIFT_NAME(DocReader.RecognizeConfig)
@interface RGLRecognizeConfig : RGLBaseConfig

/// This parameter processing an image that contains a person and a document and compare the portrait photo from the document with the person's face.
/// It works only in the single-frame processing, but not in the video frame processing.
/// Requires network connection.
/// Default: NO.
@property (nonatomic, assign) BOOL oneShotIdentification;

@property (nonatomic, readonly, strong, nullable) UIImage *image;
@property (nonatomic, readonly, strong, nullable) NSData *imageData;
@property (nonatomic, readonly, strong, nullable) NSArray <UIImage *> *images;
@property (nonatomic, readonly, strong, nullable) NSArray <RGLImageInput *> *imageInputs;

RGL_EMPTY_INIT_UNAVAILABLE

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImageData:(NSData *)imageData;
- (instancetype)initWithImages:(NSArray <UIImage *> *)images;
- (instancetype)initWithImageInputs:(NSArray <RGLImageInput *> *)imageInputs;

@end

NS_ASSUME_NONNULL_END
