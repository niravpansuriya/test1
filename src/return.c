#include <stdlib.h>

int main(int argc, char * argv[]) {
	char * endptr = NULL;
	long ret = strtol(argv[1], &endptr, 10);
	return ret;
}
