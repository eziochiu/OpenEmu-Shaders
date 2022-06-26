//
//  ViewController.m
//  shaderDemo
//
//  Created by Ezio Chiu on 2022/6/26.
//  Copyright © 2022 OpenEmu. All rights reserved.
//

#import "ViewController.h"
#import <OpenEmuShaders/OpenEmuShaders.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    OEFilterChain *emu = [[OEFilterChain alloc] initWithDevice:MTLCreateSystemDefaultDevice()];
    NSString *path = @"/Users/eziochiu/Downloads/scalehq/4xScaleHQ.slangp";
    NSURL *urlPath = [NSURL fileURLWithPath:path];
    ShaderCompilerOptions *options = [[ShaderCompilerOptions alloc] init];
    options.cacheDir = [NSURL URLWithString:@"/Users/eziochiu/Downloads/scalehq"];
    [emu setShaderFromURL:urlPath options:options error:NULL];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
