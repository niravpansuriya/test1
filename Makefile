compilation: catchme
tests: tests	
	mkdir tests
	gcc -std=c17 -o catchme catchme.c
	gcc -Wno-div-by-zero -o tests/divzero src/divzero.c
	gcc -o tests/exec src/exec.c
	gcc -o tests/fork src/fork.c
	gcc -o tests/segv src/segv.c
	gcc -o tests/write src/write.c
	gcc -o tests/signal src/signal.c
	gcc -o tests/return src/return.c
	gcc -nostdlib -static -e debut -o tests/nostart src/nostart.c
public: catchme tests
	bats public.bats
clean:
	test -x catchme && rm catchme
	test -e ./tests && rm -fr ./tests
