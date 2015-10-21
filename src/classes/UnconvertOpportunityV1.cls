public with sharing class UnconvertOpportunityV1 {


 
        //defuat constructor
        public UnconvertOpportunityV1(){
    
        }    
        
        
        //the value  that determines if the select or lead input text will be used for the lead name 
        private string leadInputOp{get;set;}
        public string getLeadInputOp(){
            if(leadInputOp==null){
                leadInputOp='true';
            }
            return leadInputOp;
        }
        
        public void setLeadInputOp(string input){
        
            this.leadInputOp=input;
        
        }
        
        //used to determin if the task will be copied
        private boolean taskCopy{get;set;}
        public boolean getTaskCopy(){
            if(taskCopy==null){
                taskCopy=false;
            }
            
                return taskCopy;
        }
        public void setTaskCopy(boolean taskCopy){
        
                this.taskCopy=taskCopy;
        
        }
        //used if the contacts list is empty to hide the select list
        private boolean emptyList{get;set;}
        public boolean getEmptyList(){
            if(emptyList==null){
                integer numAssociatedContacts=[SELECT Count() FROM OpportunityContactRole Where OpportunityId=:getCurrentOpp().id AND IsDeleted=false];
                
                if(numAssociatedContacts>0)
                emptyList=false;
                else
                emptyList=true;
            }
            
            return emptyList;
        }
        public void setEmptyList(boolean emptyList){
            this.emptyList=emptyList;
        }
        
        //used to determin if the event will be copied
        private boolean eventCopy{get;set;}
        public boolean getEventCopy(){
            if(eventCopy==null){
                eventCopy=false;
            }
                return eventCopy;
        }
        public void setEventCopy(boolean eventCopy){
        
                this.eventCopy=eventCopy;
        
        }
        
        //if the lead input box is to be rendered
        private boolean leadInputSelect{get;set;}
        public boolean getLeadInputSelect(){
            if(leadInputSelect==null){
                leadInputSelect=true;
            }
        
                return leadInputSelect;
        }
        
        public void setLeadInputSelect(boolean leadInputSelect){
                this.leadInputSelect=leadInputSelect;
        }
        
        //toggle the lead input
        public void leadInputSelect(){
        
            if(getLeadInputOp()=='true'){
                leadInputSelect=true;
            }
            else{
                leadInputSelect=false;
            }
        
        }

    /*
        // used to determine if the account is to be deleted
        private boolean deleteAccount=false;
        public boolean getDeleteAccount(){
           return deleteAccount;
        }
        public void setDeleteAccount(boolean toDelete){
            this.deleteAccount=toDelete;
        }
    */    
        
        //used to determine if the user wants to copy notes and attachments
        private boolean copyNotesAndAttachments{get; set;}
        
        //private boolean copyNotesAndAttachments=false;
        
        public boolean getCopyNotesAndAttachments(){
            if(copyNotesAndAttachments==null){
                copyNotesAndAttachments=false;
            }
            return copyNotesAndAttachments;
        
        }
        
        public void setCopyNotesAndAttachments(boolean copy){
        
        this.copyNotesAndAttachments=copy;
        
        }
        
        /*
        //public boolean deleteContact { get{ }; set; }
        private boolean deleteContact=false;// used to determine if the contact is to be deleted
        public boolean getDeleteContact(){
            
           return deleteContact;
        
        }
        
        public void setDeleteContact(boolean toDelete){
            this.deleteContact=toDelete;
        }
        
        private boolean deleteOpportunity;// used to determine if the opportunity is to be deleted
      
      
        
        public boolean getDeleteOpportunity(){
            if(deleteOpportunity==null){
                deleteOpportunity=false;
            }
            return deleteOpportunity;
        
        }
        
        public void setDeleteOpportunity(boolean toDelete){
            this.deleteOpportunity=toDelete;
        }
        */
        
        
       //sets the opportunity related to this page
        private Opportunity CurrentOpp{get;set;}
        public Opportunity getCurrentOpp() {
            if (CurrentOpp == null) {
                CurrentOpp = [SELECT Id, Name,Account.name, AccountId,IsDeleted
                              FROM Opportunity
                              WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
                              AND IsDeleted= false];
            }
            return CurrentOpp;
        }
        //setCurrentOpp. used for testing
        public void setCurrentOpp(Opportunity CurrentOpp){
           this.CurrentOpp=CurrentOpp;
        }
    
        private String firstName{get;set;}
        public String getFirstName(){
            if(firstName==null){
                firstName='';
            }
           return firstName;
        }
        public void setFirstName(String firstName){
           this.firstName=firstName;
        }
        
        private String lastName{get;set;}
        public String getlastName(){
            if(lastName==null){
                 lastName='';
            }
            return lastName;
        }
        public void setLastName(String lastName){
            this.lastName=lastName;
        }
        // the list of select options for the contact to use for the name of the new lead
        //value currently selected in list
        private String selectedValue;
        
        public String getSelectedValue(){
            return selectedValue;
        } 
        
        public void setSelectedValue(String input){
            selectedValue=input;
        } 
        
       
    
    //method for functionality of the cancel button
    public pageReference cancel() {
        
        Pagereference oppReference;
        
        try{
           string idString ='/'+getCurrentOpp().Id;
           oppReference = new PageReference(idString);
        }catch(exception e){
            ApexPages.addMessages(e);
        }
        
        
        return oppReference;
    
    }
    
        // property to hold contacts for processing later
        private map<Id, Contact> ContactsMap;
        public map<Id, Contact> getContactsMap() {
            if (ContactsMap == null) {
                try{  
                    //find the opportunityContactRoles related to this opportunity which are not already deleted
                    List<OpportunityContactRole> contactRoles =[SELECT ContactId,IsDeleted, OpportunityId
                                                                                                            FROM OpportunityContactRole
                                                                                                            Where OpportunityId=:getCurrentOpp().id
                                                                                                            AND IsDeleted=false];
                    system.debug('size of contactRoles: '+contactRoles.size());
                    //create a list of ids to hold the contact ids related to this opportunity
                    List<id> contactIds = new list<id>();       
                    
                    //catch any errors                
                                                                                          
                        for(OpportunityContactRole o : contactRoles)            
                        {
                                //add each contacts id to a list for use in mapping the contacts
                                contactIds.add(o.ContactId);
                        }                                                                               
               
                        
                        
                        //map the contacts of all related contacts
                       ContactsMap = new map<Id, Contact>([SELECT id, Name, FirstName, LastName
                                                         FROM Contact 
                                                         WHERE id IN: contactIds
                                                        ]);
                                                      
                    }catch(NoDataFoundException e)
                    {
                   
                        ApexPages.addMessages(e);
                   
                    }catch(exception e){
                   
                        ApexPages.addMessages(e);
                   
                    }
            }
            
            return ContactsMap;
        }
    
            //inner class used for selection of record removal
            public class wrapRecord{
            
            
                    public Opportunity oppToRemove{get;set;}//the opportunity to remove
                    public Account accountToRemove{get;set;}//the account to remove
                    public Contact contactRole{ get; set;}//the contact 
                    public boolean selectedtoDelete{ get; set; }//variable for if the contact is to be deleted
                    public String objectName{get;set;}
                    public String objectType{get;set;}//variable which records the type of object used
                    public wrapRecord(Opportunity oppToRemove, Account accountToRemove, Contact contactRole, boolean selectedtoDelete ){
                            this.oppToRemove=oppToRemove;
                            this.accountToRemove=accountToRemove;
                            this.contactRole=contactRole;
                            
                            this.selectedtoDelete=selectedtoDelete;
                            
                            if(oppToRemove!=null){
                                this.objectName=oppToRemove.name;
                                this.objectType='Opportunity';
                            }
                            else
                            if(accountToRemove!=null){
                                this.objectName=accountToRemove.name;
                                 this.objectType='Account';
                            }
                            else if(contactRole!=null){
                                this.objectName=contactRole.name;
                                this.objectType='Contact';
                            }
                            
                    }
            
            }
            //list of records to delete
            private list<wrapRecord> recordsToDelete;
            public list<wrapRecord> getRecordsToDelete()
            {
            
                    if(recordsToDelete == null)
                    {
                        
                            recordsToDelete= new list<wrapRecord>();
                     try{
                            //add the opportunity to list
                            system.debug('current opp is: '+getCurrentOpp());
                            if(getCurrentOpp()!=null)
                                recordsToDelete.add(new wrapRecord(getCurrentOpp(),null,null,false));
                            
                           system.debug('recordsToDelete size: '+recordsToDelete.size()  );
                                //add accounts to list
                                account accountToDelete;
                              system.debug('accountid may be the problem');
                               id accountId=getCurrentOpp().Accountid;
                               
                               system.debug('accountid: '+accountId);
                                accountToDelete = [
                                    select id, isDeleted ,name
                                    from account
                                    where id=:accountid
                                    and isDeleted=false
                                        ];  
                                if(accountToDelete!=null)
                                    recordsToDelete.add(new wrapRecord(null,accountToDelete,null,false));
                                
                            
                            
                            
                            //add contacts to list
                            for(Contact c: getContactsMap().values())
                            {
                                recordsToDelete.add(new wrapRecord(null,null,c,false));
                            }
                            
                            
                        }catch(NoDataFoundException e)
                        {
                       
                           ApexPages.addMessages(e);
                       
                        }catch(exception e){
                       
                           ApexPages.addMessages(e);
                       
                        }
                    }
            
            return recordsToDelete;
            }
         //used in testing to set all records in the records to delete to true.           
        public void setToDeleteAllRecords(){
            
            list<wrapRecord> deleteRec= getRecordsToDelete();
            for(wrapRecord w: deleteRec ){
                w.selectedtoDelete=true;
            }
        
        }
    
        // property to hold the contact options for the display
        private list<selectOption> ContactOptions;
        public list<selectOption> getContactOptions() {
            if (ContactOptions == null) {
                try{
                    contactOptions = new List<SelectOption>();
                   // contactOptions.add(new SelectOption('','Select a Contact to use as the lead name'));
                    if (!getContactsMap().isEmpty()) {
                        for(Contact c: getContactsMap().values()) {
                            contactOptions.add(new SelectOption(c.Id, c.name));
        
                            // use the first row as the selected contact
                            if (selectedValue== null)
                                selectedValue = c.Id;
                        }
                    //contactOptions.add(new SelectOption('other','Other'));    
                        
                    }
                   
                }
                 catch(DmlException e){
                        //deleting may cause an exception
                      ApexPages.addMessages(e);
                 }
                 catch(Exception e){
                        //catch any other exception
                      ApexPages.addMessages(e);
                 }    
            }            
            return contactOptions;
        }
        
        
        public pageReference unconvert(){
    
            PageReference leadReference = null;
            
            if(getCurrentOpp()!=null){
               // system.debug('opp is not null');
                try{
                    boolean insertLead=true;
                    
                    Lead newLead= new Lead();
                    
                    Account companyOnOpp =  [SELECT id, name FROM account WHERE id=:getCurrentOpp().AccountId ];
                    
                    newLead.Company=companyOnOpp.Name;
                    //system.debug('actual value: '+getContactsMap().get(recordsToDelete[2].contactRole.name));
                    
                    //system.debug('Selected value: '+getSelectedValue());
                    //get contact to use for lead name
                    Contact c = getContactsMap().get(getSelectedValue());
                    
                   system.debug('lead input op: '+ getLeadInputOp());            
                    if(getLeadInputOp()=='true' && !getEmptyList()){    
                    //if first name is not null
                    if(c.FirstName!=null)
                        newLead.FirstName=c.FirstName;
                
                    newLead.LastName=c.LastName;
                    }
                    else{
                        
                        //input custom name if name does not exist
                    if(getFirstName()!=null)
                        newLead.FirstName=getFirstName();
                        
                        if(getLastName()!=null && getLastName()!='')
                            newLead.lastName=getLastName();
                        else{
                        
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'A last name is required.'));
                           insertLead=false;
                        }
                        
                    }
                    
                    
                    system.debug('Insert Converted lead: '+insertLead);
                    
                    //insert newly created lead to ensure its id account id feild is created
                    if(insertLead){
                    insert newLead;
                
                    //refresh newLead to reflect its id.
                
                    //discover all tasks associated with opportunity
                if(taskCopy){
                    list<task> taskList = [
                        select t.id,t.whoid, t.whatid
                        from task t
                        where t.whatid= :getCurrentOpp().id
                        ];
         
                    //assosciate the current opportunity's tasks with the new lead
                    for(task t: taskList){
                        
                        //if the opp is to be deleted null the whatid
                        //if(getDeleteOpportunity()){
                            t.whatid=null;
                        //}
                        t.whoid=newLead.id;
                    }
                    update taskList;
                
                }
                
                 //if the event is to be copied
                 if(eventCopy){
                        //discover all events associated with opportunity
                    
                        list<event> eventList=[
                        select e.id, e.whoid, e.whatid
                        from event e
                        where e.whatid = :getCurrentOpp().id
                        ];
                        
                            //associate the current opportunity's events with the new lead
                    for(event e : eventList){
                    
                    //if the opp is to be deleted null the whatid
                        //if(getDeleteOpportunity()){
                            e.whatid=null;
                        //}
                        
                        e.whoid=newLead.id;
                    
                    }
                    update eventList;
                 }
                 
                if(copyNotesAndAttachments){
                id masterCaseId=newLead.id;
                id oppId=getCurrentOpp().id;
                
                  // Duplicate all attachments for the masterCase.
                // The Attachment does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                // attach any attachment from previous opportunity to the lead
                List<Attachment> AttachToBeCreated = new List<Attachment>();
               // for (Attachment masterAttach : [SELECT Id, Body, ContentType, IsPrivate, Name, Description 
               //                                   FROM Attachment WHERE ParentId IN :AttachmentParents AND IsDeleted=false]) {
                  for (Attachment masterAttach : [SELECT Id, Body, ContentType, IsPrivate, Name, Description ,ParentId
                                                  FROM Attachment WHERE ParentId = :oppId AND IsDeleted=false]) {
                
                    Attachment newAttach = masterAttach.clone();
                    newAttach.ParentId = masterCaseId;
                    AttachToBeCreated.add(newAttach);
                }
                if (!AttachToBeCreated.IsEmpty())
                    insert AttachToBeCreated;
                
                    // Duplicate all notes for the masterCase.
                // The note does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                // attach any note from previous opportunity to the lead
                List<Note> NoteToBeCreated = new List<Note>();
               // for (Attachment masterAttach : [SELECT Id, Body, ContentType, IsPrivate, Name, Description 
               //                                   FROM Attachment WHERE ParentId IN :AttachmentParents AND IsDeleted=false]) {
                  for (Note masterNote : [SELECT Id, Body, IsPrivate,ParentId,Title
                                                  FROM Note WHERE ParentId = :oppId AND IsDeleted=false]) {
                
                    Note newNote = masterNote.clone();
                    newNote.ParentId = masterCaseId;
                    NoteToBeCreated.add(newNote);
                }
                if (!NoteToBeCreated.IsEmpty())
                    insert NoteToBeCreated;
                
                }
                
                //set opportunity to closed lost
                getCurrentOpp().stageName='Closed Lost';
                update getCurrentOpp();
                    //System.debug('before delete contacts');
                    
                    //get the account and contacts that are to be deleted. delete the account before deleting the opp
                    for(wrapRecord wRecord: getRecordsToDelete())
                    {
                        // system.debug('selectedToDelete: '+wRecord.selectedtoDelete);
                        if(wRecord.selectedtoDelete){
                           
                           
                            if(wRecord.objectType=='Contact'){
                                delete wRecord.contactRole;
                                system.debug('contact deleted');
                            }
                            
                        }
                        
                        
                      }
                       
                       //the first record is should be the opportunity
                         if(getRecordsToDelete()[0].selectedtoDelete){
                            if(getRecordsToDelete()[0].objectType=='Opportunity')
                                 delete getRecordsToDelete()[0].oppToRemove;
                         }
                          //the second record should be the account
                      if(getRecordsToDelete()[1].selectedtoDelete){
                           if(getRecordsToDelete()[1].objectType=='Account'){
                            for(wrapRecord wRecord: getRecordsToDelete())
                            {
                        // system.debug('selectedToDelete: '+wRecord.selectedtoDelete);
                                //find associated contact and opportunity that are not going to be deleted
                                //and remove the association from the account.
                                if(!wRecord.selectedtoDelete){
                           
                                    if(wRecord.objectType=='Opportunity'){
                                        wRecord.oppToRemove.AccountId=null;
                                        update wRecord.oppToRemove;
                                    }
                                    if(wRecord.objectType=='Contact'){
                                     wRecord.contactRole.AccountId = null;
                                     
                                     
                                     update wRecord.contactRole;
                            
                                    }
                        
                        
                                }
                            }
                                delete getRecordsToDelete()[1].accountToRemove;
                        
                           }
                       
                       }
                    
                      leadReference = new PageReference('/' + newLead.Id);  
                    }
                    
                 }
                 catch(DmlException e){
                        //deleting may cause an exception
                      ApexPages.addMessages(e);
                 }
                 catch(Exception e){
                        //catch any other exception
                      ApexPages.addMessages(e);
                 }
                    
                
                
              
            }
               //send to debug the status of the opportunity
               //system.debug('Current opp is' + getCurrentOpp());
            
        
        
        
            return leadReference;
        }
}