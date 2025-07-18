# Real-World Vehicle Routing Problem (VRP) – Solution Analysis Dashboard

A SAP-based analytical tool designed to analyze, visualize, and evaluate real-world VRP solutions. It comprises a core CDS data model, aggregation logic, and three OData services powering three UI apps for distinct tasks.

---

## 📂 Project Structure
```
├── db/schema.cds // Core entities, associations, and views
├── srv/service.js // OData service definitions
├── app/
│ ├── dashboard/ // App for Task 1 & 2 (map & performance UI)
│ │ ├── webapp/
│ │ │ ├── ext/
│ │ │ │ ├── fragment/ // XML fragments
│ │ │ │ │ └── Map.fragment.xml
│ │ │ │ └── controller/
│ │ │ │ └── SolutionAndVehicleOverviewControllerExt.controller.js
│ ├── analyze/ // App for correlation analysis (Task 3)
│ └── insights/ // App for AI-generated insights (Task 4)
│ ├── webapp/
│ │ ├── ext/
│ │ │ ├── fragment/
│ │ │ │ └── AiSummaryDialog.fragment.xml
│ │ │ └── controller/
│ │ │ └── SolutionListExt.controller.js
```

---

## 🧠 Data Model & Views (`schema.cds`)

The data model consists of base entities, their relationships, and layered analytical views used across the apps.

### **Base Entities**
- `RouteSettings`, `Vehicles`, `Customers`, `Depots`, `Constraints`, `RouteResults`
- Associations are used to model relationships between them (e.g., a solution has many vehicles and route results)

### **Analytical Views**

The view structure is layered for maintainability and reuse:

1. **Per-Entity Level**
   - `VehicleOverview`: per-vehicle metrics such as:
     - `weight_utilization_pct`, `vehicle_cost_per_kg`, etc.
   - `RouteResultsOverview`: per-delivery metrics including:
     - `time_window_compliance` (whether the delivery respected the defined time window)

2. **Solution-Level Aggregates**
   - `SolutionVehicleAggregates`: aggregates over vehicles in a solution:
     - `total_vehicle_cost`, `avg_weight_utilization`, etc.
   - `SolutionRouteResultsAggregates`: aggregates over route results in a solution:
     - `time_window_compliance_pct` (percentage of deliveries that met the time window)
     - `route_total_stops` (total number of deliveries or stops)

3. **Final Consolidation**
   - `RouteOverview`: combines aggregates from both vehicles and route results to provide a comprehensive solution-level summary. This is the main view consumed by the apps.


---

## 🚀 Services (`service.js`)

Three distinct OData services tailored per app:

| Service Name               | Purpose                                | Exposed Views                          |
|----------------------------|----------------------------------------|----------------------------------------|
| `VRPAnalyticsService`      | Dashboard (Tasks 1 & 2)                | `VehicleOverview`, `SolutionVehicleAggregates`, `RouteOverview`, etc. |
| `CorrelationService`       | Correlation analysis (Task 3)         | Selected views needed for correlation metrics |
| `EvaluationService`        | AI‑driven insights (Task 4)           | `getAISummary()` + other views |

Only the required views are included in each service to optimize performance and clarity.

---

## 🖥️ App Overviews

### 1. Dashboard (`app/dashboard`)
- **Tasks 1 & 2**: Visualize VRP solutions on a map and evaluate performance
- **Map fragment**: `Map.fragment.xml`
- **Controller**: `SolutionAndVehicleOverviewControllerExt.controller.js`
  - Sets up map providers
  - Draws route lines and delivery spots
  - Opens delivery detail dialogs when a spot is clicked
- **Performance tables & object pages**: list of solutions, solution details page with embedded vehicle lists

### 2. Analyze (`app/analyze`)
- **Task 3**: Supports relation analysis between metrics
- Consumes views from `CorrelationService`
- Standard list/table UI for relation
- Shows what vehicle attribute most correlate with route constraints

### 3. Insights (`app/insights`)
- **Task 4**: Provides AI‑generated summaries and qualitative insight
- **AI dialog fragment**: `AiSummaryDialog.fragment.xml`
- **Controller**: `SolutionListExt.controller.js`
  - Calls `getAISummary()` from `EvaluationService`
  - Displays AI summary in message box above the solution table
  - Outlines how insights could be used with external solutions
