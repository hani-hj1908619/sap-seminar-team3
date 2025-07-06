sap.ui.define(
  ["sap/ui/core/mvc/ControllerExtension"],
  function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend(
      "dashboard.ext.controller.SolutionAndVehicleOverviewControllerExt",
      {
        // this section allows to extend lifecycle hooks or hooks provided by Fiori elements
        override: {
          /**
           * Called when a controller is instantiated and its View controls (if available) are already created.
           * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
           * @memberOf dashboard.ext.controller.SolutionObjectController
           */
          onInit: function () {
            var oExtensionAPI = this.base.getExtensionAPI();

            // reference - https://community.sap.com/t5/technology-blog-posts-by-members/fiori-elements-object-page-custom-section-containing-geomap-odata-v4-and-v2/ba-p/13551045
            var oGeomapController = oExtensionAPI.byId(
              "fe::CustomSubSection::Map--geoMap"
            );

            //Set Map configuration
            var oMapConfig = {
              MapProvider: [
                {
                  name: "OSM",
                  type: "",
                  description: "",
                  tileX: "256",
                  tileY: "256",
                  maxLOD: "20",
                  copyright: "OpenStreetMap",
                  Source: [
                    {
                      id: "s1",
                      url: "https://a.tile.openstreetmap.org/{LOD}/{X}/{Y}.png",
                    },
                  ],
                },
                // {
                //   name: "MAPTILER",
                //   type: "",
                //   description: "",
                //   tileX: "512",
                //   tileY: "512",
                //   maxLOD: "20",
                //   copyright: "Tiles Courtesy of MAPTILER",
                //   Source: [
                //     {
                //       id: "s1",
                //       url: "https://api.maptiler.com/maps/basic-v2/256/{LOD}/{X}/{Y}.png?key=2ktT7x1nds8is74daJPz",
                //     },
                //   ],
                // },
              ],
              MapLayerStacks: [
                {
                  name: "DEFAULT",
                  MapLayer: [
                    {
                      name: "OSMLayter",
                      refMapProvider: "OSM",
                      opacity: "1.0",
                      colBkgnd: "RGB(255,255,255)",
                    },
                  ],
                },
              ],
            };

            oGeomapController.setMapConfiguration(oMapConfig);
            oGeomapController.setRefMapLayerStack("DEFAULT");
          },
          onAfterRendering: function () {
            // var controllerView = this.getView();
            // console.log("onAfterRendering controllerView", controllerView);
            // var oExtensionAPI = this.base.getExtensionAPI();
            // var oModel = oExtensionAPI.getModel();
            // console.log("onAfterRendering oModel", oModel);
          },

          // reference - https://learning.sap.com/learning-journeys/developing-an-sap-fiori-elements-app-based-on-a-cap-odata-v4-service/using-controller-extensions_f47e841f-2dd8-4b88-ba5e-39c0eedd983e
          routing: {
            onAfterBinding: async function (oBindingContext) {
              const oExtensionAPI = this.base.getExtensionAPI();
              const oModel = oExtensionAPI.getModel();

              //   const oSolution = await oBindingContext.requestObject(
              //     oBindingContext.getPath()
              //   );
              //   console.log("oSolution", oSolution);

              const sPath =
                oBindingContext.getPath() + "/route_result_overviews";
              const oListBinding = oModel.bindList(sPath);

              const aContexts = await oListBinding.requestContexts();
              const routeResults = aContexts.map((context) =>
                context.getObject()
              );

              const oGeomapController = oExtensionAPI.byId(
                "fe::CustomSubSection::Map--geoMap"
              );

              // set center position to the first customer
              const firstResult = routeResults[0];
              const firstLatLong = `${firstResult.customer_latitude};${firstResult.customer_longitude}`;
              oGeomapController.setCenterPosition(firstLatLong);
              oGeomapController.setZoomlevel(10);

              // track vehicle_code and use unique color for each vehicle
              const vehicleColors = {};
              const distinctColors = [
                "#e6194b", // Red
                "#3cb44b", // Green
                "#ffe119", // Yellow
                "#4363d8", // Blue
                "#f58231", // Orange
                "#911eb4", // Purple
                "#46f0f0", // Cyan
                "#f032e6", // Magenta
                "#bcf60c", // Lime
                "#008080", // Teal
              ];
              let colorIndex = 0;

              routeResults.forEach((data) => {
                if (!vehicleColors[data.vehicle_code]) {
                  vehicleColors[data.vehicle_code] =
                    distinctColors[colorIndex % distinctColors.length];
                  colorIndex++;
                }
              });

              // loop through the stops and add a Route from each item to the next item
              let spots = [];
              let routes = [];

              // add a Spot for the first customer (always the depot)
              spots.push(
                new sap.ui.vbm.Spot({
                  position: firstLatLong,
                  icon: "sap-icon://factory",
                  contentSize: "30",
                })
              );

              for (let i = 0; i < routeResults.length - 1; i++) {
                const data1 = routeResults[i];
                const data2 = routeResults[i + 1];
                const data1LatLong = `${data1.customer_latitude};${data1.customer_longitude}`;
                const data2LatLong = `${data2.customer_latitude};${data2.customer_longitude}`;

                // if data1 and data2 have the same vehicle_code, then add a Route
                if (data1.vehicle_code == data2.vehicle_code) {
                  routes.push(
                    new sap.ui.vbm.Route({
                      position: `${data1LatLong};0; ${data2LatLong};0`,
                      color: vehicleColors[data1.vehicle_code],
                      colorBorder: "rgb(0, 0, 0)",
                      // click: "onClickRoute",
                      // contextMenu: "onContextMenuRoute",
                    })
                  );
                }

                // add a Spot for each customer - skip depot
                const spotLabel = oBindingContext
                  .getPath()
                  .includes("vehicle_overviews")
                  ? `STOP ${data1.customer_in_vehicle_route_order_number}`
                  : data1.customer_code;

                if (data1.customer_code != 1000) {
                  spots.push(
                    new sap.ui.vbm.Spot({
                      position: data1LatLong,
                      text: data1.customer_code == 1000 ? "DEPOT" : spotLabel,
                      type:
                        data1.time_window_compliance == 1 ? "Success" : "Error",
                      click: this.onPressSpot.bind(this),
                      customData: [
                        new sap.ui.core.CustomData({
                          key: "spotData",
                          value: data1,
                          writeToDom: false,
                        }),
                      ],
                    })
                  );
                }
              }

              // reference - https://ui5.sap.com/test-resources/sap/ui/vbm/bestpractices.html
              oGeomapController.addVo(
                new sap.ui.vbm.Routes({
                  items: routes,
                })
              );

              oGeomapController.addVo(
                new sap.ui.vbm.Spots({
                  items: spots,
                })
              );
            },
          },
        },

        onPressSpot: async function (oEvent) {
          // Handle the press event on the map
          const oSpot = oEvent.getSource();
          const spotData = oSpot.data("spotData");

          // Convert minutes to HH:mm format
          const toCustomerMin = spotData.come_to_the_customer_at_min;
          const hours = Math.floor(toCustomerMin / 60);
          const minutes = Math.floor(toCustomerMin % 60);
          const arrivalTime = `${hours.toString().padStart(2, "0")}:${minutes
            .toString()
            .padStart(2, "0")}`;

          const dialogData = {
            arrivalTime,
            customerWindow: spotData.customer_time_window,
            totalDeliveryMin: spotData.total_delivery_time_min,
          };

          const oDialogModel = new sap.ui.model.json.JSONModel(dialogData);

          const oExtensionAPI = this.base.getExtensionAPI();
          oExtensionAPI.oDialog ??= await oExtensionAPI.loadFragment({
            name: "dashboard.ext.fragment.Dialog",
            controller: this,
          });

          oExtensionAPI.oDialog.setModel(oDialogModel, "dialog");
          oExtensionAPI.oDialog.open();
        },
        closeSpotDialog: function () {
          const oExtensionAPI = this.base.getExtensionAPI();
          oExtensionAPI.oDialog.close();
        },
      }
    );
  }
);
