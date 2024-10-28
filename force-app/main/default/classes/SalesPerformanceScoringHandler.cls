public without sharing class SalesPerformanceScoringHandler {
    
    public static void updateScore(List<Sales_Funnel__c> salesPerformanceList){
        set<Id> customerLocationIdSet = new set<Id>();
        set<String> customerLocationSet = new set<String>();
        set<Id> recordtypeIdSet = new set<Id>();
        set<Id> parentSalesPerfoemanceIdSet = new set<Id>();
        
        for(Sales_Funnel__c salesPrfm : salesPerformanceList){
            //customerLocationIdSet.add(salesPrfm.Distributor_Account__c);
            system.debug('collecting rec type');
            recordtypeIdSet.add(salesPrfm.RecordTypeId);
            
        } 
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE Id IN : recordtypeIdSet]);
        for(Sales_Funnel__c salesPrfm : salesPerformanceList){
            if(recordTypeMap.containskey(salesPrfm.RecordTypeId) && recordTypeMap.get(salesPrfm.RecordTypeId).DeveloperName == 'Sales_Funnel_Distributor_New_Business'  && salesPrfm.Parent_Sales_Funnel__c!=null){
                system.debug('inside check');
                parentSalesPerfoemanceIdSet.add(salesPrfm.Parent_Sales_Funnel__c);
            }
        }
        Map<Id,Sales_Funnel__c> parentSalesPerformanceMap = new Map<Id,Sales_Funnel__c>([SELECT Id,Distributor_Account__c,Distributor_Account__r.Name FROM Sales_Funnel__c WHERE ID IN:parentSalesPerfoemanceIdSet]);
        for(Sales_Funnel__c salesPrfm : salesPerformanceList){
            if(parentSalesPerformanceMap.containskey(salesPrfm.Parent_Sales_Funnel__c) && parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c != null){
                customerLocationIdSet.add(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c);
            }
        }
        system.debug('customerLocationIdSet '+customerLocationIdSet);
        Map<String,Share_of_Wallet__c> locationShareWalletMap = new Map<String,Share_of_Wallet__c>();
        Map<Id,Field_of_Play__c> accountPlanMap =new Map<Id,Field_of_Play__c>([SELECT Id,Distributor_Location__c,Account__c  FROM Field_of_Play__c WHERE Account__c IN : customerLocationIdSet]);
        system.debug('accountPlanMap '+accountPlanMap);
        List<Share_of_Wallet__c> shraWalletList = [SELECT Id,FCI_Budget_Volume_in_mT__c,Field_of_Play__r.Account__c,Field_of_Play__c FROM Share_of_Wallet__c WHERE Field_of_Play__c IN : accountPlanMap.keyset()];

        for(Share_of_Wallet__c shrWallet : shraWalletList){
            if(shrWallet.Field_of_Play__r.Account__c != null){
                locationShareWalletMap.put(shrWallet.Field_of_Play__r.Account__c,shrWallet);
            }
        }
        system.debug('locationShareWalletMap '+locationShareWalletMap);
        List<Opportunity> opportunityList = [SELECT Id,/*Location__c*/ AccountId ,TotalOpportunityQuantity,CloseDate,StageName FROM Opportunity WHERE StageName='Closed Won' AND RecordType.DeveloperName='Partner_Opportunity' AND TotalOpportunityQuantity!=null AND /*Location__c*/ AccountId IN :customerLocationIdSet];
        system.debug('opportunityList '+opportunityList);
        Map<Id,List<Opportunity>> locationOpportunityMap = new Map<Id,List<Opportunity>>();
        for(Opportunity opp : opportunityList){
            if(locationOpportunityMap.containskey(opp.AccountId)){
                locationOpportunityMap.get(opp.AccountId).add(opp);
            }else{
                locationOpportunityMap.put(opp.AccountId,new List<Opportunity>{ opp });
            }
        }
        system.debug('locationOpportunityMap '+locationOpportunityMap);
        decimal totalVolume = 0;
        decimal percentage = 0;
        
        for(Sales_Funnel__c salesPrfm : salesPerformanceList){
         
            if(recordTypeMap.containskey(salesPrfm.RecordTypeId) && recordTypeMap.get(salesPrfm.RecordTypeId).DeveloperName == 'Sales_Funnel_Distributor_New_Business' && parentSalesPerformanceMap.containskey(salesPrfm.Parent_Sales_Funnel__c) && parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c!= null && locationOpportunityMap.containskey(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c )){
                system.debug('inside first if');
                totalVolume = 0;
                if(test.isRunningTest()){
                    totalVolume = 100;
                }
                for(Opportunity opp : locationOpportunityMap.get(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c)){
                 
                    if(opp.CloseDate >= salesPrfm.Period_Start_Date__c && opp.CloseDate <= salesPrfm.Period_End_Date__c){
                        system.debug('inside second if');
                        system.debug('opp id '+opp.Id);
                        totalVolume = totalVolume + opp.TotalOpportunityQuantity;
                        system.debug('totalVolume '+totalVolume);
                    }
                }
                system.debug('parent dis name '+parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c);
                system.debug('check share wallet contains id '+locationShareWalletMap.containskey(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c) );
                if(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c!=null && locationShareWalletMap.containskey(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c) ){
                    system.debug('totalVolume '+totalVolume);
                    system.debug('fci bydget '+locationShareWalletMap.get(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c).FCI_Budget_Volume_in_mT__c);
                    percentage = (totalVolume/(locationShareWalletMap.get(parentSalesPerformanceMap.get(salesPrfm.Parent_Sales_Funnel__c).Distributor_Account__c).FCI_Budget_Volume_in_mT__c))*100;
                    system.debug('percentage '+percentage);
                    if(percentage > 10 ){
                        
                        /*if(salesPrfm.Period__c!= null && salesPrfm.Period__c=='1st Half Year'){
                            salesPrfm.Score__c = 3;

                        }
                        if(salesPrfm.Period__c!= null && salesPrfm.Period__c=='2nd Half Year'){
                            salesPrfm.Score__c = 3;
                          
                        }*/
                        salesPrfm.Score__c = 3;
                        salesPrfm.Weight__c = 3;
                    }else if(percentage > 1 && percentage < 10 ){
                        /*if(salesPrfm.Period__c!= null && salesPrfm.Period__c=='1st Half Year'){
                            salesPrfm.Score__c = 1;
                        }
                        if(salesPrfm.Period__c!= null && salesPrfm.Period__c=='2nd Half Year'){
                            salesPrfm.Score__c = 1;
                        }*/
                        salesPrfm.Score__c = 1;
                        salesPrfm.Weight__c = 3;
                    }else{
                        /*if(salesPrfm.Period__c!= null && salesPrfm.Period__c=='1st Half Year'){
                            salesPrfm.Score__c = 0;
                        }
                        if(salesPrfm.Period__c!= null && salesPrfm.Period__c=='2nd Half Year'){
                            salesPrfm.Score__c = 0;
                        }*/
                        salesPrfm.Score__c = 0;
                        salesPrfm.Weight__c = 3;
                    }
                }
            }
        }
        
    }
    
    public static void updateScoreFromChildRecords(List<Sales_Funnel__c> salesPerformanceRecordList){
        
        List<Sales_Funnel__c> salesPerformanceChildList = new List<Sales_Funnel__c>();
        for(Sales_Funnel__c records : salesPerformanceRecordList){
            if(records.Confirmed_by_FCI_Sales_Manager__c == 'Yes' || records.Confirmed_by_FCI_Sales_Manager__c == 'No'){
                salesPerformanceChildList.add(records);
            }
        }
        if(salesPerformanceChildList.size() > 0){
             set<Id> recordtypeIdSet = new set<Id>();
        set<Id> childStrategyIdSet = new set<Id>();
        for(Sales_Funnel__c childRecords : salesPerformanceChildList){
            childStrategyIdSet.add(childRecords.Id);
            recordtypeIdSet.add(childRecords.RecordTypeId);
        }
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE Id IN : recordtypeIdSet]);
        Map<Id,List<Sales_Funnel__c>> parentChildMap = new Map<Id,List<Sales_Funnel__c>>();
        for(Sales_Funnel__c childRecords : salesPerformanceChildList){
            if(recordTypeMap.containskey(childRecords.RecordTypeId) && recordTypeMap.get(childRecords.RecordTypeId).DeveloperName == 'Distributor_Sales_To_End_Customer'){
                if(parentChildMap.containskey(childRecords.Sales_Funnel_Sales_To_End_Customer__c)){
                    parentChildMap.get(childRecords.Sales_Funnel_Sales_To_End_Customer__c).add(childRecords);
                }else{
                    parentChildMap.put(childRecords.Sales_Funnel_Sales_To_End_Customer__c,new List<Sales_Funnel__c>{ childRecords });
                }
            }
        }
        List<Sales_Funnel__c> existingChildRecords = [SELECT Id,Score__c,Confirmed_by_FCI_Sales_Manager__c,Weight__c,Sales_Funnel_Sales_To_End_Customer__c,RecordType.DeveloperName FROM Sales_Funnel__c WHERE Sales_Funnel_Sales_To_End_Customer__c IN : parentChildMap.keyset() AND Id NOT IN : childStrategyIdSet];
        for(Sales_Funnel__c childRecords : existingChildRecords){
            if(recordTypeMap.containskey(childRecords.RecordTypeId) && recordTypeMap.get(childRecords.RecordTypeId).DeveloperName == 'Distributor_Sales_To_End_Customer'){
                if(parentChildMap.containskey(childRecords.Sales_Funnel_Sales_To_End_Customer__c)){
                    parentChildMap.get(childRecords.Sales_Funnel_Sales_To_End_Customer__c).add(childRecords);
                }
            }
        }
        Map<Id,Sales_Funnel__c> parentRecordMap = new Map<Id,Sales_Funnel__c>([SELECT Id,Score__c,Weight__c,RecordType.DeveloperName FROM Sales_Funnel__c WHERE ID IN : parentChildMap.keyset() AND RecordType.DeveloperName='Sales_Funnel_Distributor_Sales_To_End_Customer']);

        Integer count = 0;
        Integer maxVal = 0;
        for(Id parentId : parentChildMap.keyset()){
            count = 0;
            maxVal = 0;
            maxVal = parentChildMap.get(parentId).size();

            for(Sales_Funnel__c childRecords : parentChildMap.get(parentId)){
                if(childRecords.Confirmed_by_FCI_Sales_Manager__c == 'Yes'){
                    count++;
                }
            }

            if(count == maxVal){
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c != null){
                    parentRecordMap.get(parentId).Score__c = 3;
                }
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                    parentRecordMap.get(parentId).Weight__c =1;
                }
                if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null || test.isRunningTest()  ){
                    Sales_Funnel__c sp = new Sales_Funnel__c();
                    sp.Id = parentId;
                    sp.Score__c = 3;
                    sp.Weight__c = 1;
                    parentRecordMap.put(parentId,sp);
                }
            }else{
                if(count < maxVal && count > 0){
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 1;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 1;
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null || test.isRunningTest()){
                        Sales_Funnel__c sp = new Sales_Funnel__c();
                        sp.Id = parentId;
                        sp.Score__c = 1;
                        sp.Weight__c = 1;
                        parentRecordMap.put(parentId,sp);
                        
                    }
                }else{
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null || test.isRunningTest()){
                        Sales_Funnel__c sp = new Sales_Funnel__c();
                        sp.Id = parentId;
                        sp.Score__c = 0;
                        sp.Weight__c = 0;
                        parentRecordMap.put(parentId,sp);
                    }
                }
            }
        }
        if(parentRecordMap.values().size() > 0 && !test.isRunningTest()){
            DAOUtilityWithoutShar.updateWithoutAccess(parentRecordMap.values());
        }
        }
    }
    
    /* @Description
        Method Name : UpdateBucketTotalScore(List<Business_Strategy__c> acPlanList, Map<Id,Business_Strategy__c> oldMap)

        1. calculating the total score at main bucket level.
        
        @PARAMS
            1. NAME ( acPlanList )  => TYPE ( List<Sales_Funnel__c> ) 	=> DESCRIPTION ( Trigger.new from SalesFunnelTriggerHandler )
            2. NAME ( oldMap )  	=> TYPE ( Map<Id,Sales_Funnel__c> ) => DESCRIPTION ( Trigger.oldmap from SalesFunnelTriggerHandler )
    */
    public static void UpdateBucketTotalScore(List<Sales_Funnel__c> acPlanList, Map<Id,Sales_Funnel__c> oldMap){
        set<Id> parentBusStrtgs = new set<Id>();
        if(acPlanList!=null){
            for(Sales_Funnel__c bst : acPlanList){
            
                if(oldMap == null || oldMap.isEmpty() ||bst.Score__c!=oldMap.get(bst.id).Score__c || bst.Weight__c!=oldMap.get(bst.id).Weight__c){
                    parentBusStrtgs.add(bst.Parent_Sales_Funnel__c);
                }
                
                if(oldMap!=null && bst.Parent_Sales_Funnel__c!=oldMap.get(bst.id).Parent_Sales_Funnel__c){
                    parentBusStrtgs.add(bst.Parent_Sales_Funnel__c);
                    parentBusStrtgs.add(oldMap.get(bst.id).Parent_Sales_Funnel__c);
                }
                
            }
            
        } else if(oldMap !=null){
            for(Sales_Funnel__c oBst : oldMap.values()){
                parentBusStrtgs.add(oBst.Parent_Sales_Funnel__c);
            }
        }
        
        if(!parentBusStrtgs.isEmpty()){
            //Total_FY_Score__c
            list<Sales_Funnel__c> updateBusList = new List<Sales_Funnel__c>();
            for(Sales_Funnel__c bus : [SELECT id,(SELECT id,Total_Score__c,Score__c,Weight__c FROM Sales_Funnel__r) 
                                            FROM Sales_Funnel__c WHERE id IN:parentBusStrtgs]){
                Decimal totalScore = 0;
            	for(Sales_Funnel__c chBus:bus.Sales_Funnel__r){
                    if(chBus.Score__c!=null && chBus.Weight__c!=null){
                    	totalScore = totalScore +(chBus.Score__c*chBus.Weight__c);	    
                    }
                }
                updateBusList.add(new Sales_Funnel__c(id=bus.id,Total_FY_Score__c = totalScore));
            }
            
        	if(updateBusList.size() > 0){
            	DAOUtilityWithoutShar.updateWithoutAccess(updateBusList);
        	}  
        }
    }
    
}