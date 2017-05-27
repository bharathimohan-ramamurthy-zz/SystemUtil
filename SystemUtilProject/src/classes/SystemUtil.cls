public with sharing class SystemUtil 
{   
    static String createSObject(String sObjectApiName, String sObjectJSON)
    {
    	//Deserializes the JSON string
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(sObjectJSON);
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sObjectApiName);
        SObject newSobject = objectType.newSObject();
        Map<String, Schema.sObjectField> targetFields = objectType.getDescribe().fields.getMap();
        for (String key : fieldMap.keySet())
        {
            Object value = fieldMap.get(key);
            Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
            if (value instanceof String && valueType != Schema.DisplayType.String)
            {
                String strValue = (String)value;
                if (valueType == Schema.DisplayType.Date)
                    newSobject.put(key, Date.valueOf(strValue));
                else if(valueType == Schema.DisplayType.DateTime)
                    newSobject.put(key, DateTime.valueOfGmt(strValue));
                else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency)
                    newSobject.put(key, strValue == '' ? null : Decimal.valueOf(strValue));
                else if (valueType == Schema.DisplayType.Double)
                    newSobject.put(key, strValue == '' ? null : Double.valueOf(strValue));
                else if (valueType == Schema.DisplayType.Integer)
                    newSobject.put(key, Integer.valueOf(strValue));
                else if (valueType == Schema.DisplayType.Base64)
                    newSobject.put(key, Blob.valueOf(strValue));
                else
                    newSobject.put(key, strValue);
            }
            else
                newSobject.put(key, value);
        }
        Database.SaveResult sr = Database.insert(newSobject,false);
        return sr.isSuccess()?'':((sr.getErrors()!=null && sr.getErrors()[0]!=null)?sr.getErrors()[0].getMessage():'Failed to create record. Please contact system administrator.');
    }
}