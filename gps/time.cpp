#include "time.h"
#include "parse.h"

Time getTimeFromBuffer(char * buffer) {
	Time time;
	// hhmmss time data
	uint32_t tmp = parsedecimal(buffer); 
	time.hour = tmp / 10000;
	time.minute = (tmp / 100) % 100;
	time.second = tmp % 100;
	return time;
}

Date getDateFromBuffer(char * buffer) {
	Date date;
	uint32_t tmp = parsedecimal(buffer); 
	date.date = tmp / 10000;
	date.month = (tmp / 100) % 100;
	date.year = tmp % 100;
	return date;
}

void printDateAndTime(LiquidCrystal & lcd, Date & date, Time & time) {
	lcd.clear();
	lcd.setCursor(0,0);
	date.print(lcd);
	lcd.setCursor(0,1);
	time.print(lcd);
}
