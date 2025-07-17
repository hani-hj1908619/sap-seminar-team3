using EvaluationService as service from '../../srv/service';


annotate service.SolutionPerformanceAnalytics4 with @(
    UI.PresentationVariant #EvaluationPresentation       : {
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

    UI.Chart #alpChart                                   : {
        $Type          : 'UI.ChartDefinitionType',
        Title          : 'Route Cost Analysis',
        ChartType      : #VerticalBullet,
        Dimensions     : [
            route_id,
            result_total_cost_km
        ],
        DynamicMeasures: [
            '@Analytics.AggregatedProperty#cost_per_item_average',
            '@Analytics.AggregatedProperty#cost_per_weight_average',
            '@Analytics.AggregatedProperty#cost_per_volume_average',

        ],
    },
    Analytics.AggregatedProperty #cost_per_item_average  : {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'cost_per_item_average',
        AggregatableProperty: cost_per_item,
        AggregationMethod   : 'average',
        @Common.Label       : 'Cost /item',
    },
    Analytics.AggregatedProperty #cost_per_weight_average: {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'cost_per_weight_average',
        AggregatableProperty: cost_per_weight,
        AggregationMethod   : 'average',
        @Common.Label       : 'Cost /weight',
    },
    Analytics.AggregatedProperty #cost_per_volume_average: {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'cost_per_volume_average',
        AggregatableProperty: cost_per_volume,
        AggregationMethod   : 'average',
        @Common.Label       : 'Cost /volume',
    },
);

annotate service.SolutionPerformanceAnalytics4 with @(UI.LineItem #EvaluationTable: [
    {
        $Type: 'UI.DataField',
        Value: route_id,
        Label: 'Route ID'
    },
    {
        $Type: 'UI.DataField',
        Value: result_total_cost_km
    },
    {
        $Type: 'UI.DataField',
        Value: cost_per_item
    },
    {
        $Type: 'UI.DataField',
        Value: cost_per_volume
    },
    {
        $Type: 'UI.DataField',
        Value: cost_per_weight
    },
], );
