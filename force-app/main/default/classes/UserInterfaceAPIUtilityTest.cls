@isTest
public class UserInterfaceAPIUtilityTest {
    
    public static final String sObjectName = 'Field_of_Play__c';
    public static final Id recordTypeIdToCheck = Schema.SObjectType.Field_of_Play__c.getRecordTypeInfosByDeveloperName().get('Distributor_Account_Plan').getRecordTypeId();
    public static final String dependentfieldAPIName = 'Market_Trends__c';

    @isTest
    static void getCorrectPicklistValues(){
        UserInterfaceAPIUtility.SinglePicklistWrapper singleWrap;
        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"controllerValues":{"Industry":0,"Adult Nutrition":1,"Animal Nutrition":2,"Milkpowder":3,"Early Life Nutrition & Cell Nutrition":4,"Africa":5,"Foodservice BOH - Foodservice":6,"Foodservice BOH - Global Accounts":7,"BeLux":8,"DACH Germany":9,"Greece":10,"Growth Markets - North America":11,"Growth Markets - Latin - America/Pacific":12,"Growth Markets - Future Markets Europe & B2B":13,"Growth Markets - France":14,"Growth Markets - Italy":15,"Growth Markets - Spain (incl. Canarias and Millan Vincente)":16,"Growth Markets - UK & Ireland":17,"Growth Markets - Zijerveld Int.":18,"Hungary":19,"Indonesia":20,"Middle East":21,"Netherlands - Branded NL":22,"Netherlands - OOH NL":23,"Nigeria":24,"Pakistan":25,"Philippines AMC":26,"Romania":27,"Russia":28,"Thailand":29,"Vietnam":30,"Singapore":31},"defaultValue":null,"eTag":"87b1c145f8f37ce3e36b545b5fd81200","url":"/services/data/v48.0/ui-api/object-info/Field_of_Play__c/picklist-values/01225000000bso1AAA/Market_Trends__c","values":[{"attributes":null,"label":"Market Trend A","validFor":[0,1],"value":"Market Trend A"},{"attributes":null,"label":"Market Trend B","validFor":[1,2],"value":"Market Trend B"}]}','Success',200));
        Test.startTest();
        singleWrap = UserInterfaceAPIUtility.getSinglePicklistValues(sObjectName, recordTypeIdToCheck, dependentfieldAPIName);
        Test.stopTest();
    }
}