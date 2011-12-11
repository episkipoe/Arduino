#include <LiquidCrystal.h>
LiquidCrystal lcd(27, 26, 25, 24, 23, 22);

#include "io.h"
#include "distance.h"
#include "parse.h"
#include "time.h"
#include "position.h"

// global variables
char buffer[BUFFSIZ];        // string buffer for the sentence

Position pos1;
Position pos2;

//used for coordinate input location
int count;
//used for menu position
char menulevel;
int action;
int cords;
//char level;
//char keytmp;
//Sets true or false for menu
boolean kill;
//streamline gathering?
boolean getdate;
boolean time_loaded;
boolean location;

#include <Keypad.h>
const byte ROWS = 4; //four rows
const byte COLS = 3; //three columns
char keys[ROWS][COLS] = {
	{'1','2','3'},
	{'4','5','6'},
	{'7','8','9'},
	{'*','0','#'}
};
byte rowPins[ROWS] = {41, 43, 45, 47}; //connect to the row pinouts of the keypad
byte colPins[COLS] = {49, 51, 53}; //connect to the column pinouts of the keypad

Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS );

// The time, date, location data, etc.
Time time;
Date date;
PositionData pos;

char status;

void setup() { 
	//define lcd
	lcd.begin(20, 4);
	//set menu starting point
	action = 10;
	menulevel = 'a';
	kill = true;
	//start without gathering
	getdate = false;
	time_loaded = false;
	location = false;
	if (powerpin) {
		pinMode(powerpin, OUTPUT);
	}

	// Use the pin 13 LED as an indicator
	pinMode(13, OUTPUT);

	// connect to the GPS at the desired rate
	Serial.begin(GPSRATE);

	digitalWrite(powerpin, LOW);         // pull low to turn on!
} 

void handleNumericInput() {
	switch (count){
		case 0:
			lcd.print(action);
			pos2.latitude = 0;
			pos2.latitude = pos2.latitude + action*10000000;
			break;
		case 1:
			lcd.print(action);
			lcd.print(".");
			pos2.latitude = pos2.latitude + action*1000000;
			break;
		case 2:
			lcd.print(action);
			pos2.latitude = pos2.latitude + action*100000;
			break;
		case 3:
			lcd.print(action);
			pos2.latitude = pos2.latitude + action*10000;
			break;
		case 4:
			lcd.print(action);
			pos2.latitude = pos2.latitude + action*1000;
			break;
		case 5:
			lcd.print(action);
			pos2.latitude = pos2.latitude + action*100;
			break;
		case 6:
			lcd.print(action);
			pos2.latitude = pos2.latitude + action*10;
			break;
		case 7:
			lcd.print(action);
			pos2.latitude = pos2.latitude + action;
			lcd.setCursor(5,3);
			break;
		case 8:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action*10000000;
			break;
		case 9:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action*1000000;
			lcd.print(".");
			break;
		case 10:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action*100000;
			break;
		case 11:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action*10000;
			break;
		case 12:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action*1000;
			break;
		case 13:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action*100;
			break;
		case 14:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action*10;
			break;
		case 15:
			lcd.print(action);
			pos2.longitude = pos2.longitude + action;
			break;
	}
	action = 12;
	count = count + 1;
}

void mainMenu() {
	if (kill == true){
		kill = false;
		time_loaded = false;
		lcd.clear();
		lcd.setCursor(0,0);
		lcd.print("Please Select One.");
		lcd.setCursor(0,1);
		lcd.print("1)Location");
		lcd.setCursor(0,2);
		lcd.print("2)Date And Time");
		lcd.setCursor(0,3);
		lcd.print("3)Distance");
	}
	switch(action) {
		case 1: 
			printPosition(lcd, pos);
			break;
		case 2:
			time_loaded = true;
			printDateAndTime(lcd, date, time);
			break;
		case 3:
			menuchange('b');
			break;
	}
}

void coordinateModeSelection() {
	if (kill == true){  
		kill = false;
		lcd.clear();
		lcd.print("Input Coordinates:");
		lcd.setCursor(0,1);
		lcd.print("1)Manual");
		lcd.setCursor(0,2);
		lcd.print("2)Automatic");
	}
	if (action == 10){
		menuchange('a');
	} else if (action == 1){
		menuchange('c');
	} else if (action == 2){
		menuchange('e');
	}
}

void showInputCoordinates() {
	if (kill == true){
		kill = false;
		lcd.clear();
		lcd.print("Input Coordinates:");
		lcd.setCursor(0,1);
		lcd.print("1)DD.DDDDDD");
		lcd.setCursor(0,2);
		lcd.print("2)DD MM.MMMM");
		lcd.setCursor(0,3);
		lcd.print("3)DD MM SS.SS");
	}
	if (action == 10){
		menuchange('b');
	}
	if (action == 1){
		cords = 1;
		menuchange('d');
	}
	if (action == 2){
		cords = 2;
		menuchange('d');
	}
	if (action == 3){
		cords = 3;
		menuchange('d');
	}
}

float calculateDistance() {
	//Sets lat1 to degree strictly latitude degrees    
	float deglat=(pos.latitude/1000000);
	deglat=(deglat*1000000);
	float minlat=(((pos.latitude)%1000000));
	minlat=(minlat/0.6);
	pos1.latitude=(deglat+minlat);
	pos1.latitude=(pos1.latitude/1000000);
	//Sets lon1 to degree strictly longitude degrees
	float deglon=(pos.longitude/1000000);
	deglon=(deglon*1000000);
	float minlon=(((pos.longitude)%1000000));
	minlon=(minlon/0.6);
	pos1.longitude=(deglon+minlon);
	pos1.longitude=(pos1.longitude/1000000);
	pos2.latitude=(pos2.latitude/1000000);
	pos2.longitude=(pos2.longitude/1000000);    
	return calc_dist(pos1, pos2);
}

void inputCoordinates() {
	//menulevel will go to f after
	if (cords == 1){
		//action = 11;
		if (kill == true){
			kill = false;
			lcd.clear();
			lcd.print("Enter DD.DDDDDD");
			lcd.setCursor(0,1);
			lcd.print("Press '#' when done");
			lcd.setCursor(0,2);
			lcd.print("Lat:");
			lcd.setCursor(0,3);
			lcd.print("Long:");
			lcd.setCursor(4,2);
			count = 0;
		}
		if (action == 10){
			menuchange('c');
		}
		if (action == 11){
			if (count >= 16){
				lcd.print("Distance is:");
				float dx = calculateDistance();
				lcd.print(dx);
			}
		}

		if (action < 10){
			handleNumericInput();	
		}
	}
	if (cords == 2){
		if (kill == true){
			kill = false;
			lcd.clear();
			lcd.print("Enter DD MM.MMMM");
			lcd.setCursor(0,1);
			lcd.print("Press '#' when done");
			lcd.setCursor(0,2);
			lcd.print("Lat:");
			lcd.setCursor(0,3);
			lcd.print("Long:");
		}
		if (action == 10){
			menuchange('c');
		}
		if (action < 10){
			lcd.print(action);
			action = 12;
		}
	}
	if (cords == 3){
		if (kill == true){
			kill = false;
			lcd.clear();
			lcd.print("Enter DD MM SS.SS");
			lcd.setCursor(0,1);
			lcd.print("Press '#' when done");
			lcd.setCursor(0,2);
			lcd.print("Lat:");
			lcd.setCursor(0,3);
			lcd.print("Long:");
		}
		if (action == 10){
			menuchange('c');
		}
		if (action < 10){
			lcd.print(action);
			action = 12;
		}
	}
}

void useCurrentLocation() {
	if (kill == true){
		kill = false;
		lcd.clear();
		lcd.print("Use current location");
		lcd.setCursor(0,1);
		lcd.print("Press '#'");
	}
	if (action == 10){
		menuchange('b');
	}
	if (action == 11){
		//Sets lat1 to degree strictly latitude degrees
		float deglat=(pos.latitude/1000000);
		deglat=(deglat*1000000);
		float minlat=(((pos.latitude)%1000000));
		minlat=(minlat/0.6);
		pos1.latitude=(deglat+minlat);
		pos2.latitude=(pos1.latitude/1000000);
		//Sets lon1 to degree strictly longitude degrees
		float deglon=(pos.longitude/1000000);
		deglon=(deglon*1000000);
		float minlon=(((pos.longitude)%1000000));
		minlon=(minlon/0.6);
		pos1.longitude=(deglon+minlon);
		pos2.longitude=(pos1.longitude/1000000);
		menuchange('f');
	}   
}

void distanceIs() {
	if (action == 10){
		menuchange('b');
	}
	lcd.clear();
	lcd.print("Distance is:");
	float dx = calculateDistance();
	lcd.print(dx);
}

void loadDataFromBuffer() {
	char *parseptr;              // a character pointer for parsing

	parseptr = buffer+7;
	time = getTimeFromBuffer(parseptr);

	parseptr = strchr(parseptr, ',') + 1;
	status = parseptr[0];
	parseptr += 2;

	// grab latitude & long data
	// latitude
	pos.latitude = parsedecimal(parseptr);
	if (pos.latitude != 0) {
		pos.latitude *= 10000;
		parseptr = strchr(parseptr, '.')+1;
		pos.latitude += parsedecimal(parseptr);
	}
	parseptr = strchr(parseptr, ',') + 1;
	// read latitude N/S data
	if (parseptr[0] != ',') {
		pos.latdir = parseptr[0];
	}

	//Serial.println(latdir);

	// longitude
	parseptr = strchr(parseptr, ',')+1;
	pos.longitude = parsedecimal(parseptr);
	if (pos.longitude != 0) {
		pos.longitude *= 10000;
		parseptr = strchr(parseptr, '.')+1;
		pos.longitude += parsedecimal(parseptr);
	}
	parseptr = strchr(parseptr, ',')+1;
	// read longitude E/W data
	if (parseptr[0] != ',') {
		pos.longdir = parseptr[0];
	}

	// groundspeed
	parseptr = strchr(parseptr, ',')+1;
	pos.groundspeed = parsedecimal(parseptr);

	// track angle
	parseptr = strchr(parseptr, ',')+1;
	pos.trackangle = parsedecimal(parseptr);

	// date
	parseptr = strchr(parseptr, ',')+1;
	date = getDateFromBuffer(parseptr);
}

void handleGlobalPositioningFixedData() {

	//define key globally?  
	char key = keypad.getKey();
	if (key != NO_KEY){
		if(key>='0'&&key<='9') action = key-'0';
		switch (key){
			case '*':
				if (action != 10){
					kill = true;
					action = 10;
				}
				break;
			case '#':
				action = 11;
				break;
		}
	}
	switch(menulevel) {
		case 'a':
			mainMenu();
			break;
		case 'b':
			coordinateModeSelection();
			break;
		case 'c':
			showInputCoordinates();		
			break;
		case 'd':	
			inputCoordinates();
			break;
		case 'e':
			useCurrentLocation();
			break;
		case 'f':
			distanceIs();
			break;
			
	}
}

/**
 * main program loop:  handle and process user input
*/
void loop() { 
	switch(getNextLine()) {
		case GPRMC:
			handleGlobalPositioningFixedData();
			break;
	}	
}

//Everything needed to change menus
char menuchange(char level){
	action = 12;
	kill = true;
	menulevel = level;
}


