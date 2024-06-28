#!/usr/bin/env bats

load test_helper

@test "test-1" {
	run ./catchme
	check 1 ""
}

@test "test-2" {
	run bash -c "./catchme tests/nostart > /dev/null"
	check 0 "234 14 59 1 60"
}

@test "test-3" {
	run ./catchme true
	check 0 "234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 231"
}

@test "test-4" {
	run ./catchme false
	check 1 "234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 231"
}

@test "test-5" {
	run ./catchme tests/return 77
	check 77 "234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 231"
}

@test "test-6" {
	run bash -c "./catchme ls > /dev/null"
	check 0 "234 14 59 12 158 9 21 257 4 5 3 0 10 17 11 218 273 13 302 137 16 217 1 231"
}

@test "test-7" {
	run ./catchme tests/write
	check 3 "234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 1 231"
}

@test "test-8" {
	run ./catchme tests/divzero
	check 136 "234 14 59 12 158 9 21 257 4 5 3 0 17 10 11"
}

@test "test-9" {
	run ./catchme tests/segv
	check 139 "234 14 59 12 158 9 21 257 4 5 3 0 17 10 11"
}

@test "test-10" {
	run ./catchme tests/exec true
	checki 0 <<FIN
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 56 61 231 
56 59 12 158 9 21 257 4 5 3 0 17 10 11 231
FIN
}

@test "test-11" {
	run ./catchme tests/exec false
	checki 1 <<FIN
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 56 61 231 
56 59 12 158 9 21 257 4 5 3 0 17 10 11 231
FIN
}

@test "test-12" {
	run ./catchme tests/exec tests/return 7
	checki 7 <<FIN
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 56 61 231 
56 59 12 158 9 21 257 4 5 3 0 17 10 11 231
FIN
}

@test "test-13" {
	run ./catchme tests/exec tests/signal 15
	checki 143 <<FIN
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 56 61 
56 59 12 158 9 21 257 4 5 3 0 17 10 11 110 62 231
FIN
}

@test "mem-1" {
	run valgrind --tool=memcheck --quiet --trace-children=yes --error-exitcode=99 ./catchme
	check 1 ""
}

@test "mem-2" {
	run valgrind --tool=memcheck --quiet --trace-children=yes --error-exitcode=99 bash -c "./catchme true 2> /dev/null"
	check 0 ""
}

@test "mem-3" {
	run valgrind --tool=memcheck --quiet --trace-children=yes --error-exitcode=99 bash -c "./catchme false 2> /dev/null"
	check 1 ""
}

