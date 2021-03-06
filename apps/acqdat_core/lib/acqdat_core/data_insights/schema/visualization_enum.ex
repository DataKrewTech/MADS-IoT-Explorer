import EctoEnum

# creates a visualizations module schema enum. The schema enum
# contains the name of the module which will define the module
# contianing all the key definitions for a visualizations.
defenum(VisualizationsModuleSchemaEnum,
  "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.PivotTables": 0,
  "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.Lines": 1,
  "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.Area": 2,
  "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.Column": 3,
  "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.HeatMap": 4
)

# Creates an enum for different visualizations type
defenum(VisualizationsModuleEnum,
  PivotTables: 0,
  Lines: 1,
  Area: 2,
  Column: 3,
  HeatMap: 4
)
