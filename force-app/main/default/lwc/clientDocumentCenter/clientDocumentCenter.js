import { LightningElement, wire, track } from 'lwc';
import getEngagementsWithFiles from '@salesforce/apex/ClientDocumentCenterCtrl.getEngagementsWithFiles';
import getEngagementFiles from '@salesforce/apex/ClientDocumentCenterCtrl.getEngagementFiles';
import Label from '@salesforce/label/c.ClientDocumentCenter';

export default class ClientDocumentCenter extends LightningElement {
    labelHeading = Label;
    @track gridData = [];
    @track error;
    @track batchSize = 10;
    @track offset = 0;
    @track hasMoreRecords = true;
    @track isLoading = false;

    columns = [
        {
            type: 'text',
            fieldName: 'label',
            label: 'Engagement Name'
        },
        {
            type: 'url',
            fieldName: 'sharedfileName',
            label: 'File Name',
            typeAttributes: {
                label: { fieldName: 'fileName' },
                target: '_blank'
            }
        },
        {
            type: 'text',
            fieldName: 'workRecordName',
            label: 'Work Record'
        },
        {
            type: 'text',
            fieldName: 'uploadedBy',
            label: 'Uploaded By'
        },
        {
            type: 'date',
            fieldName: 'uploadedDate',
            label: 'Uploaded Date',
            typeAttributes: {
                year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        {
            type: 'text',
            fieldName: 'fileType',
            label: 'File Type'
        }
    ];

     connectedCallback() {
        this.loadEngagements();
    }

   loadEngagements() {
        getEngagementsWithFiles({ batchSize: this.batchSize, offset: this.offset })
            .then(data => {
                const newData = data.map(item => ({
                    label: item.engagementName,
                    engagementId: item.engagementId,
                    _children: []
                }));
                this.gridData = [...this.gridData, ...newData];
                this.hasMoreRecords = data.length === this.batchSize;
                this.error = undefined;
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading engagements:', JSON.stringify(error, null, 2));
                this.error = error;
                this.hasMoreRecords = false;
                this.isLoading = false;
            });
    }

    handleLoadMore() {
        this.offset += this.batchSize;
        this.loadEngagements();
    }

   handleRowToggle(event) {
    // console.log('Row toggle event:', JSON.stringify(event.detail, null, 2));
    const engagementId = event.detail.name;
    const isExpanded = event.detail.isExpanded;

    if (!isExpanded) return;

    getEngagementFiles({ engagementId })
        .then(files => {
            console.log('Files loaded:', JSON.stringify(files, null, 2));

            var index = this.gridData.findIndex(item => item.engagementId === engagementId);
            if (index != -1) {
                this.gridData[index]._children = files.map(file => ({
                            ...file,
                            sharedfileName: this.extractHrefFromAnchorTag(file.sharedfileName)
                }))

                this.gridData = JSON.parse(JSON.stringify(this.gridData));

            }   

            
        })
        .catch(error => {
            console.error('Error loading files:', error);
        });
}


    extractHrefFromAnchorTag(anchorTag) {
        const match = anchorTag?.match(/href="(.*?)"/);
        return match ? match[1] : '';
    }

   
}