//
//  ViewController.h
//  FindMyKeys
//
//  Created by Tim Wurman on 4/5/2014
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "BLE.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController<BLEDelegate>{
	BOOL armed;
}

@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *armAlarm;


@end
