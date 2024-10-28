/******************************
* Written By : CoreFlex Solutions 
* Userstory : 155364
* Purpose : To Create the Answer records from the survey Response objects *
* ****************************/
public without sharing class IndividualAnswerRecordCreator {
    
    public static List<QualtricsAnswer__c> createIndividualsFromResponses(Qualtrics_Survey_Response__c responses, String responseName) {
        
        List<QualtricsAnswer__c> individualsToCreate = new List<QualtricsAnswer__c>();
        
        Map<Double, QualtricsAnswer__c> answerMap = new Map<Double, QualtricsAnswer__c>();
        List<QuestionMapping__mdt> questionList = new List<QuestionMapping__mdt>();
        for (QuestionMapping__mdt mapping : [
            SELECT Main_Question_Field__c, Grid_Item_Field__c, Answer_Field__c, QuestionType__c 
            FROM QuestionMapping__mdt 
            WHERE label = :responseName
        ]) {
            // Populate metadata map keyed by Answer_Field__c for quick access
            questionList.add(mapping);
        }
        
        // Iterate over each metadata entry
        for (QuestionMapping__mdt mapping :questionList) {
            if(String.isNotBlank(mapping.Answer_Field__c) && String.isNotBlank((String)responses.get(mapping.Answer_Field__c))){
                String choice;
                String answerField = mapping.Answer_Field__c;
                String questionField = mapping.Main_Question_Field__c!=null ? (String)responses.get(mapping.Main_Question_Field__c):null;
                String gridField = mapping.Grid_Item_Field__c!=null ? (String)responses.get(mapping.Grid_Item_Field__c):null;
                String questionType = mapping.QuestionType__c;
                
                List<String> gridQuestions= gridField!=null?gridField.split('\\_'):null;
                List<String> questions=questionField!=null ?questionField.split('\\_'):null;
                QualtricsAnswer__c newIndividual = new QualtricsAnswer__c();
                
                newIndividual.Question_Number__c=gridQuestions!=null ? Double.valueOf(gridQuestions[0]):Double.valueOf(questions[0]);
                if(questionType!= 'MultipleChoice'){
                    newIndividual.DisplayValue__c = String.isNotBlank((String)responses.get(answerField)) ? (String)responses.get(answerField) : null;
                }
                newIndividual.QuestionText__c = questions.size() > 1 ? questions[1] : null;
                newIndividual.GridItem__c = gridQuestions !=null ? gridQuestions[1]:gridField;
                newIndividual.QuestionType__c = questionType;
                newIndividual.Response__c = responses.Id;
                newIndividual.Contact__c=responses.Qualtrics_Contact__c;
                
                
                
                // Handle specific question types
                if (questionType == 'Rating' || questionType == 'NetPromoter') {
                    newIndividual.Number__c = Integer.valueOf(responses.get(answerField));
                } else if (questionType == 'MultipleChoice') {
                    newIndividual.Text__c=String.isNotBlank(responses.Qualtrics_Text__c)? responses.Qualtrics_Text__c:null;
                    choice= String.isNotBlank((String)responses.get(answerField)) ? (String)responses.get(answerField) : null;
                    newIndividual.Choices__c=choice!=null?choice.replaceAll('\\s*,?\\bOther\\b,?\\s*', ',').replaceAll('\\s*,\\s*', ',').replaceAll('^,|,$', '').replaceAll(',$', '').trim():null;
                    newIndividual.DisplayValue__c= newIndividual.Choices__c!=null? newIndividual.Choices__c:null;
                    choiceFieldMappingMethod(newIndividual.Choices__c, newIndividual);
                } else if(questionType=='CustomerSatisfaction'){
                    if(newIndividual.DisplayValue__c.split('\\-').size()==0){continue;}
                    newIndividual.Text__c=String.isNotBlank((String)responses.get(answerField)) ? (String)responses.get(answerField) : null;
                    newIndividual.Number__c =(newIndividual.DisplayValue__c!=null && newIndividual.DisplayValue__c.split('\\-').size()>0) ? Integer.valueOf(newIndividual.DisplayValue__c.split('\\-')[0].trim()):null;
                } else if(questionType=='ShortAnswer'){
                    newIndividual.DisplayValue__c = (newIndividual.DisplayValue__c.length() > 255) ? newIndividual.DisplayValue__c.substring(0, 255) : newIndividual.DisplayValue__c;
                    newIndividual.Text__c=String.isNotBlank((String)responses.get(answerField)) ? (String)responses.get(answerField) : null;
                }
                answerMap.put(newIndividual.Question_Number__c, newIndividual);
                newIndividual.Question_Number__c=Math.floor(newIndividual.Question_Number__c);  
            }
        }
        
        List<Double> sortedQuestionNumbers = new List<Double>(answerMap.keySet());
        sortedQuestionNumbers.sort();
        
        // Add the records to the list in sorted order
        for (Double questionNumber : sortedQuestionNumbers) {
            individualsToCreate.add(answerMap.get(questionNumber));
        }
        return individualsToCreate;
    }
    
    // Helper method to map choices for MultipleChoice question type
    private static void choiceFieldMappingMethod(String answer, QualtricsAnswer__c newIndividual) {
        if (String.isNotBlank(answer)) {
            String[] choices = answer.split(',');
            for (Integer i = 0; i < choices.size(); i++) {
                Integer choiceNumber = i + 1;
                String choiceField = 'Choice_' + choiceNumber + '__c';
                newIndividual.put(choiceField, choices[i]);
            }
        }
    }
}