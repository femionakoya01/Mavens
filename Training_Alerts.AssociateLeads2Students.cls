global class AssociateLeads2Students implements Database.Batchable<Sobject> {
    global Iterable<SObject> start(Database.BatchableContext bc) {
        return Database.getQueryLocator('select id, isLead_Associated__c, Email_Id__c from Student__c where isLead_Associated__c = false');
    }
    global void execute(Database.BatchableContext bc, List<SObject> sobjLst) {
        List<String> stdEmails = new List<String>();
        for(Student__c std : (List<Student__c>)sobjLst) {
            stdEmails.add(std.Email_Id__c);
        }
        Map<String,Id> emailIdLeadMap = new Map<String,Id>();
        for(Lead ld : [select id, Email from Lead where Email in: stdEmails]) {
            emailIdLeadMap.put(ld.Email,ld.Id);
        }
        List<Lead> leads2Update = new List<Lead>();
        List<Student__c> students2Update = new List<Student__c>();
        for(Student__c std : (List<Student__c>)sobjLst) {
            if(emailIdLeadMap.containsKey(std.Email_Id__c)) {
                leads2Update.add(new Lead(Id = emailIdLeadMap.get(std.Email_Id__c),Student__c=std.Id));
                students2Update.add(new Student__c(Id=std.id, isLead_Associated__c=true));
            }
        }
        if(leads2Update.size() > 0) {
            try {
                update leads2Update;
                try {
                    update students2Update;
                }
                Catch(Exception e) {
                    system.debug('Exception while updating the students2Update: '+e.getMessage());
                }
            }
            Catch(Exception e) {
                system.debug('Exception while updating the lead2Update: '+e.getMessage());
            }
        }
    }
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob 
        WHERE Id = :BC.getJobId()];
        insert new Training_Log__c(Type__c = 'Batch Result',Description__c = 'BatchApex: AssociateLeads2Students: '+
        'The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
    }
}