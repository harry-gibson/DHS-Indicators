# DHS-Indicators

### SQL code for generating certain DHS indicators

The DHS analysis work in this folder relates to recreating a number of the DHS's own existing "indicators", i.e. specific metrics that the DHS already extract and publish (via their API, StatCompiler, etc) from their data. 

However the DHS only publish these indicators at national and regional levels and this work was to apply those same metrics to generate indicator data at the cluster level. We were provided approximate code in Stata format for each of the required indicators for specific surveys, and the task here was to translate that into SQL code to reproduce the same things. 

This was a pretty tricky process as it wasn't necessarily the same sets of value mappings for every survey (e.g. what types of water source counted as an "improved" water source did not remain consistent). There were therefore various iterations to get things right (where "right" was defined by whether the cluster-level results, when summarised nationally, matched the indicator data in the DHS API). 

For each indicator, a template SQL file has been produced which when a survey id number is substituted in, will extract that indicator at the cluster level from the MAP DHS database (which is internal to MAP).

The FME folder contains a simple FME workbench to run each of the SQL files, and to write the results to a folder structure as specified for this particular project. The workbench also extracts national-level values for each of the indicators from the DHS API and compares the calculated results to the published figures.

This work provided the input data which enabled the production of the "modeled (indicator) surfaces" that are now published on [the DHS website](http://spatialdata.dhsprogram.com/modeled-surfaces/)