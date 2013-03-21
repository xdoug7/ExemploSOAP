//
//  ViewController.h
//  ExemploSOAP
//
//  Created by Douglas on 3/20/13.
//  Copyright (c) 2013 Douglas Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSXMLParserDelegate>

- (IBAction)calcularTemperatura:(UIButton *)sender;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *grausTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *temperaturaSegControl;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *resultadoLabel;

@end
