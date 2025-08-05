import { LightningElement, api, track } from 'lwc';

export default class ProgressStepper extends LightningElement {
    @track options = [];
    @track currentStepIndex = 0;
    @track isLoading = true;

    progressPercentage = 50;
    progressStyle = "width:" + this.progressPercentage + '%;';

    optionss = [
        {
            label: 'summary',
            itemStyle: 'slds-progress__item slds-is-completed',
            markerStyle: 'slds-progress__marker slds-progress__marker_icon',
            isCompleted: true,
            active: false

        },
       
        {
            label: 'Retail',
            itemStyle: 'slds-progress__item',
            markerStyle: 'slds-progress__marker',
            isCompleted: false,
            active: true,
        }
    ]

    @api
    set steps(value) {
        try {
            console.log('###value -> ' + value);
            this.options = value ? JSON.parse(value) : [];
            this.currentStepIndex = this.options.findIndex(step => step.active) || 0;
            this.progressPercentage = this.currentStepIndex == 0 ? 0 : (this.currentStepIndex/(this.options.length-1)*100);
            this.progressStyle = "width:" + this.progressPercentage + '%;';
            this.options = this.options.map( (step, index) => {
                console.log('###currentStepIndex -> ' + this.currentStepIndex);
                console.log('###index -> ' + index);

                let itemStyle = this.currentStepIndex > index ? 'slds-progress__item slds-is-completed' : (this.currentStepIndex == index ? 'slds-progress__item slds-is-active' : 'slds-progress__item');
                let markerStyle= this.currentStepIndex > index ? 'slds-progress__marker slds-progress__marker_icon' : 'slds-progress__marker';
                let isCompleted = this.currentStepIndex > index ? true : false;
                return  {label: step.label, active: step.active, itemStyle: itemStyle, markerStyle: markerStyle, isCompleted: isCompleted};
            })

            console.log('###progressPercentage -> ' + this.progressPercentage);
            console.log('###progressStyle -> ' + this.progressStyle);
            console.log('###options -> ' + JSON.stringify(this.options));
        } catch (error) {
            console.error('Error parsing steps JSON:', error);
            this.options = [];
            this.currentStepIndex = 0;
        }
        this.isLoading = false;
    }
    get steps() {
        return JSON.stringify(this.options); // Optional
    }

    connectedCallback() {
        this.isLoading = true;
        // Initial setup handled by the setter
        this.isLoading = false;
    }

    get progressStyle() {
        const totalSteps = this.options.length || 1;
        const progress = ((this.currentStepIndex + 1) / totalSteps) * 100;
        return `width: ${progress}%;`;
    }

    get stepNumber() {
        return this.currentStepIndex + 1;
    }

    getComputedStepClass(index) {
        return `step-circle ${this.options[index].active ? 'active' : ''}`;
    }

    handleStepClick(event) {
        const selectedIndex = parseInt(event.currentTarget.dataset.index, 10);
        if (!isNaN(selectedIndex)) {
            this.updateStep(selectedIndex);
        }
    }

    updateStep(index) {
        this.options = this.options.map((step, i) => ({
            ...step,
            active: i === index,
            isCompleted: i < index // Mark all previous steps as completed
        }));
        this.currentStepIndex = index;
        this.dispatchEvent(new CustomEvent('stepchange', {
            detail: { steps: JSON.stringify(this.options) }
        }));
    }
}