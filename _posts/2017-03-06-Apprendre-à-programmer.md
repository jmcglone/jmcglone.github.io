# Introduction à la programmation
**Liste de ressources pour les développeurs en herbe**

## Sommaire 
- [Introduction](#introduction)
    - [Objectifs](#objectifs)
    - [Par où commencer?](#par-où-commencer)
    - [Comment cette page est organisée?](#comment-cette-page-est-organisée)
    - [Quelle ressource dois-je choisir?](#quelle-ressource-dois-je-choisir)
    - [Attention](#attention)
- [Ressources générales](#ressources-générales)
    - [Autres](#autres)
    - [Cours en ligne](#cours-en-ligne)
- [Les Langages de programmation](#les-langages-de-programmation)
    - [C](#c)
    - [C++](#c-1)
    - [C#](#c-sharp)
    - [Haskell](#haskell)
    - [HTML, CSS, and JavaScript](#html-css-and-javascript)
    - [Lisp (Scheme, Common Lisp, Clojure, etc)](#lisp-scheme-common-lisp-clojure-etc)
    - [Java](#java)
    - [Perl](#perl)
    - [PHP](#php)
    - [Python](#python)
    - [Golang](#golang)
    - [Ruby](#ruby)
    - [Scratch](#scratch)
- [Données](#data)
    - [Neo4j & Graph Databases](#neo4j-and-graph-databases)
    - [MongoDB](#mongodb)
- [Autres sujets](#other-topics)
    - [Développer sur des plateformes spécifiques](#developing-on-specific-platforms)
        - [Android](#android)
        - [Mac et iOS](#mac-and-ios)
        - [Windows et Windows Phones](#windows-and-windows-phones)
    - [Structures de données et algorithmes](#data-structures-and-algorithms)
- [Outils](#tools)
    - [Contrôle de version](#version-control)
        - [Git](#git)
        - [Mercurial](#mercurial)

## Introduction

### Objectifs

La programmation et l'informatique sont de plus en plus populaires que jamais - des initiatives comme [Une heure de code](https://hourofcode.com/fr) rendent l'apprentissage de la programmation plus populaire à travers le monde.

En conséquence, il ya un nombre de plus en plus important de ressources et de tutoriels produites pour les débutants qui veulent apprendre à coder, allant des livres aux tutoriels en ligne aux sites Web interactifs aux cours en ligne massifs ouverts _(MOOCS)_ comme [Codecademy](https://www.codecademy.com/fr), [Coursera](https://www.coursera.org/) et [OpenClassrooms](https://openclassrooms.com/)

Bien que cela soit merveilleux, il peut également être un problème pour les débutants - il ya presque trop de ressources disponibles, et il est difficile de savoir par où commencer.

Cette page est destinée à aider à résoudre ce problème - pour présenter une liste de ressources pour les personnes qui sont soit nouvelles à la programmation, nouvelles à un sujet particulier, ou veulent faire progresser leurs compétences au-delà du stade débutant. Cette page n'essaie pas de répertorier toutes les ressources disponibles, mais plutôt des liens vers des ressources qui sont **garanties** d'être de haute qualité.


### Par où commencer?

Si vous savez ce que vous voulez apprendre, c'est génial! Commencez à parcourir les liens dans cette section et trouvez quelque chose qui fonctionne pour vous.

Si vous ne savez pas par où commencer et quelle language apprendre, quelques bons langages pour débutants sont:

- [Golang](#golang) (Go tente de combiner la facilité de programmation d'un langage interprété, dynamiquement typé, avec l'efficacité et la sécurité d'un langage statiquement typé, compilé.)
- [Python](#python) (À usage général; Informatique scientifique et mathématique.)
- [Java](#java) (À usage général; Développement Android)
- [HTML/CSS/JavaScript](#html-css-and-javascript) (Sites web et Applications web)
- [Scratch](#scratch) (pour les enfants)

Python et Java sont les deux langages les [plus utilisés](http://www.lemondeinformatique.fr/actualites/lire-python-passe-en-tete-des-langages-d-apprentissage-et-detrone-java-58055.html) 
pour enseigner la programmation aux débutants dans les écoles et les universités, et il existe une grande variété de ressources disponibles pour vous aider à apprendre. Ils sont aussi largement utilisés dans l'industrie qui font d'eux des langages utiles à connaître.

Le développement Web a été très populaire ces derniers temps, il y'a donc de nombreuses ressources pour l'apprentissage du HTML, CSS et JavaScript, ce qui rend également l'apprentissage plus simple et éfficace. Il nécessite peu ou pas d'installation et de configuration sur votre ordinateur. Tout ce dont vous avez besoin est un éditeur de texte pour écrire du code -- le code sera exécuté sur votre navigateur Web.

[Scratch](https://www.youtube.com/watch?v=4y6J2jXjU34) est un peu différent des autres langages. Il a été conçu à dès la base pour être facile à utiliser et à apprendre -- au lieu de taper du texte, vous faites glisser et connecter un ensemble "blocs" pour former des programmes, ce qui en fait un langage très visuel. En conséquence, Scratch est une bon langage surtout pour les enfants plus jeunes _(élèves du primaire, collège)_ ou pour les gens qui n'aiment pas taper.

### Comment cette page est organisée?

Cette page est subdivisée en trois parties: premièrement, une section _"Ressources générales"_ qui relie des sites qui offrent des contenus de haute qualité sur une variété de sujets et une section _"Ressources spécifiques"_ qui fournit des ressources sur des langages de programmation ou des sujets spécifiques.

En général, la plupart des ressources disponibles se situent entre deux catégories -- les cours en ligne, et les livres + didacticiels(tutoriels). Les cours en ligne ont tendance à enseigner en utilisant des conférences vidéo, essayant d'être interactif, essayant d'imiter la structure d'un cours semblable à ceux que vous pourriez prendre au collège. En revanche, les livres et les didacticiels enseignent par écrit et vous permettent de définir votre propre rythme.

### Quelle ressource dois-je choisir?

Que vous préfériez apprendre en regardant une vidéo ou en lisant du texte est vraiment une question de préférence personnelle. _Moi_ personnellement, c'est le visuel, mais votre style d'apprentissage pourrait être complètement différent. Vous devrez peut-être explorer et parcourir plusieurs ressources différentes avant de découvrir comment vous apprenez le mieux.

De plus, vous constaterez que la plupart des liens, qu'il s'agisse de cours en ligne, de didacticiels ou de livres, ont tendance à se concentrer sur l'un ou l'autre des trois éléments suivants:

  1. Certaines ressources se concentrent sur la _programmation_, la _sémantique_ ou la _théorie de l'informatique_ -- en d'autres termes,      comment utiliser un langage de programmation pour écrire quelque chose qui fonctionne.
  2. D'autres ressources se concentreront plus sur le _codage_ et la _syntaxe_ -- les détails particuliers et les règles sur le                fonctionnement d'un langage de programmation.
  3. D'autres ressources se concentrent sur l'enseignement _idioms_ -- l'enseignement des meilleures pratiques spécifiques à ce langage,        la philosophie sous-jacente de ce dernier, ou vous faire découvrir les différentes bibliothèques à votre disposition: l'écosystème        large.
  
Si vous êtes nouveau dans la programmation, le premier modèle sera le meilleur. La programmation concerne la résolution de problèmes appliqués: être en mesure de prendre un problème, et le briser en petits et petits morceaux jusqu'à ce qu'ils soient assez petits pour  traduction en code informatique. Simplement mémoriser une collection de règles ne sera pas très utile pour vous. Vous devez également apprendre à appliquer ces règles.

Toutefois, si vous savez déjà comment programmer, alors vous savez très probablement déjà comment faire. Dans ce cas, vous allez vouloir utiliser le deuxième type, car il sera plus facile d'apprendre les différences entre le langage que vous apprenez et celles que vous connaissez déjà.

Quand je dis qu'une ressource est _"lourde en théorie"_ ou _"rigide"_, c'est qu'elle se penche vers la première catégorie. Quand je dis qu'une ressource _"se concentre sur la syntaxe"_, je veux dire qu'elle se penche vers la seconde. Et quand je dis une ressource _"se concentre sur des idiomes"_ ou _"sur des applications pratiques"_, je veux dire qu'il se penche vers le troisième.

### ATTENTION!

Cette page est toujours un **travail en cours**! Certaines sections peuvent actuellement être incomplètes, et certains liens peuvent ne pas encore être complètement vérifiés.


## Ressources générales

### Autres

Vous pouvez trouver une énorme [Liste de livres de programmation gratuits et des ressources sur github](https://github.com/vhf/free-programming-books/blob/master/free-programming-books.md). (C'était hébergé sur StackOverflow, mais a été déplacé vers Github en octobre 2013).

Vous pouvez également trouver une méta _"liste des ressources de programmation"_ agrégateur ici: http://resrc.io/


### Cours en ligne

Les cours en ligne sont des moyens de plus en plus populaire pour les universités et les professionnels d'enseigner la programmation et l'informatique dans un format structuré. En conséquence, de nouveaux cours en ligne apparaîtront tout le temps, il est donc utile de vérifier périodiquement ces ressources pour voir les nouveautés.

- **[Codecademy](http://www.codecademy.com/fr)** - Offre des cours gratuits en ligne dans plusieurs langages différents. Cependant, Codecademy a tendance à enseigner uniquement la syntaxe de base, donc vous pouvez avoir besoin de travail grâce à plus de tutoriels après avoir fini avec Codecademy. Il se concentre principalement sur le développement web, Ruby et Python.
- **[OpenClassrooms](http://www.openclassroom.com/)** - Offre des cours gratuits et ou payants en ligne dans plusieurs langages différents. Chaque visiteur peut à la fois être un lecteur ou un rédacteur. Les cours peuvent être réalisés aussi bien par des membres, par l'équipe du site, ou éventuellement par des professeurs d'universités ou de grandes écoles partenaires.
- **[Coursera](https://www.coursera.org/)** - Offre des cours gratuits en ligne dans de nombreux domaines différents de plusieurs universités bien connues. De nouveaux cours sont ajoutés tous les trimestres et le contenu des anciens cours est généralement archivé. Parce que beaucoup de cours semblent être nouveaux / peuvent être une chose ponctuelle, cette page ne liera pas aux cours sur Coursera à moins qu'il ne semble être stable.
- **[Udacity](http://www.udacity.com/)** - Offre des cours gratuits d'informatique dispensés par des experts de l'industrie. Udacity offre deux types de cours - cours réguliers et nanodégres. Les cours réguliers sont gratuits. Les cours réguliers avec un tutorat individuel / examen de code nécessite des frais mensuels. Les nanodégres sont généralement pour les personnes ayant une certaine expérience de codage préalable, et coûtent plus d'argent.
- **[edX](https://www.edx.org/)** - Un effort conjoint entre le MIT, Harvard et Berkeley pour fournir gratuitement des versions en ligne de certains de leurs cours.
- **[OpenCulture](http://www.openculture.com/computer_science_free_courses)** - Semblable à tout ce qui précède. Les conférences vidéo sont généralement disponibles sur iTunes ou Youtube. Généralement ** n'exigent ** pas que vous faites des devoirs, contrairement à de nombreux autres cours en ligne.
- **[MIT OpenCourseWare](http://ocw.mit.edu/index.htm)** - Offre des matériels de cours statique enseigné au MIT. Sauf indication contraire, la plupart du contenu de ce site Web tend à être très rigoureux et rapide.
- **[Khan Academy](https://www.khanacademy.org/)** - Contient quelques cours sur la programmation et l'informatique; Contient beaucoup plus de cours sur toutes sortes de sujets (en particulier les mathématiques).
- **[Stanford Engineering Everywhere](http://see.stanford.edu/see/courses.aspx)** - Offre des matériels de cours statique enseigné a Stanford.

Les sites Web suivants contiennent également une grande variété de didacticiels pour de nombreux sujets différents, mais nécessitent un paiement et un enregistrement avant d'accéder à leurs cours.

- **[Team Treehouse](http://teamtreehouse.com/)** - Se concentre sur le développement web et iOS.
- **[Lynda](http://www.lynda.com/)** - Comprend des cours sur la conception, l'animation, la vidéo, les affaires et bien plus encore.
- **[PluralSight](http://www.pluralsight.com/)** - Similaire à Lynda, mais avec un accent sur les développeurs et les cours IT.
-  **[General Assembly](https://generalassemb.ly/)** - Comprend également des cours sur la conception, l'animation, la vidéo, les affaires et bien plus encore.

En général, edX, OpenCulture, MIT OpenCourseware et Stanford Engineering Everywhere ont tendance à contenir des cours plus rigoureux, approfondis et exigeants, tandis que Codecademy et Khan Academy ont tendance à se concentrer sur une introduction plus douce à la programmation. Coursera, Udacity et OpenClassrooms ont tendance à varier entre ces deux extrêmes.


## Les Langages de programmation

### C

NB: C peut être un langage difficile à enseigner. Bien que les cours en ligne et les livres soient un bon point de départ et peuvent vous prendre un long chemin, le consensus général est que la meilleure façon d'apprendre est de lire un livre réel.

- **Cours en ligne:**
    - MIT Open Courseware a quelques:
        - [Programmation pratique en C][c-mit-practical]
          Pour débutants.
        - [Introduction à la gestion de la mémoire en C et à la programmation orientée objet C ++][c-mit-intro]
          Adapté aux personnes ayant une expérience antérieure dans un langage de programmation qui n'est pas C ou C ++.
        - [Programmation efficace en C et C ++][c-mit-effective]
         Similaire à ceux qui précèdent.
- **tutoriels Videos:** N/A
- **tutoriels Interactifs:**
    - [Learn-C][c-learn-c]
      Un guide en ligne interactif qui vous enseigne le C de base étape par étape.
- **Livres et didacticiels (en ligne):**
   -  [Apprendre C, Le Hard Way][c-lcthw]
      Partie de la série "Apprenez X le Hard Way". Supposant que vous avez déjà une expérience de programmation antérieure. Actuellement incomplet, en cours.
   -  [Programmation C][c-c-programming]
      Un des livres vedettes de Wikibooks. Il se concentre  principalement sur l'enseignement de la syntaxe. Un bon point de départ et de référence.
   -  [Construisez votre propre Lisp][c-lisp]
      Vous explique comment écrire un interprèteur Lisp en C, en enseignant simultanément les deux langages.
    - [Plus de livres gratuits][c-more]
- **Livres (papier):**
    - [The C Programming Language][c-c-lang]
      Le guide définitif de C. Aussi connu sous le nom de K&R, dédicace aux auteurs.
    - [The Definitive C Book Guide and List][c-so-definitive]
Une liste très bien entretenue de livres et de ressources recommandés sur StackOverflow. Tous les livres énumérés sur cette page sont fortement recommandés.
- **Exercices:** N/A

  [c-mit-practical]: http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-087-practical-programming-in-c-january-iap-2010/
  [c-mit-intro]: http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-088-introduction-to-c-memory-management-and-c-object-oriented-programming-january-iap-2010/
  [c-mit-effective]: http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-s096-effective-programming-in-c-and-c-january-iap-2014/

  [c-learn-c]: http://learn-c.org
  [c-lcthw]: http://c.learncodethehardway.org/book/
  [c-lisp]: http://www.buildyourownlisp.com/
  [c-c-programming]: http://en.wikibooks.org/wiki/C_Programming
  [c-more]: https://github.com/vhf/free-programming-books/blob/master/free-programming-books.md#c

  [c-c-lang]: http://www.amazon.com/C-Programming-Language-2nd-Edition/dp/0131103628/
  [c-so-definitive]: http://stackoverflow.com/questions/562303/the-definitive-c-book-guide-and-list

### C++

NB: Semblable à C, C ++ peut être un langage difficile à enseigner. Bien que les cours en ligne et les livres sont un bon point de départ et peuvent vous prendre un long chemin, le consensus général est que la meilleure façon d'apprendre est de lire un livre réel.

- **Cours en ligne**
    - MIT Open Courseware a quelques uns:
        - [Introduction à C++][cpp-mit-intro]
          Pour les débutants, avec un rythme assez rapide.
        - [Introduction à la gestion de la mémoire en C et à la programmation orientée objet C ++][cpp-mit-intro-2]
          Adapté aux personnes ayant une expérience antérieure dans un langage de programmation qui n'est pas C ou C ++.
        - [Programmation efficace en C et C ++][c-mit-effective]
         Similaire à ceux qui précèdent.
    - **"Introduction à l'informatique" par Stanford en 3 parties, série pour les débutants.** Le premier cours enseigne Java, les deux derniers enseignent C et C ++.
        - [Méthodologie de la programmation][cpp-stan-methodology]
        - [Programmation: Abstractions][cpp-stan-abstractions]
        - [Les paradigmes de programmation][cpp-stan-paradigms]
    - Coursera [C ++ pour les programmeurs C][cpp-coursera-c-for-cpp]
      Peut également être utile pour les programmeurs ayant une expérience préalable dans un autre langage en dehors de C ou C ++.
- **Tutoriels interactifs:**
    - [Exercices interactifs C ++][cpp-interactive]
      Une introduction au C ++ de base. c'est un croisement entre un didacticiel interactif et un livre en ligne.
- **tutoriels videos:** N/A
- **Livres et tutoriels (en ligne):**
    - [How to Think Like a Computer Scientist][cpp-think-cs]
      Une bonne introduction au C ++ de base.
    - [Learncpp.com][cpp-learn]
      se concentre davantage sur la syntaxe, et moins sur la programmation. Peut-être utile pour les débutants, mais comme une référence, pas un tutoriel.
    - [Linear C++][cpp-linear]
      Un tutoriel sur C ++ pour les personnes ayant une certaine expérience de programmation préalable. Enseigne en présentant et en expliquant une série de programmes.
   - [Plus de livres gratuit][cpp-more]
- **Livres (papier):**
   - [The Definitive C++ Book Guide and List][cpp-so-definitive]
     Une liste très bien entretenue de livres et de ressources recommandés sur StackOverflow. Tous les livres énumérés sur cette page sont fortement recommandés.
- **Exercises:** N/A

  [cpp-google-class]: https://developers.google.com/edu/c++/
  [cpp-coursera-c-for-cpp]: https://www.coursera.org/course/cplusplus4c
  [cpp-mit-intro]: http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-096-introduction-to-c-january-iap-2011/
  [cpp-mit-intro-2]: http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-088-introduction-to-c-memory-management-and-c-object-oriented-programming-january-iap-2010/
  [cpp-mit-effective]: http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-s096-effective-programming-in-c-and-c-january-iap-2014/
  [cpp-stan-methodology]: http://see.stanford.edu/see/courseinfo.aspx?coll=824a47e1-135f-4508-a5aa-866adcae1111
  [cpp-stan-abstractions]: http://see.stanford.edu/see/courseinfo.aspx?coll=11f4f422-5670-4b4c-889c-008262e09e4e
  [cpp-stan-paradigms]: http://see.stanford.edu/see/courseinfo.aspx?coll=2d712634-2bf1-4b55-9a3a-ca9d470755ee

  [cpp-interactive]: http://nova.umuc.edu/~jarc/sdsd/

  [cpp-think-cs]: http://greenteapress.com/thinkcpp/index.html
  [cpp-learn]: http://www.learncpp.com/
  [cpp-linear]: https://github.com/jesyspa/linear-cpp
  [cpp-more]: https://github.com/vhf/free-programming-books/blob/master/free-programming-books.md#c-1

  [cpp-so-definitive]: http://stackoverflow.com/questions/388242/the-definitive-c-book-guide-and-list

### C-Sharp
C'est un langage de programmation multi-paradigme englobant des disciplines de typage forte, impérative, déclarative, fonctionnelle, générique, orientée objet (basé sur les class) et orientée composants.
- **Cours en ligne:**
    - Microsoft Virtual Academy propose quelques cours gratuits:
      - [C# Fondamentaux pour les débutants absolus][csharp-fundamentals]
       Une série de vidéos produites par Microsoft sur l'apprentissage de C# pour les débutants.
      - [Programmation en C#][csharp-jump-start]
        Une autre série de vidéos produites par Microsoft. Assume quelques connaissances antérieures de C #.
- **Tutoriels interactifs:** N/A
- **tutoriels videos:** N/A
- **Livres tutoriels (online):**
    - [C# Programming][csharp-programming]
      Un des livres vedettes de Wikibook. Pour les débutants. Il se concentrer sur la syntaxe, et ferait également une bonne référence.
    - [The C# Yellow Book][csharp-yellow]
      Le texte introductif utilisé par l'Université de Hull.
    - [C# Essentials][csharp-essentials]
      Un texte d'introduction sur C #.Il  comprend également des informations sur Windows Forms, Visual Studios et la création d'interfaces graphiques.
    - [Visual C# resources][csharp-visual]
      Séries officielles de tutoriels et de guides Microsoft sur C# et .NET.
    - [Plus de livres gratuit][csharp-more]
- **Livres (papier):**
    - [Sam's Teach Yourself C# 5.0 in 24 Hours]() par Scott Dorman
      Une bonne introduction pour les débutants.
    - [Essential C# 5.0][csharp-essential-book]
      Très complet, et destiné davantage aux programmateurs / programmateurs intermédiaires venant d'une autre langage.
    - [C# in Depth, 3rd Edition][csharp-in-depth]
      Aussi très complet, couvre la façon d'écrire idiomatique et propre code C#. Suppose que le lecteur connaît déjà C#.
    - [Effective C#][csharp-effective] and [More Effective C#][csharp-more-effective]
      Une collection de trucs et astuces pour améliorer votre code C #. Pas pour les débutants.
- **Exercises:** N/A

  [csharp-fundamentals]: http://channel9.msdn.com/Series/C-Fundamentals-for-Absolute-Beginners
  [csharp-jump-start]: http://www.microsoftvirtualacademy.com/training-courses/developer-training-with-programming-in-c

  [csharp-programming]: http://en.wikibooks.org/wiki/C_Sharp_Programming
  [csharp-yellow]: http://www.csharpcourse.com/
  [csharp-essentials]: http://www.techotopia.com/index.php/C_Sharp_Essentials
  [csharp-visual]: http://msdn.microsoft.com/en-us/vstudio/hh341490
  [csharp-more]: https://github.com/vhf/free-programming-books/blob/master/free-programming-books.md#c-sharp

  [csharp-sam]: http://www.amazon.com/Sams-Teach-Yourself-5-0-Hours/dp/0672336847
  [csharp-essential-book]: http://www.amazon.com/Essential-Edition-Microsoft-Windows-Development/dp/0321877586
  [csharp-in-depth]: http://www.amazon.com/gp/product/161729134X
  [csharp-effective]: http://www.amazon.com/Effective-Specific-Ways-Improve-Your/dp/0321245660
  [csharp-more-effective]: http://www.amazon.com/More-Effective-Specific-Ways-Improve/dp/0321485890

### Haskell
Haskell est un langage [polymorphiques](https://wiki.haskell.org/Polymorphism) [statiquement tapé](https://wiki.haskell.org/Typing), [purement fonctionnel](https://wiki.haskell.org/Lazy_evaluation), un peu different de la plupart des autres langages de programmation. La langue est nommée [Haskell Brooks Curry](https://wiki.haskell.org/Haskell_Brooks_Curry), dont le travail en logique mathématique sert de fondement aux langages fonctionnels. Haskell est basé sur le [lambda calculus](https://wiki.haskell.org/Lambda_calculus), par consequent ils utilisent lambda comme logo.
- **Cours en ligne:**
    - [Introduction à la programmation fonctionnelle d'edX][haskell-intro-func]
      nécessite une familiarité avec un langage de programmation non fonctionnel (Java, Python, C #, C ++, etc.).
- **Tutoriels interactifs**
    - [Essayez Haskell][haskell-try]
      Un guide interactif qui enseigne Haskell de base.
- **tutoriels videos:** N/A
- **Livres et tutoriels (En ligne):**
    - [Commencer avec Haskell][haskell-getting-started]
      Un méta-guide complet qui suggère l'ordre recommandé pour suivre les didacticiels Haskell du début à la fin.
    - [Learn You a Haskell for Great Good][haskell-great-good]
      Une introduction de débutant à Haskell. Tente de se concentrer sur la syntaxe.
    - [Haskell][haskell-wikibooks]
      Un des livres vedettes de Wikibook, du basic à avancé Haskell. Très complet.
    - [Real World Haskell][haskell-real-world]:
      Couvre comment utiliser Haskell pour des applications pratiques. C'est un bon deuxième livre à lire, après avoir terminé l'un des tutoriels ci-dessus.
    - [Plus de livres gratuit][haskell-more]
- **Livre (papier):** N/A
- **Exercices:**
    - [H-99][haskell-h-99]
      Une collection de 99 problèmes conçus pour augmenter votre compétence dans Haskell.

  [haskell-intro-func]: https://www.edx.org/course/introduction-functional-programming-delftx-fp101x#.VJw54f-kAA

  [haskell-try]: http://tryhaskell.org/

  [haskell-getting-started]: http://stackoverflow.com/a/1016986/646543
  [haskell-great-good]: http://learnyouahaskell.com/
  [haskell-wikibooks]: http://en.wikibooks.org/wiki/Haskell
  [haskell-real-world]: http://book.realworldhaskell.org/
  [haskell-more]: https://github.com/vhf/free-programming-books/blob/master/free-programming-books.md#haskell

  [haskell-h-99]: http://haskell.org/haskellwiki/H-99:_Ninety-Nine_Haskell_Problems

### HTML, CSS, et JavaScript

NB: HTML, CSS et JavaScript sont les trois technologies de base qui s'exécutent sur chaque navigateur Web et constituent chaque page Web.

HTML est un langage utilisé pour décrire la _structure_ et le _contenu_ d'une page web, CSS pour décrire le _style_ and _l'apparence_ et JavaScript pour le _comportement_ et les _interactivités_.

L'ordre d'apprentissage recommandé est généralement de commencer par HTML et CSS, puis passez à l'apprentissage JavaScript une fois que vous vous sentez que vous avez acquis une compréhension de base des deux précédents.

Notez également que HTML et CSS sont des exemples de "langages de balisage", pas de "langages de programmation" et donc assez différents de JavaScript. Si votre objectif est d'apprendre juste la programmation, vous voudrez peut-être sauter directement à JavaScript (ou choisir un autre langage de programmation!). Cependant, étant donné que la principale façon d'utiliser réellement JavaScript est à travers le navigateur Web, vous aurez besoin d'apprendre HTML et CSS à un moment ou un autre.
