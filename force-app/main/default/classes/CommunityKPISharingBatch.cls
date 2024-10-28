global without sharing class CommunityKPISharingBatch {

    global static void initiateKPISharingBatch(){

        //The below statement will start sharing batch for Commercial Activity Object
        Database.executeBatch(new CommercialActivitySharingBatch() , 50);

        //The below statement will start sharing batch for Business Strategy Object
        Database.executeBatch(new BusinessStrategySharingBatch() , 50);

        //The below statement will start sharing batch for Forecast Accuracy Object
        Database.executeBatch(new ForecastAccuracySharingBatch() , 50);

        //The below statement will start sharing batch for FCI Customer Support Object
        Database.executeBatch(new FCICustomerSupportSharingBatch() , 50);

        //The below statement will start sharing batch for Sales Performance Object
        Database.executeBatch(new SalesFunnelSharingBatch() , 50);

        //The below statement will start sharing batch for Sales Performance Object
        Database.executeBatch(new AccountPlanSharingBatch() , 50);

    }
}