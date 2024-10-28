public class SRM_GetHistoryRecords {
    
    @AuraEnabled
    public static List<wrapperClass> getHistoryRecords(String ratingIds){
        
        Map<Id, Supplier_Rating__C> ratingsVsRelatedHeaders = new Map<Id, Supplier_Rating__C> ();
        List<Object> cObjMap = (List<Object>) JSON.deserializeUntyped(ratingIds);
        List<string> lsstr= new List<string> ();
        List<wrapperClass> werapperList = new List<wrapperClass>();
        Map<Id, Supplier_Rating__c> relatedRatingData = new Map<Id, Supplier_Rating__c>();
        Map<Id, List<Supplier_Rating_History__c>> ratingVsHistoryRecs = new Map<Id, List<Supplier_Rating_History__c>>();
        Map<Id, List<Supplier_Rating_History__c>> ratingVsHistoryRecsFiltered = new Map<Id, List<Supplier_Rating_History__c>>();
        if(! cObjMap.isEmpty()){
            for(object obj: cObjMap){
                system.debug('obh '+ obj);
                lsstr.add(String.valueOf(obj));
            }
        }
        system.debug('lsstr '+lsstr.SIZE());
             
        Map<Id, Supplier_Rating__c> ratingsDetails = getRelatedRatingsMap(lsstr);
        Set<Id> associatedHeaderIds = new set<Id>();
        for(Supplier_Rating__c obj: ratingsDetails.values()){
            Map<Id,Supplier_Rating__c> relatedRatings = getAssoicatedRatings(obj);
            system.debug('relatedRatings '+ relatedRatings);
            List<Supplier_Rating_History__c> histories = getHistoryRecords(relatedRatings.keySet() );
            wrapperClass myWrapper = new wrapperClass();
            myWrapper.lstContact = histories;
            myWrapper.ratingName = obj.Id;
            werapperList.add(myWrapper);
        }
        
        
        /*// this returns header vs rating id.
        ratingsVsRelatedHeaders = getRealtedHeaders(lsstr);
       
        system.debug('ratingsVsRelatedHeaders '+ ratingsVsRelatedHeaders);
        // this returns header vs all history records.
        Map<Id, List<Supplier_Rating_History__c>> myMap = getHistoryChange(lsstr,ratingsVsRelatedHeaders);
        
        system.debug('myMap '+ myMap);
        
         
        for( Id key : myMap.keySet()){
            wrapperClass myWrapper = new wrapperClass();
            myWrapper.lstContact = myMap.get(key);
            myWrapper.ratingName = key;
            werapperList.add(myWrapper);
        }
        system.debug('werapperList '+ werapperList);
        if(! werapperList.isEmpty()){
            return werapperList;
        }*/
        return werapperList;
    }
    /*// in use
    public static Map<Id, List<Supplier_Rating_History__c>>  getHistoryChange(List<string>  ratingIds,Map<Id, Supplier_Rating__c> ratingsVsRelatedHeaders){
        system.debug('ratingIds '+ ratingIds);
        system.debug('ratingsVsRelatedHeaders '+ ratingsVsRelatedHeaders);
        Map<Id, List<Supplier_Rating_History__c>> ratingVsHistoryRecsFiltered = new Map<Id, List<Supplier_Rating_History__c>>();
        string activeDate = Label.Show_History_Date;
        date dt = date.valueOf(activeDate);
        List<Supplier_Rating_History__c >  histories= [select id, Rating__c, Comment__c, Year__c, Month__c, Qtr__c,Supplier_Rating__c,
                                                       Rated_Date__c, Rated_By__r.Name, Supplier_Rating__r.Name, 
                                                       Supplier_Hub__r.Supplier_Name__c ,Supplier_Rating__r.Location_With_BG__c, 
                                                       Value_Element__r.Name,Supplier_Hub__c , Supplier_Rating__r.Value_Element__c , 
                                                       Supplier_Rating__r.Supplier_Rating_Header__c, Supplier_Rating__r.Rating_Year__c, 
                                                       Supplier_Rating__r.Value_Element_Name__c from Supplier_Rating_History__c 
                                                       where Supplier_Rating__r.Supplier_Rating_Header__c IN: ratingsVsRelatedHeaders.keySet()];
        system.debug('histories '+ histories.size());
        for(Supplier_Rating_History__c objHisotry : histories){
            Set<Id> ratingIdsAll = new Set<Id>();
            ratingIdsAll.add(objHisotry.Supplier_Rating__c);
            Map<Id, Supplier_Rating__c> ratingsMap = getRelatedRatingsMap(ratingIdsAll);
            Supplier_Rating__C rating = ratingsMap.get(objHisotry.Supplier_Rating__c);
             system.debug(rating);
            system.debug(rating.Location_With_BG__c);
            system.debug(rating.Value_Element__c);
            if(rating.Location_With_BG__c == objHisotry.Supplier_Rating__r.Location_With_BG__c && rating.Value_Element__c == objHisotry.Supplier_Rating__r.Value_Element__c){
                 if(ratingVsHistoryRecsFiltered.get(rating.id) != NULL){
                            List<Supplier_Rating_History__c> alreadyThere =  ratingVsHistoryRecsFiltered.get(rating.id);
                            alreadythere.add(objHisotry);
                        }else{
                            ratingVsHistoryRecsFiltered.put(rating.id , new List<Supplier_Rating_History__c>{objHisotry});
                        }   
            }
        }
        return ratingVsHistoryRecsFiltered;
    }
     public class wrapperClass{
        @AuraEnabled public List<Supplier_Rating_History__c> lstContact{get;set;}
        @AuraEnabled public String ratingName {get;set;}
    }*/
    
    public static Map<id, Supplier_Rating__C> getRealtedHeaders (List<string>  ratingIds){
        Map<id, Supplier_Rating__C> resultMap = new Map<id, Supplier_Rating__C>();
        List<Supplier_Rating__c> ratings = [select id , Supplier_Hub__c, Supplier_Hub__r.Supplier_Rating_Header__c,  Location_With_BG__c, Value_Element__c from Supplier_Rating__c where id IN: ratingIds];
        if(! ratings.isEmpty()){
            for(Supplier_Rating__c obj: ratings){
                resultMap.put(obj.Supplier_Hub__r.Supplier_Rating_Header__c, obj);
            }
        }
        return resultMap;
    }
    public static list<Supplier_Rating_History__c> getHistoricRatingsbasedonHeaders(List<id> relatedHeaders){
        List<Supplier_Rating_History__c> ratings = [select id, Supplier_Rating__c, Supplier_Rating__r.Supplier_Rating_Header__c, Supplier_Rating__r.Rating_Year__c,Supplier_Hub__r.Supplier_Name__c from Supplier_Rating_History__c where Supplier_Hub__r.Supplier_Rating_Header__c IN: relatedHeaders and Supplier_Rating__r.Rating_Is_Active__c = false];
        return ratings;
    }
    public static Map<Id, Supplier_Rating__c> getRelatedRatingsMap(List<string>  ratingIds){
        return new Map<id, Supplier_Rating__c>([select id,Location_With_BG__c, Value_Element__c ,Supplier_Rating_Header__c   from Supplier_Rating__c where id IN: ratingIds]);
    }
    public static Map<Id,Supplier_Rating__c> getAssoicatedRatings(Supplier_Rating__c ratingObject){
        return new Map<Id, Supplier_Rating__c>([select id, name, Supplier_Rating_Header__c,Location_With_BG__c, Value_Element__r.name, Rating_Year__c from Supplier_Rating__c where Supplier_Rating_Header__c =: ratingObject.Supplier_Rating_Header__c and Location_With_BG__c =: ratingObject.Location_With_BG__c and Value_Element__c =: ratingObject.Value_Element__c ]);
    }
    public class wrapperClass{
        @AuraEnabled public List<Supplier_Rating_History__c> lstContact{get;set;}
        @AuraEnabled public String ratingName {get;set;}
    }
    public static List<Supplier_Rating_History__c> getHistoryRecords(set<Id> ratingIds){
        return [select id, Rating__c, Comment__c, Year__c, Month__c, Qtr__c,Supplier_Rating__c,
                                                       Rated_Date__c, Rated_By__r.Name, Supplier_Rating__r.Name, 
                                                       Supplier_Hub__r.Supplier_Name__c ,Supplier_Rating__r.Location_With_BG__c, 
                                                       Value_Element__r.Name,Supplier_Hub__c , Supplier_Rating__r.Value_Element__c , 
                                                       Supplier_Rating__r.Supplier_Rating_Header__c, Supplier_Rating__r.Rating_Year__c, 
                                                       Supplier_Rating__r.Value_Element_Name__c from Supplier_Rating_History__c 
                                                       where Supplier_Rating__c IN: ratingIds ORDER BY  Supplier_Rating__r.Rating_Year__c DESC];
    }

}