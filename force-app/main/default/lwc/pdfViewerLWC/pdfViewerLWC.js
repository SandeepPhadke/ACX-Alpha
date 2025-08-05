import { LightningElement, api, wire, track } from 'lwc';
import getPdfUrl from '@salesforce/apex/PdfViewerController.getPdfUrl';

export default class PdfViewerLWC extends LightningElement {
    @api heightInRem;
    @api workRecordId;
    @api hideButtonOnNextStep;  
    @api fileType;
    @api screenNumber; // Can be undefined
    @track isLoading = true; 

    pdfUrl;

    connectedCallback() {
        console.log('url : ', this.pdfUrl);
        console.log('ID : ', this.workRecordId);
        console.log('this.fileType : ', this.fileType);
        
        if (!this.workRecordId) {
            console.log('No record found');
            this.isLoading = false;
        }
    }

    @wire(getPdfUrl, { workRecordId: '$workRecordId' })
    wiredPdfUrl({ error, data }) {
        console.log('Fetching PDF data...');
        if (data) {
            this.isLoading = false;
            this.pdfUrl = data;
            console.log('PDF URL:', this.pdfUrl);
        } else {
            this.pdfUrl = undefined;
            this.isLoading = false;
            if (error) console.error('Error fetching PDF URL:', error);
        }
    }

    get pdfHeight() {
        return `height: ${this.heightInRem}rem`;
    }

    get fileLabel() {
        return this.fileType ? `Download ${this.fileType}` : 'Download';
    }

    get url() {
        return this.pdfUrl || '';
    }

    get isNoDocumentFound() {
        return !this.workRecordId || (!this.pdfUrl && !this.isLoading);
    }

    get showPdfViewer() {
        return this.screenNumber === 2 || this.screenNumber === undefined;
    }

    get isIframeVisible() {
        return (this.screenNumber === 2 || this.screenNumber === undefined) && this.pdfUrl;
    }

    get isDownloadButtonVisible() {
        return (this.screenNumber === 1 || this.screenNumber === 2 || this.screenNumber === undefined) && this.pdfUrl;
    }

    downloadPdf() {
        if (this.pdfUrl) {
            window.open(this.pdfUrl, '_blank');
        } else {
            console.error('Document is not available for download.');
        }
    }
}