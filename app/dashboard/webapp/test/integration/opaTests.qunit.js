sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'dashboard/test/integration/FirstJourney',
		'dashboard/test/integration/pages/SolutionPerformanceAnalyticsList',
		'dashboard/test/integration/pages/SolutionPerformanceAnalyticsObjectPage'
    ],
    function(JourneyRunner, opaJourney, SolutionPerformanceAnalyticsList, SolutionPerformanceAnalyticsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('dashboard') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheSolutionPerformanceAnalyticsList: SolutionPerformanceAnalyticsList,
					onTheSolutionPerformanceAnalyticsObjectPage: SolutionPerformanceAnalyticsObjectPage
                }
            },
            opaJourney.run
        );
    }
);