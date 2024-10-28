/**
* Author   :   suyogya jain
* Date     :   17 march 2022
* Desc     :   validation to check if opportunities is open for any specific account.In such case show an validation message.
* */

public class restrictUserTomakeAccountInactive {
    
    public static void showErrorMessage(list<account> acc,map<id,account>oldMap){
        map<id,integer>oppMapCount = new map<id,integer>();
        list<account> accls = new list<account>();
        string ProspectRT = Schema.SObjectType.account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        system.debug('prospect------'+ProspectRT);
        set<id> AccId = new set<id>();
         
        for(account accdata : acc){
            account accd = new account();
            accd= oldMap.get(accdata.Id);
            if(accdata.recordTypeId == ProspectRT && accdata.Active__c==false && accd.Active__c != accdata.Active__c)                                         //check for prospect account and is updated to inactive
                AccId.add(accdata.id);
            //  }
        }
        if(AccId.size()>0){                                                                                            //avoiding soql to be run on every prospect account update
            accls =[select id,Active__c,(select id,name,stageName from opportunities where stageName!= 'Closed Lost'AND stageName!= 'Closed Won') from account where Id IN :AccId];
        }
        for(account a : accls){
            oppMapCount.put(a.id,a.opportunities.size());
        }
        
        for(account accd : acc){
            if(oppMapCount.containsKey(accd.Id) && oppMapCount.get(accd.id)>0 && accd.Active__c==False){
                accd.adderror('Prospect accounts with active opportunities cannot be de-activated');
            }
        }
    }
}