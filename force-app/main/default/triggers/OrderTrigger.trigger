trigger OrderTrigger on Order (before insert, before update) {
    for (Order order : Trigger.new) {
     // Vérifier le nombre de produits minimum
                OrderService.validateOrder (order) ;
                // Sélectionner le meilleur transporteur 
                OrderService.SelectTransporter(order);
            }
        }
