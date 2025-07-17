sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'insights/insights/test/integration/FirstJourney',
		'insights/insights/test/integration/pages/SolutionPerformanceAnalytics4List',
		'insights/insights/test/integration/pages/SolutionPerformanceAnalytics4ObjectPage'
    ],
    function(JourneyRunner, opaJourney, SolutionPerformanceAnalytics4List, SolutionPerformanceAnalytics4ObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('insights/insights') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheSolutionPerformanceAnalytics4List: SolutionPerformanceAnalytics4List,
					onTheSolutionPerformanceAnalytics4ObjectPage: SolutionPerformanceAnalytics4ObjectPage
                }
            },
            opaJourney.run
        );
    }
);