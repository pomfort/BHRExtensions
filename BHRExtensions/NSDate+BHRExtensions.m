//
//  NSDate+BHRExtensions.m
//  BHRExtensions
//
//  Created by Benedikt Hirmer on 3/6/14.
//  Copyright (c) 2014 HIRMER.me. All rights reserved.
//

#import "NSDate+BHRExtensions.h"

@implementation NSDate (BHRExtensions)

- (NSString *)shortDateAndTimeWithSecondsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;

    return [dateFormatter stringFromDate:self];
}

- (NSString *)shortDateAndTimeString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	dateFormatter.dateStyle = NSDateFormatterShortStyle;
	dateFormatter.timeStyle = NSDateFormatterShortStyle;
	
	return [dateFormatter stringFromDate:self];
}

- (NSString *)shortDateAndTimeStringForFilename
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd_HH-mm-ss"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)shortRelativeDateString
{
    NSComparisonResult result = [[NSDate today] compare:self];
    NSDateFormatter *relativeDateFormatter = [[NSDateFormatter alloc] init];
    relativeDateFormatter.doesRelativeDateFormatting = YES;

    if (result != NSOrderedDescending)
    {
        relativeDateFormatter.timeStyle = NSDateFormatterShortStyle;
        relativeDateFormatter.dateStyle = NSDateFormatterNoStyle;
    }
    else
    {
        relativeDateFormatter.dateStyle = NSDateFormatterShortStyle;
        relativeDateFormatter.timeStyle = NSDateFormatterNoStyle;
    }

    return [relativeDateFormatter stringFromDate:self];
}

+ (NSDate *)today
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
										  fromDate:[NSDate date]];
	
	[components setHour:-[components hour]];
	[components setMinute:-[components minute]];
	[components setSecond:-[components second]];
	NSDate *today = [cal dateByAddingComponents:components
										 toDate:[NSDate date]
										options:0];

	return today;
}

+ (NSDate *)yesterday
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
										  fromDate:[NSDate date]];
	
	[components setHour:-24];
	[components setMinute:0];
	[components setSecond:0];
	NSDate *yesterday = [cal dateByAddingComponents:components
											 toDate:[self today]
											options:0];
	return yesterday;
}


+ (NSDate *)thisWeek
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
										  fromDate:[NSDate date]];
	
	[components setDay:([components day] - ([components weekday] - 1))];
	NSDate *thisWeek  = [cal dateFromComponents:components];

	return thisWeek;
}


+ (NSDate *)lastWeek
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
										  fromDate:[self thisWeek]];
	
	[components setDay:([components day] - 7)];
	NSDate *lastWeek  = [cal dateFromComponents:components];

	return lastWeek;
}

+ (NSDate *)last7Days
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
										  fromDate:[NSDate date]];
	
	[components setDay:([components day] - 7)];
	NSDate *lastWeek  = [cal dateFromComponents:components];
	
	return lastWeek;
}

+ (NSDate *)thisMonth
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
										  fromDate:[NSDate date]];
	
	[components setDay:([components day] - ([components day] -1))];
	NSDate *thisMonth  = [cal dateFromComponents:components];
	
	return thisMonth;
}

+ (NSDate *)lastMonth
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
										  fromDate:[self thisMonth]];
	
	[components setMonth:([components month] - 1)];
	NSDate *lastMonth  = [cal dateFromComponents:components];
	
	return lastMonth;
}

//2010-11-26T07:35:55.000000Z
- (NSString *)ISO8601FRACXMLString
{
	NSDateFormatter* formatter = [[self class] _XMLDateFormatter];
	return [formatter stringFromDate:self];
}

+ (NSDate *)dateWithISO8601FRACXMLString:(NSString *)XMLString
{
	NSDateFormatter* formatter = [[self class] _XMLDateFormatter];
	return [formatter dateFromString:XMLString];
}

+ (NSDateFormatter *)_XMLDateFormatter
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = [NSString stringWithFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXX"];
	return formatter;
}

@end
