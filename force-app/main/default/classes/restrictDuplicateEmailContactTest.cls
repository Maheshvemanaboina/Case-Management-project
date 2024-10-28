@isTest
public class restrictDuplicateEmailContactTest {
    @testSetup
    static void setup() {
        List<contact> conist = new List<contact>();
        List<contact> conist1 = new List<contact>();
        Account acc = new Account(name='Test Account',BillingStreet = '3022  Strother Street',
                                  BillingCity = 'WORMERVEER',
                                  BillingState = 'Ain V',
                                  BillingPostalCode = '35222',
                                  BillingCountry = 'France');
        insert acc;
        
        for(Integer i = 1; i <= 10; i++) {
            contact con = new contact();
            
            con.FirstName = 'Account ' + i;
            con.LastName = 'Account ' + i;
            con.email = 'test@gmail.com';
            con.accountId = acc.id;
            
            conist.add(con);
        }
        insert conist;
    }
    
    static testmethod void test() {
        list<contact> lr =[select id,name,accountId from contact];
        Test.startTest();
        for(contact c :[select id,name,accountId from contact limit 1] ){
            c.FirstName = 'test';
            c.FirstName = 'test2';
            c.email = 'test2@gmail.com';
            update c;
        }
        Test.stopTest();
        
    }
}