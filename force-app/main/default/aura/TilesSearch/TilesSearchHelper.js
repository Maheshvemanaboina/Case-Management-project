/**
 * Created by KJM on 14/08/2019.
 */

({
    hideSearchResult : function(component, event, helper) {
                 var element = document.getElementsByClassName("slds-dropdown-trigger_click")[0];
                 element.classList.remove("slds-is-open");
                 helper.emptyResultList(component, event, helper);
            },

            emptyResultList : function(component, event, helper) {
                component.set("v.resultList", '');
            },

            showSearchResult : function(component, event, helper) {
                 var element = document.getElementsByClassName("slds-dropdown-trigger_click")[0];
                 element.classList.add("slds-is-open");
            },

            showIframe : function(component, event, helper, elUrl) {
                helper.hideSearchResult(component, event, helper);

                component.set("v.displayFileIFrame", true);
                component.set("v.iFrameSrc", elUrl);
            },

            hideIframe : function(component, event, helper) {
                component.set("v.displayFileIFrame", false);
                component.set("v.iFrameSrc", '');
            },

            navigateToUrl: function(component, event, helper, url) {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
            },

            searchForResult : function(component, event, helper) {
              var val = component.find("searchInput").get('v.value');

              if (val.length < 3){
                  helper.hideSearchResult(component, event, helper);
                  return;
              }

              helper.showSearchResult(component, event, helper);

              var action = component.get('c.searchForObjs');
              action.setParams({
                  searchText: val,
                  tileStructure : component.get('v.rootTile')
              });

              action.setCallback(this, function(response) {
                  var state = response.getState();
                  if (state === 'SUCCESS') {
                      var resultWrapper = response.getReturnValue();
                      if (resultWrapper == null) {
                          helper.emptyResultList(component, event, helper);
                      } else {
                          component.set("v.resultList", resultWrapper.ResultList);
                      }
                  } else {
                      helper.emptyResultList(component, event, helper);
                  }
              });

              $A.enqueueAction(action);
          },
});