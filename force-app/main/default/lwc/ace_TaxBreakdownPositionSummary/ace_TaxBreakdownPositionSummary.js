import { LightningElement, api } from 'lwc';
import ace_TaxBreakdownPositionSummary_Header from '@salesforce/label/c.ace_TaxBreakdownPositionSummary_Header';
import ace_TaxBreakdownPositionSummary_Message from '@salesforce/label/c.ace_TaxBreakdownPositionSummary_Message';
import getFormattedTaxSummary from '@salesforce/apex/TaxInsightDashboardController.getFormattedTaxSummary';

export default class Ace_TaxBreakdownPositionSummary extends LightningElement {
    @api recordId;
    @api maxHeight;
    formattedSummary;
    workRecordContact;
    workRecordType;
    workRecordCountry;

    headerLabel = ace_TaxBreakdownPositionSummary_Header;
    messageLabel = ace_TaxBreakdownPositionSummary_Message;

    connectedCallback() {
        this.fetchTaxSummary();
    }

    fetchTaxSummary() {
        getFormattedTaxSummary({ recordId: this.recordId })
        .then(result => {
            if (result) {
                this.formattedSummary = result.FormattedSummary;
                this.workRecordContact = result.WorkRecordContact;
                this.workRecordType = result.WorkRecordType;
                this.workRecordCountry = result.WorkRecordCountry;
                console.log('Result:', result);

                const contactUserTable = this.template.querySelector('c-contact-user-tabel-l-w-c');
                if (contactUserTable) {
                    contactUserTable.userId = this.workRecordContact;
                    contactUserTable.workRecordType = this.workRecordType;
                    contactUserTable.workRecordCountry = this.workRecordCountry;
                }

                console.log('contactUserTable 3:', this.formattedSummary);
                console.log('contactUserTable 1:', this.workRecordType);
                console.log('contactUserTable country:', this.workRecordCountry);
                console.log('contactUserTable 2:', this.workRecordContact);
            }
        })
        .catch(error => {
            console.error('Error fetching tax summary:', error);
        });
    }

    renderedCallback() {
        const headerLabelElement = this.template.querySelector('span.slds-text-heading_medium');
        if (headerLabelElement) {
            const height = headerLabelElement.offsetHeight;
            this.dispatchEvent(new CustomEvent('messageheight', {
                detail: height
            }));
            console.log('Header Label Height:', height);  
        }
    }
    get computedStyleforheight() {
        console.log('Child: Received maxHeight:', this.maxHeight);
        return this.maxHeight ? `min-height: ${this.maxHeight}px;` : '';
    }
}