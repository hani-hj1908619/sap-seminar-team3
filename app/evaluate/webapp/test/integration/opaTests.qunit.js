sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'evaluate/evaluate/test/integration/FirstJourney',
		'evaluate/evaluate/test/integration/pages/SolutionPerformanceAnalytics4List',
		'evaluate/evaluate/test/integration/pages/SolutionPerformanceAnalytics4ObjectPage'
    ],
    function(JourneyRunner, opaJourney, SolutionPerformanceAnalytics4List, SolutionPerformanceAnalytics4ObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('evaluate/evaluate') + '/index.html'
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