public class SF1_ProspectToStudentExt {

    Prospect_c__x prospect;

    public SF1_ProspectToStudentExt(ApexPages.StandardController con) {
        prospect = new Prospect_c__x();
        prospect = [select Id, Training_Alerts__Name_c__c, Training_Alerts__Email_c__c, Training_Alerts__Mobile_c__c, 
        Training_Alerts__SF1_Prospect__c, Company_Name__c, Training_Alerts__Courses__c, Training_Alerts__Batch_c__c
        from Prospect_c__x where Id =: con.getId()];
    }

    public Pagereference createStudent() {
        Pagereference pr;
        List<Training_Alerts__Student__c> existingStudentLst = new List<Training_Alerts__Student__c>(
            [Select Id, Name, Training_Alerts__Student_Name__c, Training_Alerts__Email_Id__c, Training_Alerts__Whats_App__c, 
            Training_Alerts__Mobile_Number__c, Training_Alerts__Batch__c, Training_Alerts__Working_Company__c, 
            Training_Alerts__Courses__c from Training_Alerts__Student__c where Training_Alerts__Email_Id__c =: prospect.Email_c__c]
        );
        if(existingStudentLst.size() > 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,'Prospect already exists as Student.<a href="/'+existingStudentLst[0].Id+'">'+existingStudentLst[0].Name+'</a>');
            ApexPages.addMessage(msg);
        }
        else {
            List<Batch__c> batchLst = [select Id from Batch__c where Name =: prospect.Training_Alerts__Batch_c__c];
            if(batchLst != null && batchLst.size() > 0) {
                Training_Alerts__Student__c student = new Training_Alerts__Student__c(
                    Training_Alerts__Student_Name__c = prospect.Training_Alerts__Name_c__c,
                    Training_Alerts__Email_Id__c = prospect.Training_Alerts__Email_c__c,
                    Training_Alerts__Whats_App__c = prospect.Training_Alerts__Mobile_c__c,
                    Training_Alerts__Mobile_Number__c  = prospect.Training_Alerts__Mobile_c__c,
                    Training_Alerts__Batch__c = batchLst[0].Id,
                    Training_Alerts__Working_Company__c = prospect.Company_Name__c,
                    Training_Alerts__Courses__c = prospect.Training_Alerts__Courses__c
                );
                
                try {
                    insert student; //TO DO: Please validate if the student already exists.
                    pr = new PageReference('/'+student.Id);
                }
                catch(Exception e) {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,'Student insert exception.'+e.getMessage());
                    ApexPages.addMessage(msg);
                }
            }
            else {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,'Invalid Batch Number.');
                ApexPages.addMessage(msg);
            }
        }
        return pr;
    }
}