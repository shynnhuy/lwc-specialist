public with sharing class BoatDataService {
  @AuraEnabled(cacheable=true)
  public static List<Boat__c> getBoats(String boatTypeId) {
    String query = 'SELECT ' + 'Name, BoatType__c ' + 'FROM Boat__c';

    if (String.isNotBlank(boatTypeId)) {
      query += ' WHERE BoatType__c = :boatTypeId';
    }

    return Database.query(query);
  }

  @AuraEnabled(cacheable=true)
  public static List<BoatType__c> getBoatTypes() {
    return [
      SELECT Id, Name
      FROM BoatType__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Boat__c> getBoatsByLocation(String boatTypeId) {
    return [
      SELECT Id, Name, OwnerId
      FROM BoatType__c
      WHERE BoatType__c = :boatTypeId
    ];
  }

  @AuraEnabled
  public static String updateBoatList(Object data) {
    List<Boat__c> boatsForUpdate = (List<Boat__c>) JSON.deserialize(
      JSON.serialize(data),
      List<Boat__c>.class
    );

    update boatsForUpdate;
    return 'Success: Boats updated successfully';
  }
}
