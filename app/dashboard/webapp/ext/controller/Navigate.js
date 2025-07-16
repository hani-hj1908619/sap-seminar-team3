sap.ui.define([
    "sap/m/MessageToast"
], function(MessageToast) {
    'use strict';

    return {
        evaluate: function() {
            var oCrossAppNav = sap.ushell.Container.getService("CrossApplicationNavigation");
            oCrossAppNav.toExternal({
                target: {
                    semanticObject: "evaluate",  
                    action: "evaluating"                     
                },
            })
        },
        analyze: function() {
            var oCrossAppNav = sap.ushell.Container.getService("CrossApplicationNavigation");
            oCrossAppNav.toExternal({
                target: {
                    semanticObject: "analyze",  
                    action: "analyze"                     
                },
            })
        },
    };
});
