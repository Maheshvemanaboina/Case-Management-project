public class AppendTextOrTextAreaFieldValues {
    
    @InvocableMethod(
        label = 'Append Text or Text Area Field Values'
        description = 'Checks the fields in which the value should be appended and returns the concatenated value'
    )
    public static List<Response> concatenateFieldValues( List<Request> requests ) {
        
        List<Response> responses = new List<Response>();
        
        for ( Request req : requests ) {
            
            Response res = new Response();
            
            //Check whether the calculation is required or not and return the concatenated value
            if(req.isCalculationRequired && String.isNotBlank(req.sourceField)){

                //Check the target field value and append (or) override the new value accordingly.
                if(String.isBlank(req.targetField)){
                    res.concatenatedValue = String.valueOf(DateTime.now()) + ' : ' + req.sourceField.stripHtmlTags();
                }
                else if(String.isNotBlank(req.targetField) && !req.targetField.containsIgnoreCase(req.sourceField.stripHtmlTags())){
                    res.concatenatedValue = req.targetField + '\n' + String.valueOf(DateTime.now()) + ' : ' + req.sourceField.stripHtmlTags();
                }
                
            }else{
                res.concatenatedValue = '';
            }
            responses.add(res);
        }
        return responses;
    }
    
    public class Request {
        
        @InvocableVariable(
            label = 'Is Calculation Required'
            description = 'Boolean variable that decides whether the calculation needs to be triggered or not.'
        )
        public Boolean isCalculationRequired;
        
        @InvocableVariable(
            label = 'Source Field'
            description = 'Field from which the value needs to be copied.'
        )
        public String sourceField;
        
        @InvocableVariable(
            label = 'Target Field'
            description = 'Field to which the value needs to be appended.'
        )
        public String targetField;        
    }
    
    public class Response {
        
        @InvocableVariable(
            label = 'Concatenated Value'
            description = 'Combination of source and target fields values'
        )
        public String concatenatedValue;
    }
}