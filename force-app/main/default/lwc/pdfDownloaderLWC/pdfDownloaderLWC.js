import { LightningElement, api, wire, track } from 'lwc';
import getPdfUrl from '@salesforce/apex/PdfViewerController.getPdfUrl';

export default class PdfDownloaderLWC extends LightningElement {
    @api heightInRem;
    @api workRecordId;
    @api hideButtonOnNextStep;  
    @track isLoading = true;  // Start with the loading state true, to show spinner initially

    pdfUrl;

    connectedCallback() {
        console.log('url : ', this.pdfUrl);
        console.log('ID : ', this.workRecordId);
        console.log('condition');
        if (!this.workRecordId) {
            console.log('record found');
            this.isLoading = false; // Stop spinner if workRecordId is null

            
        }
    }

    @wire(getPdfUrl, { workRecordId: '$workRecordId' })
    wiredPdfUrl({ error, data }) {
        console.log('data found');
        if (data) {
            this.isLoading = false;
            console.log('data : ', data);
            this.pdfUrl = data;
            console.log('url : ', this.pdfUrl);
            // Set isLoading to false once the data is fetched
            
        } else if (error) {
            this.pdfUrl = undefined;
            console.error('Error fetching PDF URL', error);
            // Set isLoading to false if there is an error fetching the URL
            this.isLoading = false;
        }else{
            this.pdfUrl = undefined;
            this.isLoading = false;
        }
    }

    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }

    get url() {
        return this.pdfUrl ? this.pdfUrl : '';
    }

    // Getter for the condition where pdfUrl exists but url is not set (use in template)
    get isNoDocumentFound() {
        //this.isLoading = false;
        return !this.workRecordId || (!this.pdfUrl && !this.isLoading);
    }

    get isDownloadButtonVisible() {
        return !this.hideButtonOnNextStep;
    }

    downloadPdf() {
        if (this.pdfUrl) {
            window.open(this.pdfUrl, '_blank');
        } else {
            console.error('Document is not available for download.');
        }
    }
}