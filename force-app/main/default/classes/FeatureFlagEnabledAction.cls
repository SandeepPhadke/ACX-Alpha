public with sharing class FeatureFlagEnabledAction {
   
    @InvocableMethod(label='Get Is Feature Flag Enabled' iconName='slds:standard:bot')
    public static List<FeatureEvaluationResult> getFeatureFlagsEnabled(List<String> featureNames){
    	return getFeatureFlagEvaluationResults(featureNames, new FeatureFlags()); 
    }

    @testVisible
    private static List<FeatureEvaluationResult> getFeatureFlagEvaluationResults(List<String> featureNames, IFeatureFlags instance){
        List<FeatureEvaluationResult> results = new List<FeatureEvaluationResult>();
        
        for(String featureName : featureNames){
        	results.add(new FeatureEvaluationResult(instance.evaluate(featureName)));
        }
        
        return results;
    }

    public class FeatureEvaluationResult{
        @InvocableVariable(label='result') 
        @AuraEnabled
        public Boolean result;
        @InvocableVariable(label='feature name') 
        @AuraEnabled
        public String featureName;
        @InvocableVariable(label='reason') 
        @AuraEnabled
        public String reason;
    
        public FeatureEvaluationResult(FeatureFlags.FeatureEvaluationResult result){
            this.result = result.isEnabled();
            this.featureName = result.getFeatureName();
            this.reason = result.getReason()?.name();
        }
    }
    
}