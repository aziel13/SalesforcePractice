trigger LeadMinder on Lead (after insert, after update, before insert, 
before update) {
	// lead minder trigger acts on leads that are inserted
	// lead minder functionality:
	// Prevent Data Duplication
	
	list<lead> matchedLead = new list<lead>();
	
	// if the trigger is before and is either insert or update
	if( Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ) {
		
		list<string> leadName = new list<string>();
		list<string> leadCompany = new list<string>();
		
		// add the lead name and lead company to the appropriate list
		for (Lead l : Trigger.new){
			leadName.add(l.name);
			leadCompany.add(l.Company);
		}
		
		// search for all leads that match both name and company name
		for(Lead l : [SELECT id,name,company FROM Lead WHERE name IN: leadName AND company IN: leadCompany]) {
			matchedLead.add(l);
		}	
		
		// loop through the leads in new and the leads in matched lead
		for (Lead l : Trigger.new) {
			for (lead otherL : matchedLead) {
				
				// if the name and company names match 
				if (l.name == otherL.name && l.company == otherL.company) {
					//throw an error indicating that there is a lead with the same name and company
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There is already a lead called with the name' + l.name + 'and the company '+ l.company)
);
				}
			}
		}
		
			
		
		 
	}
	

}