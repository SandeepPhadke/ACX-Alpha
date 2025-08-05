public with sharing class SendGooderEmailResponse {

    @InvocableVariable(label='errors')
    public String errors;
    
    @InvocableVariable(label='is success')
    public Boolean isSuccess;

    @InvocableVariable(label='template used')
    public String templateUsed;

    @InvocableVariable(label='message')
    public String message;

    @InvocableVariable(label='request')
    public SendGooderEmailRequest request;

    public SendGooderEmailResponse() {
        
    }

    public SendGooderEmailResponse(SendGooderEmailRequest request){
        this.request = request;
    }
}