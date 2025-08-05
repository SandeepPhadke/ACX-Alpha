import { api, LightningElement,track } from 'lwc';

export default class Ace_TaxReturnOverview extends LightningElement {
    @api recordId;
    @track heightTaxReturnBreakdown = 0;
    @track heightTaxBreakdownPositionSummary = 0;
    @track maxHeight = 0;

    handleHeightChange(event) {
        console.log('Event Received:', event.type, 'Height:', event.detail);

        if (event.type === 'taxreturnheight') {
            this.heightTaxReturnBreakdown = event.detail;
        } else if (event.type === 'messageheight') {
            this.heightTaxBreakdownPositionSummary = event.detail;
        }
        console.log('Received heights:', {
            taxReturn: this.heightTaxReturnBreakdown,
            taxBreakdown: this.heightTaxBreakdownPositionSummary
        });

        if (this.heightTaxReturnBreakdown > 0 && this.heightTaxBreakdownPositionSummary > 0) {
            this.maxHeight = Math.max(this.heightTaxReturnBreakdown, this.heightTaxBreakdownPositionSummary);
            console.log('Updated maxHeight:', this.maxHeight);
        }
    }
}