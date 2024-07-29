public with sharing class BoatTriggerHandler {
    
    public static void handleAfterTrigger(List<Boats__c> newBoats, Map<Id, Boats__c> oldBoats, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        if (isInsert || isUpdate || isUndelete) {
            List<Id> fleetIds = extractFleetIds(newBoats);
            if (!fleetIds.isEmpty()) {
                BoatHelper.updateTotalCatchTarget(fleetIds);
            }
        }

        if (isUpdate) {
            Map<Id, Id> oldFleetMap = extractOldFleetMap(newBoats, oldBoats);
            Set<Id> updatedFleetIds = new Set<Id>(oldFleetMap.values());
            system.debug('old'+oldFleetMap.values());
            updatedFleetIds.addAll(oldFleetMap.keySet());

            if (!updatedFleetIds.isEmpty()) {
                BoatHelper.updateTotalCatchTarget(new List<Id>(updatedFleetIds));
            }
        }
         if (isDelete || (isUpdate && isDelete)) { 
            List<Id> fleetIds = extractFleetIds(oldBoats.values()); 
            if (!fleetIds.isEmpty()) {
                BoatHelper.updateTotalCatchTarget(fleetIds);
            }
        }
    }

    private static List<Id> extractFleetIds(List<Boats__c> boats) {
        List<Id> fleetIds = new List<Id>();
        for (Boats__c boat : boats) {
            fleetIds.add(boat.Fleet__c);
        }
        return fleetIds;
    }

    private static Map<Id, Id> extractOldFleetMap(List<Boats__c> newBoats, Map<Id, Boats__c> oldBoats) {
        Map<Id, Id> oldFleetMap = new Map<Id, Id>();
        for (Boats__c newBoat : newBoats) {
            Boats__c oldBoat = oldBoats.get(newBoat.Id);
            if (oldBoat != null && oldBoat.Fleet__c != newBoat.Fleet__c) {
                oldFleetMap.put(newBoat.Id, oldBoat.Fleet__c);
            }
        }
        return oldFleetMap;
    }
}