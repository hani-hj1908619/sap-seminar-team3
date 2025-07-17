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
                    action: "display"                     
                },
            })
        },
        insights: function() {
            var oCrossAppNav = sap.ushell.Container.getService("CrossApplicationNavigation");
            oCrossAppNav.toExternal({
                target: {
                    semanticObject: "insights",  
                    action: "display"                     
                },
            })
        }
    };
});
