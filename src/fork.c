#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

int main() {
	pid_t pid;
	pid = fork();
	if (pid == -1) 
		return 1;
	else if (pid == 0) {
		write(1, "fiston\n", 7);
		return 0;
	}
	waitpid(pid,0,0);
	write(1, "les deux\n", 9);
	return 7;
}

