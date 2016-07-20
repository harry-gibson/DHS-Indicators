# DHS-Indicators
SQL code for generating certain DHS indicators

This code is used in some collaborative work between MAP and DHS. It provides SQL for generating a number of DHS indicators at the cluster level. The SQL is intended to be run against a DHS database in PostGres. The database is internal to MAP, but was generated using scripts stored in another repository.

The FME folder contains a simple FME workbench to run each of the SQL files, and to write the results to a folder structure as specified for this particular project. The workbench also extracts national-level values for each of the indicators from the DHS API and compares the calculated results to the published figures.
