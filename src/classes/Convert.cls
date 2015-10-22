public class Convert {
    // The function of this class is to convert an opportunity into a lead.
    // The first version of this class will only work when there is a prior lead that the opportunity is derived from
	
    private boolean firstRun{ get{if(firstRun == null) {firstRun = true;} return firstRun; } set;}
	// error msg holder
	private string errorMsg;
	public string getErrorMsg () {
		// make sure that the error msg is never null.
		if (errorMsg == null) {
			errorMsg = '';
		}
		
		return errorMsg;
	}
	
	private boolean opportunityError;
	public boolean getOpportunityError () {
		if (opportunityError == null) {
			opportunityError = false;
			// insure thet the opportunity is initialized
			getOppToConvert();
		}
		return opportunityError;
	}
	
	
    // the message output to the user to explain how this page is used
    private string functionDescription;
    public string getFunctionDescription () {
        if (functionDescription == null)
        	functionDescription = 'Convert your Opportunity back into a lead <br/> This will create a new lead based on your selections';
        
        return functionDescription;
    }
    
    private boolean transferContent;
    public boolean getTransferContent() {
    	if(transferContent == null)
    		transferContent = true;
    	
    	return transferContent;
    }
    public void setTransferContent(boolean value) {
    	transferContent = value;
    }
    
    // The opportunity to be converted back into a lead
    private opportunity oppToConvert;
    public Opportunity getOppToConvert() {
        
		// find the opportunity passed through its id if one exists
        string oppId = Apexpages.currentPage().getParameters().get('oppId');
        
        // if the opportunity to convert is null and the id is valued begin initializing the opportunity and lead
        if (oppToConvert == null && !String.isblank(oppId) && firstRun) {
            
            // if the opportunity to convert is null and the oppid exists in the page parameters do a query for it
        	oppToConvert = [SELECT id,name  FROM Opportunity WHERE id =: oppId];
        	
            // if the opportunity was not found
            if(oppToConvert == null) {
            
            	opportunityError = True;
            	
            	errorMsg = 'Could not find the requested opportunity to convert. Please make sure to use the convert button on the detail page.';  
            
            
            } else
                // look for the lead that the opportunity was converted from
                inputLead = [SELECT name,firstname,lastname, company FROM Lead WHERE ConvertedOpportunityId =: oppId ALL ROWS];
            // if no lead was found initialize the input lead as a blank lead and output a message to have the user value it
            if (inputLead == null) {
            	inputLead = new lead();
            	errorMsg = 'Please enter the first name, last name, and company name you desire for the new lead';
            
            }
            else 
            	errorMsg = 'The first name, last name, and company name have been supplied for you based on the original converted lead';
            
            firstRun = false;
        } else if (oppToConvert == null) {
            
            	opportunityError = True;
            	
            	errorMsg = 'An opportunity was not supplied to convert. Please make sure to use the convert button on the detail page.';  
            
            
       	}
        
		return oppToConvert;        
    }
    
    // lead used for allowing the user to value fields for the new lead.
    private Lead inputLead;
    public Lead getInputLead () {
        return inputLead;
    }
    
    public void setInputLead (lead value) {
        inputLead = value;
    }
    
    // this method will create a new lead based on the opportunity selected
    public PageReference convertToLead () {
        PageReference returnRef;
        
        if(inputLead != null) {
        	// check if the firstname, lastname, and company are valued in the lead
        	if(!String.isblank(inputLead.lastName) && !String.isblank(inputLead.company)) {
        		Lead newLead = new lead(firstName = inputLead.firstname, lastName = inputLead.lastName, company = inputLead.company);    
        	
	            // if the new lead was succesfully valued
	            if(newLead != null) {
					// insert the new lead
	            	insert newLead;
	            	
	            	// update the converted lead field on the opportunity
	            	oppToConvert.ConvertedLeadId__c = newLead.id;
	            	update oppToConvert;
	            	
	            	// if transfer is true go to the transfer page
	            	if(transferContent)
	            		returnRef = new PageReference('/apex/Transfer?oppId=' + oppToConvert.id);
	            	// if transfer is false go to the lead page
	            	
	            	else
	                // update the return reference to send the user to the newly created lead
	                returnRef = new PageReference('/' + newLead.id); 
	            }     
        	}
        	
        	
            
        }
        
        return returnRef;
        
    }
    // method to handle the behavior of the cancel button
    public PageReference cancel() {
        PageReference returnRef;
        String oppId = Apexpages.currentPage().getParameters().get('oppId');
        // if an opportunity was defined use the id to return to the opportunity page
        if(!String.isblank(oppId) ) 
            returnRef = new PageReference('/' + oppId);
        else 
        // if you cannot find the appropriate opportunity 
           returnRef = new PageReference('/');
        
        return returnRef;
    }
}