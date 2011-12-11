#ifndef POSITION_H
#define POSITION_H

#include <LiquidCrystal.h>

/**
 *  Raw position data read from the Arduino
*/
struct PositionData {
	uint32_t latitude, longitude;
	uint8_t groundspeed, trackangle;
	char latdir, longdir;

	void print(LiquidCrystal & lcd) {
		lcd.print("Lat");
		lcd.setCursor(0,1);
		if (latdir == 'N')
			lcd.print("+");
		else if (latdir == 'S')
			lcd.print("-");
		//Prints latitude
		lcd.print(latitude/1000000, DEC); lcd.print("* ");
		lcd.print((latitude/10000)%100, DEC); lcd.print('\''); lcd.print(' ');
		lcd.print((latitude%10000)*6/1000, DEC); lcd.print(".");
		lcd.print(((latitude%10000)*6/10)%100, DEC); lcd.print('"');
		//Prints longitude
		lcd.setCursor(0,2);
		lcd.print("Long");
		lcd.setCursor(0,3);
		if (longdir == 'E')
			lcd.print("+");
		else if (longdir == 'W')
			lcd.print("-");
		lcd.print(longitude/1000000, DEC); lcd.print("* ");
		lcd.print((longitude/10000)%100, DEC); lcd.print('\''); lcd.print(' ');
		lcd.print((longitude%10000)*6/1000, DEC); lcd.print('.');
		lcd.print(((longitude%10000)*6/10)%100, DEC); lcd.print('"');
		//action = 12;
	}
};

void printPosition(LiquidCrystal & lcd, PositionData & position);

struct Position {
	float latitude, longitude;
};

#endif


