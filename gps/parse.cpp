#include <Keypad.h>

/**
 *  
 * 
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


