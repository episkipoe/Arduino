#include <LiquidCrystal.h>
LiquidCrystal lcd(27, 26, 25, 24, 23, 22);

// Use pin 2 to control power to the GPS
#define powerpin 2

// Set the GPSRATE to the baud rate of the GPS module. Most are 4800
// but some are 38400 or other. Check the datasheet!
#define GPSRATE 4800
//#define GPSRATE 38400

// The buffer size that will hold a GPS sentence. They tend to be 80 characters long
// so 90 is plenty.
#define BUFFSIZ 90 // plenty big


// global variables
char buffer[BUFFSIZ];        // string buffer for the sentence
char *parseptr;              // a character pointer for parsing
char buffidx;                // an indexer into the buffer
// used for defining lat and long for distances
float deglon;
float minlon;
float deglat;
float minlat;
float lat1;
float lon1;
float lon2;
float lat2;
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
boolean time;
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
uint8_t hour, minute, second, year, month, date;
uint32_t latitude, longitude;
uint8_t groundspeed, trackangle;
char latdir, longdir;
char status;

void setup() 
{ 
  //define lcd
  lcd.begin(20, 4);
  //set menu starting point
  action = 10;
  menulevel = 'a';
  kill = true;
  //start without gathering
  getdate = false;
  time = false;
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
 
 
void loop() 
{ 
  uint32_t tmp;
  
  readline();
  
  // check if $GPRMC (global positioning fixed data)
  if (strncmp(buffer, "$GPRMC",6) == 0) {
    
    //if (time == true){
    // hhmmss time data
      parseptr = buffer+7;
      tmp = parsedecimal(parseptr); 
      hour = tmp / 10000;
      minute = (tmp / 100) % 100;
      second = tmp % 100;
    
    
      parseptr = strchr(parseptr, ',') + 1;
      status = parseptr[0];
      parseptr += 2;
 
    // grab latitude & long data
    // latitude
      latitude = parsedecimal(parseptr);
      if (latitude != 0) {
        latitude *= 10000;
        parseptr = strchr(parseptr, '.')+1;
        latitude += parsedecimal(parseptr);
      }
      parseptr = strchr(parseptr, ',') + 1;
    // read latitude N/S data
      if (parseptr[0] != ',') {
        latdir = parseptr[0];
      }
    
    //Serial.println(latdir);
    
    // longitude
      parseptr = strchr(parseptr, ',')+1;
      longitude = parsedecimal(parseptr);
      if (longitude != 0) {
        longitude *= 10000;
        parseptr = strchr(parseptr, '.')+1;
        longitude += parsedecimal(parseptr);
      }
      parseptr = strchr(parseptr, ',')+1;
    // read longitude E/W data
      if (parseptr[0] != ',') {
        longdir = parseptr[0];
      }

    // groundspeed
    parseptr = strchr(parseptr, ',')+1;
    groundspeed = parsedecimal(parseptr);

    // track angle
    parseptr = strchr(parseptr, ',')+1;
    trackangle = parsedecimal(parseptr);

    // date
      parseptr = strchr(parseptr, ',')+1;
      tmp = parsedecimal(parseptr); 
      date = tmp / 10000;
      month = (tmp / 100) % 100;
      year = tmp % 100;
    //}
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
  if (menulevel == 'a'){
    if (kill == true){
      kill = false;
      time = false;
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
    if (action == 1){
      lcd.clear();
      lcd.setCursor(0,0);
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
    if (action == 2){
      time = true;
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print(date,DEC);
      lcd.print("/");
      lcd.print(month,DEC);
      lcd.print("/");
      lcd.print(year,DEC);
      lcd.setCursor(0,1);
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
      //action = 12;
    }
    if (action == 3){
      menuchange('b');
      /*lcd.clear();
      lcd.print("Distance is:");
//Sets lat1 to degree strictly latitude degrees, although off by a factor of 10^6    
      deglat=(latitude/1000000);
      deglat=(deglat*1000000);
      minlat=(((latitude)%1000000));
      minlat=(minlat/0.6);
      lat1=(deglat+minlat);
      lat1=(lat1/1000000);
//Sets lon1 to degree strictly longitude degrees, although off by a factor of 10^6
      deglon=(longitude/1000000);
      deglon=(deglon*1000000);
      minlon=(((longitude)%1000000));
      minlon=(minlon/0.6);
      lon1=(deglon+minlon);
      lon1=(lon1/1000000);    
      lat2 = (41.689266);
      lon2 = (87.822672);
      calc_dist(lat1, lon1, lat2, lon2);
      lcd.setCursor(0,1);
      lcd.print(lat1);
      lcd.setCursor(0,2);
      lcd.print(lon1);
      */
      }
  }
  if (menulevel == 'b'){
    if (kill = true){
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
    }
    if (action == 1){
      menuchange('c');
    }
    if (action == 2){
      menuchange('e');
    }
  }
  if (menulevel == 'c'){
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
  if (menulevel == 'd'){
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
//Sets lat1 to degree strictly latitude degrees    
            deglat=(latitude/1000000);
            deglat=(deglat*1000000);
            minlat=(((latitude)%1000000));
            minlat=(minlat/0.6);
            lat1=(deglat+minlat);
            lat1=(lat1/1000000);
//Sets lon1 to degree strictly longitude degrees
            deglon=(longitude/1000000);
            deglon=(deglon*1000000);
            minlon=(((longitude)%1000000));
            minlon=(minlon/0.6);
            lon1=(deglon+minlon);
            lon1=(lon1/1000000);
            lat2=(lat2/1000000);
            lon2=(lon2/1000000);    
            calc_dist(lat1, lon1, lat2, lon2);
        }
      }
      
      
      if (action < 10){
        switch (count){
          case 0:
            lcd.print(action);
            lat2 = 0;
            lat2 = lat2 + action*10000000;
          break;
          case 1:
            lcd.print(action);
            lcd.print(".");
            lat2 = lat2 + action*1000000;
          break;
          case 2:
            lcd.print(action);
            lat2 = lat2 + action*100000;
          break;
          case 3:
            lcd.print(action);
            lat2 = lat2 + action*10000;
          break;
          case 4:
            lcd.print(action);
            lat2 = lat2 + action*1000;
          break;
          case 5:
            lcd.print(action);
            lat2 = lat2 + action*100;
          break;
          case 6:
            lcd.print(action);
            lat2 = lat2 + action*10;
          break;
          case 7:
            lcd.print(action);
            lat2 = lat2 + action;
            lcd.setCursor(5,3);
          break;
          case 8:
            lcd.print(action);
            lon2 = lon2 + action*10000000;
          break;
          case 9:
            lcd.print(action);
            lon2 = lon2 + action*1000000;
            lcd.print(".");
          break;
          case 10:
            lcd.print(action);
            lon2 = lon2 + action*100000;
          break;
          case 11:
            lcd.print(action);
            lon2 = lon2 + action*10000;
          break;
          case 12:
            lcd.print(action);
            lon2 = lon2 + action*1000;
          break;
          case 13:
            lcd.print(action);
            lon2 = lon2 + action*100;
          break;
          case 14:
            lcd.print(action);
            lon2 = lon2 + action*10;
          break;
          case 15:
            lcd.print(action);
            lon2 = lon2 + action;
          break;
        }
        action = 12;
        count = count + 1;
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
  if (menulevel == 'e'){
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
     //if (lat1 != 0){
//Sets lat1 to degree strictly latitude degrees
     deglat=(latitude/1000000);
     deglat=(deglat*1000000);
     minlat=(((latitude)%1000000));
     minlat=(minlat/0.6);
     lat1=(deglat+minlat);
     lat2=(lat1/1000000);
//Sets lon1 to degree strictly longitude degrees
     deglon=(longitude/1000000);
     deglon=(deglon*1000000);
     minlon=(((longitude)%1000000));
     minlon=(minlon/0.6);
     lon1=(deglon+minlon);
     lon2=(lon1/1000000);
     menuchange('f');
     //}
   }   
  } 
  if (menulevel == 'f')
  {
    if (action == 10){
      menuchange('b');
    }
      lcd.clear();
      lcd.print("Distance is:");
//Sets lat1 to degree strictly latitude degrees    
      deglat=(latitude/1000000);
      deglat=(deglat*1000000);
      minlat=(((latitude)%1000000));
      minlat=(minlat/0.6);
      lat1=(deglat+minlat);
      lat1=(lat1/1000000);
//Sets lon1 to degree strictly longitude degrees
      deglon=(longitude/1000000);
      deglon=(deglon*1000000);
      minlon=(((longitude)%1000000));
      minlon=(minlon/0.6);
      lon1=(deglon+minlon);
      lon1=(lon1/1000000);    
      calc_dist(lat1, lon1, lat2, lon2);
    }
}
}
/*************************************************************************
 * //Function to calculate the distance between two waypoints
 *************************************************************************/
float calc_dist(float flat1, float flon1, float flat2, float flon2)
{
  float dist_calc=0;
  float dist_calc2=0;
  float diflat=0;
  float diflon=0;

//I've to spplit all the calculation in several steps. If i try to do it in a single line the arduino will explode.
  diflat=radians(flat2-flat1);
  flat1=radians(flat1);
  flat2=radians(flat2);
  diflon=radians((flon2)-(flon1));

  dist_calc = (sin(diflat/2.0)*sin(diflat/2.0));
  dist_calc2= cos(flat1);
  dist_calc2*=cos(flat2);
  dist_calc2*=sin(diflon/2.0);
  dist_calc2*=sin(diflon/2.0);
  dist_calc +=dist_calc2;

  dist_calc=(2*atan2(sqrt(dist_calc),sqrt(1.0-dist_calc)));

  dist_calc*=6371000.0; //Converting to meters
  lcd.print((dist_calc));
  return dist_calc;
}

//Everything needed to change menus
char menuchange(char level){
  action = 12;
  kill = true;
  menulevel = level;
}

//see if I can get this to work?
/*
int setlatlon(){
//Sets lat1 to degree strictly latitude degrees    
    deglat=(latitude/1000000);
    deglat=(deglat*1000000);
    minlat=(((latitude)%1000000));
    minlat=(minlat/0.6);
    lat1=(deglat+minlat);
    lat1=(lat1/1000000);
//Sets lon1 to degree strictly longitude degrees
    deglon=(longitude/1000000);
    deglon=(deglon*1000000);
    minlon=(((longitude)%1000000));
    minlon=(minlon/0.6);
    lon1=(deglon+minlon);
    lon1=(lon1/1000000);
}
*/

uint32_t parsedecimal(char *str) {
  uint32_t d = 0;
  
  while (str[0] != 0) {
   if ((str[0] > '9') || (str[0] < '0'))
     return d;
   d *= 10;
   d += str[0] - '0';
   str++;
  }
  return d;
}

void readline(void) {
  char c;
  
  buffidx = 0; // start at begninning
  while (1) {
      c=Serial.read();
      if (c == -1)
        continue;
      if (c == '\n')
        continue;
      if ((buffidx == BUFFSIZ-1) || (c == '\r')) {
        buffer[buffidx] = 0;
        return;
      }
      buffer[buffidx++]= c;
  }
}
