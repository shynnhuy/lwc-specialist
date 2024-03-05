public with sharing class BoatDataService {
    @AuraEnabled(cacheable = true)
    public static List<Boat__c> getBoats(String boatTypeId){
        String query = 'SELECT '
        + 'Name, BoatType__c '
        + 'FROM Boat__c';

        if (String.isNotBlank(boatTypeId)) {
            query += ' WHERE BoatType__c = :boatTypeId';
        }

        return Database.query(query);
    }
}