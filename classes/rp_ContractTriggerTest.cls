@IsTest
private class rp_ContractTriggerTest {
    @isTest static void createContractTest() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType conrt = [Select Id From RecordType Where SObjectType = 'Contract' And DeveloperName = 'Safety_Contract'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',Industry_Sector__c='11_Bluewater',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Contract con = new Contract(Name='Contract 1405',Status='Active',AccountId=acc.Id,Contract_Type__c='Safety Service',RecordtypeId=conrt.Id,Invoicing_Intervals__c='Monthly',
                                    Option_Type__c='No Extension',StartDate=Date.today(),EndDate=Date.today()+10,Contract_Pricing_Currency__c='USD',Payment_Term__c='10 Days');
        insert con;                            
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Vessel__c ves = new Vessel__c(IMO_Number__c='seqi',Name='Vessel',Ship_Status__c='Hulked',Default_Customer__c=acc.Id);
        insert ves;
        
        Contract_Vessels__c vessel = new Contract_Vessels__c(Name='Test',Contract__c=con.Id,Create_Revenue_Projections__c=true,Vsl_End_Date__c=Date.today()+30,
                                                             Vsl_Start_Date__c=Date.today(),Vessel__c=ves.Id);
        
        insert vessel;
        
        Vessel_Product__c vprod = new Vessel_Product__c(Product_Family__c='Rental',Name='vpro',Contract_Vessel__c=vessel.Id,Quantity__c=2,Unit_Price__c=100,Product2__c=prod.Id);
        insert vprod;
        
        Contract_Product_Price__c cpp = new Contract_Product_Price__c(Name='CPP',Unit_Price__c=100,Start_Date__c=Date.today(),End_Date__c=Date.today()+15,Vessel_Product__c=vprod.Id);
        insert cpp;
        
        Test.stopTest();
    }
    
    @isTest static void updateContractTest() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType conrt = [Select Id From RecordType Where SObjectType = 'Contract' And DeveloperName = 'Safety_Contract'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',Industry_Sector__c='11_Bluewater',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Contract con = new Contract(Name='Contract 1405',Status='Active',AccountId=acc.Id,Contract_Type__c='Safety Service',RecordtypeId=conrt.Id,Invoicing_Intervals__c='Monthly',
                                    Option_Type__c='No Extension',StartDate=Date.today(),EndDate=Date.today()+10,Contract_Pricing_Currency__c='USD',Payment_Term__c='10 Days');
        insert con;                            
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Vessel__c ves = new Vessel__c(IMO_Number__c='seqi',Name='Vessel',Ship_Status__c='Hulked',Default_Customer__c=acc.Id);
        insert ves;
        
        Contract_Vessels__c vessel = new Contract_Vessels__c(Name='Test',Contract__c=con.Id,Create_Revenue_Projections__c=true,Vsl_End_Date__c=Date.today()+30,
                                                             Vsl_Start_Date__c=Date.today(),Vessel__c=ves.Id);
        
        insert vessel;
        
        Vessel_Product__c vprod = new Vessel_Product__c(Product_Family__c='Rental',Name='vpro',Contract_Vessel__c=vessel.Id,Quantity__c=2,Unit_Price__c=100,Product2__c=prod.Id);
        insert vprod;
        
        Contract_Product_Price__c cpp = new Contract_Product_Price__c(Name='CPP',Unit_Price__c=100,Start_Date__c=Date.today(),End_Date__c=Date.today()+15,Vessel_Product__c=vprod.Id);
        insert cpp;
        
        Contract conagain = [SELECT Id,Invoicing_Intervals__c FROM Contract WHERE Id = :con.Id];
        conagain.Invoicing_Intervals__c = 'Quarterly';
        update conagain;
        
        Test.stopTest();
    }
    
    @isTest static void updateContractVesselTest() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType conrt = [Select Id From RecordType Where SObjectType = 'Contract' And DeveloperName = 'Safety_Contract'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',Industry_Sector__c='11_Bluewater',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Contract con = new Contract(Name='Contract 1405',Status='Active',AccountId=acc.Id,Contract_Type__c='Safety Service',RecordtypeId=conrt.Id,Invoicing_Intervals__c='Monthly',
                                    Option_Type__c='No Extension',StartDate=Date.today(),EndDate=Date.today()+10,Contract_Pricing_Currency__c='USD',Payment_Term__c='10 Days');
        insert con;                            
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Vessel__c ves = new Vessel__c(IMO_Number__c='seqi',Name='Vessel',Ship_Status__c='Hulked',Default_Customer__c=acc.Id);
        insert ves;
        
        Contract_Vessels__c vessel = new Contract_Vessels__c(Name='Test',Contract__c=con.Id,Create_Revenue_Projections__c=true,Vsl_End_Date__c=Date.today()+30,
                                                             Vsl_Start_Date__c=Date.today(),Vessel__c=ves.Id);
        
        insert vessel;
        
        Vessel_Product__c vprod = new Vessel_Product__c(Product_Family__c='Rental',Name='vpro',Contract_Vessel__c=vessel.Id,Quantity__c=2,Unit_Price__c=100,Product2__c=prod.Id);
        insert vprod;
        
        Contract_Product_Price__c cpp = new Contract_Product_Price__c(Name='CPP',Unit_Price__c=100,Start_Date__c=Date.today(),End_Date__c=Date.today()+15,Vessel_Product__c=vprod.Id);
        insert cpp;
        
        Contract_Vessels__c conagain = [SELECT Id,Vsl_End_Date__c FROM Contract_Vessels__c WHERE Id = :vessel.Id];
        conagain.Vsl_End_Date__c = Date.today()+20;
        update conagain;
        
        Test.stopTest();
    }
    
    @isTest static void updateContractProductPriceTest() {
        Test.startTest();
        RecordType accrt = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Approved_Account'];
        RecordType conrt = [Select Id From RecordType Where SObjectType = 'Contract' And DeveloperName = 'Safety_Contract'];
        
        Account acc = new Account(Name='TestAccount',Country_of_Domicile__c='Norway',RecordTypeId=accrt.Id,Country_Codex__c='NOR',Website='www.test.no.invalid.webpage',Industry_Sector__c='11_Bluewater',
                                  Payment_Terms_CT__c='Advance Payment',Credit_Terms__c='Due upon receipt',Credit_blocked__c='OPEN',Account_Currency__c='NOK',Account_Classification__c='CRM Only');
        insert acc;        
        
        Contract con = new Contract(Name='Contract 1405',Status='Active',AccountId=acc.Id,Contract_Type__c='Safety Service',RecordtypeId=conrt.Id,Invoicing_Intervals__c='Monthly',
                                    Option_Type__c='No Extension',StartDate=Date.today(),EndDate=Date.today()+10,Contract_Pricing_Currency__c='USD',Payment_Term__c='10 Days');
        insert con;                            
        
        Product2 prod = new Product2(Name='G04400000',ProductCode='KBSG04400-13-9258635000',IsActive=true);
        insert prod;
        
        Vessel__c ves = new Vessel__c(IMO_Number__c='seqi',Name='Vessel',Ship_Status__c='Hulked',Default_Customer__c=acc.Id);
        insert ves;
        
        Contract_Vessels__c vessel = new Contract_Vessels__c(Name='Test',Contract__c=con.Id,Create_Revenue_Projections__c=true,Vsl_End_Date__c=Date.today()+30,
                                                             Vsl_Start_Date__c=Date.today(),Vessel__c=ves.Id);
        
        insert vessel;
        
        Vessel_Product__c vprod = new Vessel_Product__c(Product_Family__c='Rental',Name='vpro',Contract_Vessel__c=vessel.Id,Quantity__c=2,Unit_Price__c=100,Product2__c=prod.Id);
        insert vprod;
        
        Contract_Product_Price__c cpp = new Contract_Product_Price__c(Name='CPP',Unit_Price__c=100,Start_Date__c=Date.today(),End_Date__c=Date.today()+15,Vessel_Product__c=vprod.Id);
        insert cpp;
        
        Contract_Product_Price__c cppagain = [SELECT Id,Unit_Price__c FROM Contract_Product_Price__c WHERE Id = :cpp.Id];
        cppagain.Unit_Price__c = 500;
        update cppagain;
        
        Test.stopTest();
    }
}