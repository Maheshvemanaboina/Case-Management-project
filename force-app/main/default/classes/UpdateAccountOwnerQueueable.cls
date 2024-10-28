/*      
@Name                  UpdateAccountOwnerQueueable
@Author                Mahendra mahendra.kumar@frieslandcampina.com
@Version               1.0
@CreatedDate           23-09-2022
@UsedBy                AccountTriggerHandler
@TestClass			   AccountTriggerHandlerTest
@Description           To assign the owner as soon as the end customer is created by the distributor user from disti community
@Changes
UserId           | Author-Email                   	  | Date      | Comment
=================|====================================|===========|=========
			     |									  | 	   	  | 
*/
public class UpdateAccountOwnerQueueable implements Queueable {
    List<Account> accountList = new List<Account>();
    
    public UpdateAccountOwnerQueueable(List<Account> accounts) {
        this.accountList = accounts;
    }
    
    public void execute(QueueableContext qc){
        //system.debug('accountsMap = '+accountsMap);
        List<Account> copyOfAccountList = new List<Account>();
        for(Account acc : accountList){
            Account accCopy = new Account(
            	Id = acc.Id,
                RecordTypeId = acc.RecordTypeId,
                Business_Segment__c = acc.Business_Segment__c,
                Distributor_Location__c = acc.Distributor_Location__c,
                OwnerId = acc.OwnerId
            );
            copyOfAccountList.add(accCopy);
        }
        UpdateAccountOwner.updateOwner(copyOfAccountList);
    }
}