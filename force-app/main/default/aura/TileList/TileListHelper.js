/**
 * Created by KJM on 01/04/2019.
 */
({
    childOptionTiles  : "Tiles",
    childOptionList   : "List",
    childOptionNested : "Nested",

    navigateToUrl: function(component, event, helper, url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },

    setBaseUrl: function(component, event, helper) {
       var urlString = window.location.href;
       var baseURL = urlString.substring(0, urlString.indexOf("/s"));
       component.set("v.baseUrl", baseURL);
       component.set("v.imageBaseUrl", baseURL + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=');
    },

    setBreadCrumbsOnInit: function(component, event, helper) {
        var myBreadcrumbs = [
            {
                label: component.get("v.tilesType"),
                name: component.get("v.tilesType")
            }
        ];
        component.set('v.breadCrumbs', myBreadcrumbs);
    },

    setBreadCrumbsOnChange: function(component, event, helper) {
       var bcLabel = event.getSource().get('v.label');
       var newBreadCrumbs = [];
       var breadCrumbs = component.get('v.breadCrumbs');
       for (var key in breadCrumbs ) {
         var value = breadCrumbs[key];
         newBreadCrumbs.push( {
             label : value.label,
             name : value.name
         });
         if(value.label === bcLabel) {
           break;
         }
       }

       component.set('v.breadCrumbs', newBreadCrumbs);
    },

    addBreadCrumbsElementWithData: function(component, event, helper, lab, recId) {
        var breadCrumbs = component.get('v.breadCrumbs');
        var breadCrumbsLength = breadCrumbs.length;

        var lastBreadCrumb = breadCrumbs[breadCrumbsLength - 1];
        if (lastBreadCrumb.label == lab) {
            return;
        }
		
        breadCrumbs[breadCrumbsLength] = {
            label: lab,
            name: recId
        };

        component.set('v.breadCrumbs', breadCrumbs);
    },

    setTileListOnInit : function(component, event, helper) {
        var action = component.get("c.getTileListOnInit");
        action.setParams({
            tileName : component.get("v.firstTileName")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.tilesWrapper", result);
                helper.contentAvailabilityCheck(component, event, helper, result);
                helper.setPaginationOnListInit(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    redirectToUrlOrDisplayParent : function(component, event, helper, tlName) {
        var action = component.get("c.getTileInfoByName");
        action.setParams({
            tileName : tlName
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.UrlLink != '' && result.UrlLink != undefined) {
                    if (result.IsFile == true) {
                        helper.displayIFrame(component, event, helper, result.UrlLink);
                    } else {
                        helper.navigateToUrl(component, event, helper, result.UrlLink);
                    }
                } else {
                    helper.setTileListByParent(component, event, helper, result.Id);
                    helper.addBreadCrumbsElementWithData(component, event, helper, result.UIName, result.Id);
                }
            }
        });
        $A.enqueueAction(action);
    },

    setTileListByParent : function(component, event, helper, parId) {
        var action = component.get("c.getTileListByParent");
        action.setParams({
            parentId : parId
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.tilesWrapper", result);
				helper.contentAvailabilityCheck(component, event, helper, result);
                helper.setPaginationOnListInit(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    setPaginationOnListInit : function(component, event, helper){
        component.set("v.currentPageNumber", 1);

        var tilesWrapper = component.get("v.tilesWrapper");
        if (tilesWrapper.DisplayOption == helper.childOptionNested) {
            component.set("v.currentPaginationList", tilesWrapper.TilesAsNestedList);
            return;
        }

        var tileList = tilesWrapper.TilesAsList;
        var itemsInOneSplit = component.get("v.itemsInOnePaginationSplit");
        var pagesCount = Math.ceil(tileList.length / itemsInOneSplit);
        var pagPages = [];
        for (var i = 0; i < pagesCount; i++) {
            pagPages.push(i+1);
        }

        component.set("v.paginationPages", pagPages);
        component.set("v.totalPaginationPages", pagesCount);
        component.set("v.currentPaginationList", tileList.slice(0, itemsInOneSplit));

    },

    changePaginatedList : function(component, event, helper, pageIndexForCalculation, pageIndexToSetup){
        var itemsInOneSplit = component.get("v.itemsInOnePaginationSplit");

        component.set("v.currentPaginationList", component.get("v.tilesWrapper").TilesAsList.slice(pageIndexForCalculation * itemsInOneSplit, pageIndexForCalculation * itemsInOneSplit + itemsInOneSplit));
        component.set("v.currentPageNumber", pageIndexToSetup);
    },

    displayIFrame: function(component, event, helper, iFrameUrl){
       component.set("v.displayFileIFrame", true);
       component.set("v.iFrameSrc", iFrameUrl);
   },

   hideIFrame: function(component, event, helper, iFrameUrl){
       component.set("v.displayFileIFrame", false);
       component.set("v.iFrameSrc", '');
   },
   contentAvailabilityCheck: function(component, event, helper, result){
      const tilesMap = {Tiles:'TilesAsTiles', List:'TilesAsList', Nested:'TilesAsNestedList'};              
        if(Object.keys(tilesMap).includes(result.DisplayOption)){
            let displayOption = result.DisplayOption;
            let tilesOption = tilesMap[displayOption];
            if(result[tilesOption].length === 0){
                component.set("v.noContentMessage", true);
            }else{
                component.set("v.noContentMessage", false);
            }
        }        
   },
})