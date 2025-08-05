@isTest 
public with sharing class FeatureFlagEnabledActionTest {


    @isTest 
    private static void itShouldReturnTheAction(){
        List<String> featureNames = new List<String>{};
    	
      
        FeatureFlags.setMockValue('FakeFeature', true);
        FeatureFlags.setMockValue('InactiveFakeFeature', false);
        FeatureFlags.setMockValue('ActiveFakeFeature', true);
        
        featureNames.add('FakeFeature');
        featureNames.add('InactiveFakeFeature');
        featureNames.add('ActiveFakeFeature');
        

        List<FeatureFlagEnabledAction.FeatureEvaluationResult> results;

        test.startTest();

        results = FeatureFlagEnabledAction.getFeatureFlagsEnabled(featureNames);

        test.stopTest();

        System.assertEquals(3, results.size(), 'expected three results');

    }
    
    @isTest
    private static void itShouldUseTheMock(){
        IFeatureFlags featureFlags = new FeatureFlagsMock(new Map<String, Boolean>{'Fake Feature'  => true});
        
        List<FeatureFlagEnabledAction.FeatureEvaluationResult> results;
        
        test.startTest();
        
        results =  FeatureFlagEnabledAction.getFeatureFlagEvaluationResults(new List<String>{'Fake Feature'}, featureFlags);
        
        test.stopTest();
        
        System.assertEquals(1, results.size(), 'expect one result');
        
        FeatureFlagEnabledAction.FeatureEvaluationResult result = results[0];
        
        System.assertEquals(true, result.result, 'expect true result');
        System.assertEquals(null, result.reason, 'expect null value');
    }
}