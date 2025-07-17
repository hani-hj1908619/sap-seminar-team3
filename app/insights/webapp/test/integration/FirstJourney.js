sap.ui.define([
    "sap/ui/test/opaQunit"
], function (opaTest) {
    "use strict";

    var Journey = {
        run: function() {
            QUnit.module("First journey");

            opaTest("Start application", function (Given, When, Then) {
                Given.iStartMyApp();

                Then.onTheSolutionPerformanceAnalytics4List.iSeeThisPage();

            });


            opaTest("Navigate to ObjectPage", function (Given, When, Then) {
                // Note: this test will fail if the ListReport page doesn't show any data
                
                When.onTheSolutionPerformanceAnalytics4List.onFilterBar().iExecuteSearch();
                
                Then.onTheSolutionPerformanceAnalytics4List.onTable().iCheckRows();

                When.onTheSolutionPerformanceAnalytics4List.onTable().iPressRow(0);
                Then.onTheSolutionPerformanceAnalytics4ObjectPage.iSeeThisPage();

            });

            opaTest("Teardown", function (Given, When, Then) { 
                // Cleanup
                Given.iTearDownMyApp();
            });
        }
    }

    return Journey;
});