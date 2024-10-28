@IsTest
private class BatchAddMissingRatingRecordsTest {
    @TestSetup
    static void testSetup() {
        List<Value_Element__c> valueELements = TestUtils.newValueElements(new Value_Element__c(Is_Active__c = true), 5, true);
        List<Location__c> locations = TestUtils.newLocations(null, 2, true);
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_KEY), true);
        locations[0].Is_Active__c = true;
        update locations[0];
        List<Supplier_Location__c> supplierLocations = TestUtils.newSupplierLocations(new Supplier_Location__c(Supplier_Hub__c = supplierHub.Id, Location__c = locations[0].Id), 1, true);
        supplierLocations[0].Business_Group__c = 'INGREDIENTS';
        update supplierLocations[0];
    }
    @isTest
    static void addMissingSuppliers(){
        List<Supplier_Rating__c> createdRating = [SELECT Id, Supplier_Hub__c, Value_Element__c,Supplier_Rating_Header__c,Location__c FROM Supplier_Rating__c];
        //system.assert(createdRating.size() > 0);
        try{
            delete createdRating;
        }catch(dmlException e){
            
        }
        test.startTest();
        database.executeBatch(new BatchAddMissingRatingRecords());
        test.stopTest();
        List<Supplier_Rating__c> ratingsCretaedThroughBatch = [SELECT Id, Supplier_Hub__c, Value_Element__c,Supplier_Rating_Header__c,Location__c FROM Supplier_Rating__c];

        //system.assert(ratingsCretaedThroughBatch.size() > 0);
    }
    @isTest
    static void ignoreExisitngSuppliers(){
        List<Supplier_Rating__c> createdRating = [SELECT Id, Supplier_Hub__c, Value_Element__c,Supplier_Rating_Header__c,Location__c FROM Supplier_Rating__c];
        //system.assert(createdRating.size() > 0);
        test.startTest();
        database.executeBatch(new BatchAddMissingRatingRecords());
        test.stopTest();
    }
}