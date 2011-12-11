// Use pin 2 to control power to the GPS
#define powerpin 2

// Set the GPSRATE to the baud rate of the GPS module. Most are 4800
// but some are 38400 or other. Check the datasheet!
#define GPSRATE 4800
//#define GPSRATE 38400

// The buffer size that will hold a GPS sentence. They tend to be 80 characters long
// so 90 is plenty.
#define BUFFSIZ 90 // plenty big


//Types of lines that can be read
#define UNRECOGNIZED 	-1
#define GPRMC  		0

