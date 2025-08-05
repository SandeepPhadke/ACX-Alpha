import { LightningElement, api, track } from 'lwc';
import getEngagementUsers from '@salesforce/apex/ContactUserTableController.getEngagementUsers';
import getTopUsers from '@salesforce/apex/ContactUserTableController.getTopUsers';
import getUsers from '@salesforce/apex/ContactUserTableController.getUsers';
import LINKEDIN_ICON from '@salesforce/resourceUrl/LinkedIn_Image';
import MAIL_ICON from '@salesforce/resourceUrl/Mail_Icon';
import PHONE_ICON from '@salesforce/resourceUrl/phone_Icon';

export default class ContactUserTableLWC extends LightningElement {
    @api numberOfUsers;
    @api portal;
    @api userId;
    @api workRecordType;
    @api workRecordCountry;
    @track teamHeaderLabel = '';
    @track users = [];
    photoUrl;
    isLoading = true;
    linkedinIcon = LINKEDIN_ICON;
    mailIcon = MAIL_ICON;
    phoneIcon = PHONE_ICON;

    connectedCallback() {
        console.log('connectedCallback called :-',this.workRecordCountry);

        console.log('connectedCallback called');
        this.fetchUsers();
    }

    fetchUsers() {
        console.log('fetchUsers called');
        console.log('Portal:', this.portal);
        console.log('Number of Users:', this.numberOfUsers);
        console.log('User Id:', this.userId);
        console.log('Work Record Type:', this.workRecordType);

        this.isLoading = true;
        let fetchMethod;

        if (this.portal === 'Client Portal') {
            console.log('Fetching Engagement Users');
            fetchMethod = getEngagementUsers;
            this.teamHeaderLabel = 'Your Team';
          
        } else if (this.portal === 'Tax Insight Flow'  && this.userId ) {
            console.log('Fetching Tax Insight Flow Users');
            fetchMethod = getUsers;
            this.teamHeaderLabel = '';
            
            console.log('Fetching Tax Insight Flow Users',this.teamHeaderLabel);
        } else {
            console.log('Fetching Top Users');
            this.hideTeamHeader = false;
            fetchMethod = getTopUsers;
            this.teamHeaderLabel = 'Your Team'; 
            
        }
        console.log('teamHeaderLabel:', this.teamHeaderLabel);

        if (!fetchMethod) {
            console.error('No fetch method available');
            this.isLoading = false;
            return;
        }

        fetchMethod({ numberOfUsers: this.numberOfUsers, userId: this.userId , workRecordType: this.workRecordType , workRecordCountry: this.workRecordCountry })
            .then(data => {
                console.log('API Response Data:', data);
               
                this.users = data.map(user => {
                    let isProfileAndersen = user.ProfilePhoto.includes('/file-asset-public/');
                    console.log(` ContactHeader test:`, this.workRecordCountry);

                    return {
                        ...user,
                        emailHref: `mailto:${user.Email}`,
                        linkedinIcon: this.linkedinIcon,
                        mailIcon: this.mailIcon,
                        phoneIcon: this.phoneIcon,
                        showCountry: this.portal === 'Client Portal',
                        contactHeader: user.ContactHeader,
                        isProfileAndersen: isProfileAndersen
                        
                    }
                    console.log('Users List:', this.contactHeader);
                });
                console.log('Users List new:', JSON.stringify(this.users));
               
               
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching users:', error);
                this.users = [];
                this.isLoading = false;
            });
    }

    get columnClass() {
        console.log('Calculating column class');
        console.log("Current user count",this.numberOfUsers);
        if (this.numberOfUsers == 1) {
            return 'slds-col slds-size_12-of-12 slds-p-left_none slds-p-right_none'; 
        } else
         if (this.numberOfUsers == 2) {
            return 'slds-col slds-size_12-of-12 slds-medium-size_6-of-12 slds-large-size_6-of-12';
        } else {
            return 'slds-col slds-size_12-of-12 slds-medium-size_6-of-12 slds-large-size_4-of-12';
        }
    }

    get dynamicStyle() {
        if (this.numberOfUsers == 1) {
            return 'height: 30vh;';
        } else if (this.numberOfUsers == 2) {
            return 'height: 35vh;';
        } else {
            return 'height: 65vh;';
        }
    }

    handleSendMessage(event) {
        const email = event.currentTarget.dataset.email;
        console.log('Send Message to:', email);
        if (email) {
            window.location.href = `mailto:${email}`;
        } else {
            console.error('Email not found in dataset');
        }
    }
  
    
}