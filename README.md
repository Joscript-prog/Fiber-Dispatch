# CRM Devis Bugbusters

Éditeur de devis Bugbusters : choix du DO, BPU rattachés et grille Mobility4 dans le panneau Prestations, PDF avec logo, en-tête et pied de page, historique des devis.

- **Site** : GitHub Pages (fichier `index.html`, aucun serveur à gérer).
- **Données** : Supabase, projet `crm-devis` (région Paris). Les BPU, la liste des DO et les devis sont dans la base, jamais dans ce dépôt.
- **Accès** : un code d'accès partagé par l'équipe. Sans ce code, la page ne charge aucune donnée.

## Comment fonctionne l'accès

Le code d'accès est le mot de passe d'un compte unique Supabase, `devis.equipe@bugbusters.fr`. Les règles de sécurité de la base (RLS) ne renvoient des données qu'à ce compte. La clé « publishable » visible dans `index.html` est publique par conception : seule, elle ne donne accès à rien.

À la connexion, chaque personne indique son prénom. Il est enregistré dans l'historique à chaque création, modification, changement de statut ou suppression.

## Mise en place (une seule fois)

1. **Créer le compte équipe** dans Supabase : *Authentication → Users → Add user → Create new user*.
   - Email : `devis.equipe@bugbusters.fr`
   - Mot de passe : le code d'accès que vous partagerez (12 caractères ou plus)
   - Cochez *Auto Confirm User*
2. **Fermer les inscriptions** : *Authentication → Sign In / Providers*, désactivez *Allow new users to sign up*.
3. **Charger les BPU** : ouvrez le site, entrez avec le code, allez dans *BPU & DO* et importez le fichier `catalog.json` (transmis à part, ne le déposez pas dans ce dépôt).

Pour changer le code d'accès : *Authentication → Users*, ouvrez le compte équipe et changez son mot de passe. Les personnes déjà connectées gardent leur session jusqu'à leur déconnexion.

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | L'application |
| `supabase/schema.sql` | Structure de la base (tables, sécurité, historique), pour référence |
| `.nojekyll` | Demande à GitHub Pages de servir les fichiers tels quels |

## Historique

- Onglet **Historique** : toutes les actions récentes (qui, quoi, quand, montant).
- Bouton **Historique** sur chaque devis : ses versions, avec PDF de chaque version et restauration.
- Les devis supprimés vont dans la **Corbeille** (filtre de la liste) et peuvent être restaurés.
- Les enregistrements successifs d'une même personne sur 10 minutes sont regroupés en une ligne.

## Gratuité et limites

GitHub Pages et l'offre gratuite de Supabase suffisent. Supabase met en pause un projet gratuit qui a très peu d'activité sur 7 jours ; quelques utilisations par jour suffisent à l'éviter. Un projet en pause se relance depuis le tableau de bord Supabase (*Resume project*) pendant 90 jours, avec ses données. Les sauvegardes de la base ne sont pas téléchargeables sur l'offre gratuite : utilisez *Société → Sauvegarde* dans l'application pour garder une copie des devis.
