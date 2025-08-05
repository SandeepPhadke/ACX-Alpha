import { LightningElement, wire, track, api } from 'lwc';
import getOpenWorkRecords from '@salesforce/apex/WorkRecordStatusController.getOpenWorkRecords';
import getSingleWorkRecord from '@salesforce/apex/WorkRecordStatusController.getSingleWorkRecord';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AssigneeWorkRecordStatus extends NavigationMixin(LightningElement) {
	@api recordId;
	@track workRecords;
	@track error;

	emptyStateMessage = 'No services in progress.Let us know if there’s something we can help with.';

	@wire(getOpenWorkRecords)
	wiredWorkRecords({ error, data }) {
		if (this.recordId) return; 
		if (data) {
			this.processWorkRecords(data);
		} else if (error) {
			this.handleError(error);
		}
	}

	@wire(getSingleWorkRecord, { recordId: '$recordId' })
	wiredSingleRecord({ error, data }) {
		if (!this.recordId) return; // Skip if we're showing all records
		if (data) {
			this.processWorkRecords([data]);
		} else if (error) {
			this.handleError(error);
		}
	}

	// Computed property to check if we have work records
	get hasWorkRecords() {
		return this.workRecords && this.workRecords.length > 0;
	}

	// Computed property to determine if we should show the empty state
	get showEmptyState() {
		return this.workRecords && this.workRecords.length === 0 && !this.error;
	}

	processWorkRecords(data) {
		if (data && data.length > 0) {
			this.workRecords = data.map(record => ({
				...record,
				displayName: `${record.workRecordName}`,
				steps: record.statusSteps.map(step => ({
					...step,
					class: this.getStepClass(step.isCurrent, step.isCompleted),
					icon: this.getStepIcon(step.isCurrent, step.isCompleted)
				}))
			}));
		} else {
			// Empty array case
			this.workRecords = [];
		}
		this.error = undefined;
	}

	handleError(error) {
		const errorMessage = this.formatErrorMessage(error);
		this.error = errorMessage;
		this.workRecords = undefined;
		this.showErrorToast(errorMessage);
	}

	getStepClass(isCurrent, isCompleted) {
		let baseClass = 'slds-path__item';
		if (isCurrent) {
			return `${baseClass} slds-is-current slds-is-active`;
		} else if (isCompleted) {
			return `${baseClass} slds-is-complete`;
		}
		return `${baseClass} slds-is-incomplete`;
	}

	getStepIcon(isCurrent, isCompleted) {
		if (isCompleted) {
			return 'utility:success';
		}
		return isCurrent ? 'utility:check' : 'utility:lock';
	}

	formatErrorMessage(error) {
		if (error.body && error.body.message) {
			return error.body.message;
		} else if (typeof error === 'string') {
			return error;
		}
		return 'An unexpected error occurred while loading work records. Please try refreshing the page.';
	}

	showErrorToast(message) {
		const evt = new ShowToastEvent({
			title: 'Error Loading Work Records',
			message: message,
			variant: 'error',
			mode: 'dismissable'
		});
		this.dispatchEvent(evt);
	}

	handleNavigation(event) {
		if (this.recordId) return; // Skip if we're showing a single record
		const recordId = event.currentTarget.dataset.id;
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				objectApiName: 'Work_Record__c',
				actionName: 'view'
			}
		});
	}
}