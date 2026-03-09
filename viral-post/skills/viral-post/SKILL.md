---
name: viral-post
description: Générer un post viral pour les réseaux sociaux. Utiliser quand l'utilisateur demande "/viral-post", "crée un post viral", "post LinkedIn", "post Twitter/X", ou veut générer du contenu viral pour les réseaux sociaux.
---

# viral-post — Générateur de posts viraux

Générer des posts viraux adaptés à chaque réseau social, avec mémoire persistante par thématique et apprentissage automatique via recherche web.

## Arguments

L'utilisateur peut fournir :
- Un texte libre (idée, contenu source, lien)
- `--theme <nom>` : thème à utiliser
- `--platform <nom>` : plateforme cible (linkedin, twitter, instagram, threads, tiktok)
- `--refresh` : forcer la recherche web même si mémoire récente
- `--list` : lister les thèmes existants
- `--delete <nom>` : supprimer un thème

Arguments reçus : $ARGUMENTS

## Données

- Thèmes : `~/.claude/viral-posts/themes/`
- Drafts : `~/.claude/viral-posts/drafts/`
- Références mécaniques virales : `references/viral-mechanics.md` (relatif à ce skill)
- Références plateformes : `references/platforms.md` (relatif à ce skill)

## Workflow

### Étape 0 — Commandes spéciales

**Si `--list` :**
Lister les dossiers dans `~/.claude/viral-posts/themes/`. Pour chaque thème, lister les fichiers `.md` (hors `theme.md`) pour afficher les plateformes configurées. Si aucun thème n'existe, indiquer "Aucun thème configuré. Lancer `/viral-post` pour en créer un." Fin.

**Si `--delete <nom>` :**
Demander confirmation à l'utilisateur. Si confirmé, supprimer le dossier `~/.claude/viral-posts/themes/<nom>/` et tout son contenu. Confirmer la suppression. Fin.

### Étape 1 — Contexte

Parser les arguments pour extraire `--theme`, `--platform`, `--refresh`, et le texte libre restant.

**Déterminer le thème :**
1. Si `--theme` fourni, utiliser cette valeur.
2. Sinon, lister les thèmes existants dans `~/.claude/viral-posts/themes/` via `ls`.
   - Si des thèmes existent, les proposer en choix numéroté + option "Créer un nouveau thème".
   - Si aucun thème, demander le nom du nouveau thème.

**Premier usage d'un thème (dossier inexistant) :**
Créer le dossier `~/.claude/viral-posts/themes/<theme>/`.
Poser ces questions une par une :
1. "Quelle est l'audience cible de ce thème ?" (proposer des exemples adaptés)
2. "Quel ton général adopter ?" (proposer : professionnel, décontracté, expert, inspirant, provocateur)
3. "Quels sont les mots-clés et termes importants de cette thématique ?"

Créer `~/.claude/viral-posts/themes/<theme>/theme.md` avec cette structure :
```markdown
# <Nom du thème>

## Audience
<réponse question 1>

## Ton général
<réponse question 2>

## Vocabulaire clé
<réponse question 3>

## Recherches
```

**Déterminer la plateforme :**
1. Si `--platform` fourni, utiliser cette valeur.
2. Sinon, lister les fichiers `.md` (hors `theme.md`) dans le dossier du thème pour voir les plateformes déjà configurées.
   - Si des plateformes existent, les proposer en choix + option "Ajouter une plateforme".
   - Si aucune, proposer la liste : LinkedIn, Twitter/X, Instagram, Threads, TikTok.

**Première utilisation d'une plateforme sur un thème (fichier inexistant) :**
Lire `references/platforms.md` (relatif à ce skill) pour charger les spécificités de la plateforme choisie.
Demander : "Quel ton spécifique adopter sur <plateforme> pour ce thème ?" (proposer des options adaptées à la plateforme).

Créer `~/.claude/viral-posts/themes/<theme>/<plateforme>.md` avec cette structure :
```markdown
# <Plateforme>

## Ton
<ton spécifique choisi>

## Contraintes
<extraire de references/platforms.md les contraintes clés>

## Mécaniques virales préférées
<à enrichir au fil du temps>

## Exemples de posts performants
<à enrichir au fil du temps>
```

**Déterminer l'input :**
- Si un texte libre a été fourni en argument, l'utiliser comme contenu source.
- Sinon, demander : "Partir de zéro (je propose des idées basées sur les tendances) ou d'un contenu existant (idée, article, lien) ?"

### Étape 2 — Mémoire & recherche web

Lire `~/.claude/viral-posts/themes/<theme>/theme.md`.

Chercher la date de la dernière section `### YYYY-MM-DD` sous `## Recherches`.

**Décision de recherche :**

| Situation | Action |
|-----------|--------|
| Pas de section datée sous Recherches ou thème vient d'être créé | Recherche web complète |
| Dernière date > 7 jours | Recherche web de mise à jour |
| Dernière date ≤ 7 jours et pas de `--refresh` | Pas de recherche, utiliser la mémoire |
| `--refresh` présent | Recherche web même si récente |

**Recherche web (si nécessaire) :**
Utiliser WebSearch pour chercher (adapter les requêtes au thème et à la langue de l'utilisateur) :
- "[thématique] tendances [année en cours]"
- "[thématique] débat polémique récent"
- "[thématique] contenu viral [plateforme]"
- "[thématique] nouveaux termes vocabulaire"

Synthétiser les résultats et les ajouter **en append** dans `theme.md` sous `## Recherches` :
```markdown
### YYYY-MM-DD
- Tendance : <résumé de la tendance principale>
- Sujet chaud : <sujet d'actualité du secteur>
- Angle polémique : <débat ou opinion clivante possible>
- Vocabulaire : <nouveaux termes repérés>
```

Ne jamais écraser les recherches précédentes — toujours ajouter en append.

Lire aussi `~/.claude/viral-posts/themes/<theme>/<plateforme>.md` pour le contexte plateforme.

### Étape 3 — Proposition d'angles

Lire `references/viral-mechanics.md` (relatif à ce skill) pour charger les mécaniques virales.

En combinant :
- Les connaissances thématiques (contenu de `theme.md` : audience, ton, vocabulaire, recherches)
- Les spécificités plateforme (contenu de `<plateforme>.md` + `references/platforms.md`)
- Les mécaniques virales (`references/viral-mechanics.md`)
- L'input de l'utilisateur (s'il y en a un)

Proposer **3 angles** différents. Pour chaque angle, présenter :

```
**Angle N — [Titre court]**
Format : [nom du format viral]
Approche : [2-3 lignes décrivant le contenu]
Hook : "[accroche envisagée]"
```

Varier les formats entre les 3 angles (ne pas proposer 3 fois le même format).

Appliquer automatiquement les fondamentaux décrits dans `viral-mechanics.md` (hook, structure, CTA, longueur).

Demander : "Quel angle te plaît ? (1, 2 ou 3)"

### Étape 4 — Génération

Générer le post complet en respectant :
- Le format viral choisi et ses mécaniques (cf. `viral-mechanics.md`)
- Les contraintes de la plateforme (cf. `<plateforme>.md` et `references/platforms.md`)
- Le ton défini pour ce thème × cette plateforme
- La longueur sweet spot de la plateforme
- Les fondamentaux : hook percutant, structure aérée, CTA engageant

Afficher le post complet dans le terminal, encadré clairement :

```
---
[contenu du post]
---
```

Puis proposer les options :

```
[1] Accepter — sauvegarde + copie dans le presse-papier
[2] Régénérer — même angle, nouvelle version
[3] Autre angle — revenir au choix des angles
[4] Modifier le ton — indiquer la direction souhaitée
```

Si [2] : régénérer une nouvelle version avec le même angle et format.
Si [3] : revenir à l'étape 3 et reproposer 3 angles.
Si [4] : demander la direction ("plus punchy", "plus soft", "plus polémique", "plus inspirant"...) et régénérer.

### Étape 5 — Sauvegarde

Quand l'utilisateur choisit [1] (Accepter) :

1. **Sauvegarder le draft** dans `~/.claude/viral-posts/drafts/YYYY-MM-DD-<theme>-<plateforme>.md` :
```markdown
---
theme: <theme>
platform: <plateforme>
angle: <format viral utilisé>
date: YYYY-MM-DD
---

<contenu du post>
```

Si un fichier avec le même nom existe déjà (même thème, même plateforme, même jour), ajouter un suffixe numérique : `YYYY-MM-DD-<theme>-<plateforme>-2.md`.

2. **Copier dans le presse-papier** :
```bash
echo "<contenu du post sans le frontmatter>" | pbcopy
```

3. **Confirmer** : "Post sauvegardé dans `drafts/YYYY-MM-DD-<theme>-<plateforme>.md` et copié dans le presse-papier."
