import { LightningElement, api, wire } from 'lwc';
import TaxInsightDashboardController from '@salesforce/apex/TaxInsightDashboardController.getWorkRecordDocument';
import ace_Equalization_Amount_Owed from '@salesforce/label/c.ace_Equalization_Amount_Owed';
import ace_Equalization_Amount_Due  from '@salesforce/label/c.ace_Equalization_Amount_Due';
import supplementInfor_blue from '@salesforce/label/c.supplementInfor_blue';
import supplementInfor_gray from '@salesforce/label/c.supplementInfor_gray';


export default class Ace_TaxBreakdownEqualization extends LightningElement {
    @api recordId ;
    @api key;
    isTypeEqualization = false;
    equalizationRecord;
    error;
    amount;
    isAmountPositive;
    currency;
    isPayment = false;
    currCode;

    @wire(TaxInsightDashboardController, { recordId: '$recordId' })
    wiredWorkRecordDocument({ error, data }) {
        if (data) {
            this.equalizationRecord = data;
            this.amount = Math.abs(this.equalizationRecord.Amount__c);
            this.isAmountPositive = this.equalizationRecord?.Amount__c >= 0;
            this.isTypeEqualization = this.equalizationRecord?.Type__c == 'Equalization';
            this.isPayment = this.equalizationRecord?.Settlement_Type__c === 'Payment';
            this.currCode = this.equalizationRecord?.CurrencyIsoCode;
            console.log('Work Record Document:', JSON.stringify(this.equalizationRecord, null, 2));
            console.log('Amount:', this.amount);
        } else if (error) {
            console.error('Error fetching Work Record Document:', error);
        }
    }

    get headingLabel() {
        if (this.equalizationRecord.Amount__c < 0) {
            return ace_Equalization_Amount_Due;
        } else if (this.equalizationRecord.Amount__c >= 0) {
            return ace_Equalization_Amount_Owed;
        }
        return '';
    }


    get formattedAmount() {
        const amountt = Math.abs(this.equalizationRecord.Amount__c);
        const amount = amountt.toLocaleString('en-US');
        const currCode = this.currCode? this.currCode : '';
        let formattedAmount = this.isAmountPositive ?   `${amount} ${currCode}`:`(${amount}) ${currCode}`;
        return formattedAmount;
        // return {
        //     value: formattedAmount,
        //     color: this.isPayment ? 'red' : 'green'
        // };
    }

    // get amountStyle() {
    //     if (this.amount > 0) {
    //         return 'color: red;';
    //     }
    //     return '';
    // }

    get supplementalInfo() {
    if (this.equalizationRecord.Amount__c < 0) {
        return supplementInfor_blue;
    } else {
        return supplementInfor_gray;
    }
}

get supplementalInfoStyle() {
    return this.isAmountPositive ? 'color: black;' : 'color: #077EFF;'; 
}


    get computedStyle(){
        return this.isAmountPositive ? 'color: green;':'color: red;' ;
    }
}