# claude-viral-post

Plugin Claude Code pour générer des posts viraux adaptés à chaque réseau social.

## Fonctionnalités

- Génération de posts viraux pour LinkedIn, Twitter/X, Instagram, Threads et TikTok
- Mémoire persistante par thématique (audience, ton, vocabulaire)
- Recherche web automatique des tendances (rafraîchie chaque semaine)
- 7 formats viraux : storytelling, liste actionnable, prise de position, how-to, avant/après, mythe vs réalité, question ouverte
- Sauvegarde des drafts et copie dans le presse-papier

## Installation

```bash
claude plugin add /chemin/vers/claude-viral-post
```

Ou depuis GitHub :

```bash
claude plugin add <url-du-repo>
```

## Utilisation

```
/viral-post                          # Lancer le générateur
/viral-post Mon idée de post         # Partir d'une idée
/viral-post --platform linkedin      # Cibler une plateforme
/viral-post --theme tech             # Utiliser un thème existant
/viral-post --refresh                # Forcer la recherche web
/viral-post --list                   # Lister les thèmes
/viral-post --delete <nom>           # Supprimer un thème
```

## Comment ça marche

1. **Thème** — Le plugin te demande de définir une audience, un ton et un vocabulaire pour ta thématique. Ces données sont sauvegardées et réutilisées.
2. **Plateforme** — Il adapte le format, la longueur et le style aux contraintes de chaque réseau.
3. **Recherche web** — Il cherche automatiquement les tendances récentes de ta thématique (mis à jour chaque semaine).
4. **Angles** — Il propose 3 angles différents avec des formats viraux variés.
5. **Génération** — Il génère le post complet, que tu peux régénérer ou ajuster avant de l'accepter.

## Données utilisateur

Les données personnelles sont stockées localement dans `~/.claude/viral-posts/` :

```
~/.claude/viral-posts/
├── themes/          # Mémoire par thématique
│   └── <theme>/
│       ├── theme.md       # Audience, ton, vocabulaire, recherches
│       └── <plateforme>.md  # Ton et mécaniques par plateforme
└── drafts/          # Posts générés sauvegardés
```

Ces données ne font **pas** partie du plugin et restent privées sur ta machine.

## Licence

MIT
