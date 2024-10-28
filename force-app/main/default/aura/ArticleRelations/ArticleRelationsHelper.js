/**
 * Created by KJM on 01/04/2019.
 */
({
    setArticleRelations : function(component, event, helper) {
        var action = component.get("c.getRelatedArticles");
        console.log(component.get("v.recordId"));
        action.setParams({ articleId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                /* B2B-155*/
                /*Added sorting order based on the above ticket*/
                var listOfRelatedArticles = JSON.parse(result);                
                var ordering = {};
                var sortOrder = ['Related Product Specifications','Finished Product Specification','Product Data Sheet','Customer Product Specification','Customer Specific Specification','Customer Packaging Specifiction','Flowchart','Other Documents','Statements','Vendor Data Sheet','Certificate','Recipe Comparison','Recommended Products'];
            function compareItems(a, b) {
                return sortOrder.indexOf(a.label) - sortOrder.indexOf(b.label);
            }  
            listOfRelatedArticles.sort(compareItems);
                listOfRelatedArticles.forEach(function(article) {
                    article.items.sort(function(a, b) {
                        return a.name.localeCompare(b.name);
                    });
                });                
                /*B2B-155*/              
                component.set("v.items", listOfRelatedArticles);
            }
        });
        $A.enqueueAction(action);
    }
})