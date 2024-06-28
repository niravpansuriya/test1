int ecrit(int fs, char* msg, long len)
	{ asm("mov $1, %rax; syscall"); }
int quitte(int code)
	{ asm("mov $60, %rax; syscall"); }

void debut(void) {
	ecrit(1, "Hello, World!\n", 14);
	quitte(0);
}
