<cfcontent type="text/html; charset=UTF-8">
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Influenza Hospitalizations</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <header>
        <nav class="navbar">
            <div class="navbar-container">
                <div class="logo"><a href="index.html"><img src='./images/RDE-logo.png' alt="rde logo" /></a></div>
                <ul class="nav-links">
                    <li><a href="index.html">Home</a></li>
                    <li class="dropdown">
                        <a href="#" class="dropbtn">Vaccine Pages <span id="dropdown">&#9660;</span><span id="dropup">&#9650;</span></a>
                        <div class="dropdown-content">
                            <a href="location.html">Location</a>
                            <a href="demographics.cfm?dimensionType=Age&seasonSurveyYear=All&geographyType=All&month=All&season_survey_year=All">Demographics</a>
                            <a href="vaccine.html">Doses</a>
                            <a href="hospitalizations.cfm" id="hospitalization">Hospitalizations</a>
                        </div>
                    </li>
                </ul>
                <div class="hamburger" onclick="toggleMenu()">
                    <div class="icon"><p>&#9776;</p></div>
                </div>
            </div>
            <div class="mobile-menu">
                <a href="index.html">Home</a>
                <a href="location.html">Location</a>
                <a href="demographics.cfm?dimensionType=Age&seasonSurveyYear=All&geographyType=All&month=All&season_survey_year=All">Demographics</a>
                <a href="vaccine.html">Doses</a>
                <a href="hospitalizations.cfm" id="hospitalization">Hospitalizations</a>
            </div>
        </nav>
        <script>
    function toggleMenu() {
        const mobileMenu = document.querySelector('.mobile-menu');
        mobileMenu.classList.toggle('active');
    }
</script>

    </header>

    <div class="title-container">
        <h1 class="main-title">Laboratory-Confirmed Influenza Hospitalizations</h1>
        <h2 class="sub-title">FluSurv-NET Results</h2>
    </div>

    <div class="container">

        <!-- ColdFusion logic starts here -->
        <cfset defaultRateType = "Cumulative">
        <cfset defaultViewRatesBy = "sex">
        <cfset defaultSeason = "2023-24">

        <cfif structKeyExists(url, "rateType") AND structKeyExists(url, "viewRatesBy") AND structKeyExists(url, "season")>
            <cfset selectedRateType = url.rateType>
            <cfset selectedViewRatesBy = url.viewRatesBy>
            <cfset selectedSeason = url.season>
        <cfelse>
            <cfset selectedRateType = defaultRateType>
            <cfset selectedViewRatesBy = defaultViewRatesBy>
            <cfset selectedSeason = defaultSeason>
        </cfif>

        <cfquery name="filterResults" datasource="rdecapstone">
            SELECT 
                CAST(mmwr_week AS FLOAT) AS mmwr_week_numeric,
                <cfif selectedViewRatesBy EQ "sex">
                    sex
                <cfelseif selectedViewRatesBy EQ "age">
                    age_group
                <cfelseif selectedViewRatesBy EQ "race">
                    race_ethnicity
                </cfif> AS category,
                <cfif selectedRateType EQ "Cumulative">
                    CAST(cumulative_rate AS FLOAT) AS rate_value
                <cfelse>
                    CAST(weekly_rate AS FLOAT) AS rate_value
                </cfif>
            FROM 
                HospitalizationRate 
            WHERE 
                season = <cfqueryparam cfsqltype="cf_sql_varchar" value="#selectedSeason#">
                <cfif selectedViewRatesBy EQ "sex">
                    AND sex IS NOT NULL
                <cfelseif selectedViewRatesBy EQ "age">
                    AND age_group IS NOT NULL
                <cfelseif selectedViewRatesBy EQ "race">
                    AND race_ethnicity IS NOT NULL
                </cfif>
                AND CAST(mmwr_week AS FLOAT) BETWEEN 1.0 AND 52.0
            ORDER BY 
                mmwr_week_numeric ASC, category
        </cfquery>
        <!-- ColdFusion logic ends here -->

        <form id="filterForm" action="hospitalizations.cfm" method="GET">
            <div class="sidebar">
                <div class="filter-group">
                    <label>Type of Rates</label>
                    <input type="radio" id="rateTypeCumulative" name="rateType" value="Cumulative" 
                        <cfif selectedRateType EQ "Cumulative">checked</cfif> 
                        onchange="this.form.submit()">
                    <label for="rateTypeCumulative">Cumulative</label>
                    <input type="radio" id="rateTypeWeekly" name="rateType" value="Weekly" 
                        <cfif selectedRateType EQ "Weekly">checked</cfif> 
                        onchange="this.form.submit()">
                    <label for="rateTypeWeekly">Weekly</label>
                </div>
                <div class="filter-group">
                    <label>View Rates By</label>
                    <select class="dropdown" id="viewRatesBy" name="viewRatesBy" onchange="this.form.submit()">
                        <option value="sex" <cfif selectedViewRatesBy EQ "sex">selected</cfif>>Sex</option>
                        <option value="age" <cfif selectedViewRatesBy EQ "age">selected</cfif>>Age</option>
                        <option value="race" <cfif selectedViewRatesBy EQ "race">selected</cfif>>Race/Ethnicity</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Season</label>
                    <input type="radio" name="season" value="2023-24" 
                        <cfif selectedSeason EQ "2023-24">checked</cfif> 
                        onchange="this.form.submit()"> 2023-24<br>
                    <input type="radio" name="season" value="2022-23" 
                        <cfif selectedSeason EQ "2022-23">checked</cfif> 
                        onchange="this.form.submit()"> 2022-23<br>
                    <input type="radio" name="season" value="2021-22" 
                        <cfif selectedSeason EQ "2021-22">checked</cfif> 
                        onchange="this.form.submit()"> 2021-22<br>
                    <input type="radio" name="season" value="2020-21" 
                        <cfif selectedSeason EQ "2020-21">checked</cfif> 
                        onchange="this.form.submit()"> 2020-21<br>
                    <input type="radio" name="season" value="2019-20" 
                        <cfif selectedSeason EQ "2019-20">checked</cfif> 
                        onchange="this.form.submit()"> 2019-20<br>
                    <input type="radio" name="season" value="2018-19" 
                        <cfif selectedSeason EQ "2018-19">checked</cfif> 
                        onchange="this.form.submit()"> 2018-19
                </div>
            </div>
        </form>

        <div class="content">
            <!-- Prepare Data for Chart.js -->
            <script>
                const mmwrWeeks = [];
                const categoryData = {};

                <cfoutput query="filterResults">
                    if (!mmwrWeeks.includes(#mmwr_week_numeric#)) {
                        mmwrWeeks.push(#mmwr_week_numeric#);
                    }
                    if (!categoryData["#category#"]) {
                        categoryData["#category#"] = [];
                    }
                    categoryData["#category#"].push(#rate_value#);
                </cfoutput>
                const data = {
                    labels: mmwrWeeks,
                    datasets: Object.keys(categoryData).map((category, index) => {
                        return {
                            label: category,
                            data: categoryData[category],
                            borderColor: `hsl(${Math.floor(Math.random() * 360)}, 70%, 50%)`, // Random color for each line
                            fill: false,
                            tension: 0.1
                        };
                    })
                };

                const config = {
                    type: 'line',
                    data: data,
                    options: {
                        responsive: true,
                        maintainAspectRatio: false, // Allow independent width and height
                        scales: {
                            x: {
                                title: {
                                    display: true,
                                    text: 'MMWR Week Number'
                                },
                                ticks: {
                                    callback: value => value % 4 === 0 ? value : '',
                                    stepSize: 4,
                                    max: 52
                                }
                            },
                            y: {
                                title: {
                                    display: true,
                                    text: 'Rates per 100,000 population'
                                },
                            }
                        },
                        plugins: {
                            legend: {
                                display: true,
                                position: 'top'
                            }
                        }
                    }
                };

                window.onload = function() {
                    const ctx = document.getElementById('filteredChart').getContext('2d');
                    new Chart(ctx, config);
                };
            </script>

            <!-- Canvas for the Chart -->
            <div class="chart-container">
                <canvas id="filteredChart"></canvas>
            </div>

        </div>
    </div>
    <!-- JavaScript to set default filters if no URL parameters are present -->
    <script>
        const urlParams = new URLSearchParams(window.location.search);
        
        if (!urlParams.has('rateType') || !urlParams.has('viewRatesBy') || !urlParams.has('season')) {
            // Set default values if parameters are missing in URL when first loaded
            document.getElementById('rateTypeCumulative').checked = true;
            document.getElementById('viewRatesBy').value = 'sex';
            document.querySelector('input[name="season"][value="2023-24"]').checked = true;
        }
    </script>
    <footer>
        <div class="twitterFooter">
            <a href="https://www.x.com/rdesystems"><img src="./images/twitterLogo.png"></a>
        </div>
        <div class="copyrightFooter">
            <p>Copyright &copy; 2024 RDE Systems, LLC. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
