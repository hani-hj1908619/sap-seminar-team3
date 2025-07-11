sap.ui.define([
    "sap/m/MessageToast"
], function(MessageToast) {
    'use strict';

    return {
        dashboard: function(oEvent) {
            var oCrossAppNav = sap.ushell.Container.getService("CrossApplicationNavigation");
            oCrossAppNav.toExternal({
                target: {
                    semanticObject: "dashboard",  
                    action: "dashboard"                     
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
        }
    };
});
