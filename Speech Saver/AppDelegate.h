//
//  AppDelegate.h
//  Speech Saver
//
//  Created by Peter Wunder on 09/01/14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSSpeechSynthesizerDelegate, NSDrawerDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *speakTextView;
@property (weak) IBOutlet NSButton *startStopSpeechButton;
@property (weak) IBOutlet NSDrawer *speechOptionsDrawer;

//Drawer stuff
@property (weak) IBOutlet NSSlider *dWordsPerMinuteSlider;
@property (weak) IBOutlet NSTextField *dWordsPerMinuteLabel;
@property (weak) IBOutlet NSSlider *dVolumeSlider;
@property (weak) IBOutlet NSTextField *dVolumeLabel;
@property (weak) IBOutlet NSPopUpButton *dVoicesPopUp;


@end
