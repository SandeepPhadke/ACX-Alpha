import { LightningElement,api,wire, track} from 'lwc';
import getTaxReturnBreakdown from '@salesforce/apex/TaxInsightDashboardController.getTaxReturnBreakdown';
import Net_Amount_Out_Of_Pocket from '@salesforce/label/c.Net_Amount_Out_Of_Pocket';
import 	Net_Amount_In_Pocket  from '@salesforce/label/c.Net_Amount_In_Pocket';



export default class Ace_TaxReturnBreakdown extends LightningElement {
    @api recordId;
    taxData;
    inPocket = Net_Amount_In_Pocket;
    outPocket = Net_Amount_Out_Of_Pocket;
    @track hasPayments = false;
    @track hasfbar = false;
    @track hasTaxEqualization = false;
    @track hasRefunds = false;
    @api maxHeight;
   

    @wire(getTaxReturnBreakdown, { recordId: '$recordId' })
    wiredWorkRecordDocumentList({error, data}) {
        if(data){
            this.taxData = data;
            this.hasPayments = this.taxData?.Payments?.Federal?.FederalF || this.taxData?.Payments?.State?.StateS  ? true : false;
            this.hasfbar = this.taxData?.FBAR ? true : false;
           this.hasRefunds = this.taxData?.Returns?.Refunds?.State?.StateS || this.taxData?.Returns?.Refunds?.Federal?.FederalF  ? true : false;

             this.hasTaxEqualization = this.taxData?.Equalization ? true : false;
            console.log('Federal : '+this.taxData?.Payments?.Federal?.FederalF);
            console.log('State : '+this.taxData?.Payments?.State?.StateS);
           // console.log("this.hasPayments : "+this.hasPayments);
            console.log('Work Record Document List:', JSON.stringify(this.taxData, null, 2));
            console.log(' Type of Work Record Document List:', typeof(this.taxData));
            console.log('value payments state', (this.taxData?.Returns?.Payments?.State?.StateS || []).length > 0);

        }
        else if(error){
            this.hasPayments = false;
            console.error('Error fetching Work Record Document List:', error);
        }
    }
    // hasRefunds() {
    //     console.log('value', (this.taxData?.Returns?.Refunds?.State?.StateS || []).length > 0);
    //     return Object.values(this.taxData?.Returns?.Refunds?.Federal?.FederalF || {}).flat().length > 0 ||
    //            Object.values(this.taxData?.Returns?.Refunds?.State?.StateS || {}).flat().length > 0;
    // }
    
    // hasPayments() {
    //     console.log('value payments state', (this.taxData?.Returns?.Payments?.State?.StateS || []).length > 0);
    //     console.log('value payment federal', (this.taxData?.Returns?.Payments?.Federal?.FederalF || []).length > 0);


    //     return Object.values(this.taxData?.Returns?.Payments?.Federal?.FederalF || {}).flat().length > 0 ||
    //            Object.values(this.taxData?.Returns?.Payments?.State?.StateS || {}).flat().length > 0;
    // }
    renderedCallback(){
        //console.log('renderedCallback', this.hasRefunds());
        console.log('inPocket', this.inPocket);
        console.log('outPocket', this.outPocket);
    }
    
    get federalRefunds() {
        return this.taxData?.Returns?.Refunds?.Federal?.FederalF || [];
    }

    get stateRefunds() {
        return this.taxData?.Returns?.Refunds?.State?.StateS || [];
    }

    get federalPayments() {
        return this.taxData?.Payments?.Federal?.FederalF || [];
    }

    get statePayments() {
        return this.taxData?.Payments?.State?.StateS || [];
    }

    get equalizations() {
        return this.taxData?.Equalization || [];
    }

    get fbars() {
        return this.taxData?.FBAR || [];
    }
    get NetAmountLabel() {
        return this.taxData?.WorkRecord?.Net_Amount_in_Pocket__c ? this.inPocket : this.outPocket;
    }
    
    get getNetAmountValue() {
        return this.taxData?.WorkRecord?.Net_Amount_in_Pocket__c ? this.taxData?.WorkRecord?.Net_Amount_in_Pocket__c : this.taxData?.WorkRecord?.Net_Amount_out_of_Pocket__c ;
    }
    get formattedAmount() {
       // const amount = Math.abs(this.currency);
        const amount =  this.taxData?.WorkRecord?.Net_Amount_in_Pocket__c ? this.taxData?.WorkRecord?.Net_Amount_in_Pocket__c : this.taxData?.WorkRecord?.Net_Amount_out_of_Pocket__c ;
        if (amount === undefined || amount === null) {
            return '';
        }
        const formattedAmount = amount.toLocaleString('en-US');
        const currCode = this.taxData?.WorkRecord?.CurrencyIsoCode ? this.taxData?.WorkRecord?.CurrencyIsoCode : '';
        return this.taxData?.WorkRecord?.Net_Amount_in_Pocket__c ?   `${formattedAmount} ${currCode}`:`(${formattedAmount}) ${currCode}`;
    }
    get computedStyle(){
        return this.taxData?.WorkRecord?.Net_Amount_in_Pocket__c ? 'color: green;': 'color: red;';
    }
    renderedCallback() {
        const taxReturnBreakdownElement = this.template.querySelector('h2.slds-text-heading_medium');
        
        if (taxReturnBreakdownElement) {
            const height = taxReturnBreakdownElement.offsetHeight;
            
            this.dispatchEvent(new CustomEvent('taxreturnheight', {
                detail: height
            }));
    
            console.log('Tax Return Breakdown Height:', height);
        }
    }
    get computedStyleforheight() {
        console.log('Child: Received maxHeight:', this.maxHeight);
        return this.maxHeight ? `min-height: ${this.maxHeight}px;` : '';
    }
}