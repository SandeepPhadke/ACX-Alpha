import { LightningElement, api, track, wire } from 'lwc';
import TaxInsightDashboardController from '@salesforce/apex/TaxInsightDashboardController.getWorkRecordDocument';
import ElectronicFiling from '@salesforce/label/c.ElectronicFiling';
import  PageFiling from '@salesforce/label/c.PageFiling';
import  PaymentTypeText from '@salesforce/label/c.PaymentTypeText';
import  RefundTypeText from '@salesforce/label/c.RefundTypeText';

export default class Ace_TaxSettlement extends LightningElement {
    @api recordId;
    workRecordDocument = {};
    dueDate = '';
    @api key;
    isPaymentVar = false;
    @api label;
    @api isPaymentTypeCheck;
    @api currCode;
    @api currency;
    @track hasFilingMethod = false;
    @track hasSettlementType = false;
    showIcon = true;

    @wire(TaxInsightDashboardController, { recordId: '$recordId' })
    wiredWorkRecordDocument({ error, data }) {
        if (data) {
            this.workRecordDocument = data || {};
            this.dueDate = data.Filing_Deadline__c ? this.formatDate(data.Filing_Deadline__c) : '';
            console.log('type of due date', typeof this.dueDate);
            this.hasSettlementType = this.workRecordDocument.Settlement_Type__c ? true : false;
            this.isPaymentVar = data.Settlement_Type__c === 'Payment';
            const type = this.workRecordDocument?.Type__c;
            if (type && type.includes('Federal')) {
                this.label= 'Federal';
                
            }else if(type && type.includes('FBAR')){
                this.label= 'FBAR';
                this.showIcon = false;

            }else{
                this.label= this.workRecordDocument?.State_Province_Name__c || '';
            }
            
            if(this.workRecordDocument?.Type__c.includes('FBAR')){
                this.currency = 0;
                this.currCode ='';
            }
            else{
                this.currency = data.Amount__c || 0;
                this.currCode = data.CurrencyIsoCode || '';

            }            
            this.isPaymentTypeCheck = data.Settlement_Type__c === 'Payment';

            console.log('Work Record Document:', JSON.stringify(this.workRecordDocument, null, 2));
             this.hasFilingMethod = this.workRecordDocument?.Filing_Method__c ? true : false;
        } else if (error) {
            console.error('Error fetching Work Record Document:', error);
        }
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const options = { day: 'numeric', month: 'long', year: 'numeric' };
        const date = new Date(dateString);
        return new Intl.DateTimeFormat('en-US', options).format(date);
    }

    // get lineItemType() {
    //     const type = this.workRecordDocument?.Type__c;
    //     if (type && type.includes('Federal')) {
    //         return 'Federal';
    //     }else if(type && type.includes('FBAR')){
    //         return 'FBAR';
    //     }
    //     return this.workRecordDocument?.State_Province_Name__c || '';
    // }

    get amount() {
        const amount = this.workRecordDocument?.Amount__c || 0;
        console.log('Amount:', amount);
        return this.workRecordDocument?.Settlement_Type__c === 'Refund' ? amount : -amount;
    }

    get settlementText() {
        if(this.workRecordDocument?.Type__c.includes('FBAR')){
            return '';
        }
        return this.workRecordDocument?.Settlement_Type__c === 'Refund' ? RefundTypeText : PaymentTypeText;
    }

    get filingMethodText() {
        const filingMethod = this.workRecordDocument?.Filing_Method__c || '';
        console.log(ElectronicFiling);
        switch (filingMethod) {
            case 'Electronic Filing':
                return ElectronicFiling;
            case 'Paper Filing':
                return PageFiling;
            default:
                return '';
        }
    }

    get isPayment() {
        return this.workRecordDocument?.Settlement_Type__c === 'Payment';
    }

    get formattedAmount() {
        const amount = this.workRecordDocument?.Amount__c || 0;
        const currCode = this.currCode || 'USD';

        let formattedAmount = this.isPaymentVar ? `(${amount}) ${currCode}` : `${amount} ${currCode}`;
        return formattedAmount;
    }

    get computedStyle() {
        if(this.workRecordDocument?.Type__c.includes('FBAR')){
            return 'color:  #077EFF;';
        }else{
            return this.isPayment ? 'color:  #077EFF;' : '';
        }
    }

    get iconStyle() {
        if(this.workRecordDocument?.Type__c.includes('FBAR')){
            return '--sds-c-icon-color-foreground-default: #077EFF;';
        }else{
            
        return this.isPayment ? '--sds-c-icon-color-foreground-default: #077EFF;' : '';
    
        }
    }
}