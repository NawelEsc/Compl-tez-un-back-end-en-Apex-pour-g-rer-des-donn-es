/**
 * @description Service métier pour la gestion des commandes LTP.
 *              Contient la logique de validation des commandes et de sélection
 *              automatique du transporteur le plus adapté.
 *              S'appuie sur AccountSelector, OrderSelector et TransporterSelector.
 *              Appelé par OrderTrigger sur before insert et before update.
 */
public with sharing class OrderService {

    /**
     * @description Valide le nombre minimum de produits requis selon le type de client.
     *              La validation ne s'applique que lorsque le statut est "Activated".
     *              - Particulier : minimum 3 produits
     *              - Professionnel : minimum 5 produits
     * @param  orderToValidate  Enregistrement Order en cours d'insertion ou de mise à jour
     */
    public static void validateOrder(Order orderToValidate) {

        // Valider uniquement quand le statut est Activated
        if (orderToValidate.Status != 'Activated') return;

        // Récupérer le compte directement depuis AccountId de la commande
        Account account = AccountSelector.getAccountById(orderToValidate.AccountId);

        // Compter les produits via OrderSelector
        Integer numberOfProducts = OrderSelector.countOrderItems(orderToValidate.Id);

        // Valider selon le type de client
        if (account.TypeClient__c == 'Particulier' && numberOfProducts < 3) {
            orderToValidate.addError(
                'Pour les particuliers, les commandes avec moins de 3 produits sont refusées.'
            );
        } else if (account.TypeClient__c == 'Professionnel' && numberOfProducts < 5) {
            orderToValidate.addError(
                'Pour les professionnels, les commandes avec moins de 5 produits sont refusées.'
            );
        }
    }

    /**
     * @description Sélectionne automatiquement le transporteur le moins cher compatible
     *              avec le pays de livraison et le type de client de la commande.
     *              Si aucun transporteur n'est disponible, une erreur est levée.
     *              La sélection ne s'applique que lorsque le statut est "Activated".
     * @param  orderToValidate  Enregistrement Order en cours d'insertion ou de mise à jour
     */
    public static void selectTransporter(Order orderToValidate) {

        // Sélectionner uniquement quand le statut est Activated
        if (orderToValidate.Status != 'Activated') return;

        // Récupérer le compte directement depuis AccountId de la commande
        Account account = AccountSelector.getAccountById(orderToValidate.AccountId);

        // Récupérer le moins cher et le plus rapide
        Prix_de_livraison__c cheapestTransporter = TransporterSelector.getCheapestTransporter(
                                            orderToValidate.Pays__c,
                                            account.TypeClient__c);

        Prix_de_livraison__c fastestTransporter = TransporterSelector.getFastestTransporter(
                                            orderToValidate.Pays__c,
                                            account.TypeClient__c);

        // Assigner le transporteur à la commande
        if (cheapestTransporter != null) {
            orderToValidate.Transporteur__c = cheapestTransporter.Transporteur__c;
        } else if (fastestTransporter != null) {
            orderToValidate.Transporteur__c = fastestTransporter.Transporteur__c;
        } else {
            orderToValidate.addError(
                'Aucun transporteur disponible pour ce pays et ce type de client.'
            );
        }
    }
}