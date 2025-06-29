namespace sap.capire.vrp;

// BASE ENTITIES

entity RouteSettings {
    key route_id                       : String;
        id                             : Integer;
        route_code                     : String;
        route_date                     : Date;
        algorithm_number_of_iterations : Integer;
        result_total_cost_km           : Decimal;

        vehicles                       : Association to many Vehicles
                                             on vehicles.route = $self;
        customers                      : Association to many Customers
                                             on customers.route = $self;
        depots                         : Association to many Depots
                                             on depots.route = $self;
        constraints                    : Association to many Constraints
                                             on constraints.route = $self;
        route_results                  : Association to many RouteResults
                                             on route_results.route = $self;
}

entity Vehicles {
    key id                                     : Integer;
        route_id                               : String;
        route                                  : Association to RouteSettings
                                                     on route.route_id = route_id;
        vehicle_number                         : Integer;
        vehicle_code                           : String;
        vehicle_total_weight_kg                : Decimal;
        vehicle_total_volume_m3                : Decimal;
        vehicle_fixed_cost_km                  : Decimal;
        vehicle_variable_cost_km               : Decimal;
        vehicle_available_time_from_min        : Integer;
        vehicle_available_time_to_min          : Integer;
        result_vehicle_total_driving_time_min  : Decimal;
        result_vehicle_total_delivery_time_min : Decimal;
        result_vehicle_total_active_time_min   : Decimal;
        result_vehicle_driving_weight_kg       : Decimal;
        result_vehicle_driving_volume_m3       : Decimal;
        result_vehicle_final_cost_km           : Decimal;

        vehicle_stops                          : Association to many RouteResults
                                                     on  vehicle_stops.vehicle_code = vehicle_code
                                                     and vehicle_stops.route_id     = route_id;
        assigned_constraints                   : Association to many Constraints
                                                     on  assigned_constraints.sdvrp_constraint_vehicle_code = vehicle_code
                                                     and assigned_constraints.route_id                      = route_id;
}

entity Customers {
    key id                                 : Integer;
        route_id                           : String;
        route                              : Association to RouteSettings
                                                 on route.route_id = route_id;
        customer_number                    : Integer;
        customer_code                      : String;
        customer_latitude                  : Decimal;
        customer_longitude                 : Decimal;
        customer_time_window_from_min      : Integer;
        customer_time_window_to_min        : Integer;
        customer_delivery_service_time_min : Decimal;
        number_of_articles                 : Decimal;
        total_weight_kg                    : Decimal;
        total_volume_m3                    : Decimal;

        route_visits                       : Association to many RouteResults
                                                 on  route_visits.customer_code = customer_code
                                                 and route_visits.route_id      = route_id;
        constraints                        : Association to many Constraints
                                                 on  constraints.sdvrp_constraint_customer_code = customer_code
                                                 and constraints.route_id                       = route_id;
}

entity Depots {
    key id                            : Integer;
        route_id                      : String;
        route                         : Association to RouteSettings
                                            on route.route_id = route_id;
        depot_number                  : Integer;
        depot_code                    : String;
        depot_latitude                : Decimal;
        depot_longitude               : Decimal;
        depot_available_time_from_min : Integer;
        depot_available_time_to_min   : Integer;

        depot_visits                  : Association to many RouteResults
                                            on  depot_visits.customer_code = depot_code
                                            and depot_visits.route_id      = route_id;
}

entity Constraints {
    key id                             : Integer;
        route_id                       : String;
        route                          : Association to RouteSettings
                                             on route.route_id = route_id;
        sdvrp_constraint_number        : Integer;
        sdvrp_constraint_customer_code : String;
        sdvrp_constraint_vehicle_code  : String;

        customer                       : Association to Customers
                                             on  customer.customer_code = sdvrp_constraint_customer_code
                                             and customer.route_id      = route_id;
        vehicle                        : Association to Vehicles
                                             on  vehicle.vehicle_code = sdvrp_constraint_vehicle_code
                                             and vehicle.route_id     = route_id;
}

entity RouteResults {
    key id                                     : Integer;
        route_id                               : String;
        route                                  : Association to RouteSettings
                                                     on route.route_id = route_id;
        vehicle_code                           : String;
        customer_in_vehicle_route_order_number : Integer;
        customer_code                          : String;
        customer_latitude                      : Decimal;
        customer_longitude                     : Decimal;
        come_to_the_customer_at_min            : Decimal;
        distance_between_two_last_customers_km : Decimal;
        total_distance_to_customer_km          : Decimal;
        total_delivery_time_min                : Decimal;
        customer_time_window                   : String;


        vehicle                                : Association to Vehicles
                                                     on  vehicle.vehicle_code = vehicle_code
                                                     and vehicle.route_id     = route_id;
        customer                               : Association to Customers
                                                     on  customer.customer_code = customer_code
                                                     and customer.route_id      = route_id;
        depot                                  : Association to Depots
                                                     on  depot.depot_code = customer_code
                                                     and depot.route_id   = route_id;

}

// MAIN ANALYTICS VIEWS

// ANALYTICS VIEWS - Helper Views

define view VehicleMaxDistancePerRoute as
    select from RouteResults {
        route_id,
        vehicle_code,
        max(total_distance_to_customer_km) as vehicle_max_distance : Decimal
    }
    group by
        route_id,
        vehicle_code;

define view SolutionTotalDistance as
    select from VehicleMaxDistancePerRoute {
        key route_id,
            sum(vehicle_max_distance) as total_distance : Decimal
    }
    group by
        route_id;

// vehicle aggregates on a solution level
define view SolutionVehicleAggregates as
    select from Vehicles {
        key route_id,
            sum(result_vehicle_final_cost_km)                                     as total_vehicle_cost            : Decimal,
            avg(result_vehicle_driving_weight_kg / vehicle_total_weight_kg * 100) as avg_weight_utilization        : Decimal,
            avg(result_vehicle_driving_volume_m3 / vehicle_total_volume_m3 * 100) as avg_volume_utilization        : Decimal,
            sum(result_vehicle_total_driving_time_min)                            as total_driving_time            : Decimal,
            sum(result_vehicle_total_delivery_time_min)                           as total_delivery_time           : Decimal,
            count(case
                      when result_vehicle_final_cost_km > 0
                           then id
                  end)                                                            as vehicle_count                 : Integer,
            sum(result_vehicle_driving_weight_kg)                                 as total_driving_weight_kg       : Decimal,
            sum(result_vehicle_driving_volume_m3)                                 as total_driving_volume_m3       : Decimal,

            case
                when $self.avg_weight_utilization / 10 < 0
                     then 0
                when $self.avg_weight_utilization / 10 > 99
                     then 5
                else floor($self.avg_weight_utilization / 10) * 0.5
            end                                                                   as avg_weight_utilization_rating : Decimal,

            case
                when $self.avg_volume_utilization / 10 < 0
                     then 0
                when $self.avg_volume_utilization / 10 > 99
                     then 5
                else floor($self.avg_volume_utilization / 10) * 0.5
            end                                                                   as avg_volume_utilization_rating : Decimal,
    }
    where
        result_vehicle_final_cost_km > 0
    group by
        route_id;

// route results aggregates on a solution level
define view SolutionRouteResultsAggregates as
    select from RouteResultsOverview {
        key route_id,
            route,
            customer,
            customer_code,
            vehicle,
            vehicle_code,
            count( * ) as route_total_stops          : Integer,
            round(
                1.0 * sum(case
                              when come_to_the_customer_at_min between customer.customer_time_window_from_min
                                   and customer.customer_time_window_to_min
                                   then 1
                              else 0
                          end) / count( * ) * 100, 1
            )          as time_window_compliance_pct : Decimal
    }
    group by
        route_id;

// ANALYTICS VIEWS - Main

define view RouteResultsOverview as
    select from RouteResults {
        key id,
            route_id,
            route,
            customer,
            vehicle,
            vehicle_code,
            customer_in_vehicle_route_order_number,
            customer_code,
            customer_latitude,
            customer_longitude,
            come_to_the_customer_at_min,
            total_distance_to_customer_km,
            total_delivery_time_min,
            customer_time_window,

            case
                when come_to_the_customer_at_min between customer.customer_time_window_from_min
                     and customer.customer_time_window_to_min
                     then 1
                else 0
            end as time_window_compliance : Integer
    };

define view VehicleOverview as
    select from Vehicles {
        key id,
            vehicle_code,
            route_id,
            vehicle_total_weight_kg,
            vehicle_total_volume_m3,
            result_vehicle_driving_weight_kg,
            result_vehicle_driving_volume_m3,
            result_vehicle_final_cost_km,
            (
                round(
                    result_vehicle_driving_weight_kg / vehicle_total_weight_kg * 100, 2
                )
            )   as weight_utilization_pct    : Decimal,
            (
                round(
                    result_vehicle_driving_volume_m3 / vehicle_total_volume_m3 * 100, 2
                )
            )   as volume_utilization_pct    : Decimal,

            case
                when result_vehicle_driving_weight_kg > 0
                     then round(
                              result_vehicle_final_cost_km / result_vehicle_driving_weight_kg, 4
                          )
                else 0
            end as vehicle_cost_per_kg       : Decimal,

            case
                when result_vehicle_driving_weight_kg <= vehicle_total_weight_kg
                     and result_vehicle_driving_volume_m3 <= vehicle_total_volume_m3
                     then 'Compliant'
                else 'Non-Compliant'
            end as Capacity_Compliance       : String,

            case
                when result_vehicle_driving_weight_kg > vehicle_total_weight_kg
                     then 0
                when $self.weight_utilization_pct / 10 < 0
                     then 0
                when $self.weight_utilization_pct / 10 > 5
                     then 2.5
                else floor($self.weight_utilization_pct / 10) * 0.5
            end as Weight_Utilization_Rating : Decimal,


            case
                when result_vehicle_driving_volume_m3 > vehicle_total_volume_m3
                     then 0
                when $self.volume_utilization_pct / 10 < 0
                     then 0
                when $self.volume_utilization_pct / 10 > 5
                     then 2.5
                else floor($self.volume_utilization_pct / 10) * 0.5
            end as Volume_Utilization_Rating : Decimal,

    }
    where
        result_vehicle_final_cost_km > 0;


define view RouteOverview as
    select from vrp.RouteSettings {
        key route_id,
            route_date,
            result_total_cost_km,
            count(distinct customers.id) as customer_count : Integer,


            total_distance                                 : Association to SolutionTotalDistance
                                                                 on total_distance.route_id = route_id,

            vehicle_overviews                              : Association to many VehicleOverview
                                                                 on vehicle_overviews.route_id = route_id,
            route_result_overviews                         : Association to many RouteResultsOverview
                                                                 on route_result_overviews.route_id = route_id,
            vehicle_aggregate                              : Association to SolutionVehicleAggregates
                                                                 on vehicle_aggregate.route_id = route_id,
            route_result_aggregate                         : Association to SolutionRouteResultsAggregates
                                                                 on route_result_aggregate.route_id = route_id
                                                             }
                                                             group by
                                                                 route_id;

// ANALYTICS VIEWS - Annotations

annotate RouteSettings with {
    route_id             @title: 'Route ID';
    route_code           @title: 'Route Code';
    route_date           @title: 'Route Date';
    result_total_cost_km @title: 'Total Cost';
}

annotate VehicleOverview with {
    route_id                          @title: 'Route ID';
    vehicle_code                      @title: 'Vehicle Code';
    vehicle_total_weight_kg           @title: 'Max Weight'      @Measures.Unit: 'kg';
    vehicle_total_volume_m3           @title: 'Max Volume'      @Measures.Unit: 'm³';
    result_vehicle_driving_weight_kg  @title: 'Driving Weight'  @Measures.Unit: 'kg';
    result_vehicle_driving_volume_m3  @title: 'Driving Volume'  @Measures.Unit: 'm³';
    result_vehicle_final_cost_km      @title: 'Final Cost'      @Measures.Unit: 'km';
    // for some reason using @Measures.Unit: '%' makes the values in table view empty for these fields
    weight_utilization_pct            @title: 'Weight Utilization (%)';
    volume_utilization_pct            @title: 'Volume Utilization (%)';
    vehicle_cost_per_kg               @title: 'Cost per Kg';
    Capacity_Compliance               @title: 'Capacity Compliance';
    Weight_Utilization_Rating         @title: 'Weight Utilization Rating';
    Volume_Utilization_Rating         @title: 'Volume Utilization Rating';
}

annotate Customers with {
    customer_code      @title: 'Customer Code';
    customer_latitude  @title: 'Latitude';
    customer_longitude @title: 'Longitude';
    total_weight_kg    @title: 'Order Weight (kg)'  @Measures.Unit: 'kg';
    total_volume_m3    @title: 'Order Volume (m³)'  @Measures.Unit: 'm³';
}


// VISUALIZATION VIEWS

// work in progress

define view RouteSequence as
    select from RouteResults {
        key id,
            route_id,
            vehicle_code,
            customer_in_vehicle_route_order_number,
            customer_code,
            customer_latitude,
            customer_longitude,
            come_to_the_customer_at_min,
            total_distance_to_customer_km
    }
    order by
        route_id,
        vehicle_code,
        customer_in_vehicle_route_order_number;

define view CustomerDeliveries as
    select from Customers {
        key id,
            customer_code,
            route_id,
            customer_latitude,
            customer_longitude,
            customer_time_window_from_min,
            customer_time_window_to_min,
            total_weight_kg,
            total_volume_m3,
            route_visits.come_to_the_customer_at_min,
            route_visits.vehicle_code,
            case
                when route_visits.come_to_the_customer_at_min between customer_time_window_from_min
                     and customer_time_window_to_min
                     then 'On Time'
                when route_visits.come_to_the_customer_at_min < customer_time_window_from_min
                     then 'Early'
                else 'Late'
            end as delivery_status : String
    };
