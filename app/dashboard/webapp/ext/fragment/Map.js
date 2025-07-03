sap.ui.define(["sap/m/MessageToast"], function (MessageToast) {
  "use strict";

  return {
    onPress: async function (oEvent) {
      const geoMap = this.byId("geoMap");

      const oSource = oEvent.getSource();
      const oContext = oSource.getBindingContext();

      // the 2 lines below and then adding  binding="{path: 'route_result_overviews'}" in the fragment XML took me 3 days to figure out :))
      await oContext.requestObject("route_result_overviews");
      const routeResults = oContext?.getObject().value;

      // reference - https://help.sap.com/docs/SUPPORT_CONTENT/sve/3362181389.html
      // tile images provider - https://cloud.maptiler.com/maps/

      // only uncomment this for demo. it uses too many credits from the API and we have only a few free credits

      // var oMapConfig = {
      //   MapProvider: [
      //     {
      //       name: "MAPTILER",
      //       type: "",
      //       description: "",
      //       tileX: "512",
      //       tileY: "512",
      //       maxLOD: "20",
      //       copyright: "Tiles Courtesy of MAPTILER",
      //       Source: [
      //         {
      //           id: "s1",
      //           url: "https://api.maptiler.com/maps/basic-v2/256/{LOD}/{X}/{Y}.png?key=2ktT7x1nds8is74daJPz",
      //         },
      //       ],
      //     },
      //   ],
      //   MapLayerStacks: [
      //     {
      //       name: "DEFAULT",
      //       MapLayer: {
      //         name: "layer1",
      //         refMapProvider: "MAPTILER",
      //         opacity: "1.0",
      //         colBkgnd: "RGB(255,255,255)",
      //       },
      //     },
      //   ],
      // };
      // geoMap.setMapConfiguration(oMapConfig);
      // geoMap.setRefMapLayerStack("DEFAULT");

      // set center position to the first customer
      const firstResult = routeResults[0];
      const firstLatLong = `${firstResult.customer_latitude};${firstResult.customer_longitude}`;
      geoMap.setCenterPosition(firstLatLong);
      geoMap.setZoomlevel(10);

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
        if (data1.customer_code != 1000) {
          spots.push(
            new sap.ui.vbm.Spot({
              id: `vehicle_${data1.vehicle_code}_customer_${data1.customer_code}_order_${data1.customer_in_vehicle_route_order_number}`,
              position: data1LatLong,
              text: data1.customer_code == 1000 ? "DEPOT" : data1.customer_code,
            })
          );
        }
      }

      // reference - https://ui5.sap.com/test-resources/sap/ui/vbm/bestpractices.html
      geoMap.addVo(
        new sap.ui.vbm.Routes({
          items: routes,
        })
      );

      geoMap.addVo(
        new sap.ui.vbm.Spots({
          items: spots,
        })
      );
    },
  };
});
