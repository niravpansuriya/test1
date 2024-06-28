# Aide pour les tests bats

# Comme il y a de la concurence et des risques de blocages le setup et teardown 
# sont un peu compliqués car il faut préparer des mecanises de timout er nettoyer 
# du mieux possible les processus qui s'echappent.
# De plus, les versions < 1.0.0 de bats échouent et bloquent sur des tests.

check() {
	res=0
	if [ "$status" != "$1" ]; then
		echo "Test échoué: le code de retour est $status ; $1 était attentu"
		echo "La sortie est:"
		echo "$output"
		res=1
	fi
	sortie="$(echo $output | xargs)"
	if [ "$sortie" != "$2" ]; then
		echo "Test échoué: la sortie inattendue est"
		echo "$sortie"
		echo ""
		echo "Le diff est"
		diff -Z -B -u <(echo "$2") <(echo "$sortie")
		res=2
	fi

	return "$res"
}

checki() {
	out=`cat`
	sortie="$(echo $out | sed 's/[[:blank:]]$//g' | sed 's/^[[:blank:]]//g')"
	check "$1" "$sortie"
}

setup() {
	test -d out/ && rm -r out/
	mkdir -p out
}

teardown() {
	kill %% 2> /dev/null
	pchild=`pgrep -s 0 sleep`
	kill $pchild 2> /dev/null
	test -d out/ && rm -r out/
	true
}

