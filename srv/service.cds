using sap.capire.vrp as vrp from '../db/schema';


service VRPAnalyticsService @(path: '/odata/v4/vrp-analytics') {
    // Supporting entities for drill down
    @readonly  @cds.redirection.target
    entity RouteSettings                as projection on vrp.RouteSettings;

    @readonly  @cds.redirection.target
    entity Vehicles                     as projection on vrp.Vehicles;

    @readonly  @cds.redirection.target
    entity Customers                    as projection on vrp.Customers;

    @readonly
    @Aggregation.ApplySupported: {
        Transformations       : [
            'aggregate',
            'groupby'
        ],
        GroupableProperties   : ['vehicle_code'],
        AggregatableProperties: [
            {Property: 'weight_utilization_pct'},
            {Property: 'volume_utilization_pct'},
            {Property: 'vehicle_cost_per_kg'},

        ]
    }
    entity VehicleOverview              as projection on vrp.VehicleOverview;

    @readonly
    entity RouteResultsOverview         as projection on vrp.RouteResultsOverview;

    // Main analytical entity for ALP
    @Aggregation.ApplySupported: {
        Transformations       : [
            'aggregate',
            'groupby',
            'filter'
        ],
        GroupableProperties   : ['route_id'],
        AggregatableProperties: [
            {Property: 'result_total_cost_km'},
            {Property: 'vehicle_count'},
            {Property: 'customer_count'},
            {Property: 'total_vehicle_cost'},
            {Property: 'avg_weight_utilization'},
            {Property: 'avg_volume_utilization'},
            {Property: 'total_driving_time'},
            {Property: 'total_distance'}
        ]
    }
    // entity SolutionPerformanceAnalytics as projection on vrp.RouteOverview;
    entity SolutionPerformanceAnalytics as
        select from vrp.RouteOverview {
            key route_id,
                route_date,
                result_total_cost_km,
                customer_count,
                // Sub-tables
                vehicle_overviews,
                route_result_overviews,
                // Extract data from helper views
                total_distance.total_distance,
                // SolutionRouteResultsAggregates
                route_result_aggregate.time_window_compliance_pct,
                route_result_aggregate.route_total_stops,
                // SolutionVehicleAggregates
                vehicle_aggregate.vehicle_count,
                vehicle_aggregate.total_vehicle_cost,
                vehicle_aggregate.avg_weight_utilization,
                vehicle_aggregate.avg_volume_utilization,
                vehicle_aggregate.total_driving_time,
                vehicle_aggregate.total_delivery_time,
                vehicle_aggregate.avg_weight_utilization_rating,
                vehicle_aggregate.avg_volume_utilization_rating
        };
}

// ANNOTATIONS - For UI titles

annotate VRPAnalyticsService.SolutionPerformanceAnalytics with {
    route_id                    @title: 'Route ID';
    route_date                  @title: 'Route Date';
    result_total_cost_km        @title: 'Total Cost'              @Measures.Unit: 'km';
    customer_count              @title: 'Customers';
    total_distance              @title: 'Total Distance'          @Measures.Unit: 'km';
    time_window_compliance_pct  @title: 'Time Window Compliance'  @Measures.Unit: '%';
    route_total_stops           @title: 'Total Stops';
    vehicle_count               @title: 'Vehicles';
    total_vehicle_cost          @title: 'Total Vehicle Cost';
    // for some reason using @Measures.Unit: '%' makes the values in table view empty for these fields
    avg_weight_utilization      @title: 'Avg Weight Utilization (%)';
    avg_volume_utilization      @title: 'Avg Volume Utilization (%)';
    total_driving_time          @title: 'Total Driving Time'      @Measures.Unit: 'min';
    total_delivery_time         @title: 'Total Delivery Time'     @Measures.Unit: 'min';
}

service CorrelationService @(path: '/vrp-analytics-task3') {
    // Supporting entities for drill down
    @readonly  @cds.redirection.target
    entity RouteSettings                 as projection on vrp.RouteSettings;

    @readonly  @cds.redirection.target
    entity Vehicles                      as projection on vrp.Vehicles;

    @readonly  @cds.redirection.target
    entity Customers                     as projection on vrp.Customers;

    @readonly
    @Aggregation.ApplySupported: {
        Transformations       : [
            'aggregate',
            'groupby'
        ],
        GroupableProperties   : ['vehicle_code'],
        AggregatableProperties: [
            {Property: 'weight_utilization_pct'},
            {Property: 'volume_utilization_pct'},
            {Property: 'vehicle_cost_per_kg'},

        ]
    }
    entity VehicleOverview               as projection on vrp.VehicleOverview;

    // Main analytical entity for ALP
    @Aggregation.ApplySupported: {
        Transformations       : [
            'aggregate',
            'groupby',
            'filter'
        ],
        GroupableProperties   : [
            'route_id',
            'total_distance',
            'customer_count',
            'result_total_cost_km'
        ],
        AggregatableProperties: [
            {Property: 'result_total_cost_km'},
            {Property: 'vehicle_count'},
            {Property: 'customer_count'},
            {Property: 'total_vehicle_cost'},
            {Property: 'avg_weight_utilization'},
            {Property: 'avg_volume_utilization'},
            {Property: 'total_driving_time'},
            {Property: 'total_distance'},
            {Property: 'empty_weight'},
            {Property: 'max_volume'}
        ]
    }
    // entity SolutionPerformanceAnalytics as projection on vrp.RouteOverview;
    entity SolutionPerformanceAnalytics3 as
        select from vrp.RouteOverview {
            key route_id,
                route_date,
                result_total_cost_km,
                customer_count,
                // Sub-tables
                vehicle_overviews,
                route_result_overviews,
                // Extract data from helper views
                total_distance.total_distance,
                // SolutionRouteResultsAggregates
                route_result_aggregate.time_window_compliance_pct,
                route_result_aggregate.route_total_stops,
                // SolutionVehicleAggregates
                vehicle_aggregate.vehicle_count,
                vehicle_aggregate.total_vehicle_cost,
                vehicle_aggregate.avg_weight_utilization,
                vehicle_aggregate.avg_volume_utilization,
                vehicle_aggregate.total_driving_time,
                vehicle_aggregate.total_delivery_time,
                vehicle_aggregate.avg_weight_utilization_rating,
                vehicle_aggregate.avg_volume_utilization_rating,
                vehicle_aggregate.total_active_time,
                //new
                vehicle_aggregate.max_volume,
                vehicle_aggregate.empty_weight
        };
}

annotate CorrelationService.SolutionPerformanceAnalytics3 with {
    route_id                    @title: 'Route ID';
    route_date                  @title: 'Route Date';
    result_total_cost_km        @title: 'Total Cost'              @Measures.Unit: 'km';
    customer_count              @title: 'Customers';
    total_distance              @title: 'Total Distance'          @Measures.Unit: 'km';
    time_window_compliance_pct  @title: 'Time Window Compliance'  @Measures.Unit: '%';
    route_total_stops           @title: 'Total Stops';
    vehicle_count               @title: 'Vehicles';
    total_vehicle_cost          @title: 'Total Vehicle Cost';
    // for some reason using @Measures.Unit: '%' makes the values in table view empty for these fields
    avg_weight_utilization      @title: 'Avg Weight Utilization (%)';
    avg_volume_utilization      @title: 'Avg Volume Utilization (%)';
    total_driving_time          @title: 'Total Driving Time'      @Measures.Unit: 'min';
    total_delivery_time         @title: 'Total Delivery Time'     @Measures.Unit: 'min';
    total_active_time           @title: 'Total Time'              @Measures.Unit: 'min';
    max_volume                  @title: 'Total Volume'            @Measures.Unit: 'm³';
    empty_weight                @title: 'Empty Weight'            @Measure.Uni  : 'kg';
}

service EvaluationService @(path: '/vrp-analytics-task4') {
    // Supporting entities for drill down
    @readonly  @cds.redirection.target
    entity RouteSettings                 as projection on vrp.RouteSettings;

    @readonly  @cds.redirection.target
    entity Vehicles                      as projection on vrp.Vehicles;

    @readonly  @cds.redirection.target
    entity Customers                     as projection on vrp.Customers;

    @readonly
    @Aggregation.ApplySupported: {
        Transformations       : [
            'aggregate',
            'groupby'
        ],
        GroupableProperties   : ['vehicle_code'],
        AggregatableProperties: [
            {Property: 'weight_utilization_pct'},
            {Property: 'volume_utilization_pct'},
            {Property: 'vehicle_cost_per_kg'},

        ]
    }
    entity VehicleOverview               as projection on vrp.VehicleOverview;

    // Main analytical entity for ALP
    @Aggregation.ApplySupported: {
        Transformations       : [
            'aggregate',
            'groupby',
            'filter'
        ],
        GroupableProperties   : [
            'route_id',
            result_total_cost_km
        ],
        AggregatableProperties: [
            {Property: 'result_total_cost_km'},
            {Property: 'cost_per_item'},
            {Property: 'cost_per_weight'},
            {Property: 'cost_per_volume'}
        ]
    }
    // entity SolutionPerformanceAnalytics as projection on vrp.RouteOverview;
    entity SolutionPerformanceAnalytics4 as
        select from vrp.RouteOverview {
            key route_id,
                route_date,
                result_total_cost_km,
                customer_count,
                // Sub-tables
                vehicle_overviews,
                route_result_overviews,
                // Extract data from helper views
                total_distance.total_distance,
                // SolutionRouteResultsAggregates
                route_result_aggregate.time_window_compliance_pct,
                route_result_aggregate.route_total_stops,
                // SolutionVehicleAggregates
                vehicle_aggregate.vehicle_count,
                vehicle_aggregate.total_vehicle_cost,
                vehicle_aggregate.avg_weight_utilization,
                vehicle_aggregate.avg_volume_utilization,
                vehicle_aggregate.total_driving_time,
                vehicle_aggregate.total_delivery_time,
                vehicle_aggregate.avg_weight_utilization_rating,
                vehicle_aggregate.avg_volume_utilization_rating,
                vehicle_aggregate.total_active_time,
                //new
                vehicle_aggregate.max_volume,
                vehicle_aggregate.empty_weight,
                cost_per_volume.cost_per_volume,
                cost_per_weight.cost_per_weight,
                cost_per_item.cost_per_item

        };

    function summary() returns LargeString;
}

annotate EvaluationService.SolutionPerformanceAnalytics4 with {
    route_id                    @title: 'Route ID';
    route_date                  @title: 'Route Date';
    result_total_cost_km        @title: 'Total Cost'              @Measures.Unit: 'km';
    customer_count              @title: 'Customers';
    total_distance              @title: 'Total Distance'          @Measures.Unit: 'km';
    time_window_compliance_pct  @title: 'Time Window Compliance'  @Measures.Unit: '%';
    route_total_stops           @title: 'Total Stops';
    vehicle_count               @title: 'Vehicles';
    total_vehicle_cost          @title: 'Total Vehicle Cost';
    // for some reason using @Measures.Unit: '%' makes the values in table view empty for these fields
    avg_weight_utilization      @title: 'Avg Weight Utilization (%)';
    avg_volume_utilization      @title: 'Avg Volume Utilization (%)';
    total_driving_time          @title: 'Total Driving Time'      @Measures.Unit: 'min';
    total_delivery_time         @title: 'Total Delivery Time'     @Measures.Unit: 'min';
    total_active_time           @title: 'Total Time'              @Measures.Unit: 'min';
    max_volume                  @title: 'Total Volume'            @Measures.Unit: 'm³';
    empty_weight                @title: 'Empty Weight'            @Measure.Uni  : 'kg';
    cost_per_item               @title: 'Cost of Items Delivered';
    cost_per_volume             @title: 'Cost of Volume Delivered';
    cost_per_weight             @title: 'Cost of Weight Delivered'
}
