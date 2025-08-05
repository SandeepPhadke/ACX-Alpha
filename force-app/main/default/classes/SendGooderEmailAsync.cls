public with sharing class SendGooderEmailAsync implements Queueable{
    
    private List<SendGooderEmailRequest> requests;

    @testVisible
    private SendGooderEmail emailInstance;

    public SendGooderEmailAsync(List<SendGooderEmailRequest> requests) {
        this.requests = requests;
        this.emailInstance = new SendGooderEmail();
    }

    public void execute(QueueableContext qc){
        this.emailInstance.sendEmail(requests);
    }
}