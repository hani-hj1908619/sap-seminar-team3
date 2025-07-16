sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'evaluate',
            componentId: 'SolutionPerformanceAnalytics4ObjectPage',
            contextPath: '/SolutionPerformanceAnalytics4'
        },
        CustomPageDefinitions
    );
});