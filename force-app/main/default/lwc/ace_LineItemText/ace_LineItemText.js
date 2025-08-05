// ace_LineItemText.js
import { LightningElement, api, track, wire } from 'lwc';
import TaxInsightDashboardController from '@salesforce/apex/TaxInsightDashboardController.getWorkRecordDocument';



export default class Ace_LineItemText extends LightningElement {
    @api label;
    @api currCode;
    @api currency;
    @api isPaymentTypeCheck;
    currencyFormat='';



    




    renderedCallback() {
       // this.formatValue();
       console.log('this.label',this.label);
         console.log('this.currCode',this.currCode);
            console.log('this.currency',this.currency);
            console.log('this.isPaymentTypeCheck',this.isPaymentTypeCheck);
    }

    get formattedAmount() {
        if (this.currency == 0) {
            return '';
        }
        const amount = Math.abs(this.currency);
        const formattedAmount = amount.toLocaleString('en-US');
        const currCode = this.currCode ? this.currCode : '';
        return this.isPaymentTypeCheck ? `(${formattedAmount}) ${currCode}` : `${formattedAmount} ${currCode}`;
    }

   

    // formatValue() {
    //     let numericValue = parseFloat(this.value);

    //     if (isNaN(numericValue)) {
    //         this.formattedValue = 'Invalid Value';
    //         this.valueClass = '';
    //         return;
    //     }

    //     if (numericValue < 0) {
    //         this.formattedValue = '(' + Math.abs(numericValue).toLocaleString() + ')';
    //         this.valueClass = 'negative-value';
    //     } else {
    //         this.formattedValue = numericValue.toLocaleString();
    //         this.valueClass = 'positive-value';
    //     }
    // }
    get computedStyle(){
        return this.isPaymentTypeCheck ? 'color: red;' : 'color: green;';
    }
}