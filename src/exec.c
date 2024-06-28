#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
	pid_t pid;
	pid = fork();
	if (pid == -1) 
		return 1;
	else if (pid == 0) {
		execvp(argv[1], argv+1);
	}
	int status;
	waitpid(pid,&status,0);
	if (WIFEXITED(status))
		return WEXITSTATUS(status);
	else if (WIFSIGNALED(status))
		return WTERMSIG(status);
	else
		return 0;
}

