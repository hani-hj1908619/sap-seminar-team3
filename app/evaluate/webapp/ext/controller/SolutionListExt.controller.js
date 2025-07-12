sap.ui.define(
  ["sap/ui/core/mvc/ControllerExtension"],
  function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend(
      "evaluate.evaluate.ext.controller.SolutionListExt",
      {
        getAISummary: async function () {
          const oExtensionAPI = this.base.getExtensionAPI();
          const oModel = oExtensionAPI.getModel();
          const oView = this.getView();

          if (!this.oSummaryDialog) {
            this.oSummaryDialog = await this.base
              .getExtensionAPI()
              .loadFragment({
                name: "evaluate.evaluate.ext.fragment.AiSummaryDialog",
                controller: this,
              });
            oView.addDependent(this.oSummaryDialog);
          }
          this.oSummaryDialog.open();

          const oActionContext = oModel.bindContext("/summary(...)");

          // execute the action call
          await oActionContext
            .execute()
            .then(() => {
              const oResult = oActionContext.getBoundContext().getObject();
              const jsonModel = new sap.ui.model.json.JSONModel({
                summary: oResult.value,
              });
              sap.ui.getCore().byId("_IDGenDialog1").setModel(jsonModel);
            })
            .catch((err) => {
              console.error("Error executing action:", err);
              sap.m.MessageToast.show("Failed to fetch AI summary.");
            });
        },
        onSummaryDialogClose: function () {
          if (this.oSummaryDialog) {
            this.oSummaryDialog.close();
          }
        },
      }
    );
  }
);
