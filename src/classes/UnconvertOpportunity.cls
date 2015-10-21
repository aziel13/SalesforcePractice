public with sharing class UnconvertOpportunity {
    //  Default constructor
    public UnconvertOpportunity(){}    

    //  The value  that determines if the select or lead input text will be used for the lead name 
    private string leadInputOp{get;set;}
    public string getLeadInputOp(){
        if(leadInputOp == null){
            integer numAssociatedContacts = [SELECT Count() FROM OpportunityContactRole Where OpportunityId=:getCurrentOpp().id AND IsDeleted=false];
            
            if(numAssociatedContacts > 0)
                leadInputOp = 'true';
            else
                leadInputOp = 'false';
        
        }
        
        return leadInputOp;
    }
        
    public void setLeadInputOp(string input){
    
        this.leadInputOp = input;
    
    }
    //the value  that determines if the select or lead input text will be used for the lead name 
    private string companyInputOp{get;set;}
    public string getCompanyInputOp(){
        if(companyInputOp == null){
            
            if(getCurrentOpp().accountId == null)
                companyInputOp = 'false';
            else
                companyInputOp = 'true';  
        }
        
        return companyInputOp;
    }
        
    public void setCompanyInputOp(string companyInputOp){
        this.companyInputOp = companyInputOp;
    }
    //used if the contacts list is empty to hide the select list
    private boolean emptyList{get;set;}
    public boolean getEmptyList(){
        if(emptyList == null){
            integer numAssociatedContacts = [SELECT Count() FROM OpportunityContactRole Where OpportunityId=:getCurrentOpp().id AND IsDeleted = false];
            
            if(numAssociatedContacts > 0)
                emptyList = false;
            else
                emptyList = true;
        }
        
        return emptyList;
    }
    public void setEmptyList(boolean emptyList){
        this.emptyList = emptyList;
    }
        
    //if the lead input box is to be rendered
    private boolean leadInputSelect{get;set;}
    public boolean getLeadInputSelect(){
        if(leadInputSelect == null){
            integer numAssociatedContacts = [SELECT Count() FROM OpportunityContactRole Where OpportunityId=:getCurrentOpp().id AND IsDeleted=false];
            if(numAssociatedContacts > 0)
                leadInputSelect = true;
            else
                leadInputSelect = false;
        }
        return leadInputSelect;
    }
    
    public void setLeadInputSelect(boolean leadInputSelect){
        this.leadInputSelect=leadInputSelect;
    }
        
    //toggle the lead input
    public void leadInputSelect(){
    
        if(getLeadInputOp() == 'true')
            leadInputSelect = true;
        else
            leadInputSelect = false;
    }
    //used to control visibility of company input and related no company available error message
    private boolean companyInputSelect{get;set;}
    public boolean getCompanyInputSelect(){
        if(companyInputSelect == null)
        {
            if(getCurrentOpp().accountId != null)
                companyInputSelect = true;
            else
                companyInputSelect = false;
        }
            return companyInputSelect;
    }
    
    public void setCompanyInputSelect(boolean companyInputSelect){
        this.companyInputSelect = companyInputSelect;
    }
        
    //toggle the lead input
    public void companyInputSelect(){
        if(getCompanyInputOp() == 'true')
            companyInputSelect = true;
        else
            companyInputSelect = false;
    }
        
    private String companyName{get;set;}
    public String getCompanyName(){
        if(companyName == null)
            companyName = '';
    return companyName;
    }
    public void setCompanyName(String companyName){
        this.companyName = companyName;
    }
    
    private boolean noAccount{get;set;}
    public boolean getNoAccount()
    {
        if(noAccount == null){
            
            //check to see if there is an account associated with the current opp
            if(getCurrentOpp().accountId == null)
                noAccount = true;
            else
                noAccount = false;
        }
        return noAccount;
    }
    public void setNoAccount(boolean noAccount){
        this.noAccount = noAccount;
    }
    //sets the opportunity related to this page
    private Opportunity CurrentOpp{get;set;}
    public Opportunity getCurrentOpp() {
        if (CurrentOpp == null) 
            CurrentOpp = [SELECT Id,LeadSource, Name,Account.name, AccountId,IsDeleted, Description
                          FROM Opportunity
                          WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
                          AND IsDeleted = false];
        
        return CurrentOpp;
    }
    //setCurrentOpp. used for testing
    public void setCurrentOpp(Opportunity CurrentOpp){
       this.CurrentOpp = CurrentOpp;
    }
    
    private String firstName{get;set;}
    public String getFirstName(){
        if(firstName == null)
            firstName = '';
        
       return firstName;
    }
    public void setFirstName(String firstName){
       this.firstName = firstName;
    }
    
    private String lastName{get;set;}
    public String getlastName(){
        if(lastName == null)
             lastName = '';
        
        return lastName;
    }
    public void setLastName(String lastName){
        this.lastName = lastName;
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
           string idString = '/'+getCurrentOpp().Id;
           oppReference = new PageReference(idString);
        }catch(exception e){ApexPages.addMessages(e);}
        
        
        return oppReference;
    
    }
    
    //lead created for the opportunity by unconvert
    private Lead newLead{get;set;}
    public Lead getNewLead(){
        if(newLead == null)
            newLead = new Lead();
        
        return newLead;
    }
    public void setNewLead(Lead newLead)
    {
    this.newLead = newLead;
    }
    private PageReference leadOutput{get;set;}
    public PageReference getLeadOutput(){
        return leadOutput;
    }
    public void setLeadOutput(PageReference leadOutput){
        this.leadOutput=leadOutput;
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
                                                    SELECT id, title,Name, FirstName, LastName,email,phone,Fax,MobilePhone,MailingCity,MailingState, MailingCountry, MailingPostalCode,MailingStreet
                                                    FROM Contact 
                                                    WHERE id IN(
                                                        SELECT ContactId
                                                        FROM OpportunityContactRole
                                                        Where OpportunityId = :getCurrentOpp().id
                                                        AND IsDeleted = false
                                                    )]);
                                                  
                }catch(NoDataFoundException e){ApexPages.addMessages(e);}catch(exception e){ApexPages.addMessages(e);}
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
        public boolean preventDelete{get;set;}
        public wrapRecord(Opportunity oppToRemove, Account accountToRemove, Contact contactRole, boolean selectedtoDelete, boolean noteAttachCopy,boolean eventCopy, boolean taskCopy ,boolean preventDelete){
            //copy values from constructor into variable
            this.oppToRemove = oppToRemove;
            this.accountToRemove = accountToRemove;
            this.contactRole = contactRole;
            this.selectedtoDelete = selectedtoDelete;
            this.noteAttachCopy = noteAttachCopy;
            this.eventCopy = eventCopy;
            this.taskCopy = taskCopy;
            this.preventDelete=preventDelete;
            if(oppToRemove != null){
                this.objectName = oppToRemove.name;
                this.objectType = 'Opportunity';
            }
            else
            if(accountToRemove != null){
                this.objectName = accountToRemove.name;
                this.objectType = 'Account';
            }
            else if(contactRole != null){
                this.objectName = contactRole.name;
                this.objectType = 'Contact';
            }
                
        }
    
    }
    //list of records to delete
    private list<wrapRecord> recordsToDelete;
    public list<wrapRecord> getRecordsToDelete(){

        if(recordsToDelete == null)
        {
            
            recordsToDelete = new list<wrapRecord>();
            try{
                //add the opportunity to list
                system.debug('current opp is: '+getCurrentOpp());
                if(getCurrentOpp() != null)
                    recordsToDelete.add(new wrapRecord(getCurrentOpp(),null,null,true,true,true,true,false));
               
               if(getCurrentOpp().accountId != null ){ 
                   //add accounts to list
                   account accountToDelete;
                   id accountId = getCurrentOpp().Accountid;
                   
                   accountToDelete = [select id, isDeleted ,name from account where id=:accountid and isDeleted = false];
                   
                   integer otherOpps =[SELECT Count() FROM Opportunity Where Accountid =: getCurrentOpp().Accountid AND id !=: getCurrentOpp().id];
                   integer otherContacts=[SELECT Count() FROM CONTACT WHERE id NOT IN:getContactsMap().values() AND accountid=:getCurrentOpp().Accountid];
                   
                   
                   if(accountToDelete != null && otherOpps==0 && otherContacts==0)
                        recordsToDelete.add(new wrapRecord(null,accountToDelete,null,true,true,true,true,false));
                   else
                        recordsToDelete.add(new wrapRecord(null,accountToDelete,null,false,true,true,true,true));
               }
                
                //add contacts to list
                for(Contact c: getContactsMap().values())
                    recordsToDelete.add(new wrapRecord(null,null,c,true,true,true,true,false));
            }catch(NoDataFoundException e){ApexPages.addMessages(e);}catch(exception e){ApexPages.addMessages(e);}
        }
    
        return recordsToDelete;
    }
    
    //used in testing to set all records in the records to delete to true.           
    public void setToDeleteAndCopyAllRecords(){
            
        list<wrapRecord> deleteRec = getRecordsToDelete();
        for(wrapRecord w: deleteRec ){
            w.selectedtoDelete = true;
            w.taskCopy = true;
            w.eventCopy = true;
            w.noteAttachCopy = true;
            
        }
    }
    
    public void setAccountToDelete(){
        getRecordsToDelete()[1].selectedToDelete = true;
    }
    
    // property to hold the contact options for the display
    private list<selectOption> ContactOptions;
    public list<selectOption> getContactOptions() {
        if (ContactOptions == null) {
            try{
                contactOptions = new List<SelectOption>();
                if (!getContactsMap().isEmpty()) {
                    for(Contact c: getContactsMap().values()) {
                        contactOptions.add(new SelectOption(c.Id, c.name));
    
                        // use the first row as the selected contact
                        if (selectedValue == null)
                            selectedValue = c.Id;
                    }
                }
            }
            catch(DmlException e){ApexPages.addMessages(e);}catch(Exception e){ ApexPages.addMessages(e);}
        }            
        return contactOptions;
    }
    
    public void unconvert(){
        PageReference leadReference = null;
        if(getCurrentOpp()!=null){
            try{
                boolean insertLead=true;
                
                if(getCurrentOpp().Description!= null)
                getNewLead().Description = getCurrentOpp().Description;
                
                if(!getNoAccount() && getCompanyInputOp() == 'true'){
                    Account companyOnOpp =  [SELECT id, name FROM account WHERE id=:getCurrentOpp().AccountId AND IsDeleted=false ];

                    getNewLead().Company = companyOnOpp.Name;
                }
                else
                {
                    //get the current company name
                    String companyName = getCompanyName();
                    if(companyName != null &&companyName != '')
                        getNewLead().Company=companyName;
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'A company name is required.'));
                        insertLead = false;
                    }
                }
                
                if(!getNoAccount()){
                    Account companyOnOpp =  [SELECT id, name,Rating,Industry, numberOfEmployees,AnnualRevenue FROM account WHERE id=:getCurrentOpp().AccountId AND IsDeleted=false ];
                    getNewLead().numberOfEmployees=companyOnOpp.numberOfEmployees;
                    getNewLead().AnnualRevenue=companyOnOpp.AnnualRevenue;
                    getNewLead().Rating=companyOnOpp.Rating;
                    getNewLead().industry=companyOnOpp.Industry;
                }
                
                newLead.LeadSource=getCurrentOpp().LeadSource;
                //get contact to use for lead name
                Contact c = getContactsMap().get(getSelectedValue());
                if(getLeadInputOp() == 'true' && !getEmptyList()){    
                    
                    //fill out name fields with the contact name
                    if(c.FirstName != null)
                        getNewLead().FirstName = c.FirstName;
                    getNewLead().LastName = c.LastName;
                    //fill out other informational fields from the contact
                    getNewLead().MobilePhone=c.MobilePhone;
                    getNewLead().Fax=c.Fax;
                    getNewLead().email=c.email;
                    getNewLead().phone=c.phone;
                    getNewLead().city=c.MailingCity;
                    getNewLead().state=c.MailingState;
                    getNewLead().Country=c.MailingCountry;
                    getNewLead().PostalCode=c.MailingPostalCode;
                    getNewLead().Street=c.MailingStreet;
                    getNewLead().title=c.title;
                    //getNewLead().=c.;
                }
                else{
                    //input custom name if name does not exist
                    if(getFirstName() != null)
                        getNewLead().FirstName = getFirstName();

                    if(getLastName() != null && getLastName() != '')
                        getNewLead().lastName = getLastName();
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, 'A last name is required.'));
                        insertLead = false;
                    }
                }
                    //insert newly created lead to ensure its id account id feild is created
                if(insertLead && getNewLead()!=null){
                    insert newLead;
                    
                    
                    leadReference = new PageReference('/' + getNewLead().Id);  
                    leadOutput=leadReference;
                    
                    //set opportunity to closed lost
                    getCurrentOpp().stageName = 'Closed Lost';
                    
                    update getCurrentOpp();
                    //System.debug('before delete contacts');
                    
                    //get the account and contacts that are to be deleted. delete the account before deleting the opp
                    for(wrapRecord wRecord: getRecordsToDelete())
                    {
                        // system.debug('selectedToDelete: '+wRecord.selectedtoDelete);
                            if(wRecord.objectType == 'Contact'){
                                
                                if(wRecord.taskCopy){
                                    list<task> taskList = [
                                                           SELECT id,whoid,whatid
                                                           FROM task 
                                                           WHERE whoid =: wRecord.contactRole.id
                                                           AND isDeleted=false
                                                           ];

                                    //assosciate the current opportunity's tasks with the new lead
                                    for(task t: taskList){
                                        t.whoid = getNewLead().id;
                                        t.whatid = null;
                                    }//endfor
                                    update taskList;

                                }//endtaskcopy

                                //if the event is to be copied
                                if(wRecord.eventCopy){
                                    //discover all events associated with opportunity
                                    list<event> eventList=[
                                                           SELECT id, whoid, whatid
                                                           FROM event 
                                                           WHERE whoid =: wRecord.contactRole.id
                                                           AND isDeleted=false
                                                           ];

                                    //associate the current opportunity's events with the new lead
                                    for(event e : eventList){
                                        e.whoid = getNewLead().id;
                                        e.whatid = null;
                                    }//endfor
                                    update eventList;
                                }//endeventcopy

                                if(wRecord.noteAttachCopy){
                                    id masterCaseId = getNewLead().id;
                                    id oppId = wRecord.contactRole.id;

                                    // Duplicate all attachments for the masterCase.
                                    // The Attachment does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                                    // attach any attachment from previous opportunity to the lead
                                    List<Attachment> AttachToBeCreated = new List<Attachment>();
                                    List<Attachment> AttachToBeDeleted =new List<Attachment>();
                                    for (Attachment masterAttach : [SELECT Id, Body, ContentType, IsPrivate, Name, Description ,ParentId
                                                                    FROM Attachment WHERE ParentId = :oppId AND IsDeleted=false]) {
                                        AttachToBeDeleted.add(masterAttach);
                                        Attachment newAttach = masterAttach.clone();
                                        newAttach.ParentId = masterCaseId;
                                        AttachToBeCreated.add(newAttach);
                                    }//endfor
                                    if (!AttachToBeCreated.IsEmpty())
                                        insert AttachToBeCreated;
                                    if(!AttachToBeDeleted.IsEmpty())
                                        delete AttachToBeDeleted;
                                    // Duplicate all notes for the masterCase.
                                    // The note does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                                    // attach any note from previous opportunity to the lead
                                    List<Note> NoteToBeCreated = new List<Note>();
                                    List<Note> NoteToBeDeleted = new List<Note>();
                                    for (Note masterNote : [SELECT Id, Body, IsPrivate,ParentId,Title
                                                            FROM Note WHERE ParentId = :oppId AND IsDeleted=false]) {
                                        NoteToBeDeleted.add(masterNote);
                                        Note newNote = masterNote.clone();
                                        newNote.ParentId = masterCaseId;
                                        NoteToBeCreated.add(newNote);
                                    }//endfor
                                    if (!NoteToBeCreated.IsEmpty())
                                        insert NoteToBeCreated;
                                    if(!NoteToBeDeleted.isEmpty())
                                        delete NoteToBeDeleted;
                                }
                                
                                if(wRecord.selectedtoDelete)
                                    delete wRecord.contactRole;
                            }
                      }
                       //the first record is should be the opportunity
                         
                            if(getRecordsToDelete()[0].objectType=='Opportunity'){
                            if(getRecordsToDelete()[0].taskCopy){
                                list<task> taskList = [
                                                       SELECT id,whoid, whatid
                                                       FROM task 
                                                       WHERE whatid= :getRecordsToDelete()[0].oppToRemove.id
                                                       AND IsDeleted=false
                                                       ];

                                //assosciate the current opportunity's tasks with the new lead
                                for(task t: taskList){
                                    t.whoid = getNewLead().id;
                                    t.whatid = null;
                                }
                                update taskList;
                            }
                        //if the event is to be copied
                        if(getRecordsToDelete()[0].eventCopy){
                            //discover all events associated with opportunity

                            list<event> eventList = [
                                                   SELECT id, whoid, whatid
                                                   from event
                                                   where whatid = :getRecordsToDelete()[0].oppToRemove.id
                                                   AND IsDeleted=false
                                                   ];

                            //associate the current opportunity's events with the new lead
                            for(event e : eventList){
                                e.whoid = getNewLead().id;
                                e.whatid = null;
                            }
                            update eventList;
                        }

                        if(getRecordsToDelete()[0].noteAttachCopy){
                            id masterCaseId = getNewLead().id;
                            id oppId = getRecordsToDelete()[0].oppToRemove.id;

                            // Duplicate all attachments for the masterCase.
                            // The Attachment does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                            // attach any attachment from previous opportunity to the lead
                            List<Attachment> AttachToBeCreated = new List<Attachment>();
                            List<Attachment> AttachToBeDeleted =new List<Attachment>();
                            for (Attachment masterAttach : [SELECT Id, Body, ContentType, IsPrivate, Name, Description ,ParentId
                                                            FROM Attachment WHERE ParentId = :oppId AND IsDeleted=false]) {
                                AttachToBeDeleted.add(masterAttach);
                                Attachment newAttach = masterAttach.clone();
                                newAttach.ParentId = masterCaseId;
                                AttachToBeCreated.add(newAttach);
                            }//endfor
                            if (!AttachToBeCreated.IsEmpty())
                                insert AttachToBeCreated;
                            if(!AttachToBeDeleted.IsEmpty())
                                delete AttachToBeDeleted;
                            // Duplicate all notes for the masterCase.
                            // The note does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                            // attach any note from previous opportunity to the lead
                            List<Note> NoteToBeCreated = new List<Note>();
                            List<Note> NoteToBeDeleted = new List<Note>();
                            for (Note masterNote : [SELECT Id, Body, IsPrivate,ParentId,Title
                                                    FROM Note WHERE ParentId = :oppId AND IsDeleted=false]) {
                                NoteToBeDeleted.add(masterNote);
                                Note newNote = masterNote.clone();
                                newNote.ParentId = masterCaseId;
                                NoteToBeCreated.add(newNote);
                            }//endfor
                            if (!NoteToBeCreated.IsEmpty())
                                insert NoteToBeCreated;
                            if(!NoteToBeDeleted.isEmpty())
                                delete NoteToBeDeleted;
                        }
                                //Delete the opp
                        if(getRecordsToDelete()[0].selectedtoDelete)
                            delete getRecordsToDelete()[0].oppToRemove;
                         
                    }
                         
                          //the second record should be the account
                      if(getRecordsToDelete().size()>1)
                               if(getRecordsToDelete()[1].objectType == 'Account'){
                            
                            if(getRecordsToDelete()[1].taskCopy){
                                    list<task> taskList = [
                                                           select t.id,t.whoid, t.whatid
                                                           from task t
                                                           where t.whatid =: getRecordsToDelete()[1].accountToRemove.id AND IsDeleted = false
                                                           ];
    
                                    //assosciate the current opportunity's tasks with the new lead
                                    for(task t: taskList){
                                        t.whoid = getNewLead().id;
                                        t.whatid = null;
                                    }
                                    update taskList;
    
                                }
    
                                //if the event is to be copied
                                if(getRecordsToDelete()[1].eventCopy){
                                    //discover all events associated with account
                                    list<event> eventList = [
                                                           select e.id, e.whoid, e.whatid
                                                           from event e
                                                           where e.whatid = :getRecordsToDelete()[1].accountToRemove.id AND IsDeleted=false
                                                           ];
                                    //associate the current account's events with the new lead
                                    for(event e : eventList){
                                        e.whoid = getNewLead().id;
                                        e.whatid = null;
                                    }
                                    update eventList;
                                }
                                if(getRecordsToDelete()[1].noteAttachCopy){
                                    id masterCaseId = getNewLead().id;
                                    id oppId = getRecordsToDelete()[1].accountToRemove.id;

                                    // Duplicate all attachments for the masterCase.
                                    // The Attachment does not allow parentid reassignment, so it is not possible to change case association by changing the ParentId.
                                    // attach any attachment from previous account to the lead
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
                                    // attach any note from previous account to the lead
                                    List<Note> NoteToBeCreated = new List<Note>();
                                    for (Note masterNote : [SELECT Id, Body, IsPrivate,ParentId,Title
                                                            FROM Note WHERE ParentId =: oppId AND IsDeleted=false]) {

                                        Note newNote = masterNote.clone();
                                        newNote.ParentId = masterCaseId;
                                        NoteToBeCreated.add(newNote);
                                    }
                                    if (!NoteToBeCreated.IsEmpty())
                                        insert NoteToBeCreated;

                                }
                                if(getRecordsToDelete()[1].selectedtoDelete)
                                    for(wrapRecord wRecord: getRecordsToDelete())
                                    {
                                        //find associated contact and opportunity that are not going to be deleted
                                        //and remove the association from the account.
                                        if(!wRecord.selectedtoDelete){
                                            if(wRecord.objectType == 'Opportunity'){
                                                wRecord.oppToRemove.AccountId = null;
                                                update wRecord.oppToRemove;
                                            }
                                        if(wRecord.objectType == 'Contact'){
                                                wRecord.contactRole.AccountId = null;
                                                update wRecord.contactRole;
                                            }
                                        }
                                    }
                                
                                //find associated opportunities and contacts which are not related to this 
                                //opportunity and break their association with this account to prevent them from being deleted
                                
                                list<Opportunity> otherOpps = [SELECT id, accountId FROM Opportunity WHERE id!=:getCurrentOpp().id];
                                
                                
                                if(getRecordsToDelete()[1].selectedtoDelete)
                                    delete getRecordsToDelete()[1].accountToRemove;
                            }
                        ApexPages.addMessage(
                        new ApexPages.Message(
                        ApexPages.severity.info,
                        'Your new Lead record has been created. Click the link below to access it.'));
                    }//end of insert lead
                    
                 }//end of try
                 catch(DmlException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,string.valueOf(e)));
                    ApexPages.addMessage(
                    new ApexPages.Message(
                    ApexPages.severity.info,
                    'Your new Lead record has been created, however additional error(s) may have prevented any requested removal and/or reparenting of records.  Please review the error above for more details.'));}
                    catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,string.valueOf(e)));}
              
            }//end of insert lead
    }//end of unconvert
}