import { LightningElement, api } from 'lwc';
import getFormattedTaxSummary from '@salesforce/apex/TaxInsightDashboardController.getFormattedTaxSummary';
import myImage from '@salesforce/resourceUrl/Tax_Return_Iamge';
import ace_TaxReturnbanner_Text from '@salesforce/label/c.ace_TaxReturnbanner_Text';

export default class Ace_TaxReturnBanner extends LightningElement {
    @api recordId ;
    @api screenNumber;
    imageUrl = myImage;
    formattedName;
    formattedUserText;
    FormattedText = ace_TaxReturnbanner_Text;

    connectedCallback() {
        this.fetchTaxSummary();
    }

    fetchTaxSummary() {
        if (!this.recordId) {
            
            return;
        }

        getFormattedTaxSummary({ recordId: this.recordId }) 
        .then(result => {
            if (result) {

                this.formattedName = result.FormattedName;  
                this.formattedUserText = result.FormattedUserText;

                console.log('Banner Data received:', JSON.stringify(result));
                console.log('Banner Formatted Name:', this.formattedName);
                console.log('Banner Formatted User Text:', this.formattedUserText);
            } else {
                console.warn('No data returned from Apex.');
            }
        })
        .catch(error => {
            console.error('❌Error fetching tax summary:', error);
        });
    }
    get showFirstHeading() {
        console.log('working');
        console.log('screen number:',this.screenNumber);
        console.log('Evaluating showFirstHeading:', this.screenNumber !== 2); // Debugging

        return this.screenNumber !== 2;
    }
}