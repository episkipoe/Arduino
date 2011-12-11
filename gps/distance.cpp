#include <Keypad.h>
#include "distance.h"

/*************************************************************************
 * //Function to calculate the distance between two waypoints
 *************************************************************************/
float calc_dist(Position & pos1, Position & pos2) {
	float dist_calc=0;
	float dist_calc2=0;
	float diflat=0;
	float diflon=0;

	//I've to split all the calculation in several steps. If i try to do it in a single line the arduino will explode.
	diflat=radians(pos2.latitude-pos1.latitude);
	pos1.latitude=radians(pos1.latitude);
	pos2.latitude=radians(pos2.latitude);
	diflon=radians((pos2.longitude)-(pos1.longitude));

	dist_calc = (sin(diflat/2.0)*sin(diflat/2.0));
	dist_calc2= cos(pos1.latitude);
	dist_calc2*=cos(pos2.latitude);
	dist_calc2*=sin(diflon/2.0);
	dist_calc2*=sin(diflon/2.0);
	dist_calc +=dist_calc2;

	dist_calc=(2*atan2(sqrt(dist_calc),sqrt(1.0-dist_calc)));

	dist_calc*=6371000.0; //Converting to meters
	return dist_calc;
}


