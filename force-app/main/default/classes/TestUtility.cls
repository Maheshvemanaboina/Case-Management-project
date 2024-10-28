/**
 * Created by KJM on 18/04/2019.
 */

//Removed all the reference of Constants.OPPORTUNITY_RECORD_TYPE_FCI_NEW_BUSINESS_ID and changed to Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID.
//Did this for the Community users on-05/04/2020.
//B2B 78 Changed the Picklist value from QSR & Beverages QSR EU

@isTest
public with sharing class TestUtility {

    public static User createFCICustomerPortalUser(String userName) {
        Account acc = TestUtility.createAccount('testAccForContact');
        insert acc;

        Contact c = createContact(acc, null);
        insert c;        

        User user = createUser(userName, Constants.TEST_DE_CUSTOMER_USER);
        user.ContactId = c.Id;
        insert user;

        return user;
    }

    public static User createPartnerPortalUser(String userName) {
        Account acc = TestUtility.createAccount('testAccForContact');
        insert acc;

        Contact c = createContact(acc, null);
        insert c;
         User user = createUser(userName, Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
         user.ContactId = c.Id;
        System.runAs(user) {
            insert user;
        }
        return user;
    }

    public static User createPartnerPortalUser(String userName, Account parentWorkLocation, Account contactWorkLocation) {
        Contact c = createContact(parentWorkLocation, contactWorkLocation);
        insert c;
        User user = createUser(userName, Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        user.ContactId = c.Id;
        insert user;
        return user;
    }

    public static User createPartnerPortalManagerUser(String userName, Account parentWorkLocation, Account contactWorkLocation) {
        Contact c = createContact(parentWorkLocation, contactWorkLocation);
        insert c;
        User user = createUser(userName, Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        user.ContactId = c.Id;
        user.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_MANAGER_USER;
        insert user;
        return user;
    }

    public static User createPartnerPortalUser(String userName, Account contactWorkLocation) {
        Account parentAcc = TestUtility.createCommercialCustomer();
        insert parentAcc;

        if (contactWorkLocation == null) {
            contactWorkLocation = TestUtility.createCustomerLocation(parentAcc);
            insert contactWorkLocation;
        }

        Contact c = createContact(parentAcc, contactWorkLocation);
        insert c;
        User user = createUser(userName, Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        user.ContactId = c.Id;
        user.PortalRole = 'Executive';
            //Test.startTest();
            insert user;
            //Test.stopTest();
            return user;
    }

    public static User createPartnerPortalUserSeeAllData(String userName) {
        List<Account> customerCommercialAccs = [SELECT Id FROM Account WHERE Name = 'IMCD Holding'];
        Account parentAcc = customerCommercialAccs.isEmpty() ?  TestUtility.createCommercialCustomer() : customerCommercialAccs.get(0);
        upsert parentAcc;

        List<Account> customerLocationAccs = [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account contactWorkLocation = customerLocationAccs.isEmpty() ?  TestUtility.createCustomerLocation('IMCD Italy Spa', parentAcc) : customerLocationAccs.get(0);
        upsert contactWorkLocation;

        Contact c = createContact(parentAcc, contactWorkLocation);
        insert c;

        User user = createUser(userName, Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        user.ContactId = c.Id;
        insert user;

        return user;
    }

    public static Listing__c createListings(Id accId, Id prodId){

        return new Listing__c(

            Active__c = true,
            Customer__c = accId,
            Product__c = prodId
        );
    }

    public static User createDECustomerPortalUser(String userName, Account contactWorkLocation) {
        List<Account> customerCommercialAccs = [SELECT Id FROM Account WHERE Name = 'IMCD Holding'];
        Account parentAcc = customerCommercialAccs.isEmpty() ?  TestUtility.createCommercialCustomer() : customerCommercialAccs.get(0);
        upsert parentAcc;

        if (contactWorkLocation == null) {
            contactWorkLocation = TestUtility.createCustomerLocation(parentAcc);
            insert contactWorkLocation;
        }

        Contact c = createContact(parentAcc, contactWorkLocation);
        insert c;
        
        User user = createUser(userName, Constants.TEST_DE_CUSTOMER_USER);
        user.ContactId = c.Id;
        insert user;

        return user;
    }

    public static User createUser(String userName, String profileName) {
        return new User (
                ProfileID = [Select Id From Profile Where Name = :profileName].id,
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                FirstName = 'first',
                LastName = 'last',
                Username = userName,
                Country = 'Italy',
                Alias = 't1',
                Email = 'no@email.com',
                IsActive = true,
                Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_STANDARD_USER        		 
        //insert obj; 
        );
    }
    
    public static User createManagerUser(String userName, String profileName) {
        User usr = TestUtility.createUser(userName, profileName);
        usr.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_MANAGER_USER;
        return usr;
    }

    public static User createCommunityManagerUser(String userName, String profileName) {
        User usr = TestUtility.createUser(userName, profileName);
        usr.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_MANAGER_USER;
        return usr;
    }

    public static Account createCommercialCustomer() {
        return createCommercialCustomer('IMCD Holding');
    }

    public static Account createCommercialCustomer(String name) {
        return new Account(
                Name = name,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId(),
                Active__c = true,
                Type = 'Direct Customer'
        );
    }

    public static Account createCustomerLocation(Account parentAcc) {
        Account ac = TestUtility.createCustomerLocation('IMCD Italy Spa', parentAcc);
        return ac;
    }
    
    public static Account createCustomerLocation(String AccName, Account parentAcc) {
        return new Account(
                Name = AccName,
                ParentId = parentAcc.Id,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId(),
                Active__c = true,
                BillingStreet = 'Centro Leoni-Edificio A',
                BillingPostalCode = '20141',
                BillingCity = 'MILANO',
                BillingCountry = 'Italy',
                BillingCountryCode = 'IT',
            	Business_Segment__c = 'QSR EU'
        );
    }    
   
    public static Account createAccount(String accountName) {
        return new Account(
                Name = accountName,
                BillingStreet = 'TestBillingStreet',
                BillingPostalCode = '0000',
                BillingCity = 'TestCity',
                BillingCountry = 'Italy',
                BillingCountryCode = 'IT',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId()
        );
    }

    public static Account createEndCustomerAccount(String accountName) {
        return new Account(
                Name = accountName,
                BillingStreet = 'TestBillingStreet',
                BillingPostalCode = '0000',
                BillingCity = 'TestCity',
                BillingCountry = 'Italy',
                BillingCountryCode = 'IT',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId()
        );
    }

    public static Account createAgentAccount(String accountName) {
        return new Account(
                Name = accountName,
                BillingStreet = 'TestBillingStreet',
                BillingPostalCode = '0000',
                BillingCity = 'TestCity',
                BillingCountry = 'Italy',
                BillingCountryCode = 'IT',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Agent').getRecordTypeId()
        );
    }

    public static Contact createContact(String firstName, String lastName, Account acc, Account contactWorkLocation) {
        
        Contact cont = new Contact(
                FirstName = firstName,
                LastName = lastName,
               // AccountId = acc.Id,
                AccountId = contactWorkLocation.Id,
                Parent_Account__c = acc.Id,
                Email = 'test@kvp.com',
                OtherCountry = 'Belgium',
                OtherCountryCode = 'BE',
                Business_Segment__c = 'Adult Nutrition',
                Sub_Segment__c = 'Beverages',
                Region__c = 'EMEA',
                Additional_Country_Responsibility__c = 'France',
                MailingCountry = 'Italy'
            
        );

        if (contactWorkLocation != null) {
            //cont.Work_Location__c = contactWorkLocation.Id;
            cont.Parent_Account__c = acc.Id;
        }

        return cont;
    }

    public static Contact createAgentContact(String firstName, String lastName, Account contactWorkLocation) {
        
        Contact cont = new Contact(
                FirstName = firstName,
                LastName = lastName,
               // AccountId = acc.Id,
                AccountId = contactWorkLocation.Id,
                Email = 'test@kvp.com',
                OtherCountry = 'Belgium',
                OtherCountryCode = 'BE',
                Business_Segment__c = 'Adult Nutrition',
                Sub_Segment__c = 'Beverages',
                Region__c = 'EMEA',
                Additional_Country_Responsibility__c = 'France',
                MailingCountry = 'Italy'
            
        );


        return cont;
    }

    public static Contact createContact(Account acc, Account contactWorkLocation) {
        return TestUtility.createContact(generateRandomString(6), generateRandomString(6), acc, contactWorkLocation);
    }

    public static AccountTeamMember createAccountTeamMember(User user, Account acc, String teamMemberRole) {
        return new AccountTeamMember(
                UserId = user.Id,
                AccountId = acc.Id,
                TeamMemberRole = teamMemberRole
        );
    }

    public static Pricebook2 createPriceBook(String name) {
        return new Pricebook2(
                Name = name,
                IsActive = true
        );
    }

    public static Product2 createProduct(String name) {
        return new Product2(
                Name = name,
                IsActive = true,
                RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Product2' AND Name = 'Product SKU' LIMIT 1].Id
        );
    }

    public static PricebookEntry createPricebookEntry(Product2 prod, Id prBookId) {
        return new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = prBookId,
            CurrencyIsoCode = 'USD',
            UnitPrice = 100.00,
            UseStandardPrice = false,
            IsActive = true
        );
    }

    public static Knowledge__kav createKnowledgeKav(String title, String urlName) {
        return new Knowledge__kav(
                Title = title,
                UrlName = urlName,
                IsVisibleInPkb = true,
                IsVisibleInCsp = true,
                IsVisibleInPrm = true,
                Language = 'en_US'
        );
    }
    
    public static Tile__c createTile(String uIName) {
        return new Tile__c (
            UI_Name__c = uIName,
            Name = uIName,
            Community_Name__c = CommunityUtility.getCurrentCommunityName()
        );
    }

    public static Related_Tile__c createRelatedTile(Tile__c mainTile, Tile__c relatedTile, String type) {
        return new Related_Tile__c(
                Tile__c = mainTile.Id,
                Related_Tile__c = relatedTile.Id,
                Related_Tile_Type__c = type
        );
    }

    public static Community_Setting__mdt getCommunityOptions() {
        Community_Setting__mdt option = new Community_Setting__mdt();

        option.Show_relations_on_certificate_article__c = true;
        option.Show_relations_on_articles__c = true;
        option.Show_relations_in_both_sides__c = true;
        option.Default_child_tiles_display_option__c = Constants.TILE_CHILD_TYPE_NESTED;
        option.Account_team_roles_to_get__c = 'Sales Manager;CMO';
        option.Show_chatter_button_on_my_FCI_team__c = true;
        option.Show_chatter_button_on_my_Customer_team__c = true;
        option.Show_contact_details_on_my_FCI_team__c = true;
        return option;
    }

    public static ContentDocumentLink createTileDocument(Tile__c tl) {
        ContentVersion contentVersion = new ContentVersion(
                Title = 'testImageTitle',
                PathOnClient = 'testImage.jpg',
                VersionData = Blob.valueOf('testContentVesion'),
                IsMajorVersion = true
        );
        //insert contentVersion;

        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Id = :docId];

        ContentDocumentLink contentDoc = New ContentDocumentLink(
                LinkedEntityId = tl.id,
                ContentDocumentId = doc.Id,
                shareType = 'V',
                Visibility = 'AllUsers'
        );

        return contentDoc;
    }

    public static Case createCase(Contact cont) {
        return new Case(
            ContactId = cont.Id
        );
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static Opportunity createOpportunity(String OppName, Id recordTypeId, Account Acc, Account LocationAccount) {
        Integer index;
        List<String> pckValues = new List<String>();
        String typ,typ1,typ2,typ3,busSeg,stgNm,forecst;
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.Type);
        index = pckValues.indexOf('Direct Customer: Sold-to');
        typ = index !=-1 ? pckValues[index] : pckValues[0];
        index = pckValues.indexOf('Sold-to');
        typ1 = index !=-1 ? pckValues[index] :pckValues[0];
        index = pckValues.indexOf('Ship-to');
        typ2 = index !=-1 ? pckValues[index] : pckValues[0];
        index = pckValues.indexOf('Bill-to');
        typ3 = index !=-1 ? pckValues[index] :pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.StageName);
        index = pckValues.indexOf('Prospecting');
        stgNm = index !=-1 ? pckValues[index] :pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.ForecastCategoryName);
        index = pckValues.indexOf('Pipeline');
        forecst =  index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.Business_Segment__c);
        //index = pckValues.indexOf('Animal Nutrition');
        //busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        busSeg = pckValues[0];
        return new Opportunity(
                Name = OppName,
                //AccountId = Acc.Id,
                //location__c = LocationAccount.Id,
                AccountId = LocationAccount.Id,
                Parent_Account__c = Acc.Id,
                RecordTypeId = recordTypeId,
                Type = typ+';'+typ1+';'+typ2+';'+typ3,   //'Direct Customer: Sold-to;Ship-to;Bill-to',
                CloseDate = System.today().addDays(2),
                StageName = stgNm , //'Prospecting',
                ForecastCategoryName =forecst,   //'Pipeline',
                Business_Segment__c = busSeg //'Animal Nutrition'
        );
    }

    public static Opportunity createFCINewBusinessOpportunity(String OppName, Account Acc, Account LocationAccount){
        return createOpportunity(OppName, Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId(), Acc, LocationAccount);
    }
    
    public static Case createCase(String CaseSubject,String Descrip,Account Acc,Account SoldToLocation){
        Integer index;
        String stats;
        index = (FetchPicklistValueUtilityClass.fetchPickListValues(Case.Status)).indexOf('Outstanding Notification');
        stats = index !=-1 ? FetchPicklistValueUtilityClass.fetchPickListValues(Case.Status)[index] : FetchPicklistValueUtilityClass.fetchPickListValues(Case.Status)[0];
        return new Case(
                Subject = CaseSubject,
                Description = Descrip,
                AccountId = SoldToLocation.Id,
                Parent_Account__c = Acc.Id,
                //AccountId = acc.Id,
                //Sold_to_Location__c = SoldToLocation.Id,
                RecordTypeId = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'BGI_Case' LIMIT 1].Id,
                status = 'New' //'Outstanding Notification'
        );
    }
    public static Lead createLead(String testCompany,String testLastName,Account DistributorLocation,Account Distributor,String recordType)
    {
         Integer index;
        String stats;
        index = (FetchPicklistValueUtilityClass.fetchPickListValues(Lead.Department__c)).indexOf('Finance');
         stats = index !=-1 ? FetchPicklistValueUtilityClass.fetchPickListValues(Lead.Department__c)[index] : FetchPicklistValueUtilityClass.fetchPickListValues(Case.Status)[0];
        return new Lead(
            LastName = testLastName,
            Company = testCompany,
            Distributor__c = Distributor.Id,
            Distributor_Location__c = DistributorLocation.Id,
            RecordTypeId = recordType,
            Department__c = stats//Finance
        );
    }

    public static String generateRandomUserName() {
        return UserInfo.getOrganizationId() + System.currentTimeMillis() + '@test.test';
    }


    public static void createInitialTestAccountsAndUsers() {
        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA');
        accsCustomLocToInsert.add(commercialCustDanone);
        

        Account agentAccount = TestUtility.createAgentAccount('Usta');
        accsCustomLocToInsert.add(agentAccount);
        insert accsCustomLocToInsert;

        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        customerLocItaly.BillingCountry = 'Italy';
        customerLocItaly.BillingCountryCode = 'IT';
        accsToInsert.add(customerLocItaly);

        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
        customerLocItaly.BillingCountry = 'France';
        customerLocItaly.BillingCountryCode = 'FR';
        accsToInsert.add(customerLocFrance);

        Account customerLocPoland = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCust);
        customerLocItaly.BillingCountry = 'Poland';
        customerLocItaly.BillingCountryCode = 'PL';
        accsToInsert.add(customerLocPoland);

        Account customerLocChina = TestUtility.createCustomerLocation('IMCD China', commercialCust);
        customerLocChina.BillingCountry = 'China';
        customerLocChina.BillingCountryCode = 'CN';
        accsToInsert.add(customerLocChina);

        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone);
        customerLocItaly.BillingCountry = 'Poland';
        customerLocItaly.BillingCountryCode = 'PL';
        accsToInsert.add(customerLocDanone);
        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>();
        Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly);
        contactsToInsert.add(cItaly);

        Contact cAgent = TestUtility.createAgentContact('Test','Agent', agentAccount);
        cAgent.Email = 'test12345@kvp.com';
        cAgent.OtherCountry = 'India';
        cAgent.OtherCountryCode = 'IN';
        contactsToInsert.add(cAgent);
        

        Contact cItalySubsegment = TestUtility.createContact('FirstTest','ItalySubSegment',commercialCust, customerLocItaly);
        cItalySubsegment.Email = 'test12345@kvp.com';
        cItalySubsegment.OtherCountry = 'India';
        cItalySubsegment.OtherCountryCode = 'IN';
        contactsToInsert.add(cItalySubsegment);

        Contact cFrance = TestUtility.createContact(commercialCust, customerLocFrance);
        contactsToInsert.add(cFrance);

        Contact cPoland = TestUtility.createContact(commercialCust, customerLocPoland);
        contactsToInsert.add(cPoland);

        Contact cDanonePoland = TestUtility.createContact(commercialCustDanone, customerLocDanone);
        contactsToInsert.add(cDanonePoland);

        Contact cManager = TestUtility.createContact(commercialCust, customerLocItaly);
        contactsToInsert.add(cManager);
        insert contactsToInsert;

        List<User> usersToInsert = new List<User>();
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrItaly.ContactId = cItaly.Id;
        usersToInsert.add(usrItaly);

        User usrItalySubSegment = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItalySubSegment', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        // usrItalySubSegment.Email = 'abcd@abcd.com';
        // usrItalySubSegment.Country = 'Australia';
        usrItalySubSegment.Community_Account_Role__c = 'Sub-Segment Responsible User';
        usrItalySubSegment.ContactId = cItalySubsegment.Id;
        // usrItalySubSegment.Alias = 't1';
        // usrItalySubSegment.LanguageLocaleKey = 'en_IN';
        // usrItalySubSegment.LocaleSidKey = 'en_IN';
        usersToInsert.add(usrItalySubSegment);

        User usrAgent = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestAgentSubSegment', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrAgent.Community_Account_Role__c = 'Sub-Segment Responsible User';
        usrAgent.ContactId = cAgent.Id;
        usersToInsert.add(usrAgent);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrFrance.ContactId = cFrance.Id;
        usersToInsert.add(usrFrance);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrPoland.ContactId = cPoland.Id;
        usersToInsert.add(usrPoland);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrDanonePoland.ContactId = cDanonePoland.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManager = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrManager.ContactId = cManager.Id;
        usersToInsert.add(usrManager);

        insert usersToInsert;

        
    }
    
    public static Visit_Report__c getVisitReportInstance(Account commercialCust,Account custLoc){
        Integer index;
        String stats, busSeg, purp;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Visit_Report__c.Status__c);
        index =pckValues.indexOf('Pre-Visit Report');
        stats = index !=-1 ? pckValues[index] :pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Visit_Report__c.Business_Segment__c);
        index = pckValues.indexOf('QSR EU');
        busSeg = index !=-1 ? pckValues[index] :pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Visit_Report__c.Purpose_of_the_Visit__c);
        index = pckValues.indexOf('Complaint Handling');
        purp = index !=-1 ? pckValues[index] : pckValues[0];
        return new Visit_Report__c(
            Name = 'Test',
            Customer_Name__c = custLoc.Id,
            Parent_Account__c = commercialCust.Id,
            Visit_Date__c = System.today(),
            Status__c =stats,  //'Pre-Visit Report',
            Business_Segment__c =busSeg,  //'QSR EU',
            RecordTypeId = Constants.VISIT_VBS_RECORD_TYPE_ID,
            Purpose_of_the_Visit__c =purp,  //'Complaint Handling',
            Agenda_Discussed__c = 'Test',
            Brief_Conclusion__c = 'Test');
    }

    public static Customer_Attendees__c getCustomerAttendeesInstance(Id visitRecId, Id contactId){
        return new Customer_Attendees__c(
            Related_Visit_Report__c = visitRecId,
            Contact__c  = contactId
        );
    }

    public static Salesforce_or_Non_Salesforce_User__c getSalesforceNonSalesforceUser(Id visitRecId,Id fcEmpId){
        return new Salesforce_or_Non_Salesforce_User__c(
            Related_Visit_Report__c = visitRecId,
            FrieslandCampina_Employee__c = fcEmpId
        );
    }
    
    public static Key_Buying_Factors__c getWITYKeyBuyingInstance(Visit_Report__c visitRec){
        return new Key_Buying_Factors__c(
            Visit_Report__c = visitRec.Id,
            Description__c = 'Test');
    }
    
    public static WITY_Scoring__c getWITYScoringInstance(Key_Buying_Factors__c keyBuy,String questionName,Decimal ratingOne,Decimal ratingtwo){
        return new WITY_Scoring__c(
            WITY_Key_Buying_Factors__c = keyBuy.Id,
            Question_Name__c = questionName,
            Rating_One__c = 5,
            Rating_Two__c = 7,
            Comments__c = 'Test');
    }

    public static Legal_Sales_Document__c getLegalInstance(Id customerNameId,Id CustomerLocId,Decimal totalNetSales){
        Integer index;
        List<String> pckValues = new List<String>();
        String lsdType,devRf,busSeg,fcLeg,busGrp;
        pckValues =FetchPicklistValueUtilityClass.fetchPickListValues(Legal_Sales_Document__c.Type_of_LSD__c);
        index = pckValues.indexOf('RFC T&Cs (Incl MPC Conditions)');
        lsdType = index !=-1 ? pckValues[index] : pckValues[0] ; 
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Legal_Sales_Document__c.Business_Group__c);
        index = pckValues.indexOf('FCI');
        busGrp = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Legal_Sales_Document__c.Deviations_from_RFC_LSD_Template__c);
        index = pckValues.indexOf('Deviations');
        devRf = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Legal_Sales_Document__c.FC_Legal_Entity__c);
        index = pckValues.indexOf('FC_Legal_Entity__c');
        fcLeg = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Legal_Sales_Document__c.Leading_Business_Segment__c);
        index = pckValues.indexOf('Adult Nutrition');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        fcLeg = 'FrieslandCampina Nederland B.V.';

        Legal_Sales_Document__c legalInstance = new Legal_Sales_Document__c(Status_of_LSD__c='No LSD',
                                                Total_Net_Sales_Value__c=totalNetSales,
                                                Parent_Account__c = customerNameId,
                                                Account_Name__c = CustomerLocId,
                                                Type_of_LSD__c = lsdType,  //'RFC T&Cs (Incl MPC Conditions)',
                                                Business_Group__c = busGrp,  //'FCI',
                                                Deviations_from_RFC_LSD_Template__c = devRf,  //'Deviations',
                                                FC_Legal_Entity__c   = fcLeg,  //'FrieslandCampina Nederland B.V.',
                                                Leading_Business_Segment__c = busSeg,  //'QSR EU',
                                                RecordTypeId = Constants.LEGAL_SALES_DEVIATION_RECORD_TYPE);
        return legalInstance;
    }

    public static SCAF__c getSCAFInstance(Id legalSalesId){
        Integer index;
        String standLiab,directDmg,fcLeg,indem,indirectDmg,standWarr,standOrd,standTerm,penalty,standGov;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Standard_Liability__c);
        index = pckValues.indexOf('No');
        standLiab = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Indemnity__c);
        index = pckValues.indexOf('Yes');
        indem = index !=-1 ?pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Standard_Warranties__c);
        index = pckValues.indexOf('Yes');
        standWarr =  index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Standard_Order_Process__c);
        index = pckValues.indexOf('No');
        standOrd = index !=-1 ? pckValues[index] :pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Direct_Damages_Capped__c);
        index = pckValues.indexOf('Invoice value');
        directDmg = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Standard_Termination__c);
        index = pckValues.indexOf('Yes');
        standTerm = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Indirect_Damages_ExcludedCapped__c);
        index = pckValues.indexOf('Yes, Excluded');
        indirectDmg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Penalties_or_Other_Financial_Exposure__c);
        index = pckValues.indexOf('Yes');
        penalty = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(SCAF__c.Standard_Governing_Law__c);
        index = pckValues.indexOf('Yes');
        standGov = index !=-1 ? pckValues[index] :pckValues[0];
        
        
        SCAF__c scafInstance = new SCAF__c(LSD_StartEffective_Date__c = System.today(),
                                    Initial_Term_of_LSD_In_Months__c = 72,
                                    Termination_Notice_Period_In_Months__c = 42,
                                    Standard_Liability__c = standLiab,  //'No',
                                    Indemnity__c = indem, // 'Yes',
                                    Standard_Warranties__c  =standWarr,   //'Yes',
                                    Aggregate_Liability_Cap_Amount_EUR__c = 11000000,
                                    Standard_Order_Process__c =standOrd,  //'No',
                                    Liability_Cap_Per_Year_EUR__c = 4000,
                                    Direct_Damages_Capped__c =directDmg,   //'Invoice value',
                                    Standard_Termination__c = standTerm,  //'Yes',
                                    Indirect_Damages_ExcludedCapped__c =indirectDmg,   //'Yes, Excluded',
                                    Penalties_or_Other_Financial_Exposure__c =penalty,  //'Yes',
                                    Standard_Governing_Law__c =standGov,   //'Yes',
                                    Legal_Sales_Document__c = legalSalesId,
                                    RecordTypeId = Constants.SCAF_DEVIATION_RECORD_TYPE);
        return scafInstance;
    }

    public static void createQueue(String queueName,String sObjectName){
        
        Group g = new Group(Type='Queue', Name=queueName);
        insert g;

        QueueSObject q = new QueueSObject(SobjectType = sObjectName, QueueId=g.Id);
        insert q;
    }

    public static Sales_Area__c createSalesArea(String sName,Account cust, String sOrgName, String sOrg, String distChannel,String division){

        return new Sales_Area__c(Name = sName,
            Customer_Name__c        = cust.Id,
            DISTR_CHAN__c           = distChannel,
            DIVISION__c             = division,
            SALES_ORG__c            = sOrgName,
            Sales_Organization__c   = sOrg,
            External_Key__c         = cust.SAP_Number_PE1__c + '-' + sOrg + '-' + distChannel + '-' + division
        );
    }

    public static Partner_Role__c createPartnerRole(String pName, Account targetAcc, Account sourceAcc, Sales_Area__c sArea, String sOrg, String partnerCode){

        return new Partner_Role__c(Name = pName,
            Target_Account__c = targetAcc.Id,
            Source_Account__c = sourceAcc.Id,
            Sales_Area__c = sArea.Id,
            Sales_Organization__c = sOrg,
            Partner_Code__c = partnerCode,
            External_Key__c = sourceAcc.SAP_Number_PE1__c + '-' + sOrg + '-' + sArea.DISTR_CHAN__c + '-' + sArea.DIVISION__c + '-' + partnerCode + '-' + targetAcc.SAP_Number_PE1__c
        );
    }

    public static  Contract createContract(Account commercialCust, Account customerLocation){

        return new Contract(
            Status ='Draft',
            Parent_Account__c = commercialCust.id,
            AccountId = customerLocation.id,
            StartDate = system.today(),
            EndDate = system.today()+25
        );
    }

    public static Order createOrder(Account commercialCust, Account customerLocation){

        return new Order(
            Parent_Account__c = commercialCust.id,
            AccountId =customerLocation.id
        );
    }

    public static Delivery__c createDelivery(Account customerLocation){

         return new Delivery__c(
            Sold_To__c = customerLocation.id,
            Ship_To__c = customerLocation.id
        );
    }

    public static AccountShare createAccountShareforPortalUsers(Account acc, User usr){

        return new AccountShare(
            AccountId = acc.Id,
            AccountAccessLevel = Constants.SHARE_ACCESS_LEVEL_READ,
            CaseAccessLevel = Constants.SHARE_ACCESS_LEVEL_NONE,
            OpportunityAccessLevel = Constants.SHARE_ACCESS_LEVEL_NONE,
            ContactAccessLevel = Constants.SHARE_ACCESS_LEVEL_NONE,
            RowCause = Constants.SHARE_ROW_CAUSE_MANUAL,
            UserOrGroupId = usr.Id
        );
    }
    
     public static ContentVersion getContentVersionToInsert(Blob base64Data,String fileName){

       //  base64Data = EncodingUtil.urlDecode(String.valueOf(base64Data), 'UTF-8');

        ContentVersion conVer   = new ContentVersion(
                        ContentLocation = 'S',          // to use S specify this document is in Salesforce, to use E for external files
                        PathOnClient    = fileName,     // The files name, extension is very important here which will help the file in preview.
                        Title           = fileName,     // Display name of the files
                        versionData     = base64Data,  // Body/Content of the File
                        IsMajorVersion = false  
                );

        return conVer;
    }
    
    //Create a new record in the custom Account team object (Account_Team__c)
    public static Account_Team__c createAccountTeamMember_Custom(User user, Account acc, String teamMemberRole, String businessSegment){
        return new Account_Team__c(
                Team_Member__c = user.Id,
                Source_Account__c = acc.Id,
                Team_Role__c = teamMemberRole,
            	Business_Segment__c = businessSegment
        );
    }
     
 }