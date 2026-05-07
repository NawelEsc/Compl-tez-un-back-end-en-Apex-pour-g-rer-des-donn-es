public with sharing class OrderSelector {

    public static Integer countOrderItems(Id orderId) {
        return [
            SELECT COUNT() 
            FROM OrderItem 
            WHERE OrderId = :orderId
        ];
    }
}
