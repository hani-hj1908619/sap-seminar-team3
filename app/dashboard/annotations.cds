using VRPAnalyticsService as service from '../../srv/service';

// ========================================
// SOLUTION LIST PAGE
// ========================================

annotate service.SolutionPerformanceAnalytics with @(
    // these are the properties that will be shown as an option in the chart settings UI under "Measures"
    Analytics.AggregatedProperty #Route_Total_Cost            : {
        Name                : 'Route_Total_Cost',
        AggregatableProperty: result_total_cost_km,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Total Cost',
    },

    Analytics.AggregatedProperty #Route_Customer_Count        : {
        Name                : 'Route_Customer_Count',
        AggregatableProperty: customer_count,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Customer Count'
    },

    Analytics.AggregatedProperty #Route_Total_Distance        : {
        Name                : 'Route_Total_Distance',
        AggregatableProperty: total_distance,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Total Distance (km)'
    },
    Analytics.AggregatedProperty #Route_Vehicle_Count         : {
        Name                : 'Route_Vehicle_Count',
        AggregatableProperty: vehicle_count,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Vehicle Count'
    },
    Analytics.AggregatedProperty #Route_Avg_Weight_Utilization: {
        Name                : 'Route_Avg_Weight_Utilization',
        AggregatableProperty: avg_weight_utilization,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Avg Weight Utilization (%)'
    },
    Analytics.AggregatedProperty #Route_Avg_Volume_Utilization: {
        Name                : 'Route_Avg_Volume_Utilization',
        AggregatableProperty: avg_volume_utilization,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Avg Volume Utilization (%)'
    },

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
);

// Solution Analytics List Page Charts
annotate service.SolutionPerformanceAnalytics with @(
    UI.Chart #SolutionPerformanceChart         : {
        Title          : 'Solution Performance Overview',
        ChartType      : #Column,
        Dimensions     : [route_id],
        // These will be the properties selected by default in the chart measure settings
        DynamicMeasures: ['@Analytics.AggregatedProperty#Route_Total_Distance'],

    },
    UI.PresentationVariant #SolutionPerformance: {
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
            '@UI.Chart#SolutionPerformanceChart',
            '@UI.LineItem#SolutionPerformanceTable'
        ]
    },
    UI.SelectionVariant #AllRoutes             : {Text: 'All Routes'},
    UI.SelectionVariant #HighCostRoutes        : {
        Text         : 'High Cost Routes',
        SelectOptions: [{
            PropertyName: result_total_cost_km,
            Ranges      : [{
                Sign  : #I,
                Option: #GT,
                Low   : 1000
            }]
        }]
    },
);

// Line Item for table view
annotate service.SolutionPerformanceAnalytics with @(UI.LineItem #SolutionPerformanceTable: [
    {
        $Type: 'UI.DataField',
        Value: route_id,
        Label: 'Route ID'
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
    {
        $Type: 'UI.DataField',
        Value: total_distance
    }
], );

// ========================================
// SOLUTION OBJECT PAGE
// ========================================

// aggregated properties used for vehicle comparison chart in solution object page
annotate service.VehicleOverview with @(
    Analytics.AggregatedProperty #Vehicle_Weight_Utilization: {
        Name                : 'Vehicle_Weight_Utilization',
        AggregatableProperty: weight_utilization_pct,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Vehicle Weight Utilization (%)'
    },
    Analytics.AggregatedProperty #Vehicle_Volume_Utilization: {
        Name                : 'Vehicle_Volume_Utilization',
        AggregatableProperty: volume_utilization_pct,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Vehicle Volume Utilization (%)'
    },
    Analytics.AggregatedProperty #Vehicle_Cost_Per_KG       : {
        Name                : 'Vehicle_Cost_Per_KG',
        AggregatableProperty: vehicle_cost_per_kg,
        AggregationMethod   : 'sum',
        ![@Common.Label]    : 'Vehicle Cost per KG'
    }
);

annotate service.SolutionPerformanceAnalytics with @(UI: {
    HeaderInfo          : {
        TypeName      : 'Solution Performance Analytics',
        TypeNamePlural: 'Solution Performance Analytics',
        Description   : {Value: 'Solution Details'},
        Title         : {
            $Type: 'UI.DataField',
            Value: route_id
        },
    },

    HeaderFacets        : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Volume_Utilization_Rating',
            Target: '@UI.DataPoint#VolumeUtilizationRating'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Weight_Utilization_Rating',
            Target: '@UI.DataPoint#WeightUtilizationRating'
        },
    ],
    FieldGroup #Overview: {Data: [
        {Value: route_id},
        {Value: route_date},
        {Value: vehicle_count},
        {Value: customer_count},
        {Value: route_total_stops},
        {Value: total_distance},
        {Value: total_vehicle_cost},
        {Value: total_driving_time},
        {Value: total_delivery_time},
        {Value: avg_weight_utilization},
        {Value: avg_volume_utilization},
        {Value: time_window_compliance_pct},
    ]},
    Facets              : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Solution Overview',
            Target: '@UI.FieldGroup#Overview'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Vehicle Comparison',
            ID    : 'VehicleComparisonChart',
            Target: 'vehicle_overviews/@UI.Chart#VehicleComparisonChart'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'VehicleOverviewTable',
            Label : 'Vehicle List',
            Target: 'vehicle_overviews/@UI.LineItem#VehicleOverviewTable'
        }
    ],
});

annotate service.VehicleOverview with @(UI.Chart #VehicleComparisonChart: {
    // Title          : 'Vehicle Comparison',
    ChartType      : #Column,
    Dimensions     : [vehicle_code],
    DynamicMeasures: [
        '@Analytics.AggregatedProperty#Vehicle_Weight_Utilization',
        '@Analytics.AggregatedProperty#Vehicle_Volume_Utilization',
        '@Analytics.AggregatedProperty#Vehicle_Cost_Per_KG'
    ],
});

// Line Item for vehicles sub table
annotate service.VehicleOverview with @(UI.LineItem #VehicleOverviewTable: [
    {
        $Type: 'UI.DataField',
        Value: vehicle_code,
        Label: 'Vehicle Code',
    },
    {
        $Type: 'UI.DataField',
        Value: weight_utilization_pct,
        Label: 'Weight Utilization (%)'
    },
    {
        $Type: 'UI.DataField',
        Value: volume_utilization_pct,
        Label: 'Volume Utilization (%)'
    },
    {
        $Type: 'UI.DataField',
        Value: result_vehicle_final_cost_km,
        Label: 'Final Cost (km)'
    }
]);


// ========================================
// VEHICLE OVERVIEW OBJECT PAGE
// ========================================

annotate service.VehicleOverview with @(
    UI.DataPoint #VolumeUtilizationRating: {
        $Type        : 'UI.DataPointType',
        Value        : Volume_Utilization_Rating,
        Title        : 'Volume Utilization Rating',
        TargetValue  : 5,
        Visualization: #Rating,
    },
    UI.DataPoint #WeightUtilizationRating: {
        $Type        : 'UI.DataPointType',
        Value        : Weight_Utilization_Rating,
        Title        : 'Weight Utilization Rating',
        TargetValue  : 5,
        Visualization: #Rating,
    }
);

annotate service.VehicleOverview with @(UI.Identification: [
    {
        $Type: 'UI.DataField',
        Value: vehicle_code
    },
    {
        $Type: 'UI.DataField',
        Value: route_id
    },
    {
        $Type: 'UI.DataField',
        Value: id
    }

]);

annotate service.VehicleOverview with @(UI: {
    HeaderInfo          : {
        TypeName      : 'Vehicle',
        TypeNamePlural: 'Vehicles',
        Description   : {Value: 'Solution Vehicle Performance Analytics'},
        Title         : {
            $Type: 'UI.DataField',
            Value: vehicle_code
        },
    },

    HeaderFacets        : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Volume_Utilization_Rating',
            Target: '@UI.DataPoint#VolumeUtilizationRating'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'Weight_Utilization_Rating',
            Target: '@UI.DataPoint#WeightUtilizationRating'
        },
    ],
    FieldGroup #Overview: {Data: [
        {Value: Capacity_Compliance},
        {Value: result_vehicle_final_cost_km},
        {Value: vehicle_total_weight_kg},
        {Value: result_vehicle_driving_weight_kg},
        {Value: vehicle_total_volume_m3},
        {Value: result_vehicle_driving_volume_m3},
        {Value: weight_utilization_pct},
        {Value: volume_utilization_pct},
        {Value: vehicle_cost_per_kg},
    ]},
    Facets              : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Overview',
        Target: '@UI.FieldGroup#Overview'
    }],
});
