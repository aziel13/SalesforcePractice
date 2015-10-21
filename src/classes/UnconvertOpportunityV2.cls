public with sharing class UnconvertOpportunityV2 {



 
        //defuat constructor
        public UnconvertOpportunityV2(){
    
        }    
        
        
        //the value  that determines if the select or lead input text will be used for the lead name 
        private string leadInputOp{get;set;}
        public string getLeadInputOp(){
            if(leadInputOp==null)
                leadInputOp='true';
            
            return leadInputOp;
        }
        
        public void setLeadInputOp(string input){
        
            this.leadInputOp=input;
        
        }
        
        //used to determin if the task will be copied
        private boolean taskCopy{get;set;}
        public boolean getTaskCopy(){
            if(taskCopy==null)
                taskCopy=false;
            
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
            if(eventCopy==null)
                eventCopy=false;
            
                return eventCopy;
        }
        public void setEventCopy(boolean eventCopy){
        
                this.eventCopy=eventCopy;
        
        }
        
        //if the lead input box is to be rendered
        private boolean leadInputSelect{get;set;}
        public boolean getLeadInputSelect(){
            if(leadInputSelect==null)
                leadInputSelect=true;
            
        
                return leadInputSelect;
        }
        
        public void setLeadInputSelect(boolean leadInputSelect){
                this.leadInputSelect=leadInputSelect;
        }
        
        //toggle the lead input
        public void leadInputSelect(){
        
            if(getLeadInputOp()=='true')
                leadInputSelect=true;
            
            else
                leadInputSelect=false;
            
        
        }
        
        
        private String companyName{get;set;}
        public String getCompanyName()
        {
	        if(companyName==null)
	        	companyName='';
	    
        return companyName;
        }
        public void setCompanyName(String companyName){
        this.companyName=companyName;
        }
        
        private boolean noAccount{get;set;}
        public boolean getNoAccount()
        {
	        if(noAccount==null){
	        	
	        	//check to see if there is an account associated with the current opp
	        	if(getCurrentOpp().accountId==null)
	        	noAccount=true;
	        	else
	        	noAccount=false;
	        }
            return noAccount;
        }
        public void setNoAccount(boolean noAccount){
            this.noAccount=noAccount;
        }
        
        //used to determine if the user wants to copy notes and attachments
        private boolean copyNotesAndAttachments{get; set;}
        
        //private boolean copyNotesAndAttachments=false;
        
        public boolean getCopyNotesAndAttachments(){
            if(copyNotesAndAttachments==null)
                copyNotesAndAttachments=false;
            
            return copyNotesAndAttachments;
        
        }
        
        public void setCopyNotesAndAttachments(boolean copy){
        
        this.copyNotesAndAttachments=copy;
        
        }
         //sets the opportunity related to this page
        private Opportunity CurrentOpp{get;set;}
        public Opportunity getCurrentOpp() {
            if (CurrentOpp == null) 
                CurrentOpp = [SELECT Id, Name,Account.name, AccountId,IsDeleted
                              FROM Opportunity
                              WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
                              AND IsDeleted= false];
            
            return CurrentOpp;
        }
        //setCurrentOpp. used for testing
        public void setCurrentOpp(Opportunity CurrentOpp){
           this.CurrentOpp=CurrentOpp;
        }
    
        private String firstName{get;set;}
        public String getFirstName(){
            if(firstName==null)
                firstName='';
            
           return firstName;
        }
        public void setFirstName(String firstName){
           this.firstName=firstName;
        }
        
        private String lastName{get;set;}
        public String getlastName(){
            if(lastName==null)
                 lastName='';
            
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
                    
                    //create a list of ids to hold the contact ids related to this opportunity
                   List<id> contactIds = new list<id>();       
                    
                    //catch any errors                
                    ContactsMap = new map<Id, Contact>([
														SELECT id, Name, FirstName, LastName
														FROM Contact 
														WHERE id IN(
														    SELECT ContactId
														    FROM OpportunityContactRole
														    Where OpportunityId=:getCurrentOpp().id
														    AND IsDeleted=false
														)]);
                                                      
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
                    public boolean noteAttachCopy{get;set;}//variable to determine if notes and attachments should be copied to this variable
                    public boolean eventCopy{get;set;}//variable for if events will be copied 
                    public boolean taskCopy{get;set;} //variable for if tasks will be copied
                    public wrapRecord(Opportunity oppToRemove, Account accountToRemove, Contact contactRole, boolean selectedtoDelete, boolean noteAttachCopy,boolean eventCopy, boolean taskCopy ){
                            //copy values from constructor into variable
                            this.oppToRemove=oppToRemove;
                            this.accountToRemove=accountToRemove;
                            this.contactRole=contactRole;
                            this.selectedtoDelete=selectedtoDelete;
                            this.noteAttachCopy=noteAttachCopy;
                            this.eventCopy=eventCopy;
                            this.taskCopy=taskCopy;
                            
                            
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
                                recordsToDelete.add(new wrapRecord(getCurrentOpp(),null,null,false,false,false,false));
                           
                           if(getCurrentOpp().accountId!=null ){ 
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
                                    recordsToDelete.add(new wrapRecord(null,accountToDelete,null,false,false,false,false));
                                
                           }
                            
                            
                            //add contacts to list
                            for(Contact c: getContactsMap().values())
                                recordsToDelete.add(new wrapRecord(null,null,c,false,false,false,false));
                            
                            
                            
                        }catch(NoDataFoundException e){
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
            for(wrapRecord w: deleteRec )
                w.selectedtoDelete=true;
            
        
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


                if(!getNoAccount()){
                    Account companyOnOpp =  [SELECT id, name FROM account WHERE id=:getCurrentOpp().AccountId ];

                    newLead.Company=companyOnOpp.Name;
                }
                else
                {

                    String companyName= getCompanyName();
                    companyName.split('1');

                    if(companyName!=null &&companyName!='')
                        newLead.Company=getCompanyName();
                    else{

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'A company name is required.'));
                        insertLead=false;
                    }

                }
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
              
                
                
                //set opportunity to closed lost
                getCurrentOpp().stageName='Closed Lost';
                update getCurrentOpp();
                    //System.debug('before delete contacts');
                    
                    //get the account and contacts that are to be deleted. delete the account before deleting the opp
                    for(wrapRecord wRecord: getRecordsToDelete())
                    {
                        // system.debug('selectedToDelete: '+wRecord.selectedtoDelete);
                        if(wRecord.selectedtoDelete)
                            if(wRecord.objectType=='Contact'){
                            	
                            	if(wRecord.taskCopy){
                                    list<task> taskList = [
                                                           select t.id,t.whoid, t.whatid
                                                           from task t
                                                           where t.whoid= :wRecord.contactRole.id
                                                           ];

                                    //assosciate the current opportunity's tasks with the new lead
                                    for(task t: taskList){
                                        // t.whatid=null;
                                        t.whoid=newLead.id;
                                    }//endfor
                                    update taskList;

                                }//endtaskcopy

                                //if the event is to be copied
                                if(wRecord.eventCopy){
                                    //discover all events associated with opportunity

                                    list<event> eventList=[
                                                           select e.id, e.whoid, e.whatid
                                                           from event e
                                                           where e.whatid = :wRecord.contactRole.id
                                                           ];

                                    //associate the current opportunity's events with the new lead
                                    for(event e : eventList){
                                        e.whatid=null;
                                        e.whoid=newLead.id;
                                    }//endfor
                                    update eventList;
                                }//endeventcopy

                                if(wRecord.noteAttachCopy){
                                    id masterCaseId=newLead.id;
                                    id oppId=wRecord.contactRole.id;

                                    // Duplicate all attachments for the masterCase.
                                    // The Attachment does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                                    // attach any attachment from previous opportunity to the lead
                                    List<Attachment> AttachToBeCreated = new List<Attachment>();
                                    for (Attachment masterAttach : [SELECT Id, Body, ContentType, IsPrivate, Name, Description ,ParentId
                                                                    FROM Attachment WHERE ParentId = :oppId AND IsDeleted=false]) {

                                        Attachment newAttach = masterAttach.clone();
                                        newAttach.ParentId = masterCaseId;
                                        AttachToBeCreated.add(newAttach);
                                    }//endfor
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
                                    }//endfor
                                    if (!NoteToBeCreated.IsEmpty())
                                        insert NoteToBeCreated;

                                }
                            	
                            	
                                delete wRecord.contactRole;
                                system.debug('contact deleted');
                            }
                            
                        
                        
                        
                      }
                       
                       //the first record is should be the opportunity
                         if(getRecordsToDelete()[0].selectedtoDelete)
                            if(getRecordsToDelete()[0].objectType=='Opportunity'){
                            	
                            
                            	
                            if(getRecordsToDelete()[0].taskCopy){
                                list<task> taskList = [
                                                       select t.id,t.whoid, t.whatid
                                                       from task t
                                                       where t.whatid= :getRecordsToDelete()[0].oppToRemove.id
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
                        if(getRecordsToDelete()[0].eventCopy){
                            //discover all events associated with opportunity

                            list<event> eventList=[
                                                   select e.id, e.whoid, e.whatid
                                                   from event e
                                                   where e.whatid = :getRecordsToDelete()[0].oppToRemove.id
                                                   ];

                            //associate the current opportunity's events with the new lead
                            for(event e : eventList){
                                e.whatid=null;
                                e.whoid=newLead.id;
                            }
                            update eventList;
                        }

                           if(getRecordsToDelete()[0].noteAttachCopy){
                            id masterCaseId=newLead.id;
                            id oppId=getRecordsToDelete()[0].oppToRemove.id;

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
                            	//Delete the opp
                                 delete getRecordsToDelete()[0].oppToRemove;
                         
                    }
                         
                         
                          //the second record should be the account
                      if(getRecordsToDelete()[1].selectedtoDelete)
                           if(getRecordsToDelete()[1].objectType=='Account'){
                        
                        if(getRecordsToDelete()[1].taskCopy){
                                list<task> taskList = [
                                                       select t.id,t.whoid, t.whatid
                                                       from task t
                                                       where t.whatid= :getRecordsToDelete()[1].accountToRemove.id
                                                       ];

                                //assosciate the current opportunity's tasks with the new lead
                                for(task t: taskList){
                                    t.whatid=null;

                                    t.whoid=newLead.id;
                                }
                                update taskList;

                            }

                            //if the event is to be copied
                            if(getRecordsToDelete()[1].eventCopy){
                                //discover all events associated with opportunity

                                list<event> eventList=[
                                                       select e.id, e.whoid, e.whatid
                                                       from event e
                                                       where e.whatid = :getRecordsToDelete()[1].accountToRemove.id
                                                       ];

                                //associate the current opportunity's events with the new lead
                                for(event e : eventList){
                                    e.whatid=null;
                                    e.whoid=newLead.id;
                                }
                                update eventList;
                            }

                        
                        
                         if(getRecordsToDelete()[1].noteAttachCopy){
                                id masterCaseId=newLead.id;
                                id oppId=getRecordsToDelete()[1].accountToRemove.id;

                                // Duplicate all attachments for the masterCase.
                                // The Attachment does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                                // attach any attachment from previous opportunity to the lead
                                List<Attachment> AttachToBeCreated = new List<Attachment>();
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
                        
                            for(wrapRecord wRecord: getRecordsToDelete())
                            {
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
                       
                      leadReference = new PageReference('/' + newLead.Id);  
                    }//end of insert lead
                    
                 }//end of try
                 catch(DmlException e){
                        //deleting may cause an exception
                      ApexPages.addMessages(e);
                 }
                 catch(Exception e){
                        //catch any other exception
                      ApexPages.addMessages(e);
                 }
              
            }//end of insert lead
        
            return leadReference;
        }//end of unconvert

}//end of UnconvertOpportunityV2