sap.ui.define([
    "sap/ui/test/opaQunit"
], function (opaTest) {
    "use strict";

    var Journey = {
        run: function() {
            QUnit.module("First journey");

            opaTest("Start application", function (Given, When, Then) {
                Given.iStartMyApp();

                Then.onTheSolutionPerformanceAnalytics3List.iSeeThisPage();

            });


            opaTest("Navigate to ObjectPage", function (Given, When, Then) {
                // Note: this test will fail if the ListReport page doesn't show any data
                
                When.onTheSolutionPerformanceAnalytics3List.onFilterBar().iExecuteSearch();
                
                Then.onTheSolutionPerformanceAnalytics3List.onTable().iCheckRows();

                When.onTheSolutionPerformanceAnalytics3List.onTable().iPressRow(0);
                Then.onTheSolutionPerformanceAnalytics3ObjectPage.iSeeThisPage();

            });

            opaTest("Teardown", function (Given, When, Then) { 
                // Cleanup
                Given.iTearDownMyApp();
            });
        }
    }

    return Journey;
});