/*
Created : Suyogya Jain
Description : This class is used to check if any user is creating contact with the dupliate email which is 
already present under same account .So In this case it won't allow that user to craete contact under that specific account.
*/

public class restrictDuplicateEmailContact {
    public static void findDuplicate(list<contact>conl,map<id, contact> oldMap){
        set<ID> accountIds = new set<ID>();
        Map <String , Contact> mapToCheckDuplicateContacts = new Map <String , Contact>();
        set<String> setCheckDuplicateinSameList = new set<String>(); //check Duplicates in the Same List Bulk Insertion
        for(Contact conVar:conl){
            
            if(setCheckDuplicateinSameList.contains(conVar.Email +'-'+ conVar.AccountId)){
               // conVar.addError('Duplicae Contact in Bulk Insertion');
            }
            if(!setCheckDuplicateinSameList.contains(conVar.Email +'-'+ conVar.AccountId)){
                setCheckDuplicateinSameList.add(conVar.Email +'-'+ conVar.AccountId);
            }
            if(trigger.isInsert){
                if(conVar.Email != null){
                    accountIds.add(conVar.accountId);
                }
            }
            if(trigger.isUpdate){
                if(oldMap.get(conVar.Id).accountId != conVar.accountId || oldMap.get(conVar.Id).Email != conVar.Email){
                    if(conVar.Email != null){
                        accountIds.add(conVar.accountId);					
                    }
                }
            }
        }
        if(accountIds.size() > 0){ 
            for(Contact conObj :[Select id,email , accountId from contact where accountId in:accountIds]){
                mapToCheckDuplicateContacts.put(conObj.Email +'-'+ conObj.AccountId , conObj);
            }
            for(Contact con:conl){
                if(mapToCheckDuplicateContacts.containsKey(con.Email +'-'+ con.AccountId) ){
                    con.addError('You are creating a duplicate record. We recommend you use an existing record instead');
                }
            }
        }
    }
}