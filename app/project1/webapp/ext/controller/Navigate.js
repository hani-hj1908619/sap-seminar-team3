sap.ui.define([
    "sap/m/MessageToast"
], function(MessageToast) {
    'use strict';

    return {
        dashboard: function() {
            var oCrossAppNav = sap.ushell.Container.getService("CrossApplicationNavigation");
            oCrossAppNav.toExternal({
                target: {
                    semanticObject: "dashboard",  
                    action: "dashboard"                     
                },
            })
        },
        evaluate: function() {
            var oCrossAppNav = sap.ushell.Container.getService("CrossApplicationNavigation");
            oCrossAppNav.toExternal({
                target: {
                    semanticObject: "evaluate",  
                    action: "evaluate"                     
                },
            })
        }
    };
});
