//
//  Macro.h
//  Funfacts
//
//  Created by Jeethu on 11/04/14.
//  Copyright (c) 2014 QWERTYUIOP. All rights reserved.
//

#ifndef Funfacts_Macro_h
#define Funfacts_Macro_h

#define k_DeviceTypeIsIphone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define k_DeviceTypeIsIpad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define k_DeviceIsIphone5 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0)
#define k_DeviceWidth [UIScreen mainScreen].bounds.size.width
#define k_DeviceHeight [UIScreen mainScreen].bounds.size.height


#define k_n_facts @"facts"
#define k_n_jokes @"jokes"
#define k_n_twisters @"twisters"

#endif
