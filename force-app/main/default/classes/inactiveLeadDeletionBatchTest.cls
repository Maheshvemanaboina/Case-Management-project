@isTest
public class inactiveLeadDeletionBatchTest {
    @testSetup
    static void setup() {        
        Profile prof = [select id from profile where name = 'New FCl Lightning Users'];        
        String testLbl = Label.Pardot_User_ID;
        List<lead> Leads = new List<lead>();
        List<lead> updateLeads = new List<lead>();
        // insert 10 leads
        for (Integer i=0;i<10;i++) {
            Lead l= new Lead();
            l.lastName='test'+i;
            l.Status='New';
            l.Company='open';
            l.active__c= true;
            l.IsConverted = false;
            Date myDate = system.today()-189;
            Time myTime = Time.newInstance(8, 0, 0, 0);
            DateTime dt1 = DateTime.newInstanceGMT(myDate, myTime);
            l.CreatedDate=dt1;
            l.LastModifiedDate =dt1;
            if(i==3){
               l.Last_Activity_Date__c =dt1; 
            }            
            leads.add(l);
        }
        insert leads;        
        Date myDate =system.today()-1;
        Time myTime = Time.newInstance(8, 0, 0, 0);
        DateTime dt3 = DateTime.newInstanceGMT(myDate, myTime);
    }  
   	 static testmethod void test() {
        String testLbl = Label.Pardot_User_ID;
        list<lead> lr =[select id,name,LastModifiedDate,createdDate from lead ];
        system.debug('data inside-'+lr);
        system.debug('data inside-'+lr.size());
        Test.startTest();
        inactiveLeadDeletionBatch uca = new inactiveLeadDeletionBatch();
        database.executeBatch(uca);
        Test.stopTest();
        list<lead> ld =  [Select id,active__c,ownerId from lead] ;
        System.assertEquals(10, ld.size());       
        
    }
    
    
}