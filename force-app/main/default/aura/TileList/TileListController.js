/**
 * Created by KJM on 01/04/2019.
 */
({
    doInit : function(component, event, helper) {
        helper.setTileListOnInit(component, event, helper);
        helper.setBreadCrumbsOnInit(component, event, helper);
        helper.setBaseUrl(component, event, helper);
    },

    handleTileTreeClick: function(component, event, helper) {
        var tlName = event.getParam('name');
        helper.redirectToUrlOrDisplayParent(component, event, helper, tlName);
    },

    handleTileTileClick : function(component, event, helper) {
        var tlName = event.currentTarget.getAttribute("data-TlName");
        var tlId = event.currentTarget.getAttribute("data-recId");
        if(tlName.includes("Recipe")){
            helper.setTileListByParent(component, event, helper, tlId);
        }else{
         	helper.redirectToUrlOrDisplayParent(component, event, helper, tlName);   
        }
    },

    handleBreadCrumbClick : function(component, event, helper) {
        helper.hideIFrame(component, event, helper);

        var name = event.getSource().get('v.name');
        if (name == component.get("v.tilesType")) {
            helper.setTileListOnInit(component, event, helper);
            helper.setBreadCrumbsOnInit(component, event, helper);
        } else {
            helper.setTileListByParent(component, event, helper, name);
            helper.setBreadCrumbsOnChange(component, event, helper);
        }
    },

    handlePreviousPaginationPageClick :  function(component, event, helper) {
        var currentPageIndex = component.get("v.currentPageNumber");
        helper.changePaginatedList(component, event, helper, currentPageIndex - 2, currentPageIndex - 1);
    },

    handlePaginationPageClick : function(component, event, helper) {
        var currentPageIndex = parseInt(event.target.name);
        helper.changePaginatedList(component, event, helper, currentPageIndex - 1, currentPageIndex);
    },

    handleNextPaginationPageClick : function(component, event, helper) {
        var currentPageIndex = component.get("v.currentPageNumber");
        helper.changePaginatedList(component, event, helper, currentPageIndex, currentPageIndex + 1);
    },

    handleBreadCrumbHomeClick : function(component, event, helper) {
        var url = component.get("v.baseUrl") + '/s';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})