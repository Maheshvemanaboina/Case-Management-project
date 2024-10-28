@isTest
public class AccountRegionUpdateTest {
    @isTest
    static void updateRegiontest(){
        List<Account> acc = new List<Account>();
        Account prospect = TestUtility.createAccount('China test oil');
        prospect.BillingCountryCode = null;
        acc.add(prospect);
        insert acc;
        List<Account> accloc = new List<Account>();
        Account location = TestUtility.createCustomerLocation('China loc', prospect);
        //location.BillingCountryCode='IT';
        accloc.add(location);
        insert accloc;
        //AccountRegionUpdateHandler.getCountrySetting(accloc);
    }
}