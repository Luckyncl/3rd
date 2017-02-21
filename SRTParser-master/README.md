SRTParser
=========

An SRT parser written in Objective-C.

This is a simple SRT Parser for iOS Projects, developed in Objective-C. It consists of three basic classes,
SRTParser, SRTSubtitle and SRTTime. For your convenience the classes are provided inside a sample project
that illustrates its usage.

Using the parser is easy. Simply conform your main Class to SRTParserDelegate and make sure you implement

- (void)parsingFinishedWithSubs:(NSArray *)subs

Then in your main Class's implementation create an SRTParser object and initialise it with the path to
the .srt file. Call 

- (void)parse 

on that object and wait for the delegate method to fire with the array of subs.
