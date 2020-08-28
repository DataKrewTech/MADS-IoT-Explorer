import EctoEnum

# creates a widget vendor schema enum. The schema enum
# contains the name of the module which will define the module
# contianing all the key definitions for a vendor.
defenum(WidgetVendorSchemaEnum,
  "Elixir.AcqdatCore.Widgets.Schema.Vendors.HighCharts": 0,
  "Elixir.AcqdatCore.Widgets.Schema.Vendors.CustomCards": 1
)

# Creates an enum for different vendors for which widget
# type is created.
defenum(WidgetVendorEnum,
  HighCharts: 0,
  CustomCards: 1
)
