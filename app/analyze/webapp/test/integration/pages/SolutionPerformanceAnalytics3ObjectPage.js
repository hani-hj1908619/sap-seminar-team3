sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'analyze',
            componentId: 'SolutionPerformanceAnalytics3ObjectPage',
            contextPath: '/SolutionPerformanceAnalytics3'
        },
        CustomPageDefinitions
    );
});