({
    doInit : function(component, event, helper) {
        var contentCategoryObj = component.get("v.contentCategoryObj");
        var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
    },
    
    moveUp : function(component){
        var rowIndex = component.get("v.rowIndex") + 1;
        component.getEvent("ReOrderRelatedContentsEvent").fire({"indexVar" : rowIndex});
    },
    
    addNewRow : function(component, event, helper) {
        var contentCategoryObj = component.get("v.contentCategoryObj");
            if(contentCategoryObj.tileKnowledgeId.length == 0){
            helper.fireToastMessage('Error', 'Knowledge Article should be selected before adding new one', 'error');
        }else{
            var rowIndex = component.get("v.rowIndex") + 1;
            component.getEvent("AddRowEvt").fire({"indexVar" : rowIndex});
        }
    },
     
     handleCheckboxChange: function (component, event, helper) {
        var checkbox = event.getSource();
        var isChecked = checkbox.get("v.checked");
        var rowIndex = checkbox.get("v.name");
        var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
        contentCategoriesObjList.forEach(function (item, index) {
            if (index == rowIndex) {
                item.isChecked = isChecked;
                item.showEditIcon = isChecked;
            }
        });
        component.set("v.contentCategoriesObjList", contentCategoriesObjList);
        component.set("v.showDeleteButton", isChecked);
      
    }, 

    editRow: function(component, event, helper) {
        var index = event.currentTarget.getAttribute('data-row-index');
        component.set("v.selectedIndex", index);
        var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
        var itemToEdit = contentCategoriesObjList[index];
        itemToEdit.tileKnowledgeId = itemToEdit.tileKnowledgeId || '';
        itemToEdit.tileKnowledgeName = itemToEdit.tileKnowledgeName || '';
        itemToEdit.contentCategorySelectedOld = itemToEdit.contentCategorySelected || '';
        itemToEdit.tileKnowledgeIdOld = itemToEdit.tileKnowledgeId || '';
        itemToEdit.tileKnowledgeNameOld = itemToEdit.tileKnowledgeName || '';
        component.set("v.selectedItem", itemToEdit);
        component.set('v.editModal', true);
    },
   
        
    handleDelete: function (component, event, helper) {
        component.set("v.isModalDelete", true);
    },
    
        handleCategory: function (component, event, helper) {
               var appEvent = $A.get("e.c:OnChangeEvent");
       appEvent.setParams({"onchange1":"true"});
       appEvent.fire();
    },
    
    handleAddRelation: function (component, event, helper) {
        component.set("v.relatedArticlesToCreate", []);
        let relatedArticlesToCreate = [];
        for (var i = 0; i < 5; i++) {
            relatedArticlesToCreate.push({"contentCategorySelected": "", "tileKnowledgeName": ""});
        }
        component.set("v.relatedArticlesToCreate", relatedArticlesToCreate);
    
        let contentCategories = [
            {"label": "Finished Product Specification", "value": "Finished Product Specification"},
            {"label": "Product Data Sheet", "value": "Product Data Sheet"},
            {"label": "Customer Product Specification", "value": "Customer Product Specification"},
            {"label": "Customer Specific Specification", "value": "Customer Specific Specification"},
            {"label": "Customer Packaging Specifiction", "value": "Customer Packaging Specifiction"},
            {"label": "Flowchart", "value": "Flowchart"},
            {"label": "Other Documents", "value": "Other Documents"},
            {"label": "Statements", "value": "Statements"},
            {"label": "Vendor Data Sheet", "value": "Vendor Data Sheet"},
            {"label": "Certificate", "value": "Certificate"},
            {"label": "Recipe Comparison", "value": "Recipe Comparison"},
            {"label": "Recommended Products", "value": "Recommended Products"}
        ];
        component.set("v.contentCategories", contentCategories);
        component.set("v.isAddRelation", true);
    },
    
   handleSelectAllChange: function(component, event, helper) {
    let selectAllChecked = event.getSource().get("v.checked");
    let rowCheckboxes = component.find("selectCheckbox");

    let contentCategoriesObjList = component.get("v.contentCategoriesObjList") || [];
    
    if (Array.isArray(rowCheckboxes)) {
        rowCheckboxes.forEach(function(checkbox) {
            checkbox.set("v.checked", selectAllChecked);
        });
    } else if (rowCheckboxes) { 
        rowCheckboxes.set("v.checked", selectAllChecked);
    }

    contentCategoriesObjList.forEach(function(item) {
        item.isChecked = selectAllChecked;
        item.showEditIcon = selectAllChecked;
    });

    let updatedList = component.get("v.updatedList") || []; 
    if (updatedList.length === 0) {
        updatedList.push({"contentCategorySelected": "", "tileKnowledgeName": ""});
    }

    component.set("v.contentCategoriesObjList", contentCategoriesObjList);
    component.set("v.updatedList", updatedList); 
    component.set("v.showDeleteButton", selectAllChecked);
},
    
    handleDeleteRow: function (component, event, helper) {
        var deleteRowEvent = component.getEvent("DeleteRowEvt");
        deleteRowEvent.setParams({
            rowIndex: component.get("v.rowIndex")
        });
        deleteRowEvent.fire();
    },
    
    handleAddRow: function (component, event, helper) {
        var addRowEvent = component.getEvent("AddRowEvt");
        addRowEvent.fire();
    },
    
    handleMoveUp1: function (component, event, helper) {
        var reorderEvent = component.getEvent("ReOrderRelatedContentsEvent");
        reorderEvent.setParams({
            direction: "up",
            rowIndex: component.get("v.rowIndex")
        });
        reorderEvent.fire();
    },
    
    handleMoveDown: function (component, event, helper) {
        var reorderEvent = component.getEvent("ReOrderRelatedContentsEvent");
        reorderEvent.setParams({
            direction: "down",
            rowIndex: component.get("v.rowIndex")
        });
        reorderEvent.fire();
    },
    
    closeModalDelete: function (component, event, helper) {
        component.set("v.isModalDelete", false);
    },
    
    closeModalforEdit: function (component, event, helper) {
        var selectedItem =  component.get("v.selectedItem");
        var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
        var rowIndex = component.get("v.selectedIndex");
        contentCategoriesObjList.forEach(function (item, index) {
            if (index == rowIndex) {
                item.contentCategorySelected = selectedItem.contentCategorySelectedOld;
                item.tileKnowledgeId = selectedItem.tileKnowledgeIdOld;
                item.tileKnowledgeName = selectedItem.tileKnowledgeNameOld;
            }
        });
        component.set("v.contentCategoriesObjList", contentCategoriesObjList);
        component.set("v.editModal", false);
    },
    
   //326
   confirmDelete: function (component, event, helper) {
       var appEvent = $A.get("e.c:OnChangeEvent");
       appEvent.setParams({"onchange1":"true"});
       appEvent.fire();
    var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
    console.log('contentCategoriesObjListB:', contentCategoriesObjList);
    var updatedList = contentCategoriesObjList.filter(function(item) {
        if(item.contentCategorySelected != ""){
            return !item.isChecked;
        }
        else{
            return true;
        }
    });
       if(updatedList.length==0){
        updatedList.push({"contentCategorySelected": "", "tileKnowledgeName": ""});
    }
    component.set("v.contentCategoriesObjList", updatedList);
    component.set("v.isModalDelete", false);
    component.set("v.showDeleteButton",false);
    },
   //326
    
    
    
    saveEditChanges: function(component, event, helper) {
         var index = component.get("v.selectedIndex");
         var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
        var selectedItem = {
            contentCategorySelected: component.find("contentType").get("v.value"), 
            tileKnowledgeName: component.find("contentCategoriesSObjectLookup").get("v.selectedRecordLabel"), 
            tileKnowledgeId: component.find("contentCategoriesSObjectLookup").get("v.selectedRecordId")
        };
        if (index !== -1) {
            contentCategoriesObjList[index].contentCategorySelected = selectedItem.contentCategorySelected;
            contentCategoriesObjList[index].tileKnowledgeName = selectedItem.tileKnowledgeName;
            contentCategoriesObjList[index].tileKnowledgeId = selectedItem.tileKnowledgeId;
        }
        component.set("v.contentCategoriesObjList", contentCategoriesObjList);
        component.set('v.editModal', false);
    },
    
    closeAddRelation: function (component, event, helper) {
        component.set("v.isAddRelation", false);
    },
    
    // confirmSaveCreateNew: function(component, event, helper) {
    //     var contentCategoriesObjList = component.get("v.contentCategoriesObjList") || [];
    //     var relatedArticlesToCreate = component.get("v.relatedArticlesToCreate");

    //     var existingEntriesMap = new Map();
    //     contentCategoriesObjList.forEach(item => {
    //         if(item.contentCategorySelected){
    //             existingEntriesMap.set(item.contentCategorySelected + '|' + item.tileKnowledgeName, true);
    //         }
    //     });
        
    //     relatedArticlesToCreate.forEach(item => {
    //         if (item.contentCategorySelected && item.tileKnowledgeName) {
    //             var key = item.contentCategorySelected + '|' + item.tileKnowledgeName;
    //             if (!existingEntriesMap.has(key)) {
    //                 if(item.contentCategorySelected){
    //                 contentCategoriesObjList.push({
    //                         contentCategorySelected: item.contentCategorySelected,
    //                         tileKnowledgeName: item.tileKnowledgeName, 
    //                         tileKnowledgeId :item.tileKnowledgeId
    //                 });
    //             }
    //                 existingEntriesMap.set(key, true); 
    //             }
    //         }
    //     });
    //     const cleanedArray = contentCategoriesObjList.filter(item => {
    //         return Object.values(item).some(value => value !== "");
    //     });
    //     contentCategoriesObjList = cleanedArray;
    //      var compEvent = component.getEvent("SelectEvent");
    //     compEvent.setParams({ "contentCategoryList" : contentCategoriesObjList });
    //     compEvent.fire();
    //     component.set("v.contentCategoriesObjList", contentCategoriesObjList);
    //     component.set("v.isAddRelation", false);
    // },  
    
    confirmSaveCreateNew: function(component, event, helper) {
        var contentCategoriesObjList = component.get("v.contentCategoriesObjList") || [];
        var relatedArticlesToCreate = component.get("v.relatedArticlesToCreate");
        
        
        // Validate entries
        let hasValidEntries = relatedArticlesToCreate.some(item => 
            item.contentCategorySelected && item.tileKnowledgeName
        );
    
        if (!hasValidEntries) {
            // Show error popup
            helper.showErrorPopup("Category and Knowledge Article should be selected before saving.");
              return;
        }

        var existingEntriesMap = new Map();
        contentCategoriesObjList.forEach(item => {
            if (item.contentCategorySelected) {
                existingEntriesMap.set(item.contentCategorySelected + '|' + item.tileKnowledgeName, true);
            }
        });
        
        relatedArticlesToCreate.forEach(item => {
            if (item.contentCategorySelected && item.tileKnowledgeName) {
                var key = item.contentCategorySelected + '|' + item.tileKnowledgeName;
                if (!existingEntriesMap.has(key)) {
                    contentCategoriesObjList.push({
                        contentCategorySelected: item.contentCategorySelected,
                        tileKnowledgeName: item.tileKnowledgeName, 
                        tileKnowledgeId: item.tileKnowledgeId
                    });
                    existingEntriesMap.set(key, true);
                }
            }
        });
    
        const cleanedArray = contentCategoriesObjList.filter(item => {
            return Object.values(item).some(value => value !== "");
        });
        contentCategoriesObjList = cleanedArray;
    
        var compEvent = component.getEvent("SelectEvent");
        compEvent.setParams({ "contentCategoryList": contentCategoriesObjList });
        compEvent.fire();
        component.set("v.contentCategoriesObjList", contentCategoriesObjList);
        component.set("v.isAddRelation", false);
    },
    removeRow : function(component, event, helper) {
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex"),
                                                      "recordObj" : component.get("v.contentCategoryObj")}).fire();
    },
    
    moveUp : function(component){
        component.getEvent("ReOrderRelatedContentsEvent").setParams({"itemIndex" : component.get("v.rowIndex"),
                                                                     "eventType" : 'moveUp'}).fire();
    },
    
    moveDown : function(component){
        component.getEvent("ReOrderRelatedContentsEvent").setParams({"itemIndex" : component.get("v.rowIndex"),
                                                                     "eventType" : 'moveDown'}).fire();
    },   
    
   handleSObjectLookUpSelect: function(component, event, helper) {
       var appEvent = $A.get("e.c:OnChangeEvent");
       appEvent.setParams({"onchange1":"true"});
       appEvent.fire();
        var selectedRecordId = event.getParam("recordId");
        var selectedSourceName = event.getParam("sourceName");
        var selectedRecordLabel = event.getParam("recordLabel");
        if((selectedSourceName) && (selectedSourceName.startsWith('relatedArticlesToCreate'))){
        const rowIndex = selectedSourceName.replace('relatedArticlesToCreate', ''); // Extract index from name attribute            
            let relatedArticlesToCreate = component.get("v.relatedArticlesToCreate");
            relatedArticlesToCreate[rowIndex]['tileKnowledgeId'] = selectedRecordId;
            relatedArticlesToCreate[rowIndex]['tileKnowledgeName'] = selectedRecordLabel;
            component.set("v.relatedArticlesToCreate", relatedArticlesToCreate);            
        }
    }
})