public with sharing class SendGooderEmailRequest {
    
    @InvocableVariable(label='Send to just this one email address' required=false)
    public String sendToThisOneEmailAddress;

    @InvocableVariable(label='Send to this list of email addresses' required=false)
    public List<String> sendToCollectionOfEmailAddresses;

    @InvocableVariable(label='CC just this one email address' required=false)
    public String sendCCToJustOneEmailAddress;

    @InvocableVariable(label='CC this collection of email addresses' required=false)
    public List<String> sendCCToCollectionOfEmailAddresses;

    @InvocableVariable(label='BCC This one email address' required=false)
    public String sendBccToThisOneEmailAddress;

    @InvocableVariable(label='BCC this collection of email addresses' required=false)
    public List<String> sendBccToThisCollectionOfEmailAddresses;

    @InvocableVariable(label='send asynchronously?' required = true)
    public Boolean sendAsync;
    
    @InvocableVariable(label='Template Target Object Id' required = false)
    public String templateTargetObjectId;

    @InvocableVariable(label='Treat Target Object as Recipient' required=true)
    public Boolean templateTargetObjectIsRecipient;
    
    @InvocableVariable(label='Email Template Id' required = false)
    public String templateId;
    
    @InvocableVariable(label='Record Id associated to this email' required = false)
    public String recordId;

    @InvocableVariable(label='Reply to' required=false)
    public String replyTo;

    @InvocableVariable(label='BCC Sender'  required=true)
    public Boolean bcc;

    @InvocableVariable(label='Subject' required=false)
    public String subject;

    @InvocableVariable(label='HTML Text Body' required = false)
    public String htmlBody;

    @InvocableVariable(label='Plain Text Body' required=false)
    public String plainTextBody;
    
    @InvocableVariable(label='A list of CONTENT VERSION Ids to attach to this email' required = false)
    public List<String> attachments;
    
    @InvocableVariable(label='Org Wide Email Id.  If you use this, the sender display name is ignored' required = false )
    public String OrgWideEmailId;
    
    @InvocableVariable(label='Sender Display Name' required = false)
    public String SenderDisplayName;

    public SendGooderEmailRequest() {

    }
}