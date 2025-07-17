using CorrelationService as service from '../../srv/service';

// ========================================
// SOLUTION LIST PAGE
// ========================================

annotate service.SolutionPerformanceAnalytics3 with @(
    // these are the properties that will be shown as an option in the chart settings UI under "Measures"
    Analytics.AggregatedProperty #Route_Total_Cost            : {
        Name                : 'Route_Total_Cost',
        AggregatableProperty: result_total_cost_km,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Total Cost',
    },


    // Analytics.AggregatedProperty #Route_Customer_Count        : {
    //     Name                : 'Route_Customer_Count',
    //     AggregatableProperty: customer_count,
    //     AggregationMethod   : 'sum',
    //     ![@Common.Label]    : 'Customer Count'
    // },

    // Analytics.AggregatedProperty #Route_Total_Distance        : {
    //     Name                : 'Route_Total_Distance',
    //     AggregatableProperty: total_distance,
    //     AggregationMethod   : 'sum',
    //     ![@Common.Label]    : 'Total Distance (km)'
    // },
    // Analytics.AggregatedProperty #Route_Vehicle_Count         : {
    //     Name                : 'Route_Vehicle_Count',
    //     AggregatableProperty: vehicle_count,
    //     AggregationMethod   : 'sum',
    //     ![@Common.Label]    : 'Vehicle Count'
    // },
    // Analytics.AggregatedProperty #Route_Avg_Weight_Utilization: {
    //     Name                : 'Route_Avg_Weight_Utilization',
    //     AggregatableProperty: avg_weight_utilization,
    //     AggregationMethod   : 'sum',
    //     ![@Common.Label]    : 'Avg Weight Utilization (%)'
    // },
    // Analytics.AggregatedProperty #Route_Avg_Volume_Utilization: {
    //     Name                : 'Route_Avg_Volume_Utilization',
    //     AggregatableProperty: avg_volume_utilization,
    //     AggregationMethod   : 'sum',
    //     ![@Common.Label]    : 'Avg Volume Utilization (%)'
    //},

    //new
    // Analytics.AggregatedProperty #Route_Total_Vehicle_Time          : {
    //     Name                : 'Route_Total_Vehicle_Time',
    //     AggregatableProperty: result_total_cost_km,
    //     AggregationMethod   : 'sum',
    //     ![@Common.Label]    : 'Total Cost',
    // },

    // star ratings used in the header facet
    UI.DataPoint #VolumeUtilizationRating                     : {
        $Type        : 'UI.DataPointType',
        Value        : avg_volume_utilization_rating,
        Title        : 'Volume Utilization Rating',
        TargetValue  : 5,
        Visualization: #Rating,
    },
    UI.DataPoint #WeightUtilizationRating                     : {
        $Type        : 'UI.DataPointType',
        Value        : avg_weight_utilization_rating,
        Title        : 'Weight Utilization Rating',
        TargetValue  : 5,
        Visualization: #Rating,
    },
    Analytics.AggregatedProperty #customer_count_max : {
        $Type : 'Analytics.AggregatedPropertyType',
        Name : 'customer_count_max',
        AggregatableProperty : customer_count,
        AggregationMethod : 'max',
        ![@Common.Label] : 'Customers Served ',
    },
    UI.PresentationVariant #CorrelationPresentation: {
        MaxItems      : 50,
        SortOrder     : [
            {
                Property  : route_id,
                Descending: true
            },
            {
                Property  : result_total_cost_km,
                Descending: true
            }
        ],
        Visualizations: [
            '@UI.Chart#alpChart',
            '@UI.LineItem#AnalyticTable'
        ]
    },

    UI.Chart #alpChart : {
        $Type : 'UI.ChartDefinitionType',
        ChartType : #Line,
        Dimensions : [
            total_distance,
            customer_count,
            result_total_cost_km
        ],
        DynamicMeasures : [
            '@Analytics.AggregatedProperty#Route_Total_Cost',
            '@Analytics.AggregatedProperty#empty_weight_average',
            '@Analytics.AggregatedProperty#max_volume_average',
            
        ],
    },
    Analytics.AggregatedProperty #empty_weight_average : {
        $Type : 'Analytics.AggregatedPropertyType',
        Name : 'empty_weight_average',
        AggregatableProperty : empty_weight,
        AggregationMethod : 'average',
        ![@Common.Label] : 'Empty Weight',
    },
    Analytics.AggregatedProperty #max_volume_average : {
        $Type : 'Analytics.AggregatedPropertyType',
        Name : 'max_volume_average',
        AggregatableProperty : max_volume,
        AggregationMethod : 'average',
        ![@Common.Label] : 'Max Volume (m³)',
    },

);



// Line Item for table view
annotate service.SolutionPerformanceAnalytics3 with @(UI.LineItem #AnalyticTable: [
    {
        $Type: 'UI.DataField',
        Value: route_id,
        Label: 'Route ID'
    },
    {
        $Type: 'UI.DataField',
        Value: total_distance
    },
    {
        $Type: 'UI.DataField',
        Value: total_vehicle_cost
    },
    {
        $Type: 'UI.DataField',
        Value: total_driving_time
    },
    {
        $Type: 'UI.DataField',
        Value: empty_weight
    },
    {
        $Type: 'UI.DataField',
        Value: max_volume
    },
    {
        $Type: 'UI.DataField',
        Value: route_date,
        Label: 'Route Date'
    },
    {
        $Type: 'UI.DataField',
        Value: result_total_cost_km
    },
    {
        $Type: 'UI.DataField',
        Value: vehicle_count,
    },
    {
        $Type: 'UI.DataField',
        Value: customer_count,
    },
    {
        $Type: 'UI.DataField',
        Value: avg_weight_utilization
    },
    {
        $Type: 'UI.DataField',
        Value: avg_volume_utilization
    },

], );
