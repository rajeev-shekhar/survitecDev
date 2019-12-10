@IsTest
private class rp_OpportunityTriggerTest {
    @isTest static void createOppTest() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType opprt = [Select Id From RecordType Where SObjectType = 'Opportunity' And DeveloperName = 'Deal'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        Opportunity opp = new Opportunity(Name='Opportunity Test',StageName='Preparing Proposal',Potential_Deal_Type__c='Liferaft Rental & Exchange Agreement',Billing_Method__c='Monthly-1',Potential_Deal_Duration_months__c='12',
                                          AccountId=acc.Id,CurrencyIsoCode='USD',RecordtypeId=opprt.Id,CloseDate=Date.today()+5,Time_to_full_Contract_implementation__c=6,Time_to_revenue_days__c=30,Create_Revenue_Projections__c=true);
        insert opp;
        
        OpportunityLineItem line = new OpportunityLineItem(Quantity=2,PricebookEntryId=standardPrice.Id,UnitPrice=300,OpportunityId=opp.Id,Product2Id=prod.Id);
        insert line;
        
        Test.stopTest();
    }
    
    @isTest static void updateOppTest() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType opprt = [Select Id From RecordType Where SObjectType = 'Opportunity' And DeveloperName = 'Deal'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        Opportunity opp = new Opportunity(Name='Opportunity Test',StageName='Preparing Proposal',Potential_Deal_Type__c='Liferaft Rental & Exchange Agreement',Billing_Method__c='Monthly-1',Potential_Deal_Duration_months__c='12',
                                          AccountId=acc.Id,CurrencyIsoCode='USD',RecordtypeId=opprt.Id,CloseDate=Date.today()+5,Time_to_full_Contract_implementation__c=6,Time_to_revenue_days__c=30,Create_Revenue_Projections__c=true);
        insert opp;
        
        OpportunityLineItem line = new OpportunityLineItem(Quantity=2,PricebookEntryId=standardPrice.Id,UnitPrice=300,OpportunityId=opp.Id,Product2Id=prod.Id);
        insert line;
        
        Opportunity oppagain = [Select Id, Billing_Method__c FROM Opportunity WHERE Id = :opp.Id];
        oppagain.Billing_Method__c = 'Quarterly-3';
        update oppagain;
        
        Test.stopTest();
    }
    
    @isTest static void updateOppTest2() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType opprt = [Select Id From RecordType Where SObjectType = 'Opportunity' And DeveloperName = 'Deal'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        Opportunity opp = new Opportunity(Name='Opportunity Test',StageName='Preparing Proposal',Potential_Deal_Type__c='Liferaft Rental & Exchange Agreement',Billing_Method__c='Monthly-1',Potential_Deal_Duration_months__c='12',
                                          AccountId=acc.Id,CurrencyIsoCode='USD',RecordtypeId=opprt.Id,CloseDate=Date.today()+5,Time_to_full_Contract_implementation__c=6,Time_to_revenue_days__c=30,Create_Revenue_Projections__c=true);
        insert opp;
        
        OpportunityLineItem line = new OpportunityLineItem(Quantity=2,PricebookEntryId=standardPrice.Id,UnitPrice=300,OpportunityId=opp.Id,Product2Id=prod.Id,Revenue_Projection_Batch_Processed__c='Pending');
        insert line;
        
        Opportunity oppagain = [Select Id, Time_to_revenue_days__c FROM Opportunity WHERE Id = :opp.Id];
        oppagain.Time_to_revenue_days__c = 60;
        update oppagain;
        
        Test.stopTest();
    }
    
    @isTest static void spotOppTest2() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType opprt = [Select Id From RecordType Where SObjectType = 'Opportunity' And DeveloperName = 'Spot'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        Opportunity opp = new Opportunity(Name='Opportunity Test',StageName='Preparing Proposal',Potential_Deal_Type__c='Liferaft Rental & Exchange Agreement',Billing_Method__c='Monthly-1',Potential_Deal_Duration_months__c='12',
                                          AccountId=acc.Id,CurrencyIsoCode='USD',RecordtypeId=opprt.Id,CloseDate=Date.today()+5,Time_to_full_Contract_implementation__c=6,Time_to_revenue_days__c=30,Create_Revenue_Projections__c=true);
        insert opp;
        
        OpportunityLineItem line = new OpportunityLineItem(Quantity=2,PricebookEntryId=standardPrice.Id,UnitPrice=300,OpportunityId=opp.Id,Product2Id=prod.Id,Revenue_Projection_Batch_Processed__c='Pending');
        insert line;
        
        Test.stopTest();
    }
    
    @isTest static void updateOppLineTest() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType opprt = [Select Id From RecordType Where SObjectType = 'Opportunity' And DeveloperName = 'Deal'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        Opportunity opp = new Opportunity(Name='Opportunity Test',StageName='Preparing Proposal',Potential_Deal_Type__c='Liferaft Rental & Exchange Agreement',Billing_Method__c='Monthly-1',Potential_Deal_Duration_months__c='12',
                                          AccountId=acc.Id,CurrencyIsoCode='USD',RecordtypeId=opprt.Id,CloseDate=Date.today()+5,Time_to_full_Contract_implementation__c=6,Time_to_revenue_days__c=30,Create_Revenue_Projections__c=true);
        insert opp;
        
        OpportunityLineItem line = new OpportunityLineItem(Quantity=2,PricebookEntryId=standardPrice.Id,UnitPrice=300,OpportunityId=opp.Id,Product2Id=prod.Id);
        insert line;
        
        OpportunityLineItem lineagain = [Select Id, Quantity FROM OpportunityLineItem WHERE Id = :line.Id];
        lineagain.Quantity = 4;
        update lineagain;
        
        Test.stopTest();
    }
}