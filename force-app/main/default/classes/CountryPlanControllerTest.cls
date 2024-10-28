/*       
@Name           - CountryPlanControllerTest
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 11-04-2020

@Description    - Test class for CountryPlanController class

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 11-04-2020    | Created Class
*/
@IsTest
public class CountryPlanControllerTest {
    
    @TestSetup
    static void makeData(){

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'FCI' Limit 1];

        /* create Internal Users */
        List<User> internalUsersToInsert = new List<User>();
        User FCIUser = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser', 'System Administrator');
        FCIUser.UserRoleId = userrole.Id;
        internalUsersToInsert.add(FCIUser);

        insert internalUsersToInsert;

        System.runAs(FCIUser){
     
            /* Creates H1 */
            Account commercialCust = TestUtility.createAccount('IMCD Holding');
            insert commercialCust;

            /* Creates H5 which is the Distributor Location */
            List<Account> accsToInsert = new List<Account>();
            Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
            customerLocItaly.OwnerId = FCIUser.Id;
            accsToInsert.add(customerLocItaly);

            Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
            customerLocFrance.OwnerId = FCIUser.Id;
            accsToInsert.add(customerLocFrance);

            Account competitorAcc = TestUtility.createEndCustomerAccount('Test Competitor');
            /* change end customer record type to competitor */
            competitorAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId();
            accsToInsert.add(competitorAcc);

            insert accsToInsert;

            /* Create Contacts under H5, these contacts will be Distributors */
            List<Contact> contactsToInsert = new List<Contact>();

            Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cItaly);

            insert contactsToInsert;

            /* Create Partner Users for above H5 */
            List<User> usersToInsert = new List<User>();
            User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrItaly.ContactId = cItaly.Id;
            usersToInsert.add(usrItaly);

            insert usersToInsert;

            /* Create an Apex share to Share the above competitor with Partner Users,
            There is criteria-based sharing rule defined but these do not execute in test classes,hence manual sharing is required */
            List<AccountShare> accShareToInsert = new List<AccountShare>();
            accShareToInsert.add(new AccountShare(AccountId = competitorAcc.Id, UserOrGroupId = usrItaly.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read'));

            insert accShareToInsert;

            /* Create Master Business Strategy Record to hold all bucket records */
            List<Business_Strategy__c> masterBusinessStrategyList = new List<Business_Strategy__c>();

            Business_Strategy__c masterBusinessStrategy = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocItaly);
            masterBusinessStrategyList.add(masterBusinessStrategy);

            insert masterBusinessStrategyList;

            /* Create Business Strategy Bucket Records beforehand */
            List<Business_Strategy__c> allBusinessStrategyChildBucketRecords = new List<Business_Strategy__c>();

            Business_Strategy__c accountPlanBucket = CommunityKPITestUtility.createAccountPlanBucket(customerLocItaly, masterBusinessStrategy);
            allBusinessStrategyChildBucketRecords.add(accountPlanBucket);

            insert allBusinessStrategyChildBucketRecords;

            TriggerHandler.skipTrigger = true;
            /* Create Account Plan Under the Business Strategy Account plan bucket */
            Field_of_Play__c accountPlan =  CommunityKPITestUtility.createAccountPlan(accountPlanBucket);
            accountPlan.OwnerId = usrItaly.Id;
            insert accountPlan;

            /* Associate Share of Wallet record to the above Account Plan Created */
            Share_of_Wallet__c shareOfWall = CommunityKPITestUtility.createShareOfWallet(accountPlan);
            insert shareOfWall;

            /* Associate Related Customer Location record to the above Account Plan Created */
            Other_Related_Customer_Location__c otherRelCustLocation = CommunityKPITestUtility.createRelatedCustomerLocation(accountPlan, customerLocFrance);
            otherRelCustLocation.OwnerId = usrItaly.Id;
            insert otherRelCustLocation;

            /* Associate Competitor Info record to the above Account Plan created */
            Business_Strategy__c competitorInfo = CommunityKPITestUtility.createCompetitorInfoForAccountPlan(accountPlan, competitorAcc);
            competitorInfo.OwnerId = usrItaly.Id;
            insert competitorInfo;
            TriggerHandler.skipTrigger = false;

        }

    }

    @isTest
    static void getDataOnInitAccountPlanCreate(){

        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"controllerValues":{"Industry":0,"Adult Nutrition":1,"Animal Nutrition":2,"Milkpowder":3,"Early Life Nutrition & Cell Nutrition":4,"Africa":5,"Foodservice BOH - Foodservice":6,"Foodservice BOH - Global Accounts":7,"BeLux":8,"DACH Germany":9,"Greece":10,"Growth Markets - North America":11,"Growth Markets - Latin - America/Pacific":12,"Growth Markets - Future Markets Europe & B2B":13,"Growth Markets - France":14,"Growth Markets - Italy":15,"Growth Markets - Spain (incl. Canarias and Millan Vincente)":16,"Growth Markets - UK & Ireland":17,"Growth Markets - Zijerveld Int.":18,"Hungary":19,"Indonesia":20,"Middle East":21,"Netherlands - Branded NL":22,"Netherlands - OOH NL":23,"Nigeria":24,"Pakistan":25,"Philippines AMC":26,"Romania":27,"Russia":28,"Thailand":29,"Vietnam":30,"Singapore":31},"defaultValue":null,"eTag":"87b1c145f8f37ce3e36b545b5fd81200","url":"/services/data/v48.0/ui-api/object-info/Field_of_Play__c/picklist-values/01225000000bso1AAA/Market_Trends__c","values":[{"attributes":null,"label":"Market Trend A","validFor":[0,1],"value":"Market Trend A"},{"attributes":null,"label":"Market Trend B","validFor":[1,2],"value":"Market Trend B"}]}','Success',200));

        Business_Strategy__c accountPlanBucket = [SELECT Id FROM Business_Strategy__c WHERE Name LIKE '%Account Plan Bucket%'];
        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];

        CountryPlanController.CountryPlanWrapper accountPlanWrap;
        Test.startTest();
        System.runAs(usrItaly){
            accountPlanWrap = CountryPlanController.getDataOnInit(null, 'Account', accountPlanBucket.Id, false);
        }
        Test.stopTest();

        System.assertEquals(usrItaly.Contact.Region__c, accountPlanWrap.userRegion);
        System.assertEquals(usrItaly.Contact.Account.BillingCountry, accountPlanWrap.userCountry);
    }

    @isTest
    static void getDataOnInitAccountPlanEdit(){

        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"controllerValues":{"Industry":0,"Adult Nutrition":1,"Animal Nutrition":2,"Milkpowder":3,"Early Life Nutrition & Cell Nutrition":4,"Africa":5,"Foodservice BOH - Foodservice":6,"Foodservice BOH - Global Accounts":7,"BeLux":8,"DACH Germany":9,"Greece":10,"Growth Markets - North America":11,"Growth Markets - Latin - America/Pacific":12,"Growth Markets - Future Markets Europe & B2B":13,"Growth Markets - France":14,"Growth Markets - Italy":15,"Growth Markets - Spain (incl. Canarias and Millan Vincente)":16,"Growth Markets - UK & Ireland":17,"Growth Markets - Zijerveld Int.":18,"Hungary":19,"Indonesia":20,"Middle East":21,"Netherlands - Branded NL":22,"Netherlands - OOH NL":23,"Nigeria":24,"Pakistan":25,"Philippines AMC":26,"Romania":27,"Russia":28,"Thailand":29,"Vietnam":30,"Singapore":31},"defaultValue":null,"eTag":"87b1c145f8f37ce3e36b545b5fd81200","url":"/services/data/v48.0/ui-api/object-info/Field_of_Play__c/picklist-values/01225000000bso1AAA/Market_Trends__c","values":[{"attributes":null,"label":"Market Trend A","validFor":[0,1],"value":"Market Trend A"},{"attributes":null,"label":"Market Trend B","validFor":[1,2],"value":"Market Trend B"}]}','Success',200));

        Business_Strategy__c accountPlanBucket = [SELECT Id FROM Business_Strategy__c WHERE Name LIKE '%Account Plan Bucket%'];
        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Account competitorAcc = [SELECT Id FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId()];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];
        Field_of_Play__c accountPlan = [SELECT Id FROM Field_of_Play__c LIMIT 1];

        CountryPlanController.CountryPlanWrapper accountPlanWrap;
        Test.startTest();
        System.runAs(usrItaly){
            accountPlanWrap = CountryPlanController.getDataOnInit(accountPlan.Id, 'Account', null, false);
        }
        Test.stopTest();

    }

    @isTest
    static void getDataOnInitAccountPlanClone(){

        
        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"controllerValues":{"Industry":0,"Adult Nutrition":1,"Animal Nutrition":2,"Milkpowder":3,"Early Life Nutrition & Cell Nutrition":4,"Africa":5,"Foodservice BOH - Foodservice":6,"Foodservice BOH - Global Accounts":7,"BeLux":8,"DACH Germany":9,"Greece":10,"Growth Markets - North America":11,"Growth Markets - Latin - America/Pacific":12,"Growth Markets - Future Markets Europe & B2B":13,"Growth Markets - France":14,"Growth Markets - Italy":15,"Growth Markets - Spain (incl. Canarias and Millan Vincente)":16,"Growth Markets - UK & Ireland":17,"Growth Markets - Zijerveld Int.":18,"Hungary":19,"Indonesia":20,"Middle East":21,"Netherlands - Branded NL":22,"Netherlands - OOH NL":23,"Nigeria":24,"Pakistan":25,"Philippines AMC":26,"Romania":27,"Russia":28,"Thailand":29,"Vietnam":30,"Singapore":31},"defaultValue":null,"eTag":"87b1c145f8f37ce3e36b545b5fd81200","url":"/services/data/v48.0/ui-api/object-info/Field_of_Play__c/picklist-values/01225000000bso1AAA/Market_Trends__c","values":[{"attributes":null,"label":"Market Trend A","validFor":[0,1],"value":"Market Trend A"},{"attributes":null,"label":"Market Trend B","validFor":[1,2],"value":"Market Trend B"}]}','Success',200));

        Business_Strategy__c accountPlanBucket = [SELECT Id FROM Business_Strategy__c WHERE Name LIKE '%Account Plan Bucket%'];
        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Account competitorAcc = [SELECT Id FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId()];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];
        Field_of_Play__c accountPlan = [SELECT Id FROM Field_of_Play__c LIMIT 1];

        CountryPlanController.CountryPlanWrapper accountPlanWrap;
        Test.startTest();
        System.runAs(usrItaly){
            accountPlanWrap = CountryPlanController.getDataOnInit(accountPlan.Id, 'Account', null, true);
        }
        Test.stopTest();
    }

    @isTest
    static void getCorrectCompetitorAccountByName(){

        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Account competitorAcc = [SELECT Id,Name FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId()];
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = competitorAcc.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        List<Account> competitorAccList = new List<Account>();
        Test.startTest();
        System.runAs(usrItaly){
            competitorAccList = (List<Account>)CountryPlanController.getCompetitorAccountsByName('Competitor', 'Account');
        }
        Test.stopTest();

        System.assertEquals('Test Competitor', competitorAccList[0].Name);
    }

    @isTest
    static void getCorrectCompetitorAccountByNameBlankSearch(){

        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Account competitorAcc = [SELECT Id,Name FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId()];

        List<Account> competitorAccList = new List<Account>(); 
        Test.startTest();
        System.runAs(usrItaly){
            competitorAccList = (List<Account>)CountryPlanController.getCompetitorAccountsByName(null, 'Account');
        }
        Test.stopTest();

        System.assertEquals(1, competitorAccList.size());
    }

    @isTest
    static void getCorrectCustomerLocationByName(){

        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = customerLocFrance.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        List<Account> customerLocationList = new List<Account>();
        Test.startTest();
        System.runAs(usrItaly){
            customerLocationList = (List<Account>)CountryPlanController.getCustomerLocsAccountsByName('France', 'Account');
        }
        Test.stopTest();

        System.assertEquals('IMCD France Spa', customerLocationList[0].Name);
    }

    @isTest
    static void getCorrectCustomerLocationByNameBlankSearch(){

        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];

        List<Account> customerLocationList = new List<Account>();
        Test.startTest();
        System.runAs(usrItaly){
            customerLocationList = (List<Account>)CountryPlanController.getCustomerLocsAccountsByName(null, 'Account');
        }
        Test.stopTest();

        System.assertEquals(2, customerLocationList.size());
    }

    @isTest
    static void saveNewAccountPlan(){

        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Business_Strategy__c accountPlanBucket = [SELECT Id FROM Business_Strategy__c WHERE Name LIKE '%Account Plan Bucket%'];
        Account competitorAcc = [SELECT Id FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId()];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];

        TriggerHandler.skipTrigger = true;
        Test.startTest();
        System.runAs(usrItaly){
            CountryPlanController.saveCountryPlanData(null, accountPlanBucket.Id, getCompetitorInfoData(competitorAcc), getCountryWrapperData(), 
                                                    /* OtherPrincipalChoosen*/new List<String>{'Agropalma', 'BENEO GmbH'}, /* subsegmentChoosen*/ new List<String>{'Food'}, /* Additional Country*/ new List<String>{'Afghanistan','Albania'},
                                                     /*marketTrendsChoosen*/new List<String>{'Vegan'}, getRelatedInfoData(customerLocFrance), 
                                                     /*custLocDeleteIds*/ new List<String>(), /*competitorDeleteIds*/new List<String>(), /*fiscalYearChoosen*/'2021', false);
        }
        Test.stopTest();
        TriggerHandler.skipTrigger = false;
    }

    @isTest
    static void saveEditedAccountPlan(){

        User usrItaly = [SELECT Id,Contact.Region__c, Contact.Account.BillingCountry FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        Business_Strategy__c accountPlanBucket = [SELECT Id FROM Business_Strategy__c WHERE Name LIKE '%Account Plan Bucket%'];
        Field_of_Play__c accountPlan = [SELECT Id FROM Field_of_Play__c LIMIT 1];
        Account competitorAcc = [SELECT Id FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId()];
        Other_Related_Customer_Location__c RelatedCustomerLoc = [SELECT Id FROM Other_Related_Customer_Location__c LIMIT 1];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];

        TriggerHandler.skipTrigger = true;
        Test.startTest();
        System.runAs(usrItaly){
            CountryPlanController.saveCountryPlanData(accountPlan.Id, null, getCompetitorInfoData(competitorAcc), getCountryWrapperData(), 
                                                    /* OtherPrincipalChoosen*/new List<String>{'Agropalma', 'BENEO GmbH'}, /* subsegmentChoosen*/ new List<String>{'Food'}, /* Additional Country*/ new List<String>{'Afghanistan','Albania'},
                                                     /*marketTrendsChoosen*/new List<String>{'Vegan'}, getRelatedInfoData(customerLocFrance), 
                                                     /*custLocDeleteIds*/ new List<String>{RelatedCustomerLoc.Id}, /*competitorDeleteIds*/new List<String>{competitorAcc.Id}, /*fiscalYearChoosen*/'2021', false);
        }
        Test.stopTest();
        TriggerHandler.skipTrigger = false;
    }

    private static String getCountryWrapperData(){

        String countryWrap = '{"additionalCountries":["Afghanistan","Aland Islands"],';
        countryWrap +=  '"additionalCountriesSelected":[],';
        countryWrap += '"businessSegments":["Industry","Adult Nutrition","Animal Nutrition","Milkpowder","Early Life Nutrition & Cell Nutrition","Africa","Foodservice BOH - Foodservice","Foodservice BOH - Global Accounts","BeLux","DACH Germany","Greece","Growth Markets - North America","Growth Markets - Latin - America/Pacific","Growth Markets - Future Markets Europe & B2B","Growth Markets - France","Growth Markets - Italy","Growth Markets - Spain (incl. Canarias and Millan Vincente)","Growth Markets - UK & Ireland","Growth Markets - Zijerveld Int.","Hungary","Indonesia","Middle East","Netherlands - Branded NL","Netherlands - OOH NL","Nigeria","Pakistan","Philippines AMC","Romania","Russia","Thailand","Vietnam","Singapore"],';
        countryWrap += '"businessSegmentSelected":"Industry",';
        countryWrap += '"businessStrategies":["Grow Business","Stable Business (Organic Growth)","Defend Business","Declining Business"],';
        countryWrap += '"businessStrategySelected":"Defend Business",';
        countryWrap += '"competitorInfoWrapList":[],';
        countryWrap += '"distributorOpportunities":"O","distributorStrengths":"S","distributorThreats":"T","distributorVol":"2000","distributorWeaknesses":"W",';
        countryWrap += '"FCIBudgetVol":"100",';
        countryWrap += '"fiscalYearList":["2021"],';
        countryWrap += '"growthOpportunity":"Growth",';
        countryWrap += '"marketInfo":"Growth",';
        countryWrap += '"marketTrends":["Market Trend A"],';
        countryWrap += '"marketTrendsSelected":[],';
        countryWrap += '"OtherComments":"",';
        countryWrap += '"otherPrincipals":["Agropalma","Bell Flavors & Fragrances","BENEO GmbH","BUNGE LODERS CROKLAAN B.V.","Cargill","Chr. Hansen A/S","CP Kelco","Döhler GmbH","DSM","DowDupont","Firmenich","Givaudan","IFF","Novozymes","Palsgaard","Rousselot","Roquette","Others"],';
        countryWrap += '"otherPrincipalsSelected":[],';
        countryWrap += '"relatedCustLocInfoWrapList":[],';
        countryWrap += '"subSegments":["Active Nutrition","Alcoholic Beverages","Bakery – Laminated","Bakery – Non Laminated","Beverages","Calf Feed","Cell Nutrition","Chocolate","Encaps","Fats / Oils","Food","Ice Cream","Industrial Food Applications","Infant Nutrition","Ingredient Applications","Medical","Milk Powder","Multiple","Non Alcoholic Beverages","Other","Performance Nutrition","Pharma","Piglet Feed","Repackers","Resellers C&C - Wholesale","Savory","Trading Single Ingredients"],';
        countryWrap += '"subSegmentsSelected":[],';
        countryWrap += '"userCountry":"Italy",';
        countryWrap += '"userRegion":"EMEA"}';

        return countryWrap;
    }

    private static String getCompetitorInfoData(Account competitorAcc){

       String competitorInfoData = '[{"recordObjId":"","Name":"Test Competitor","CompetitorId":"'+ competitorAcc.Id +'","distributorNames":"hello","dirOrIndirVal":"Yes","recordName":"Test1"}]';
       return competitorInfoData;
    }

    private static String getRelatedInfoData(Account customerLoc){

        String relatedInfoData = '[{"type":"icon","recordObjId":"","CustLocId":"'+customerLoc.Id+'","label":"IMCD UK Limited","iconName":"standard:account","alternativeText":"Account"}]';
        return relatedInfoData;
    }

}