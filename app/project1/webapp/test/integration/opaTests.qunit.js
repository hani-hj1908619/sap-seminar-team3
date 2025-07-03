sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'test/project1/test/integration/FirstJourney',
		'test/project1/test/integration/pages/SolutionPerformanceAnalytics3List',
		'test/project1/test/integration/pages/SolutionPerformanceAnalytics3ObjectPage'
    ],
    function(JourneyRunner, opaJourney, SolutionPerformanceAnalytics3List, SolutionPerformanceAnalytics3ObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('test/project1') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheSolutionPerformanceAnalytics3List: SolutionPerformanceAnalytics3List,
					onTheSolutionPerformanceAnalytics3ObjectPage: SolutionPerformanceAnalytics3ObjectPage
                }
            },
            opaJourney.run
        );
    }
);