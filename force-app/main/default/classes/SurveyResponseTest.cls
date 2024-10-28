/******************************
* Written By : CoreFlex Solutions 
* Userstory : 155364
* ****************************/
@IsTest
public class SurveyResponseTest {

    @IsTest
    public static void surveyResponseTest() {
        // Create a list to hold Qualtrics_Survey_Response__c records
        List<Qualtrics_Survey_Response__c> responseList = new List<Qualtrics_Survey_Response__c>();
        
        // Create a new instance of Qualtrics_Survey_Response__c
        Qualtrics_Survey_Response__c response = new Qualtrics_Survey_Response__c();
        response.Survey_Response_Name__c = 'FrieslandCampina';
        response.Question_1__c = '1_How likely is it that you would recommend FrieslandCampina Ingredients to a friend';
        response.Answer_1__c = '2';
        response.Question_4__c = '4_How satisfied are you with the following aspects regarding the employees at FrieslandCampina Ingredients';
        response.Question_5__c = '4.1_The employees at FrieslandCampina Ingredients are easy to reach';
        response.Answer_5__c = '2';
        response.Question_2__c ='2_Which factors are most important in giving this score?';
        response.Answer_2__c = 'Other,Product quality';
        response.Question_15__c='6_Which products do you currently miss in our offering?';
        response.Answer_15__c='Which products do you';
        // Add the record to the list
        responseList.add(response);
        
        // Insert the list of records if it contains any elements
        if (responseList.size() > 0) {
            insert responseList;
        }

        // Assert statements to validate the test
        // Check if the inserted response list is not empty
        List<Qualtrics_Survey_Response__c> insertedResponses = [SELECT Id, Name, Question_1__c, Answer_1__c,Survey_Response_Name__c FROM Qualtrics_Survey_Response__c WHERE Survey_Response_Name__c = 'FrieslandCampina'];
        System.assert(insertedResponses.size() == 1, 'The response should have been inserted.');
        System.assertEquals('1_How likely is it that you would recommend FrieslandCampina Ingredients to a friend', insertedResponses[0].Question_1__c, 'The Question_1__c should match.');
        System.assertEquals('2', insertedResponses[0].Answer_1__c, 'The Answer_1__c should match.');
    }
}