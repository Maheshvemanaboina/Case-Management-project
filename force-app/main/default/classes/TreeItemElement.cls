/**
 * Created by KJM on 20/05/2019.
 */

public without sharing class TreeItemElement {
    @AuraEnabled public String label { get; private set; }
    @AuraEnabled public String name { get; private set; }
    @AuraEnabled public List<TreeItemElement> items { get; private set; }
    @AuraEnabled public Boolean expanded { get; private set; }
    @AuraEnabled public String href { get; private set; }
    @AuraEnabled public String metatext { get; private set; }

    public TreeItemElement(String label, String name, List<TreeItemElement> items, Boolean expanded, String href, String metatext) {
        this.label = label;
        this.name = name;
        this.items = (items != null && items.size() > 0) ? items : new List<TreeItemElement>();
        this.expanded = expanded;
        this.href = href;
        this.metatext = metatext;
    }
}