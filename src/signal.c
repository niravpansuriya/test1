#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>

int main(int argc, char * argv[]) {
	char * endptr = NULL;
	long sig = strtol(argv[1], &endptr, 10);
	pid_t ppid = getppid();
	kill(ppid, sig);
	return 0;
}
