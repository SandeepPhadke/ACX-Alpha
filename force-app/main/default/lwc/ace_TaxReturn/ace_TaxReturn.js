import { LightningElement, api, wire } from 'lwc';
import getFormattedTaxSummary from '@salesforce/apex/TaxInsightDashboardController.getFormattedTaxSummary';

export default class Ace_TaxReturn extends LightningElement {
    @api recordId;
    @api Screen;
    @api ScreenNumber;
    @api taxnumber;
    
    sharedFileId;
    sharedFileType;

    get sharedFileData() {
        return {
            id: this.sharedFileId,
            type: this.sharedFileType
        };
    }

    
    @wire(getFormattedTaxSummary, { recordId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            console.log('Received Data:', data);
            this.sharedFileId = data.sharedFileId;
            this.sharedFileType = data.sharedFileType;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    get showOverviewSection() {
        return this.ScreenNumber == 1; 
    }

    get showPdfViewer() {
        return this.ScreenNumber == 2; 
    }

    get showPdfViewerForScreenThird() {
        return this.ScreenNumber == 3; 
    }
}