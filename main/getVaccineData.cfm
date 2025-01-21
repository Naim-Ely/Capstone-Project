<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type">

<cfset this.datasource = "rdecapstone">
<cfquery name="vaccineData" datasource="#this.datasource#">
    SELECT 
        start_date, 
        end_date, 
        cumulative_flu_doses_distributed
    FROM 
        weekly_vaccine_distribution
</cfquery>

<cfset result = []>

<cfloop query="vaccineData">
    <cfset weekNumber = DatePart("ww", start_date)>
    <cfset yearNumber = DatePart("yyyy", start_date)>
    <cfset arrayAppend(result, {
        "week_number": weekNumber,
        "year_number": yearNumber,
        "cumulative_flu_doses_distributed": cumulative_flu_doses_distributed
    })>
</cfloop>

<cfcontent type="application/json">
<cfoutput>#serializeJSON(result)#</cfoutput>
