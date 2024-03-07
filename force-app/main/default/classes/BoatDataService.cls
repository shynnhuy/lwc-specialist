public with sharing class BoatDataService {
  public static final String LENGTH_TYPE = 'Length';
  public static final String PRICE_TYPE = 'Price';
  public static final String TYPE_TYPE = 'Type';
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
  public static String getBoatsByLocation(
    Decimal latitude,
    Decimal longitude,
    String boatTypeId
  ) {
    String query = 'SELECT Name, Description__c, BoatType__c, Contact__r.Name, Price__c, Length__c, Picture__c, Geolocation__c FROM Boat__c';

    if (String.isNotBlank(boatTypeId)) {
      query += ' WHERE BoatType__c = :boatTypeId';
    }

    query += ' WITH SECURITY_ENFORCED ORDER BY DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'mi\') LIMIT 10';

    List<Boat__c> boats = Database.query(query);

    return JSON.serialize(boats);
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

  @AuraEnabled
  public static List<BoatReview__c> getAllReviews(Id boatId) {
    return [
      SELECT
        Boat__c,
        Name,
        Comment__c,
        Rating__c,
        LastModifiedDate,
        CreatedDate,
        CreatedBy.Name,
        CreatedBy.SmallPhotoUrl,
        CreatedBy.CompanyName
      FROM BoatReview__c
      WHERE Boat__c = :boatId
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate DESC
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Boat__c> getSimilarBoats(Id boatId, String similarBy) {
    List<Boat__c> similarBoatsList = new List<Boat__c>();
    List<Boat__c> allBoats = [
      SELECT
        Id,
        Name,
        BoatType__r.Name,
        Length__c,
        Picture__c,
        Price__c,
        Year_Built__c
      FROM Boat__c
      WHERE Id != :boatId
    ];

    if (allBoats.isEmpty()) {
      return similarBoatsList;
    }

    if (similarBy == LENGTH_TYPE) {
      similarBoatsList = [
        SELECT
          Id,
          Name,
          BoatType__r.Name,
          Length__c,
          Picture__c,
          Price__c,
          Year_Built__c
        FROM Boat__c
        WHERE
          Id != :allBoats.get(0).Id
          AND Length__c >= :allBoats.get(0).Length__c / 1.2
          AND Length__c <= :allBoats.get(0).Length__c * 1.2
        ORDER BY Length__c, Price__c, Year_Built__c
      ];
    } else if (similarBy == PRICE_TYPE) {
      similarBoatsList = [
        SELECT
          Id,
          Name,
          BoatType__r.Name,
          Length__c,
          Picture__c,
          Price__c,
          Year_Built__c
        FROM Boat__c
        WHERE
          Id != :allBoats.get(0).Id
          AND Price__c >= :allBoats.get(0).Price__c / 1.2
          AND Price__c <= :allBoats.get(0).Price__c * 1.2
        ORDER BY Length__c, Price__c, Year_Built__c
      ];
    } else if (similarBy == TYPE_TYPE) {
      similarBoatsList = [
        SELECT
          Id,
          Name,
          BoatType__r.Name,
          Length__c,
          Picture__c,
          Price__c,
          Year_Built__c
        FROM Boat__c
        WHERE
          Id != :allBoats.get(0).Id
          AND BoatType__c = :allBoats.get(0).BoatType__c
        ORDER BY Length__c, Price__c, Year_Built__c
      ];
    }

    return similarBoatsList;
  }
}
