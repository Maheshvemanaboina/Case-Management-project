public Without sharing class OpportunityLineItemTriggerHandler {
    
    public static void updateNPDProjectOnOpportunity(List<OpportunityLineItem> opportunityLineItemLst){
        
        Set<id> productsId = new Set<id>();
        Set<id> opportunitiesId = new Set<id>();
        Map<id,id> productProjectmap = new Map<id,id>();
        Set<String> combineOpprProjectIds = new Set<String>();
        Set<String> presentProjectAssociateToProject = new Set<String>();
        List<Opportunity_Project_Association__c> opportunityRelatedToProject = new List<Opportunity_Project_Association__c>();
        Id projectNPDRecordType = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('FCI_NPD_Projects').getRecordTypeId();
        
        
        for(OpportunityLineItem OLI :opportunityLineItemLst){   
            productsId.add(OLI.Product2Id);
            opportunitiesId.add(OLI.OpportunityId);
        }
        
        if(productsId.size()>0){
            for(Project_Product_Association__c product:[SELECT id,Product_Name__c,Project_Name__c FROM Project_Product_Association__c WHERE Product_Name__c IN: productsId AND Project_Name__r.RecordTypeId =:projectNPDRecordType]){
                
                if(product.Project_Name__c!=null){
                    productProjectmap.put(product.Product_Name__c,product.Project_Name__c);
                }
                
            }
        }
        
        if(opportunitiesId.size()>0 && !productProjectmap.isEmpty()){
            for(Opportunity_Project_Association__c opprProject : [SELECT id,Project_Name__c,Opportunity__c FROM Opportunity_Project_Association__c where Project_Name__c IN:productProjectmap.values() AND Opportunity__c IN:opportunitiesId]){
                
                String opportunityId = opprProject.Opportunity__c;
                String projectID = opprProject.Project_Name__c;
                
                if(opportunityId!=null && projectID!=null)
                    presentProjectAssociateToProject.add(opportunityId+projectID);
            }
        }
        
        
        if(!productProjectmap.isEmpty()){
            for(OpportunityLineItem OLI :opportunityLineItemLst){
                
                Opportunity_Project_Association__c project = new Opportunity_Project_Association__c();
                
                if(productProjectmap.containsKey(OLI.Product2Id)){
                    
                    String opportunityId =  OLI.OpportunityId;
                    String projectId =  productProjectmap.get(OLI.Product2Id);
                    
                    if(productProjectmap.get(OLI.Product2Id)!=null && !presentProjectAssociateToProject.contains(opportunityId+projectId) && !combineOpprProjectIds.contains(opportunityId+projectId)){
                        project.Project_Name__c = productProjectmap.get(OLI.Product2Id);
                        project.Opportunity__c = OLI.OpportunityId;
                        opportunityRelatedToProject.add(project);
                        combineOpprProjectIds.add(opportunityId+projectId);    
                    } 
                    
                }
                
            }
        }
        
        if(opportunityRelatedToProject.size()>0)
            INSERT opportunityRelatedToProject;
    }
    
    public static void updateCampaignOnOpportunity(List<OpportunityLineItem> opportunityLineItemLst){
        Map<id,id> opproductsId = new Map<id,id>();
        integer productCount = 0;
        for(OpportunityLineItem oli : opportunityLineItemLst){
            opproductsId.put(oli.Product2Id,oli.OpportunityId);
        } 
        set<String> productName = getPlantProducts();
        Map<id,Opportunity> opportunityMap = new Map<id,Opportunity>([SELECT id,Name,CampaignId FROM Opportunity where ID IN:opproductsId.values()]);
        set<ID> allProducts = new set<ID>();
        for(OpportunityLineItem allOli : [select Id,Name,Product2Id from OpportunityLineItem where OpportunityId IN:opproductsId.values()]){
            allProducts.add(allOli.Product2Id);
        }      
        system.debug('allProducts' +allProducts);
        Map<id,Product2> productMap =new Map<id,Product2>([SELECT id,Name FROM Product2 where ID IN:allProducts]);
        for(Product2 pro : productMap.values() ){
            if(productName.contains(pro.Name)){
                productCount ++;
            }
        }
        List<Opportunity> updateOpportunitesList = new List<Opportunity>();
        Id campaignId = getCampaign();
        if(productCount > 0){          
            for(Opportunity opp :opportunityMap.values()){
                if(opp.CampaignId == null){
                    opp.CampaignId = campaignId;
                    updateOpportunitesList.add(opp);
                }
            }
        }    
        if(!updateOpportunitesList.isEmpty()){
            update updateOpportunitesList;
        }       
    }

    public static void updateCampaignOnProductDelete(List<OpportunityLineItem> opportunityLineItemLst){
        Map<id,id> opproductsId = new Map<id,id>();
        integer productCount = 0;
        for(OpportunityLineItem oli : opportunityLineItemLst){
            opproductsId.put(oli.OpportunityId,oli.Product2Id);
        } 
        set<String> productName = getPlantProducts();
        Map<id,Opportunity> opportunityMap = new  Map<id,Opportunity>([SELECT id,Name,CampaignId FROM Opportunity where ID IN:opproductsId.keySet()]);
        set<ID> allProducts = new set<ID>();
        for(OpportunityLineItem allOli : [select Id,Name,Product2Id from OpportunityLineItem where OpportunityId IN:opproductsId.keySet()]){
            allProducts.add(allOli.Product2Id);
        }      
        Map<id,Product2> productMap =new Map<id,Product2>([SELECT id,Name FROM Product2 where ID IN:allProducts]);
        for(Product2 pro : productMap.values() ){
            if(productName.contains(pro.Name)){
                productCount ++;
            }
        }
        List<Opportunity> updateOpportunitesList = new List<Opportunity>();
        Id campaignId = getCampaign();
        if(productCount == 0 ){            
            for(Opportunity opp :opportunityMap.values()){
                if(opp.CampaignId == campaignId){
                    opp.CampaignId = null;
                    updateOpportunitesList.add(opp);
                }
            }
        }   
         if(productCount > 0 ){            
            for(Opportunity opp :opportunityMap.values()){
                if(opp.CampaignId == null){
                    opp.CampaignId = campaignId;
                    updateOpportunitesList.add(opp);
                }
            }
        }     
        if(!updateOpportunitesList.isEmpty()){
            update updateOpportunitesList;
        }       
    }


    public static set<String> getPlantProducts(){
        set<String> productName = new set<string>();
        List<Plantaris_Products__mdt> plantProducts = [SELECT Id,Label FROM Plantaris_Products__mdt];
        for (Plantaris_Products__mdt pp : plantProducts){
            productName.add(pp.Label);
        } 
        return productName;
    }

    public static ID getCampaign(){
        String campaignName = System.Label.PlantarisCampaign;
        return [Select Id,Name from campaign where Name =:campaignName and Parent.Name ='Plantaris Marketing Campaign']?.Id;
    }
    
}