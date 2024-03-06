public with sharing class BoatDataService {
  @AuraEnabled(cacheable=true)
  public static List<Boat__c> getBoats(String boatTypeId) {
    String query = 'SELECT Name, Description__c, BoatType__c, Contact__r.Name, Price__c, Length__c, Picture__c, Geolocation__c FROM Boat__c';

    if (String.isNotBlank(boatTypeId)) {
      query += ' WHERE BoatType__c = :boatTypeId';
    }

    List<Boat__c> boats = Database.query(query);

    return boats;
  }

  @AuraEnabled(cacheable=true)
  public static List<BoatType__c> getBoatTypes() {
    return [
      SELECT Id, Name
      FROM BoatType__c
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Boat__c> getBoatsByLocation(
    String boatTypeId,
    Decimal longitude,
    Decimal latitude
  ) {
    String query = 'SELECT Name, Description__c, BoatType__c, Contact__r.Name, Price__c, Length__c, Picture__c, Geolocation__c FROM Boat__c';

    if (String.isNotBlank(boatTypeId)) {
      query += ' WHERE BoatType__c = :boatTypeId';
    }

    query += ' ORDER BY DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'mi\') LIMIT 10';

    List<Boat__c> boats = Database.query(query);

    return boats;
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
