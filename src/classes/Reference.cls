public with sharing class Reference {
	// class to hold reference variables and lists
	
	
	// list of sobjects that are transferable in the transfer class.
	private list<string> transferableSObjects;
	public list<string> getTransferableSObjects () {

		return transferableSObjects;
	}
	
	// map of sobjects that are transferable in the transfer class.
	private map<string,string> transferableLabelToName;
	public map<string, string> getTransferableLabelToName () {
		
		if (transferableLabelToName == null) {
			transferableLabelToName = new map<string,string>( );
			transferableLabelToName.put('Attachments', 'Attachment');
			transferableLabelToName.put('Notes', 'Note');
			transferableLabelToName.put('Tasks', 'Task');
			transferableLabelToName.put('Events', 'Event');
		}
		
		
		
		return transferableLabelToName;
		
	}
	
	// map of sobjects that are transferable to the association field used to lookup the opportunity
	private map<string,string> transferableLabelToLookup;
	public map<string,string> getTransferableLabelToLookup () {
	
		if (transferableLabelToLookup == null) {
			transferableLabelToLookup = new map<string,string>( );
			transferableLabelToLookup.put('Attachments', 'ParentId');
			transferableLabelToLookup.put('Notes', 'ParentId');
			transferableLabelToLookup.put('Tasks', 'Whatid');
			transferableLabelToLookup.put('Events', 'Whatid');
		}
		
		return transferableLabelToLookup;
		
	}
	
	private map<string,string> trasnferableLabelToQuerySelect;
	public map<string,string> getTrasnferableLabelToQuerySelect () {
	
		if (trasnferableLabelToQuerySelect == null) {
			trasnferableLabelToQuerySelect = new map<string,string>( );
			
			trasnferableLabelToQuerySelect.put('Attachments', 'Id, Body, ContentType, IsPrivate, Name, Description ,ParentId');
			trasnferableLabelToQuerySelect.put('Notes', 'Id, Body, IsPrivate,ParentId,Title');
			trasnferableLabelToQuerySelect.put('Tasks', 'id, whoid, whatid');
			trasnferableLabelToQuerySelect.put('Events', 'id, whoid, whatid');
		}
		
		return trasnferableLabelToQuerySelect;
		
	}
	
	private map<string, boolean> trasnferableLabelToNeedCopyToTransfer;
	public map<string, boolean> getTrasnferableLabelToNeedCopyToTransfer() {
		
		if (trasnferableLabelToNeedCopyToTransfer == null) {
			trasnferableLabelToNeedCopyToTransfer = new map<string, boolean>();
			trasnferableLabelToNeedCopyToTransfer.put('Attachments', true);
			trasnferableLabelToNeedCopyToTransfer.put('Notes', true);
			trasnferableLabelToNeedCopyToTransfer.put('Tasks', false);
			trasnferableLabelToNeedCopyToTransfer.put('Events', false);
		}
		
		return trasnferableLabelToNeedCopyToTransfer;
	
	
	}
	
	
	// color value for error text 
	private String errorColor;
	public String getErrorColor (){
		if(errorColor == null) 
			errorColor = '#FF0000';
		
		return errorColor;
	}
	
	// color value for values that are valid
	private String validColor;
	public String getValidColor () {
		if (validColor == null)
			validColor = '';
			
		return validColor;
	}
}