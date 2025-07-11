sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'evaluate.evaluate',
            componentId: 'SolutionPerformanceAnalytics4List',
            contextPath: '/SolutionPerformanceAnalytics4'
        },
        CustomPageDefinitions
    );
});