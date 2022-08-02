# Index

*   [Fonctionnalité](#funcionalidades)
*   [Enregistrement de l’utilisateur](#registro-de-usuario)
*   [Profil utilisateur](#perfil-de-usuario)
*   [Profils d’administrateur, de modérateur et d’administrateur](#perfiles-de-administrador,-moderador-y-gestor)
*   [Profils de l’évaluateur et de la chaise de table](#perfiles-de-evaluador-y-presidente-de-mesa)

## Fonctionnalité

CONSUL prend actuellement en charge :

*   Enregistrement et vérification des utilisateurs à la fois dans la même application et auprès de différents fournisseurs (Twitter, Facebook, Google).
*   Différents profils d’utilisateurs, à la fois des citoyens individuels et des organisations et des fonctionnaires.
*   Différents profils d’administration, de gestion, d’évaluation et de modération.
*   Espace permanent pour les débats et les propositions.
*   Commentaires imbriqués dans les débats et les propositions.
*   Budgétisation participative à travers différentes phases.

## Enregistrement de l’utilisateur

Pour enregistrer un nouvel utilisateur, il est possible de le faire dans l’application elle-même, en donnant un nom d’utilisateur (nom public qui apparaîtra dans vos publications), un e-mail et un mot de passe avec lequel le Web sera accessible. Les conditions d’utilisation doivent être acceptées. L’utilisateur doit confirmer son e-mail pour pouvoir se connecter.

![Registro de usuario](imgs/user_registration.png "Registro de usuario")

D’autre part, l’inscription peut également être activée via des services externes tels que Twitter, Facebook et Google. Pour cela, il est nécessaire d’avoir la configuration activée dans Paramètres et les clés et secrets de ces services dans le fichier *config/secrets.yml*.

      twitter_key: ""
      twitter_secret: ""
      facebook_key: ""
      facebook_secret: ""
      google_oauth2_key: ""
      google_oauth2_secret: ""

Une fois que l’utilisateur s’est connecté, la possibilité de vérifier son compte apparaîtra, via une connexion avec le registre municipal.

![Verificación de usuario](imgs/user_preverification.png?raw=true "Verificación de usuario")

Pour cette fonctionnalité, il est nécessaire que le registre municipal prenne en charge la possibilité de connexion via une API, vous pouvez voir un exemple dans *lib/census_api.rb*.

![Verificación de usuario](imgs/user_verification.png?raw=true "Verificación de usuario")

## Profil utilisateur

Dans son profil (« Mon compte » dans le menu supérieur), chaque utilisateur peut configurer s’il souhaite afficher publiquement sa liste d’activités, ainsi que les notifications que l’application lui enverra par e-mail. Ces notifications peuvent être :

*   Recevez un e-mail lorsque quelqu’un commente vos propositions ou discussions.
*   Recevez un e-mail lorsque quelqu’un répond à vos commentaires.
*   Recevez des e-mails contenant des informations intéressantes sur le Web.
*   Recevoir un résumé des notifications sur les propositions.
*   Recevez des e-mails avec des messages privés.

## Profils d’administrateur, de modérateur et d’administrateur

CONSUL dispose de trois profils utilisateur pour gérer le contenu Web : administrateur, modérateur et gestionnaire. Il dispose également de deux autres profils pour la gestion participative des processus : [évaluateur et chaise de table](#perfiles_de_evaluador,\_gestor_y_presidente_de_mesa), qui sont détaillés ci-dessous.

Les utilisateurs disposant d’un profil d’administrateur peuvent attribuer n’importe quel type de profil à n’importe quel type d’utilisateur. Cependant, tous les profils doivent être des utilisateurs vérifiés (contrairement au registre municipal) pour pouvoir effectuer certaines actions (par exemple, les gestionnaires doivent être vérifiés pour créer des projets de dépenses).

### Gérer le panneau

![Panel de administración](imgs/panel_administration.png?raw=true "Panel de administración")

De là, vous pouvez gérer le système, à travers les menus suivants:

#### Catégories ![categorias](imgs/icon_categories.png?raw=true "categorías")

##### Sujets de discussion/propositions

Les sujets (aussi appelés tags, ou tags) sont des mots qui définissent les utilisateurs lors de la création de débats ou de propositions pour faciliter leur catalogage (ex : santé, mobilité, arganzuela, ...). À partir de là, l’administrateur dispose des options suivantes:

*   Créer de nouveaux thèmes
*   Supprimer les rubriques inappropriées
*   Marquez les sujets à afficher comme suggestion lors de la création de discussions/propositions. Chaque utilisateur peut créer ceux qu’il souhaite, mais l’administrateur peut en suggérer certains qu’il trouve utiles comme catalogage par défaut. En cochant « Proposer un sujet lors de la création de la proposition » sur chaque sujet, définissez ceux qui sont suggérés.

#### Contenu modéré ![contenido moderado](imgs/icon_moderated_content.png?raw=true "contenido moderado")

##### Propositions/Débats/Commentaires cachés

Lorsqu’un administrateur ou un modérateur masque une proposition/discussion/commentaire sur le Web, il apparaît dans cette liste. De cette façon, les administrateurs peuvent examiner les éléments qui ont été masqués et corriger les erreurs possibles.

*   En cliquant sur « Confirmer », celui qui a été masqué est accepté; on considère que cela a été fait correctement.
*   S’il est considéré que le masquage a été erroné, cliquer sur « Afficher à nouveau » inverse l’action de masquage et redevient une Proposition / Débat / Commentaire visible sur le web.

Pour faciliter la gestion, nous trouvons ci-dessus un filtre avec les sections: « En attente » (les éléments sur lesquels « Confirmer » ou « Reshow » n’ont pas encore été cliqués, qui devraient encore être revus), « Confirmé » et « Tous ».

Il est conseillé de vérifier régulièrement la section « En attente ».

#### Utilisateurs bloqués

Lorsqu’un modérateur ou un administrateur bloque un utilisateur du Web, il apparaît dans cette liste. Lorsqu’un utilisateur est bloqué, il ne peut pas effectuer d’actions sur le Web et toutes ses propositions/débats/commentaires ne seront plus visibles.

*   En cliquant sur « Confirmer », le bloc est accepté; on considère que cela a été fait correctement.
*   Si le verrou est considéré comme erroné, cliquer sur « Afficher à nouveau » inverse le verrou et l’utilisateur est à nouveau actif.

#### Votes ![votaciones](imgs/icon_polls.png?raw=true "votaciones")

Vous pouvez créer un vote en cliquant sur « Créer un vote » et en définissant un nom, une date d’ouverture et de clôture. De plus, le vote peut être limité à certaines zones en cochant « Restreindre par zones ». Les zones disponibles sont définies dans le menu [Gérer les districts](#gestionar-distritos).

Les utilisateurs doivent être vérifiés afin de participer au vote.

Une fois le vote créé, ses composantes sont définies et ajoutées. Les votes comportent trois composantes : les questions des citoyens, les présidents de table et l’emplacement des urnes.

##### Questions des citoyens

Vous pouvez créer une question citoyenne ou en rechercher une existante. Lors de la création de la question, elle peut être affectée à un certain vote. Vous pouvez également modifier l’affectation à une question existante en appuyant dessus et en sélectionnant « Modifier ».

À partir de la section Questions des citoyens, les propositions citoyennes qui ont dépassé le seuil de soutien peuvent également être affectées à un vote. Ils peuvent être sélectionnés dans l’onglet « Propositions qui ont dépassé le seuil ».

##### Présidents

Tout utilisateur inscrit sur le web peut devenir une table de chaise. Pour lui attribuer ce rôle, son e-mail est entré dans le champ de recherche et une fois trouvé, il est attribué avec « Ajouter en tant que président de table ». Lorsque les présidents accèdent au Web avec leur utilisateur, ils voient en haut une nouvelle section appelée « Présidents de table ».

##### Emplacement des urnes

Pour ajouter une urne à la liste, sélectionnez « Ajouter une urne », puis renseignez le nom de l’urne et les données d’emplacement.

#### Budgétisation participative ![presupuestos participativos](imgs/icon_participatory_budgeting.png?raw=true "presupuestos participativos")

Dans cette section, vous pouvez créer un budget participatif en sélectionnant « Créer un nouveau budget » ou modifier un budget existant. En éditant, vous pouvez modifier la phase dans laquelle se trouve le processus; ce changement se reflétera sur le Web. Vous pouvez également créer des groupes de postes budgétaires et ajouter des projets de dépenses qui ont été précédemment créés par un [gérant](#panel-gestión).

#### Profils ![perfiles](imgs/icon_profiles.png?raw=true "perfiles")

##### Organisations

Sur le Web, tout utilisateur peut s’inscrire avec un profil individuel ou en tant qu’organisation. Les utilisateurs des organisations peuvent être vérifiés par les administrateurs, confirmant que la personne qui gère l’utilisateur représente efficacement cette organisation. Une fois le processus de vérification effectué, par le processus externe au Web qui a été défini pour lui, le bouton « Vérifier » est enfoncé pour le confirmer; ce qui entraînera l’apparition d’une étiquette à côté du nom de l’organisation indiquant qu’il s’agit d’une organisation vérifiée.

Dans le cas où le processus de vérification a été négatif, le bouton « Rejeter » est enfoncé. Pour modifier les données de l’organisation, cliquez sur le bouton « Modifier ».

Les organisations qui n’apparaissent pas dans la liste peuvent être trouvées pour agir sur eux via le moteur de recherche en haut. Pour faciliter la gestion, nous trouvons ci-dessus un filtre avec les sections: « en attente » (organisations qui n’ont pas encore été vérifiées ou rejetées), « vérifié », « rejeté » et « tous ».

Il est conseillé de revoir régulièrement la section « en attente ».

##### Fonctions publiques

Le statut de charge publique ne peut pas être choisi dans l’enregistrement qui est fait à partir du Web: il est attribué directement à partir de cette section. L’administrateur recherche un utilisateur en entrant son adresse e-mail dans le champ de recherche et lui attribue le rôle de charge publique.

La fonction publique ne diffère de l’utilisateur individuel que par le fait qu’une étiquette l’identifiant apparaît à côté de son nom et modifie légèrement le style de ses commentaires. Cela permet aux utilisateurs de vous identifier plus facilement. À côté de chaque charge, nous voyons l’identification qui apparaît sur son étiquette et son niveau (la façon dont le Web utilise en interne pour différencier un type de frais des autres). En appuyant sur le bouton « Modifier » à côté de l’utilisateur, ses informations peuvent être modifiées. Les fonctionnaires qui n’apparaissent pas sur la liste peuvent être trouvés pour agir sur eux via le moteur de recherche en haut.

##### Modérateurs

Tout utilisateur enregistré sur le web peut devenir modérateur. Pour attribuer ce rôle, votre e-mail est entré dans le champ de recherche et une fois trouvé, il est attribué avec « Ajouter en tant que modérateur ». Lorsque les modérateurs accèdent au Web avec leur utilisateur, ils voient en haut une nouvelle section appelée « Modéré ».

La sélection de « Activité du modérateur » affiche une liste de toutes les actions effectuées par les modérateurs : masquer/afficher les propositions/discussions/commentaires et bloquer les utilisateurs. Dans la colonne « Action », nous vérifions si l’action correspond à masquer ou à afficher (restaurer) des éléments ou à bloquer des utilisateurs. Dans les autres colonnes, nous avons le type d’élément, le contenu de l’élément et le modérateur ou l’administrateur qui a effectué l’action.

Cette section permet aux administrateurs de détecter les comportements irréguliers de modérateurs spécifiques et ainsi de pouvoir les corriger.

##### Évaluateurs

Tout utilisateur inscrit sur le web peut devenir évaluateur. Pour attribuer ce rôle, votre e-mail est entré dans le champ de recherche et une fois trouvé, il est attribué avec « Ajouter en tant qu’évaluateur ». Lorsque les évaluateurs accèdent au Web avec leur utilisateur, ils voient en haut une nouvelle section appelée « Évaluation ».

##### Gestionnaires

Tout utilisateur inscrit sur le site peut devenir gestionnaire. Pour attribuer ce rôle, votre e-mail est entré dans le champ de recherche et une fois trouvé, il est attribué avec « Ajouter en tant que gestionnaire ». Lorsque les gestionnaires accèdent au site Web avec leur utilisateur, ils voient en haut une nouvelle section appelée « Gestion ».

#### Bannières ![banners](imgs/icon_banners.png?raw=true "banners")

Dans le menu « Gérer les bannières », vous pouvez créer des bannières pour faire des annonces spéciales qui apparaîtront toujours en haut du Web, à la fois dans les sections discussions et propositions. Pour le créer, vous devez sélectionner « Créer une bannière » et entrer vos données et les dates de début et de fin de publication au format `dd/mm/aaa`.

Par défaut, une seule bannière apparaîtra sur le web. S’il existe plusieurs bannières dont les dates indiquent qu’elles doivent être actives, seule celle dont la date de début de publication est la plus ancienne sera affichée.

#### Personnaliser le site ![personalizar sitio](imgs/icon_customize_site.png?raw=true "personalizar sitio")

##### Personnaliser les pages

Les pages servent à afficher tout type de contenu statique lié aux processus de participation. Lors de la création ou de la modification d’une page, vous devez entrer un *Limace* pour définir le *permalien* de cette page en question. Une fois créé, nous pouvons y accéder à partir de la liste, en sélectionnant « Afficher la page ».

##### Personnaliser les images

À partir de ce panneau, les images des éléments corporatifs de votre CONSUL sont définies.

##### Personnaliser les blocs

Vous pouvez créer des blocs HTML qui seront incorporés dans l’en-tête ou le pied de page de votre CONSUL.

Les blocs d’en-tête (top_links) sont des blocs de liens qui doivent être créés dans le format suivant :

    <li><a href="http://site1.com">Site 1</a></li>
    <li><a href="http://site2.com">Site 2</a></li>
    <li><a href="http://site3.com">Site 3</a></li>

Les blocs de pied de page peuvent être dans n’importe quel format et peuvent être utilisés pour enregistrer des empreintes Javascript, du contenu CSS ou du contenu HTML personnalisé.

#### Gérer les districts

À partir de ce menu, vous pouvez créer les différents districts d’une municipalité avec leur nom, leurs coordonnées, leur code externe et leur code de recensement.

#### Feuilles de signature

Afin d’enregistrer un support externe pour la plate-forme, vous pouvez créer des feuilles de signature de propositions citoyennes ou de projets de dépenses en entrant l’ID de la proposition en question et en entrant les numéros des documents séparés par des virgules (,).

#### Statistiques

Statistiques générales du système.

#### Paramètres globaux

Options générales de configuration du système.

### Panel modéré

![Panel de moderación](imgs/panel_moderation.png?raw=true "Panel de moderación")

De là, vous pouvez modérer le système, en procédant aux actions suivantes:

#### Propositions / Débats / Commentaires

Lorsqu’un utilisateur marque dans une proposition/débat/commentaire l’option « signaler comme inappropriée », elle apparaît dans cette liste. En ce qui concerne chacun d’eux, le titre, la date, le nombre de plaintes (combien d’utilisateurs différents ont vérifié l’option de plainte) et le texte de la proposition/débat/commentaire apparaîtront.

À droite de chaque élément apparaît une boîte que nous pouvons marquer pour sélectionner tous ceux que nous voulons dans la liste. Une fois qu’un ou plusieurs ont été sélectionnés, nous trouvons à la fin de la page trois boutons pour effectuer des actions sur eux:

*   Masquer : empêchera l’affichage de ces éléments sur le Web.
*   Bloquer les auteurs: cela fera en sorte que l’auteur de cet élément cesse d’accéder au Web, et qu’en plus toutes les propositions / débats / commentaires de cet utilisateur cesseront d’être affichés sur le Web.
*   Marquer comme examiné lorsque nous considérons que ces éléments ne devraient pas être modérés, que leur contenu est correct et que, par conséquent, ils devraient cesser d’être affichés dans cette liste d’éléments inappropriés.

Pour faciliter la gestion, nous trouvons ci-dessus un filtre avec les sections:

*   En attente : Propositions/Débats/Commentaires sur lesquels vous n’avez pas encore cliqué sur « masquer », « bloquer » ou « marquer comme révisé », et qui doivent donc encore être examinés.
*   Tous: afficher toutes les propositions / débats / commentaires sur le site Web, et pas seulement ceux marqués comme inappropriés.
*   Marqués comme révisés: ceux qu’un modérateur a marqués comme révisés et semblent donc corrects.

Il est conseillé de revoir régulièrement la section « en attente ».

#### Bloquer les utilisateurs

Un moteur de recherche nous permet de trouver n’importe quel utilisateur en entrant son nom d’utilisateur ou son adresse e-mail, et de le bloquer une fois trouvé. En le bloquant, l’utilisateur ne pourra plus accéder au web, et toutes ses propositions/débats/commentaires seront masqués et ne seront plus visibles sur le web.

### Panneau de gestion

![Panel de gestión](imgs/panel_management.png?raw=true "Panel de gestión")

De là, vous pouvez gérer les utilisateurs via les actions suivantes:

*   Utilisateurs.
*   Modifier le compte d’utilisateur.
*   Créer une proposition.
*   Soutenir les propositions.
*   Créer un projet de dépenses.
*   Soutenir les projets de dépenses.
*   Imprimer des propositions.
*   Imprimer des projets de dépenses.
*   Invitations pour les utilisateurs.

## Profils de l’évaluateur et de la chaise de table

### Groupe d’évaluation

### Panneau de chaises de table
