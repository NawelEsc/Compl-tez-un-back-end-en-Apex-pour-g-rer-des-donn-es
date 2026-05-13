/**
 * @description Contrôleur Apex exposé au composant LWC lancerLivraison.
 *              S'appuie sur TransporterSelector et AccountSelector existants.
 *              Retourne des wrappers sérialisables en JSON pour le LWC.
 */
public with sharing class LivraisonController {

    // ─────────────────────────────────────────────────────────────
    // 1. Transporteur le moins cher
    // ─────────────────────────────────────────────────────────────

    /**
     * @description Retourne le transporteur le moins cher compatible
     *              avec le pays et le type de client de la commande.
     * @param  orderId  Id de l'enregistrement Order
     * @return          TransporteurOption ou null si aucun trouvé
     */
    @AuraEnabled
    public static TransporteurOption getMoinsCher(Id orderId) {
        try {
            Order cmd = getOrder(orderId);
            Account account = AccountSelector.getAccountByOrderId(orderId);

            Prix_de_livraison__c prix = TransporterSelector.getCheapestTransporter(
                cmd.Pays__c,
                account.TypeClient__c
            );

            return prix != null ? buildOption(prix) : null;

        } catch (Exception e) {
            throw new AuraHandledException('Erreur getMoinsCher : ' + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────
    // 2. Transporteur le plus rapide
    // ─────────────────────────────────────────────────────────────

    /**
     * @description Retourne le transporteur avec le délai le plus court
     *              compatible avec le pays et le type de client.
     * @param  orderId  Id de l'enregistrement Order
     * @return          TransporteurOption ou null si aucun trouvé
     */
    @AuraEnabled
    public static TransporteurOption getPlusRapide(Id orderId) {
        try {
            Order cmd = getOrder(orderId);
            Account account = AccountSelector.getAccountByOrderId(orderId);

            Prix_de_livraison__c prix = TransporterSelector.getFastestTransporter(
                cmd.Pays__c,
                account.TypeClient__c
            );

            return prix != null ? buildOption(prix) : null;

        } catch (Exception e) {
            throw new AuraHandledException('Erreur getPlusRapide : ' + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────
    // 3. Tous les transporteurs compatibles
    // ─────────────────────────────────────────────────────────────

    /**
     * @description Retourne la liste complète des transporteurs compatibles
     *              avec le pays et le type de client, triée par prix croissant.
     * @param  orderId  Id de l'enregistrement Order
     * @return          Liste de TransporteurOption (peut être vide)
     */
    @AuraEnabled
    public static List<TransporteurOption> getTransporteursCompatibles(Id orderId) {
        try {
            Order cmd = getOrder(orderId);
            Account account = AccountSelector.getAccountByOrderId(orderId);

            List<Prix_de_livraison__c> tarifs = TransporterSelector.getCompatibleTransporters(
                cmd.Pays__c,
                account.TypeClient__c
            );

            // Tri par prix croissant
            tarifs.sort(new PrixComparator());

            List<TransporteurOption> options = new List<TransporteurOption>();
            for (Prix_de_livraison__c p : tarifs) {
                options.add(buildOption(p));
            }
            return options;

        } catch (Exception e) {
            throw new AuraHandledException('Erreur getTransporteursCompatibles : ' + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────
    // 4. Lancer la livraison (simulation)
    // ─────────────────────────────────────────────────────────────

    /**
     * @description Crée un enregistrement Livraison__c, met à jour la commande
     *              et simule la réponse du transporteur.
     * @param  orderId        Id de la commande
     * @param  transporteurId Id du transporteur choisi
     * @return                LivraisonResult avec statut et message
     */
    @AuraEnabled
    public static LivraisonResult lancerLivraison(Id orderId, Id transporteurId) {
        try {
            Order cmd = getOrder(orderId);

            // Récupération du prix pour ce transporteur / pays
            List<Prix_de_livraison__c> tarifs = [
                SELECT Name, Delai_de_livraison__c
                FROM   Prix_de_livraison__c
                WHERE  Transporteur__c = :transporteurId
                AND    Pays__c         = :cmd.Pays__c
                LIMIT  1
            ];

            Decimal prix  = tarifs.isEmpty() ? 0 : Decimal.valueOf(tarifs[0].Name);
            Decimal delai = tarifs.isEmpty() ? 0 : tarifs[0].Delai_de_livraison__c;

            // Simulation réponse transporteur (90% succès)
            Boolean succes = simulerReponseTransporteur();
            String statut  = succes ? 'En cours' : 'Échouée';

            // Création Livraison__c — Order__c est le vrai API name du champ Commande
            Livraison__c livraison = new Livraison__c(
                Order__c             = orderId,
                Transporteur__c      = transporteurId,
                Pays__c              = cmd.Pays__c,
                Prix__c              = prix,
                Date_de_livraison__c = Date.today().addDays((Integer) delai),
                Statut__c            = statut
            );
            insert livraison;

            // Mise à jour de la commande
            cmd.Transporteur__c        = transporteurId;
            cmd.Statut_de_livraison__c = statut;
            update cmd;

            String message = succes
                ? 'Livraison lancée avec succès.'
                : 'Le transporteur n\'a pas pu accepter la commande. Veuillez réessayer ou choisir un autre transporteur.';

            return new LivraisonResult(succes, livraison.Id, message);

        } catch (Exception e) {
            throw new AuraHandledException('Erreur lancerLivraison : ' + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Méthodes privées
    // ─────────────────────────────────────────────────────────────

    private static Order getOrder(Id orderId) {
        return [
            SELECT Id, Pays__c, AccountId, Transporteur__c, Statut_de_livraison__c
            FROM   Order
            WHERE  Id = :orderId
            LIMIT  1
        ];
    }

    private static TransporteurOption buildOption(Prix_de_livraison__c p) {
        return new TransporteurOption(
            p.Transporteur__c,
            p.Transporteur__r.Name,
            Decimal.valueOf(p.Name),
            p.Delai_de_livraison__c
        );
    }

    @TestVisible
    private static Boolean simulerReponseTransporteur() {
        return (Math.random() >= 0.1);
    }

    // ─────────────────────────────────────────────────────────────
    // Comparateur prix
    // ─────────────────────────────────────────────────────────────

    private class PrixComparator implements Comparator<Prix_de_livraison__c> {
        public Integer compare(Prix_de_livraison__c a, Prix_de_livraison__c b) {
            Decimal pA = Decimal.valueOf(a.Name);
            Decimal pB = Decimal.valueOf(b.Name);
            return (pA < pB) ? -1 : (pA > pB) ? 1 : 0;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Wrappers JSON → LWC
    // ─────────────────────────────────────────────────────────────

    public class TransporteurOption {
        @AuraEnabled public Id      transporteurId { get; set; }
        @AuraEnabled public String  nom            { get; set; }
        @AuraEnabled public Decimal prix           { get; set; }
        @AuraEnabled public Decimal delai          { get; set; }

        public TransporteurOption(Id id, String nom, Decimal prix, Decimal delai) {
            this.transporteurId = id;
            this.nom            = nom;
            this.prix           = prix;
            this.delai          = delai;
        }
    }

    public class LivraisonResult {
        @AuraEnabled public Boolean succes      { get; set; }
        @AuraEnabled public Id      livraisonId { get; set; }
        @AuraEnabled public String  message     { get; set; }

        public LivraisonResult(Boolean succes, Id livraisonId, String message) {
            this.succes      = succes;
            this.livraisonId = livraisonId;
            this.message     = message;
        }
    }
}