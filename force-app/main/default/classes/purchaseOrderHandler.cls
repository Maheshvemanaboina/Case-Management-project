public without sharing class purchaseOrderHandler {

    public static void CaseClosureLogic(Map<id,Purchase_order__c> OldPOMap,Map<id,Purchase_order__c> NewPOMap)
    {
        Set<id> CaseIds = new Set<Id>();
        Map<Id,List<Purchase_order__c>> CasePOMap = new Map<Id,List<Purchase_order__c>>();
        List<Case> CUpdList = new List<Case>();
        for(Purchase_order__c newPO : NewPOMap.values())
        {
            System.debug('Hello');
            Purchase_order__c OldPO = OldPOMap.get(newPO.Id);
            if((newPO.Status__c!=OldPO.Status__c) && (newPO.Status__c == 'Closed' || newPO.Status__c == 'Declined'))
            {
                CaseIds.add(newPO.Case__c);
            }
        }
        System.debug('CaseIds --> '+CaseIds);
        if(!CaseIds.isEmpty())
        {
            List<String> POStatus = new List<String>();
            POStatus.add('Closed');
            POStatus.add('Declined');
            List<Case> CaseList = [Select id,(select id from Purchase_orders__r) from Case where Id in:CaseIds];
            List<purchase_order__c> polist = [Select id,Case__c from purchase_order__c where case__c in:CaseIds and status__c in:POStatus];
            System.debug('polist -->'+polist.size());
            for(purchase_order__c p : polist)
            {
                if(!CasePOMap.containsKey(p.Case__c))
                {
                    List<Purchase_order__c> newPOList = new List<Purchase_order__c>();
                    newPOList.add(p);
                    CasePOMap.put(p.Case__c,newPOList);
                }
                else
                {
                    List<Purchase_order__c> existPOList = CasePOMap.get(p.Case__c);
                    existPOList.add(p);
                    CasePOMap.put(p.Case__c,existPOList);
                }
            }
            for(Case c : CaseList)
            {
                if(c.Purchase_orders__r.size() == CasePOMap.get(c.Id).size())
                {
                    c.Status = 'Closed';
                    CUpdList.add(c);
                }
            }
        }
        if(!CUpdList.isEmpty())
        {
            update CUpdList;
        }
    }
}