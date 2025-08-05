import { LightningElement, track, wire, api } from 'lwc';
import getLocaleOptions from '@salesforce/apex/LocaleSelectorController.getLocaleOptions';
import updateUserLocale from '@salesforce/apex/LocaleSelectorController.updateUserLocale';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_LOCALE from '@salesforce/i18n/locale';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['User.LocaleSidKey'];

export default class LocaleSelector extends LightningElement {
	@api availableActions = [];
	@api selectedLocale;

	@track currentUserId = Id;
	@track localeOptions = [];
	@track browserLocale;
	@track isLoading = false;

	@wire(getRecord, { recordId: '$currentUserId', fields: FIELDS })
	userRecord({ error, data }) {
		if (data) {
			this.selectedLocale = data.fields.LocaleSidKey.value || USER_LOCALE;
			this.updateBrowserLocale(this.selectedLocale);
		} else if (error) {
			console.error('Error loading user record:', error);
			this.selectedLocale = USER_LOCALE;
		}
	}

	/**
	 * Wired Apex method to retrieve locale options.
	 * Populates the combobox with user-friendly labels and associated values.
	 */
	@wire(getLocaleOptions)
	wiredLocaleOptions({ error, data }) {
		if (data) {
			// Map the data to combobox options
			this.localeOptions = data.map(localeOption => {
				return {
					label: localeOption.displayLabel,
					value: localeOption.localeCode,
					browserLocale: localeOption.browserLocale
				};
			});
			// Set initial browser locale
			this.updateBrowserLocale(this.selectedLocale);
		} else if (error) {
			// Handle any errors and notify the user
			this.showToast('Error', 'Error loading locale options', 'error');
			console.error('Error retrieving locale options:', error);
		}
	}

	/**
	 * Handles changes in the combobox selection.
	 * Invokes the method to update the user's locale.
	 *
	 * @param event - The event containing the selected locale value.
	 */
	handleLocaleChange(event) {
		this.selectedLocale = event.detail.value;
		this.updateBrowserLocale(this.selectedLocale);
		this.updateUserLocale();

		// Dispatch flow event if in flow context
		if (this.availableActions.length > 0) {
			const attributeChangeEvent = new FlowAttributeChangeEvent(
				'selectedLocale',
				this.selectedLocale
			);
			this.dispatchEvent(attributeChangeEvent);
		}
	}

	/**
	 * Calls the Apex method to update the user's locale.
	 * Provides user feedback through toasts and handles the loading state.
	 */
	updateUserLocale() {
		this.isLoading = true;
		updateUserLocale({ localeCode: this.selectedLocale })
			.then(() => {
				this.isLoading = false;
				// Update component state and show success message
				this.refreshFormattedValues();
				this.showToast('Success', 'Locale updated successfully.', 'success');
			})
			.catch(error => {
				this.isLoading = false;
				// Handle any errors and notify the user
				this.showToast('Error updating locale', error.body.message, 'error');
				console.error('Error updating user locale:', error);
			});
	}

	updateBrowserLocale(sfLocale) {
		const option = this.localeOptions.find(opt => opt.value === sfLocale);
		this.browserLocale = option ? option.browserLocale : 'en-US';
	}

	refreshFormattedValues() {
		// Force a reactive refresh of the formatted values
		this.selectedLocale = this.selectedLocale;
	}

	/**
	 * Displays a toast notification with the specified parameters.
	 *
	 * @param title - The title of the toast.
	 * @param message - The message content of the toast.
	 * @param variant - The variant (e.g., 'success', 'error').
	 */
	showToast(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
			mode: 'dismissable'
		});
		this.dispatchEvent(evt);
	}

	get formattedDate() {
		try {
			return new Date().toLocaleDateString(this.browserLocale);
		} catch (error) {
			console.error('Error formatting date:', error);
			return new Date().toLocaleDateString('en-US');
		}
	}

	get formattedNumber() {
		try {
			return (1234567.89).toLocaleString(this.browserLocale);
		} catch (error) {
			console.error('Error formatting number:', error);
			return (1234567.89).toLocaleString('en-US');
		}
	}

	get formattedTime() {
		try {
			return new Date().toLocaleTimeString(this.browserLocale);
		} catch (error) {
			console.error('Error formatting time:', error);
			return new Date().toLocaleTimeString('en-US');
		}
	}
}