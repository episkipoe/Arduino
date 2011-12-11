#ifndef TIME_H
#define TIME_H

#include <LiquidCrystal.h>

struct Time {
	uint8_t hour, minute, second;

	void print(LiquidCrystal & lcd) {
		if (hour <= 9){
			lcd.print("0");
			lcd.print(hour,DEC);
		}
		if (hour >= 10){
			lcd.print(hour,DEC);
		}
		lcd.print(":");
		if (minute <= 9){
			lcd.print("0");
			lcd.print(minute,DEC);
		}
		if (minute >= 10){
			lcd.print(minute,DEC);
		}
		lcd.print(":");
		if (second <= 9){
			lcd.print("0");
			lcd.print(second,DEC);
		}
		if (second >= 10){
			lcd.print(second,DEC);
		}
	}
};

struct Date {
	uint8_t year, month, date;
	void print(LiquidCrystal & lcd) {
		lcd.print(date,DEC);
		lcd.print("/");
		lcd.print(month,DEC);
		lcd.print("/");
		lcd.print(year,DEC);
	}
};

Time getTimeFromBuffer(char * buffer);
Date getDateFromBuffer(char * buffer);

void printDateAndTime(LiquidCrystal & lcd, Date & date, Time & time);

#endif

