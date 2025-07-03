using sap.capire.vrp as vrp from '../db/schema';


service VRPAnalyticsService @(path: '/vrp-analytics') {
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
    entity RouteResultsOverview                as projection on vrp.RouteResultsOverview;

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


    // Customer Delivery Analytics
    @Aggregation.ApplySupported.Transformations: [
        'aggregate',
        'groupby',
        'filter'
    ]
    entity CustomerDeliveryAnalytics    as
        select from vrp.CustomerDeliveries {
            key id,
                route_id,
                customer_code,
                delivery_status,
                total_weight_kg,
                total_volume_m3,
                come_to_the_customer_at_min,
                customer_time_window_from_min,
                customer_time_window_to_min,
                case
                    when delivery_status = 'On Time'
                         then 1
                    else 0
                end as on_time_delivery : Integer,

                case
                    when delivery_status = 'Late'
                         then 1
                    else 0
                end as late_delivery    : Integer
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


annotate VRPAnalyticsService.CustomerDeliveryAnalytics with {
    customer_code    @title: 'Customer Code';
    delivery_status  @title: 'Delivery Status';
    on_time_delivery @title: 'On Time Delivery';
    late_delivery    @title: 'Late Delivery';
}