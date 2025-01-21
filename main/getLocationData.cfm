<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET, POST">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type">
<cfcontent type="application/json" reset="true">

<cfparam name="url.searchTerm" default="">
<cfset result = []>

<cftry>
    <cfquery name="locationData" datasource="rdecapstone"> 
        SELECT loc_name, loc_phone, loc_admin_street1, loc_admin_city, loc_admin_state, loc_admin_zip, 
               sunday_hours, monday_hours, tuesday_hours, wednesday_hours, thursday_hours, friday_hours, 
               saturday_hours, web_address, in_stock, latitude, longitude 
        FROM cleaned_vaccineLocations
        WHERE loc_name LIKE <cfqueryparam value="%#url.searchTerm#%" cfsqltype="cf_sql_varchar">
        AND loc_admin_state = 'NJ'
    </cfquery>

    <cfif locationData.recordCount>
        <cfloop query="locationData">
            <cfset arrayAppend(result, {
                "loc_name": locationData.loc_name,
                "loc_phone": locationData.loc_phone,
                "loc_admin_street1": locationData.loc_admin_street1,
                "loc_admin_city": locationData.loc_admin_city,
                "loc_admin_state": locationData.loc_admin_state,
                "loc_admin_zip": locationData.loc_admin_zip,
                "sunday_hours": locationData.sunday_hours,
                "monday_hours": locationData.monday_hours,
                "tuesday_hours": locationData.tuesday_hours,
                "wednesday_hours": locationData.wednesday_hours,
                "thursday_hours": locationData.thursday_hours,
                "friday_hours": locationData.friday_hours,
                "saturday_hours": locationData.saturday_hours,
                "web_address": locationData.web_address,
                "in_stock": locationData.in_stock,
                "latitude": locationData.latitude,
                "longitude": locationData.longitude
            })>
        </cfloop>
    <cfelse>
        <cfset result = [{ "message": "No matching locations found." }]>
    </cfif>

    <cfoutput>#serializeJSON(result)#</cfoutput>

<cfcatch type="any">
    <cflog file="app-errors" text="Error Type: #cfcatch.type#, Message: #cfcatch.message#, Detail: #cfcatch.detail#" />
    <cfoutput>{"error": true, "message": "Database or server error", "details": "#cfcatch.detail#"}</cfoutput>
</cfcatch>
</cftry>