/**
 * @description Sélecteur pour l'objet Order.
 *              Centralise les requêtes SOQL liées aux commandes
 *              conformément à l'architecture en couches du projet LTP.
 *              Utilisé par OrderService pour compter les produits d'une commande
 *              avant validation.
 */
public with sharing class OrderSelector {

    /**
     * @description Compte le nombre de produits (OrderItem) associés à une commande.
     *              Utilisé par OrderService.validateOrder pour vérifier que le nombre
     *              minimum de produits est respecté avant d'activer la commande.
     * @param  orderId  Id de l'enregistrement Order
     * @return          Nombre d'OrderItem liés à la commande (0 si aucun)
     */
    public static Integer countOrderItems(Id orderId) {
        return [
            SELECT COUNT()
            FROM OrderItem
            WHERE OrderId = :orderId
        ];
    }
}