//
//  ViewController.m
//  FindMyKeys
//
//  Created by Tim Wurman on 4/5/2014
//

#import "ViewController.h"

@interface ViewController ()


@end



@implementation ViewController{
    
}

@synthesize ble;

- (void)viewDidLoad
{
	
    ble = [[BLE alloc]init];
    [ble controlSetup:1];
    ble.delegate = self;
    armed = false;

	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sendArming {
    printf("sending data to board\n");
	if([ble isConnected]){
		
        UInt8 buf[1] = {0x01};
        NSData *d = [[NSData alloc]initWithBytes:buf length:1];
        [ble write:d];
		
        [_armAlarm setTitle:@"Disarm" forState:UIControlStateNormal];
        armed = true;
    }
}

- (IBAction)sendDisarming {
    printf("sending data to board\n");
    if([ble isConnected]){
        
        UInt8 buf[1] = {0x00};
        NSData *d = [[NSData alloc]initWithBytes:buf length:1];
        [ble write:d];
        
        [_armAlarm setTitle:@"Arm" forState:UIControlStateNormal];
        armed = false;
    }
}

- (IBAction)armAlarm:(id)sender {
	
    //check if password is correct
    //send arming signal
    if([ble isConnected] && !armed){
        [self sendArming];
    } else if([ble isConnected] && armed) {
        [self sendDisarming];
    } else {
        [self scanForPeripherals];
    }
}



#pragma mark - BLEDelegate
-(void)bleDidConnect{

}

-(void)bleDidDisconnect{
    
}

-(void)bleDidReceiveData:(unsigned char *)data length:(int)length{
    
    if(data[0] == 0x00){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Computer Under Attack!" message:@"Beware! Your computer might be getting stolen!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        //alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}

-(void)bleDidUpdateRSSI:(NSNumber *)rssi{
	//do nothing
}

#pragma mark - BLE Actions
-(void)scanForPeripherals{
	[self disconnectFromPeripheral];
	
    if(ble.peripherals){
        ble.peripherals = nil;
    }
    
    [ble findBLEPeripherals:2];
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}

-(void)disconnectFromPeripheral{
     //this seems like its for disconnecting...
     if(ble.activePeripheral){
         if (ble.activePeripheral.isConnected) {
             [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
         
         }
     }
}

-(void)connectionTimer:(NSTimer*)timer{
	
	
    if(ble.peripherals.count > 0){
		
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
		[NSTimer scheduledTimerWithTimeInterval:(float)300.0 target:self selector:@selector(disconnectTimer:) userInfo:nil repeats:NO];
        
    } else {
        
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Device not in range" message:@"Could not connect to device. Must be within 100ft of your location" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		//alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		[alert show];
    }
    
}

-(void)disconnectTimer:(NSTimer*)timer{
	if (ble.activePeripheral.isConnected) {
		[self disconnectFromPeripheral];
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Disconnected From Device" message:@"Press Retry to Reconnect" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		//alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		[alert show];
		
	} else {
		//not working properly
		[timer invalidate];
	}
	
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
////    currentLocation = [locations objectAtIndex:0];
////    [locationManager stopUpdatingLocation];
////    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
////    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
////     {
////         if (!(error))
////         {
////             CLPlacemark *placemark = [placemarks objectAtIndex:0];
////             NSLog(@"\nCurrent Location Detected\n");
////             NSLog(@"placemark %@",placemark);
////             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
////             NSString *Address = [[NSString alloc]initWithString:locatedAt];
////			 
////			 //get time
////			 NSDate *today = [NSDate date];
////			 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
////			 // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
////			 [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
////			 [dateFormatter setDateStyle:NSDateFormatterShortStyle];
////			 NSString *currentDate = [dateFormatter stringFromDate:today];
////			 
////			 NSString *lastSeen = [NSString stringWithFormat:@"Last Seen:\n%@\n%@", currentDate, Address];
////			 self.locationLabel.text = lastSeen;
////			 
////			 //store last location
////			 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////			 NSString *location = self.locationLabel.text;	//change to address
////			 [defaults setObject:Address forKey:@"lastLocation"];
////			 [defaults setObject:currentDate forKey:@"lastTime"];
////			 //[defaults setObject:placemark forKey:@"placeMark"];
////			 NSLog(@"Logging location: \n%@\n",location);
////			 [defaults synchronize];
////
////         }
////         else
////         {
////             NSLog(@"Geocode failed with error %@", error);
////             NSLog(@"\nCurrent Location Not Detected\n");
////             //return;
////         }
////		 
////     }];
//}
//
//-(void)CurrentLocationIdentifier
//{
//    //---- For getting current gps location
////    locationManager = [CLLocationManager new];
////    locationManager.delegate = self;
////    locationManager.distanceFilter = kCLDistanceFilterNone;
////    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
////    [locationManager startUpdatingLocation];
//    //------
//}

@end
