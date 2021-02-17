import EctoEnum

# creates a visualizations module schema enum. The schema enum
# contains the name of the module which will define the module
# contianing all the key definitions for a visualizations.
defenum(VisualizationsModuleSchemaEnum,
  "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.PivotTables": 0,
  "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.Lines": 1
)

# Creates an enum for different visualizations type
defenum(VisualizationsModuleEnum,
  PivotTables: 0,
  Lines: 1
)
