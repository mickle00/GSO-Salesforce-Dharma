public with sharing class GoogleTranslate { 
    
    public static TranslationResult doTranslation(string originalText){
        TranslationResult myResult = new TranslationResult(originalText);
        return myResult;
    }
    
    public class TranslationResult{
        LanguageDetection myDetection;
        LanguageTranslation myTranslation;
        
        public TranslationResult(string originalText){
            myDetection = detectLanguage(originalText);
            myTranslation = translateLanguage(originalText);            
        }
        
        public string getSourceLanguage(){
            return myDetection.getDetectedLanguage();
        }
        
        public double getConfidence(){
            return myDetection.getConfidence() * 100;
        }
        
        public string getTranslation(){
            return myTranslation.getTranslation();          
        }
    }

    public static LanguageDetection detectLanguage (String source){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        
        source = EncodingUtil.urlEncode(source, 'UTF-8');
        
        if (source.length() > 1000){
            source = source.substring(0, 999);
        }
        
        //mickle00@gmail.com key....paid
        String key = 'AIzaSyC6TGkkfwzyP91vQ7xbKkGPW6R-ajN_qF8';
        
        req.setEndpoint('https://www.googleapis.com/language/translate/v2/detect?key=' + 
                        EncodingUtil.urlEncode(key, 'UTF-8') +
                        '&q=' +
                        source);                
        
        req.setMethod('GET');

        try{
            res = http.send(req);
            string responseBody = res.getBody();
            LanguageDetection deserializedResponse = (LanguageDetection)JSON.deserialize(responseBody, LanguageDetection.class);
            return deserializedResponse;
        }
        catch(System.CalloutException e){
            System.debug('Job Error: '+ e);
            System.debug(res.toString());
            
        }
        return null;
    }
    
    public static LanguageTranslation translateLanguage (String originalLanguage){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        string body = 'q=' + EncodingUtil.urlEncode(originalLanguage, 'UTF-8');
        
        //can only translate 5k characters. leaving a buffer just cause
        if (body.length() > 4800){
            body = body.substring(0, 4800);
        }
      
        //mickle00@gmail.com key....paid
        String key = 'AIzaSyC6TGkkfwzyP91vQ7xbKkGPW6R-ajN_qF8';
        
        req.setEndpoint('https://www.googleapis.com/language/translate/v2?key=' +        
                        EncodingUtil.urlEncode(key, 'UTF-8') +
                        '&target=en&prettyprint=true');
                        
        //Can POST up to 5k characters. GET limit is 2k characters
        req.setMethod('POST');

        //must explicitly state overriding GET
        req.setHeader('X-HTTP-Method-Override', 'GET');
        req.setBody(body);
        //req'd
        req.setHeader('Content-Length',string.valueOf(body.length()));

        try{
            res = http.send(req);
            string responseBody = res.getBody();
            LanguageTranslation deserializedResponse = (LanguageTranslation)JSON.deserialize(responseBody, LanguageTranslation.class);
            return deserializedResponse;
        }
        catch(System.CalloutException e){
            System.debug('Job Error: '+ e);
            System.debug(res.toString());
            
        }
        return null;       
    }      
    
    public class LanguageDetection {
        
        //not sure why Google returns a list of lists
        public Map<String, List<List<detections>>> data = new Map<String, List<List<detections>>>(); 
        
        public LanguageDetection(Map<String, List<List<detections>>> myData){
            data = myData;
        }
        
        public string getDetectedLanguage(){
            return this.data.get('detections')[0][0].language;
        }
        
        public double getConfidence(){
            return this.data.get('detections')[0][0].confidence;
        }
    }
    
    //Name has to be plural for System.JSON.deserialize to work
    public class detections {
        public string language;
        public boolean isReliable;
        public double confidence;
        
        public detections(string myLanguage, boolean myReliable, double myConfidence){
            language = myLanguage;
            isReliable = myReliable;
            confidence = myConfidence;
        }
    }
    
    public class LanguageTranslation {              
        Map<String, List<translations>> data = new Map<String, List<translations>>();        
        public LanguageTranslation(Map<String, List<translations>> myData){
            data = myData;
        } 
        
        public string getTranslation(){
            return this.data.get('translations')[0].translatedText;
        }   
    }
    
    //Nqme has to be plural for System.JSON.deserialize to work
    public class translations {
        public string translatedText;
        public string detectedSourceLanguage;
        
        public translations (string myTranslatedText, string myDetectedSourceLanguage){
            translatedText = myTranslatedText;
            detectedSourceLanguage = myDetectedSourceLanguage;
        }
    }
}