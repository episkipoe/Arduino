#include "position.h"

void printPosition(LiquidCrystal & lcd, PositionData & position) {
	lcd.clear();
	lcd.setCursor(0,0);
	position.print(lcd);
}
