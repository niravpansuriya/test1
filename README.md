# TP1 - `catchme`

L'objectif du TP1 est de développer l'utilitaire `catchme` qui lance une ligne de commande et capte tous les appels système fait par cette commande.

## Description de l'outil

```
catchme LIGNE_COMMANDES
```
L'utilitaire `catchme` prend au moins un paramêtre : une ligne de commande _shell_ à exécuter, avec éventuellement une ou plusieurs options.

`catchme` va créer un processus fils `P` et effectuer les actions suivantes.
- Lancer la `LIGNE_COMMANDES` dans le processus fils `P`.
- Capter les numéros des appels système dans l'ordre dans lequel ils ont été effectués par la `LIGNE_COMMANDES` du processus fils  `P`;
  - si le processus fils `P` lance à son tour des processus enfants, `catchme` va récursivement les suivre et également capter leur appels système.
- Attendre la fin du processus fils `P`.
- Une fois que le processus `P` est terminé, `catchme` va effectuer les actions suivantes,
  - afficher les appels système fait par `P` un par un, séparé par un espace et dans l'ordre dans lequel ils ont été effectués;
  - s'il y a des processus fils lancé par `P`, `catchme` va également afficher la liste de leur appels système dans le même format, un processus par ligne et dans l'ordre de leur création;
  - si le fils `P` s'est terminé normalement, `catchme` va retourner la valeur retournée par `P`;
  - si le fils `P` s'est terminé à cause d'un signal reçu, `catchme` va retourner `128 +` le numéro du signal;
  - attention, pour la valeur retournée, `catchme` ne considère que le premier processus fils `P`. Si ce dernier lance des processus fils, `catchme` ne s'intéressera pas à leur valeur retournée ni aux signaux qu'ils recevront, `catchme` s'intéressera uniquement à leur appels système. 

Voir des exemples d'exécution dans la section **Exemples** plus bas.

### Fonctionnement

`catchme` va lancer une surveillance sur tous les appels système effectués par le processus fils exécutant `LIGNE_COMMANDES` ou n'importe quel processus créé récursivement par un processus dans `LIGNE_COMMANDES`.

#### Cas 1 : `LIGNE_COMMANDES` ne lance aucun processus fils

C'est le cas basique de fonctionnement de `catchme`.
Dans ce cas on a les comportements suivants.
- `catchme` va créer un processus fils dans lequel `LIGNE_COMMANDES` sera exécutée.
- `catchme` va surveiller les évenements portant sur les appels système fait par son processus fils.
- Chaque appel système effectué par le processus fils, sera capté et son numéro sauvegardé.
  - Chaque numéro d'appel système sera sauvegardé une seule fois, même si le processus fils l'effectue plusieurs fois.
  - Les appels système sont sauvegardés dans l'ordre dans lequel ils ont été effectués.
- Une fois que le processus fils s'est terminé, 
  - `catchme` affiche, les numéros des appels système sur la même ligne, séparés par un espace et dans l'ordre dans lequel ils ont été effectués;
  - `catchme` va récupérer la valeur retournée par son processus fils et la retourner à son tour;
  - si le processus fils a été terminé par un signal, `catchme` va retourner `128 +` le numéro du signal.

#### Cas 2 : `LIGNE_COMMANDES` lance un ou plusieurs processus fils

Dans ce cas `catchme`, va effectuer toutes les tâches du **Cas 1**, en plus de surveiller les appels système des processus fils lancés par `LIGNE_COMMANDES`. 
Donc en plus du comportement du **Cas 1**, `catchme` va avoir les comportements suivants.
- `catchme` va surveiller **récursivement** les évenements portant sur les appels système fait par tous les processus fils lancés par `LIGNE_COMMANDES`.
- Chaque appel système effectué par un des processus fils de `LIGNE_COMMANDES`, sera capté et son numéro sauvegardé. De même que le **Cas 1**.
  - Chaque numéro d'appel système sera sauvegardé une seule fois, même si le processus l'effectue plusieurs fois.
  - Les appels système sont sauvegardés dans l'ordre dans lequel ils ont été effectués.
  - À la fin de l'exécution, `catchme` va afficher, pour chaque processus lancé par `LIGNE_COMMANDES`, les numéros des appels système sur la même ligne, séparés par un espace et dans l'ordre dans lequel ils ont été effectués.

### Traitement des erreurs et valeur de retour

L'utilitaire `catchme` **n'affiche aucun message d'erreur** et retourne les valeurs suivantes.

- Pour tout problème lié au traitement des paramètres d'entrée de l'utilitaire, `catchme` retourne **1**.
  - Le seul cas à traiter est celui où aucun paramètre n'est fournit pour lancer `catchme`.
- Si un appel système échoue, `catchme` doit s'arrêter immédiatement et la valeur **2** doit être retournée, **sans aucun affichage**.
- Sinon, `catchme` va retourner les valeurs suivantes,
  - la même valeur que son **premier processus fils** s'il s'est terminé normalement,
  - ou `128 +` le numéro du signal, son **premier processus fils** s'est terminé avec un signal.

### Exemples

<p>

<details>

<summary>Exemple 1</summary>
<pre>
<b>iam@groot:~/TP1$</b> ./catchme
<b>iam@groot:~/TP1$</b> echo $?
1
<b>iam@groot:~/TP1$</b> ./catchme true
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 231
<b>iam@groot:~/TP1$</b> echo $?
0
<b>iam@groot:~/TP1$</b> ./catchme false
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 231
<b>iam@groot:~/TP1$</b> echo $?
1
<b>iam@groot:~/TP1$</b> cat src/segv.c 
#include <stddef.h>
int main(int argc, char *argv[]) {
	int *i = NULL; 
	return *i;
}
<b>iam@groot:~/TP1$</b> gcc -std=c17 src/segv.c -o tests/segv
<b>iam@groot:~/TP1$</b> ./catchme tests/segv
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11
<b>iam@groot:~/TP1$</b> echo $?
139
</pre>

</details>

</p>

<p>

<details>

<summary>Exemple 2</summary>
<pre>
<b>iam@groot:~/TP1$</b> gcc -std=c17 src/exec.c -o tests/exec
<b>iam@groot:~/TP1$</b> ./catchme tests/exec false
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 56 61 231 
56 59 12 158 9 21 257 4 5 3 0 17 10 11 231
<b>iam@groot:~/TP1$</b> echo $?
1
<b>iam@groot:~/TP1$</b> gcc -std=c17 src/segv.c -o tests/segv
<b>iam@groot:~/TP1$</b> ./catchme tests/exec tests/segv
234 14 59 12 158 9 21 257 4 5 3 0 17 10 11 56 61 231 
56 59 12 158 9 21 257 4 5 3 0 17 10 11
<b>iam@groot:~/TP1$</b> echo $?
11
</pre>

</details>

</p>

## Directives d'implémentation

Vous devez développer le programme en C.
Le fichier source doit s'appeler `catchme.c` et doit être à la racine du dépôt.
Vu la taille du projet, tout doit rentrer dans ce seul fichier source.

Pour la réalisation du TP, vous devez respecter les directives suivantes.


### Appels système

**Vous devez utiliser** les appels système suivants.

- `fork` pour créer un nouveau processus et l'appel système `execve` pour le recouvrement.
  - Vous pouvez également utiliser l'une des fonctions de librairies `execl`, `execlp`, `execle`, `execv` ou `execvp` pour le recouvrement.
- `wait` ou `waitpid` pour surveiller les processus enfants.
  - Vous devez également utiliser leur macro pour récupérer les informations communiquées par le système d'exploitation.
- `ptrace` pour surveiller des processus enfants (voir plus bas pour plus d'explications).
- Noubliez pas de traiter les erreurs de chaque appel système, s'il y a lieu.

### Appel système `ptrace`

L'appel système principal que vous devez utiliser est `ptrace`.
C'est un appel système bas niveau offert par le noyau Linux (et la plupart des systèmes Unix) qui sert à implémenter les débogueurs (comme `gdb`) ou d'autres outils comme `strace`.
C'est un appel système qui fait beaucoup de choses et est assez complexe.
Dans le cadre du TP on reste à une utilisation très superficielle de `ptrace`.

`ptrace` est un appel système très puissant, car il permet à un processus de prendre le contrôle d'un autre processus, y compris sa mémoire et le code machine qu'il exécute.

La logique principale de `ptrace` c'est que le processus surveillé (*ptracé* ou *observé*) s'exécute normalement jusqu'à ce qu'il se passe un événement particulier (réception d'un signal, appel système, etc.).
À ce moment-là, le processus surveillé passe dans un état bloqué particulier (*ptrace stopped*) qui apparait sous un `t` avec la commande `ps`.

Le processus qui surveille (le *traceur*) est notifié que le tracé est arrêté avec l'appel système `wait`.
Plutôt que de créer un appel système dédié, les concepteurs ont réutilisé cet appel système, ce qui peut être déroutant.

#### Directives d'utilisation de ptrace

Dans le cadre du TP, seul le sous-ensemble suivant des requêtes `ptrace` devra être utilisé

- `PTRACE_TRACEME` pour tracer la commande.
- `PTRACE_SETOPTIONS` avec les flags `PTRACE_O_EXITKILL` et `PTRACE_O_TRACEFORK`.
- `PTRACE_GETREGS` pour récupérer les valeurs des registres y compris celle du registre.
  - En particulier le registre `RAX` qui contiendra, lors d'un appel système, le numéro de l'appel système utilisé à l'appel et la valeur retourné à la fin. Vous aurez besoin d'une structure `struct user_regs_struct` pour récupérer cette valeur.
  - Attention, ça fonctionne seulement sur des processeurs avec l'architecture `x86_64`.
- `PTRACE_SYSCALL` pour que le processus qui surveille soit prévenu à chaque début ou fin d'un appel système des processus surveillés et faire continuer l'exécution du processus surveillé stoppé.

Pour déterminer le chemin des exécutables, consultez `/proc/PID/exe` avec l'appel système `readlink`.
Avec `PTRACE_O_TRACEEXEC`, le processus surveillé est stoppé après que l'exécutable a été chargé (et donc `/proc/PID/exe` est celui du nouvel exécutable).

Voici quelques conseils pour réussir à développer ce programme.

- Lisez la page de manuel de `ptrace`. Elle est dense et tout ne vous sera pas utile, mais il ne faut pas ignoner les parties qui le seront.
- Évitez les documentations tierces (forum, blog, projets gitbug, etc.) qui contiennent beaucoup d'imprécisions voire de bêtises.
- Commencez par votre développement avec `PTRACE_O_EXITKILL` et ajoutez `PTRACE_O_TRACEFORK` dans un second temps.
- Attention, `PTRACE_TRACEME` ne stoppe pas l'appelant, vous pouvez donc faire `raise(SIGSTOP);` juste après (RTFM pour les détails)
- Attention, remettez le signal éventuel dans `PTRACE_SYSCALL` (RTFM pour les détails).
- [Lisez](https://twitter.com/jcsrb/status/1392459191353286656) la [page](https://xkcd.com/293/) de [manuel](https://www.commitstrip.com/en/2015/06/29/as-the-last-resort/) de [`ptrace`](https://manpages.debian.org/buster/manpages-dev/ptrace.2.en.html).

### Précisions

- `catchme` doit surveiller récursivement tous les processus enfants.
- Vous devez compléter le fichier `catchme.c`.
  - **Vous n'avez pas le droit d'ajouter** d'autres directives `#include`.
- Mis à part l'utilisation des appels système cités plus haut qui est obligatoire, vous pouvez utiliser n'importe quelle fonction des librairies standard du C déjà incluses.
- Comme le TP n'est pas si gros (de l'ordre de grandeur d'une centaine de lignes), il est attendu un effort important sur le soin du code et la gestion des cas d'erreurs.

## Acceptation et remise du TP

### Remise

La remise s'effectue sur [Moodle](https://ena01.uqam.ca/course/view.php?id=64167), il n'y a que le fichier `catchme.c` que vous devez remettre. 
Vous pouvez faire plusieurs remises (déposer votre TP), seule la remise qui sera « **Envoyer** » sera considérée. 
La date de remise est le **dimanche 30 juin à 23h55**.

### Tests

Vouz pouvez compiler avec `make` (le `Makefile` est fourni).

Vous pouvez vous familiariser avec le contenu du dépôt, en étudiant chacun des fichiers (`README.md`, `Makefile`, `*.bats`, etc.).

La vérification locale de ce TP a peu de chance de fonctionner. 
En effet, dépendamment du système d'exploitation (vieux ou plus récent), parfois il y a des appels système qui se traduisent différemment d'un système à l'autre.
Il est donc possible que la liste des appels système pour le même programme, diffère d'une machine à l'autre.
Les valeurs fournies dans les tests sont spécifiques à la machine `java.labunix.uqam.ca`. 

Les tests fournis ne couvrent que les cas d'utilisation de base, en particulier ceux présentés ici.
Réussir ces tests n'implique pas une note complète. 
Une analyse de votre code sera effectuée pour valider le respect des contraintes/exigences et des pénalités plus au moins importantes vont s'appliquer en cas de non-respect.
Enfin, il est possible que des tests privés soient ajoutés lors de la correction pour tester davantages de scénarios (voir la section Barème et critères de correction plus bas).

En cas de problème pour exécuter les tests sur votre machine, merci de,

1. lire la documentation présente ici et 
2. poser vos questions en classe ou sur [Mattermost](https://mattermost.info.uqam.ca/forum/channels/inf3173).

Attention toutefois à ne pas fuiter de l’information relative à votre solution (conception, morceaux de code, etc.)

### Barème et critères de correction

Le barème utilisé est le suivant

- Seuls les tests qui passent sur le serveur `java.labunix.uqam.ca` seront considérés.
  - 60%: pour le jeu de test public fourni dans le fichier `public.bats`.
  - 40%: pour un jeu de test privé exécuté lors de la correction. Ces tests pourront être plus gros, difficiles et/ou impliquer des cas limites d'utilisation (afin de vérifier l'exactitude et la robustesse de votre code).
- Des pénalités pourront êtreappliquées pour de mauvaises pratiques ou carrément des bogues dans le code source du programme (voir plus bas).

Quelques exemples de bogues fréquents dans les copies TP de INF3173 qui causent une perte de points, en plus d'être responsable de tests échoués:

- Utilisation de variables ou de mémoire non initialisés (comportement indéterminé).
- Mauvaise vérification des cas d'erreur des fonctions et appels système (souvent comportement indéterminé si le programme continue comme si de rien n'était)
- Utilisation de valeurs numériques arbitraires (*magic number*) qui cause des comportements erronés si ces valeurs sont dépassées (souvent dans les tailles de tableau).
- Code inutilement compliqué, donc fragile dans des cas plus ou moins limites.
- Des pénalités pour des bogues spécifiques et des défauts dans le code source du programme, ce qui inclut, mais sans s'y limiter l'exactitude, la robustesse, la lisibilité, la simplicité, la conception, les commentaires (même si Serge n'est pas d'accord...), etc.
  - En résumé, suivez les [bonnes pratiques](https://en.wikipedia.org/wiki/Coding_best_practices).

## Mentions supplémentaires importantes

⚠️ **Intégrité académique**
Si vous travailler sur un dépôt git, le rendre public ou rendre public votre code ici ou ailleurs ; ou faire des MR contenant votre code vers ce dépôt principal (ou vers tout autre dépôt public) sera considéré comme du **plagiat**.

⚠️ Attention, vérifier **=/=** valider.
Ce n'est pas parce que les tests passent chez vous ou ailleurs ou que vous avez une pastille verte sur gitlab que votre TP est valide et vaut 100%.
Par contre, si des tests échouent quelque part, c'est généralement un bon indicateur de problèmes dans votre code.

⚠️ Si votre programme **ne compile pas** ou **ne passe aucun test public**, une note de **0 sera automatiquement attribuée**, et cela indépendamment de la qualité de code source ou de la quantité de travail mise estimée.
Il est ultimement de votre responsabilité de tester et valider votre programme.

Pour les tests, autant publics que privés (s'il y a lieu), les résultats qui font foi sont ceux sur le serveur `java.labunix.uqam.ca`. 
Si un test réussi presque ou de temps en temps, il est considéré comme échoué (sauf rares exceptions).

Quelques exemples de pénalités :

- Vous faites une MR sur le dépôt public avec votre code privé : à partir de -10%
- Vous m'ajoutez à votre dépôt : -5%
- Vous faites une remise par courriel : -100%
- Un code qui ne compile pas : -100%
- Vous utilisez « mais chez-moi ça marche » (ou une variante) comme argument : -100%
- Si je trouve des morceaux de votre code sur le net (même si vous en êtes l'auteur) : -100%
  - Citez vos sources et expliquez les changements que vous avez éventuellement apporté au code source d'origine.