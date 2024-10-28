@IsTest(SeeAllData = true)
public with sharing class LightningSelfRegisterControllerTest {
    
    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword() {
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
        System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
    }
    
    @IsTest
    static void testSiteAsContainerEnabled() {
        string baseURL = 'https://'+DomainCreator.getExperienceCloudSitesHostname();
        System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled(baseURL));
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
        System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
    }
    
    
    /* Verifies the selfRegistration flow for valid inputs */
    @IsTest
    static void testSelfRegisterWithProperCredentials() {
        Map < String, String > paramsMap = initializeParams();
        System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
    }
    
    /* Verifies SelfRegistration flow with an accounId that is created within the test */
    @IsTest
    static void testSelfRegisterWithCreatedAccount() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        Account acc = new Account(name = 'test acc test 123456789');
        acc.Name='test acc test 123456789';
        acc.BillingStreet = 'TestBillingStreet 1 test test test';
        acc.BillingPostalCode = '12345-9918123014';
        acc.BillingCity = 'CityTest1';
        acc.BillingCountry = 'Italy';
        acc.BillingCountryCode = 'IT';
        Database.insert(acc, dml);
        //insert acc;
        List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
        System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
        String accountId = accounts[0].Id;
        Map < String, String > paramsMap = initializeParams();
        System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
    }
    
    @IsTest
    static void testGetNullExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null));
    }
    
    @IsTest
    static void testGetNonEmptyExtraFields() {
        System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'));
    }
    
    /* Verifies validation of extraFields within the Self Registration flow */
    @IsTest
    static void testGetExtraFieldsInSelfRegistration() {
        List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
        Map < String, String > paramsMap = initializeParams();
        Map < String, Object > fieldMap = new Map < String, Object > ();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
    }
    
    @IsTest
    static void LightningSelfRegisterControllerInstantiation() {
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        System.assertNotEquals(controller, null);
    }
    
    /* Helper method to initialize the parameters required for SelfRegistration. */
    private static Map < String, String > initializeParams() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
    
    @IsTest
    static void LightningSelfRegistersetExperienceId() {
        LightningSelfRegisterController.setExperienceId('testexpid');
        LightningSelfRegisterController.setExperienceId('');
    }
    
}