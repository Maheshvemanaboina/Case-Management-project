public Without sharing class MultiplePOExtension {
    
    public Case c;
    public List<Purchase_Order__c> plist{set;get;}
    public List<Purchase_Order__c> pnewlist{set;get;}
    public String currTourType{set;get;}
    public Map<String,purchase_order__c> purMap;
    public MultiplePOExtension(ApexPages.StandardController contr)
    {
        c = (Case)contr.getRecord();
        purMap = new Map<String,Purchase_order__c>();
        pnewlist = new List<Purchase_Order__c>();
        plist = [Select id,Case__c,New_Delivery_Date__c,New_Delivery_Time__c,Old_Delivery_Date__c,Old_Delivery_Time__c,Order_Number_FC__c,PO_Number__c,Case__r.CaseNumber,Within_Forecast__c,Reason_of_Decline__c,Status__c from Purchase_Order__c where Case__c=:c.Id];
        if(plist.isEmpty())
        {
            Purchase_Order__c po = new Purchase_Order__c();
            pnewlist.add(po);
        }
        else
        {
            Purchase_Order__c po = new Purchase_Order__c();
            pnewlist.add(po);
            for(Purchase_Order__c pl : plist)
            {
                purMap.put(pl.PO_Number__c, pl);
            }
        }
    }
    public void AddPO()
    {
        System.debug('pnewlist--> '+pnewlist);
        System.debug('currTourType--->'+currTourType);
        Purchase_Order__c por = pnewlist.get(Integer.valueOf(currTourType)-1);
        system.debug('-----por Old_Delivery_Time__c----- ' + por.Old_Delivery_Time__c);
        System.debug('por order number '+por.PO_Number__c);
        if(por.PO_Number__c != null)
        {
            Purchase_Order__c po = new Purchase_Order__c();
            pnewlist.add(po);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Enter all informations before adding new Purchase Order'));
        }
    }
    public void DeletePO()
    {
        if(pnewlist.size()!=1)
        {
            System.debug('-------------------->'+ApexPages.currentPage().getParameters().get('passNum'));
            Integer counter = Integer.valueOf(ApexPages.currentPage().getParameters().get('passNum'));
            pnewlist.remove(--counter);
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is only 1 item, it cannot be Deleted');
            ApexPages.addMessage(myMsg);
        }
    }
    public Pagereference doSave()
    {
        List<purchase_order__c> listiterate = new List<Purchase_order__c>();
        if(!pnewlist.isEmpty())
        {
            List<purchase_order__c> polist = new List<Purchase_order__c>();
            System.debug('pnewlist in save'+pnewlist);
            for(purchase_order__c p : pnewlist)
            {
                if(p.PO_Number__c!=null && !purMap.containsKey(p.PO_Number__c.trim()))
                {
                    purchase_order__c pr = new purchase_order__c();
                    pr.Case__c = c.Id;
                    pr.PO_Number__c = p.PO_Number__c;
                    pr.Order_Number_FC__c = p.Order_Number_FC__c;
                    pr.New_Delivery_Date__c = p.New_Delivery_Date__c;
                    pr.New_Delivery_Time__c = p.New_Delivery_Time__c;
                    pr.Old_Delivery_Date__c = p.Old_Delivery_Date__c;
                    pr.Old_Delivery_Time__c = p.Old_Delivery_Time__c;
                    pr.Within_Forecast__c = p.Within_Forecast__c;
                    pr.Status__c = p.Status__c;
                    pr.Reason_of_Decline__c = p.Reason_of_Decline__c;
                    polist.add(pr);
                }
            }
            if(!polist.isEmpty())
            {
                insert polist;
            }
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Save as no purchase order added');
            ApexPages.addMessage(myMsg);
        }
        if(!plist.isEmpty())
        {
            update plist;
        }
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Records are successfully Saved');
        ApexPages.addMessage(myMsg);
        return null;
    }
}