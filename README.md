# CRM Devis Bugbusters

Éditeur de devis Bugbusters : choix du DO, BPU rattachés et grille Mobility4 dans le panneau Prestations, PDF avec logo, en-tête et pied de page, historique des devis et suivi « Fil de l'eau » (activité, devis, production).

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

**Ajouter des BPU plus tard** : *BPU & DO → Importer des BPU (.json)*. L'import est additif : un aperçu indique les BPU nouveaux et mis à jour, rien n'est supprimé, et les rattachements DO ↔ BPU existants sont conservés. Un BPU qui porte le même identifiant qu'un BPU existant le remplace (nouvelle version de la grille).

Pour changer le code d'accès : *Authentication → Users*, ouvrez le compte équipe et changez son mot de passe. Les personnes déjà connectées gardent leur session jusqu'à leur déconnexion.

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | L'application |
| `supabase/schema.sql` | Structure de la base (tables, sécurité, historique, production), pour référence |
| `.nojekyll` | Demande à GitHub Pages de servir les fichiers tels quels |

## Historique

- Onglet **Historique** : toutes les actions récentes (qui, quoi, quand, montant).
- Bouton **Historique** sur chaque devis : ses versions, avec PDF de chaque version et restauration.
- Les devis supprimés vont dans la **Corbeille** (filtre de la liste) et peuvent être restaurés.
- Les enregistrements successifs d'une même personne sur 10 minutes sont regroupés en une ligne.

## Fil de l'eau

Onglet **Fil de l'eau**, reprise du fichier Excel « FIL DE L'EAU AUDIT-DEVIS » :

- **Activité** : tableau de bord calculé en direct (devis par statut, taux de transformation, panier moyen, production par statut, CA et marge, chiffres par CDP, relances à faire, 12 derniers mois).
- **Devis** : tous les devis avec CDP, activité, n° de ticket, date d'envoi, relances, jours sans relance et « À relancer » calculés comme dans l'Excel.
- **Production** : une ligne est créée automatiquement quand un devis passe à « Accepté » (statut « A PLANIFIER »). Date d'intervention, technicien, prix d'achat ; la marge et le % de marge sont calculés.
- **Listes** : répartition DO → CDP, délai de relance, listes des CDP, activités et techniciens.

Le PDF « DO » d'un brouillon le passe automatiquement en « Envoyé – en attente » avec la date du jour.

## Gratuité et limites

GitHub Pages et l'offre gratuite de Supabase suffisent. Supabase met en pause un projet gratuit qui a très peu d'activité sur 7 jours ; quelques utilisations par jour suffisent à l'éviter. Un projet en pause se relance depuis le tableau de bord Supabase (*Resume project*) pendant 90 jours, avec ses données. Les sauvegardes de la base ne sont pas téléchargeables sur l'offre gratuite : utilisez *Société → Sauvegarde* dans l'application pour garder une copie des devis.
