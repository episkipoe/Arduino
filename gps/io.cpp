#include <Keypad.h>
#include "io.h"

extern char buffer[];

void readline(void) {
	char c;

	char buffidx = 0; // start at begninning
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

int getNextLine() {
	readline();
	if (!strncmp(buffer, "$GPRMC",6)) return GPRMC; 
	return UNRECOGNIZED;
}



