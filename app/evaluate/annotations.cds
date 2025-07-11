using EvaluationService as service from '../../srv/service';


// ========================================
// SOLUTION LIST PAGE
// ========================================

annotate service.SolutionPerformanceAnalytics4 with @(
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
    UI.PresentationVariant #EvaluationPresentation: {
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
            '@UI.LineItem#EvaluationTable'
        ]
    },

    UI.Chart #alpChart : {
        $Type : 'UI.ChartDefinitionType',
        ChartType : #VerticalBullet,
        Dimensions : [
            route_id,
            result_total_cost_km
        ],
        DynamicMeasures : [
            '@Analytics.AggregatedProperty#cost_per_item_average',
            '@Analytics.AggregatedProperty#cost_per_weight_average',
            '@Analytics.AggregatedProperty#cost_per_volume_average',
            
        ],
    },
    Analytics.AggregatedProperty #cost_per_item_average : {
        $Type : 'Analytics.AggregatedPropertyType',
        Name : 'cost_per_item_average',
        AggregatableProperty : cost_per_item,
        AggregationMethod : 'average',
        @Common.Label : 'cost_per_item (Average)',
    },
    Analytics.AggregatedProperty #cost_per_weight_average : {
        $Type : 'Analytics.AggregatedPropertyType',
        Name : 'cost_per_weight_average',
        AggregatableProperty : cost_per_weight,
        AggregationMethod : 'average',
        @Common.Label : 'cost_per_weight (Average)',
    },
    Analytics.AggregatedProperty #cost_per_volume_average : {
        $Type : 'Analytics.AggregatedPropertyType',
        Name : 'cost_per_volume_average',
        AggregatableProperty : cost_per_volume,
        AggregationMethod : 'average',
        @Common.Label : 'cost_per_volume (Average)',
    },
    );



// Line Item for table view
annotate service.SolutionPerformanceAnalytics4 with @(UI.LineItem #EvaluationTable: [
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
