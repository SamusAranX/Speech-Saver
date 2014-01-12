//
//  AppDelegate.m
//  Speech Saver
//
//  Created by Peter Wunder on 09/01/14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSDocumentController *SpeechDocumentController;
@end
@implementation AppDelegate {
	NSSpeechSynthesizer* speechSynth;
	NSMutableDictionary* speechSynthVoices;
	__weak NSDocumentController *_SpeechDocumentController;
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
	speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]];
	[speechSynth setDelegate:self];
	[speechSynth setRate:200];
	
	speechSynthVoices = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *voiceReadableNames = [[NSMutableArray alloc] init];
	
	for (NSString* voice in [NSSpeechSynthesizer availableVoices]) {
		NSString* voiceName = [self getVoiceName:voice];
		voiceName = [voiceName capitalizedString];
		[voiceReadableNames addObject:voiceName];
		[speechSynthVoices setValue:voice forKey:voiceName];
	}
	[self.dVoicesPopUp addItemsWithTitles:voiceReadableNames];
	[self.speechOptionsDrawer setDelegate:self];
	
	[self.dVoicesPopUp selectItemWithTitle:[self getVoiceName:[NSSpeechSynthesizer defaultVoice]]];
}

- (IBAction)voiceSelected:(id)sender {
	NSString* selectedItem = [self.dVoicesPopUp selectedItem].title;
	[self selectVoice:selectedItem];
}

- (NSString*)getVoiceName:(NSString*)voiceIdentifier {
	NSArray* voiceNameComponents = [voiceIdentifier componentsSeparatedByString:@"."];
	NSUInteger voiceNameComponentCount = [voiceNameComponents count];
	NSString* voiceName = voiceNameComponents.lastObject;
	if ([voiceName isEqualToString: @"premium"] && voiceNameComponentCount >= 2) voiceName = voiceNameComponents[voiceNameComponentCount - 2];
	return [voiceName capitalizedString];
}
- (void)selectVoice:(NSString*)voiceName {
	NSString* voiceIdentifier = speechSynthVoices[voiceName];
	[speechSynth setVoice:voiceIdentifier];
}

- (IBAction)wpmChanged:(id)sender {
	float wordsPerMinute = self.dWordsPerMinuteSlider.floatValue;
	[self.dWordsPerMinuteLabel setStringValue:[NSString stringWithFormat:@"%.f words per minute", wordsPerMinute]];
	[speechSynth setRate:wordsPerMinute];
}
- (IBAction)volumeChanged:(id)sender {
	float volume = self.dVolumeSlider.floatValue;
	[self.dVolumeLabel setStringValue:[NSString stringWithFormat:@"Volume: %.f%%", volume]];
	[speechSynth setVolume:volume];
}
- (IBAction)startSpeaking:(id)sender {
	if ([speechSynth isSpeaking]) {
		[speechSynth stopSpeaking];
	} else {
		NSString* text;
		if ([self.speakTextView selectedRange].length > 0) {
			text = [self.speakTextView.string substringWithRange:[self.speakTextView selectedRange]];
		} else {
			text = self.speakTextView.string;
		}
		[speechSynth startSpeakingString:text];
	}
	[self.startStopSpeechButton setState:[speechSynth isSpeaking]];
}

- (IBAction)toggleVoiceOptions:(id)sender {
	[self.speechOptionsDrawer toggle:self];
}

// Open/Save methods

- (IBAction)openText:(id)sender {
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	NSArray* allowedFiles = @[@"txt", @"rtf"]; // Dunno what file types besides txt and rtf NSAttributedString supports, so I'll go with this
	
	NSInteger result = [self.SpeechDocumentController runModalOpenPanel:openPanel forTypes:allowedFiles]; //Was a file actually opened?
	if (result == YES) { // There is no data. There is only BOOL.
		[self openFile:[openPanel URL]];
	}
}
- (IBAction)saveSpeech:(id)sender {
	[speechSynth stopSpeaking];
	NSString* text = self.speakTextView.string;
	
	NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"aiff"]]; //only allow aiff because that's the only thing OS X's voices support
	NSURL* homeDirectory = [NSURL URLWithString:NSHomeDirectory()];
    [savePanel setDirectoryURL:homeDirectory]; //start save panel in
	
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [savePanel orderOut:self]; //close save panel
			
			[speechSynth startSpeakingString:text toURL:[savePanel URL]];
        }
    }];
}

- (void)openFile:(NSURL*)fileURL {
	[self.SpeechDocumentController noteNewRecentDocumentURL:fileURL];
	NSMutableAttributedString* fileContent = [[NSMutableAttributedString alloc] init];
	NSError* errors = nil;
	[fileContent readFromURL:fileURL options:nil documentAttributes:nil error:&errors];
	NSString* text = [fileContent string];
	[self.speakTextView setString:text];
}

// Delegate methods

-(void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking {
	[self.startStopSpeechButton setState:[speechSynth isSpeaking]];
}
-(NSSize)drawerWillResizeContents:(NSDrawer *)sender toSize:(NSSize)contentSize	{
	return [sender contentSize];
}

// Application delegate methods

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}
- (BOOL)application:(NSApplication *)application openFile:(NSString *)filename {
	[self openFile:[NSURL fileURLWithPath:filename]];
	return YES;
}

@end
