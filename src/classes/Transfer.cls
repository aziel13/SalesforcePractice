public with sharing class Transfer {
	
	// an inner class that holds the name of the object that can be transfred, how many would be transfered, and if it should be transfred.
	public class transferableSObject {
		
		public boolean isTransferable{get;set;}
		public boolean needsToBeCopied{get;set;}
		public integer transferableCount{get;set;}
		public string name{get;set;}
		
		
		// initializer for transferable object
		public transferableSObject (string name, integer transferableCount, boolean isTransferable, boolean needsToBeCopied) {
			
			this.isTransferable = isTransferable;
			this.transferableCount = transferableCount;
			this.name = name;
			this.needsToBeCopied = needsToBeCopied;
		
		}
		
		
	}
	
	// class to transfer notes, attachments, tasks, and events from an opportunity to a lead.
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
			getSourceOpportunity();
		}
		return opportunityError;
	}
	
	
    // the message output to the user to explain how this page is used
    private string functionDescription;
    public string getFunctionDescription () {
        if (functionDescription == null)
        	functionDescription = 'Transfer attachments, notes, tasks, and events from converted opportunity to the new lead.';
        
        return functionDescription;
    }
    
    // string that will be used on completion of transfer of records from the opportunity to lead
    private string transferNotice;
    public string getTransferNotice () {
    	
    	// initialize the transfer notice.
    	if (transferNotice == null) {
    		transferNotice = '';
    	}
    	
    	return transferNotice;
    }
    
    private boolean transferComplete;
    public boolean getTransferComplete() {
    	if (transferComplete == null)
    		transferComplete = false;
    	
    	return transferComplete;
    }
    
    
    // source opportunity to transfer from
    private Opportunity sourceOpportunity;
    public Opportunity getSourceOpportunity() {
    	
    	// find the opportunity passed through its id if one exists
        string oppId = Apexpages.currentPage().getParameters().get('oppId');
        if (sourceOpportunity == null && !String.isblank(oppId) && firstRun) {
        	sourceOpportunity = [SELECT id, name, ConvertedLeadId__c  FROM Opportunity WHERE id =: oppId];
        	
        	// post an error message if an opportunity was not provided instead of allowing the user to attempt a transfer
        	if (sourceOpportunity == null) {
        		opportunityError = true;
        		errorMsg = 'An opportunity to transfer from has not been provided. Please go back to the opportunity and make use of the transfer button.';
        	} else if(sourceOpportunity.ConvertedLeadId__c != null) {
        		
        	
        	}
        	
        	firstRun = false;
        }
        
    	return sourceOpportunity;
    }
    
    // reference class variable
	private Reference reference;
    
    // list of transferable objects
    private list<transferableSObject> transferableSObjects;
    public list<transferableSObject> getTransferableSObjects() {
    	if(transferableSObjects == null) {
    		// initialize the reference class 
    		reference = new Reference();
    		transferableSObjects = new list<transferableSObject>();
    		// populate the transferable object based on the reference class
    		for(String transferableSObject :reference.getTransferableLabelToName ().keyset())
    		
    			transferableSObjects.add( new transferableSObject(transferableSObject, 0 , false , reference.getTrasnferableLabelToNeedCopyToTransfer().get(transferableSObject)  ));
    		
    		// calculate how many items will be transfered up to 10001
    		calculateTransferables();
    		
    	}
    	
    	return transferableSObjects;
    }
    public void getTransferableSObjects(list<transferableSObject> value) {
    	
   		transferableSObjects = value;
   		
    }
    
    private boolean transferablesOverLimit;
    public boolean getTransferablesOverLimit() {
    	
    	if (transferablesOverLimit == null) {
    		
    		transferablesOverLimit = false;
    		if(getTotalRecordsToTransfer() > 10000)
    			transferablesOverLimit = true;
    	
    			
    	}
    	
    	return transferablesOverLimit;
    }
    
    private integer totalRecordsToTransfer;
    public integer getTotalRecordsToTransfer() {
    	
    	if (sourceOpportunity != null && totalRecordsToTransfer == null){
    		
    		totalRecordsToTransfer = totalRecordsToTransfer();
    	} else if(sourceOpportunity == null && totalRecordsToTransfer == null) {
    		// initialize the value 
    		totalRecordsToTransfer = 0;
    	}
    	
    	return totalRecordsToTransfer;
    }
    
    
    // method that handles the transfer of requested notes, attachments, tasks, and events from the opportunity to lead
    public void transfer() {
    	// before trying to do any transfer determine if the number of records to be transfered will break the limits.
    	if(sourceOpportunity != null) {
    		
    		if (sourceOpportunity.ConvertedLeadId__c != null) {
    				
    				// the number of records that can be queried for.
    				integer totalRecordCounter = 0;
    				
    				// list the number of objects
    				list<SObject> SObjectsToInsert = new list<sobject>();
    				list<SObject>  SObjectsToUpdate = new list<SObject>();
    				list<SObject> DupSObjectsToDelete = new list<SObject>();
    				
    				// loop through each type of object. This is code needs imprevement since it will unfortunately break the bulk rule.
    				for ( transferableSObject  obj : getTransferableSObjects() ) {
    					// initialize the query string based on the type of object
    					
    					if(obj.isTransferable) {
    					
    						string oppId = Apexpages.currentPage().getParameters().get('oppId');
    						string wherefield = reference.getTransferableLabelToLookup ().get(obj.name);
    						
							string query = 'Select ' + reference.getTrasnferableLabelToQuerySelect ().get(obj.name) +
							 ' From '+ reference.getTransferableLabelToName().get(obj.name) 
		    				+' Where ' + wherefield + ' = \'' +  oppId + '\' Limit 10000';
	    					system.debug(query);
	    					
	    					// Based on which object this is create a list and transfer . 
	    					// This needs to be genericized but for right now its hardcoded to the object per list.
				    		if (reference.getTransferableLabelToName().get(obj.name) == 'task') {
				    			
				    			list<task> taskList = database.query(query);
				    			
				    			// loop through the tasks and switch whoid to the lead to transfer to and the whatid to null
				    			for (task t : tasklist) {
				    				
				    				if (totalRecordCounter < 10000) {
				    					
				    					// transfer the ownership of this record over to the lead from the opportunity
				    					t.whoid = sourceOpportunity.ConvertedLeadId__c;
				    					t.whatid = null;
				    					
				    					// add the task to the list of objects to update
				    					SObjectsToUpdate.add(t);
				    					
				    					// decrease the total records that can be transfered
				    					totalRecordCounter ++;
				    				}
				    			}
				    			
				    		} else if (reference.getTransferableLabelToName().get(obj.name) == 'event') {
				    			
				    			list<event> eventList = database.query(query);
				    			
				    			// loop through the tasks and switch whoid to the lead to transfer to and the whatid to null
				    			for (event e : eventList) {
				    				
				    				// make sure the total number of updates/inserts will be less than 10000
				    				if (totalRecordCounter < 10000) {
				    					
				    					// transfer the ownership of this record over to the lead from the opportunity
				    					e.whoid = sourceOpportunity.ConvertedLeadId__c;
				    					e.whatid = null;
				    					
				    					// add the task to the list of objects to update
				    					SObjectsToUpdate.add(e);
				    					
				    					// decrease the total records that can be transfered
				    					totalRecordCounter ++;
				    				}
				    			}
				    			
				    		} else if (reference.getTransferableLabelToName().get(obj.name) == 'Attachment') {
				    			
				    			list<attachment> attachmentList = database.query(query);
				    			
				    			for (attachment a : attachmentList) {
				    				
				    				// make sure the total number of updates/inserts will be less than 10000
				    				if (totalRecordCounter < 10000) {
				    					
					    				// add the original attachment to be deleted to prevent duplication
					    				DupSObjectsToDelete.add(a);
			                            
			                            // create a copy of the attachment
			                            Attachment newAttach = a.clone();
			                            
			                            // set the parent id of the copy to the lead
			                            newAttach.ParentId = sourceOpportunity.ConvertedLeadId__c;
			                            
			                            // add the attachemnt to the list of objects to be updated
			                            SObjectsToInsert.add(newAttach);
			                            
			                            
				    					// decrease the total records that can be transfered
				    					totalRecordCounter ++;
				    				}
				    			}
				    			
				    		} else if (reference.getTransferableLabelToName().get(obj.name) == 'Note') {
				    			
				    			list<note> noteList = database.query(query);
				    			
				    			for (note n : noteList) {
				    				
				    				// make sure the total number of updates/inserts will be less than 10000
				    				if (totalRecordCounter < 10000) {
				    					
				    					// setup the origional note to be deleted to clean up duplicates.
					    				DupSObjectsToDelete.add(n);
					    				
					    				// create a clone of the note
			                            Note newNote = n.clone();
			                            
			                            // set the clone of the note's parent id to the new lead 
			                            newNote.ParentId = sourceOpportunity.ConvertedLeadId__c;
			                            
			                            // add the note to the list of objects to update
			                            SObjectsToInsert.add(newNote);
			                         
				    					// decrease the total records that can be transfered
				    					totalRecordCounter ++;
				    				}
				    			}
				    			
				    		}
    					}
			    	}
    				// insert the list, to insert new records and update old ones. 
    				if (SObjectsToInsert.size() > 0) {
    					insert SObjectsToInsert;
    				}
    				
    				// update the list, to insert new records and update old ones. 
    				if (SObjectsToUpdate.size() > 0) {
    					update SObjectsToUpdate;
    				}
    				
    				// if there are any duplicate records to delete then delete them.
    				if (DupSObjectsToDelete.size() > 0) {
    					delete DupSObjectsToDelete;
    				}
    				// output if the transfer is complete or not
    				if (totalRecordCounter >= getTotalRecordsToTransfer()) {
    					// alert the user that all of the records have been transfered
    					if(totalRecordCounter > 0) {
    						ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.CONFIRM, 'All '+ getTotalRecordsToTransfer() +' records have been transfered to the lead'));
    					} else {
    						ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.WARNING, 'There were no records to be transfered to the lead'));
    					}
    					
    				} else {
    					// alert the user that not all of the records have been transfered
    					ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.WARNING, 'Only '+totalRecordCounter+ 'records have been transfered to the lead. There are approximately '
    					+( getTotalRecordsToTransfer() - totalRecordCounter) + ' records left to transfer. You can press the transfer button again to continue transfering records from the opportunity to the lead.'));
    				
    				}
    				
    			
    		} else {
    				ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.ERROR, 'Please select a lead to transfer to before attempting to make a transfer.'));
    		}
    			
    	} 
    }
    // calculate an individual objects total transferables
    public void reCalculateTrasnferable() {
    	String oppId = Apexpages.currentPage().getParameters().get('oppId');
    	string objectName = Apexpages.currentPage().getParameters().get('name');
    	//objectName
    	for( transferableSObject  obj : getTransferableSObjects() ) {
    		// update only the object that is passed
    		if (obj.name == objectName) {
    			string query = 'Select Count() From '+ reference.getTransferableLabelToName().get(obj.name) 
    			+' Where '+reference.getTransferableLabelToLookup ().get(obj.name)+' = :oppId And IsDeleted=false Limit 10001';
    		
    			obj.transferableCount = Database.countQuery(query);
    		}
    	}
    	
    	// recalculate the total records to transfer
    	totalRecordsToTransfer = totalRecordsToTransfer();
    }
    
    // method to update the calculation of how many items are transferable. Each is limited to 10001 to prevent query over
    public void calculateTransferables() {
    	String oppId = Apexpages.currentPage().getParameters().get('oppId');
    	// this runs the count query for each object to check how many objects will be available.
    	for( transferableSObject  obj : getTransferableSObjects() ) {
    		
    		string query = 'Select Count() From '+ reference.getTransferableLabelToName().get(obj.name) 
    		+' Where '+reference.getTransferableLabelToLookup ().get(obj.name)+' = :oppId And IsDeleted=false Limit 10001';
    		
    		obj.transferableCount = Database.countQuery(query);
    	}
    	
    	// recalculate the total records to transfer
    	totalRecordsToTransfer = totalRecordsToTransfer();
    }
    
    // method to determine the total number of records to transfer
    public integer totalRecordsToTransfer() {
    	
    	// cumlative number of records to be queried
    	integer recordsQueried = 0;
    	
    	for( transferableSObject  obj : getTransferableSObjects() ) {
    		
    		if (obj.isTransferable  && obj.transferableCount != null) {
    			
    			recordsQueried += obj.transferableCount;
    		}
    		
    	}
    	
    	return recordsQueried;
    }
    
    // method that handles checking if the number of records will exceed the total number of queries or updates that this can do at one time
    public boolean isWithinLimits( string oppId ) {
    	// result of the limit checking opperation. Assume that it will pass
    	boolean limitResult = true;
    	
    	if(totalRecordsToTransfer() > 10000) 
    		limitResult = false;

    	return limitResult;
    	
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