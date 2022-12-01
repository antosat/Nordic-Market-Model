# Nordic-Market-Model
Detailed market model of the Nordic countries (Denmark, Norway, Sweden and Finland)

This document contains some informations about the files in the repository "Nordic-Market-Model".

*-------------------------------------------------------------------------------------------------------*\
List of files:

(excel files - folder 'Data')
- NE_DATA.xlsx
- NE_HVDC.xlsx
- NE_Time_series_parameters.xlsx
- NE_Transmission_capacity.xlsx

(matlab files - folder 'Code')
- NE_main.m
- NE_DataFunction.m
- RG_UTCE.m
- RG_Nordic.m
- RG_FBMC.m
- NE_TimeSeriesParameters.m
- NE_makeBbus.m
- NE_estimatedPTDF.m
- NE_Capacities_ATC.m
- NE_Optimization_SingleSnapshot.m
- NE_Optimization_TimeSeries.m
- NE_Results_SingleSnapshot.m
- NE_Results_TimeSeries

*-------------------------------------------------------------------------------------------------------*

** NE_DATA.xlsx\
This file contains all the information about buses, generators, loads, AC lines, transformers and HVDC 
lines.
The test case is divided into 3 areas: RG_UCTE, RG_Nordic and a third RG_FBMC which contains the 
informations about Neighboring countries and HVDC interconnectors.
The bus numbering starts from 1 in each area.

** NE_HVDC.xlsx\
This file contains all the information HVDC lines and the parameters of the loss functions.

** NE_Time_series_parameters.xlsx\
This file contains load, wind and solar coefficients for each zone for each hour of 2017.

** NE_Transmission_capacity.xlsx\
This file contains the available transmission capacity between bidding zones for each zone for each 
hour of 2017.

*-------------------------------------------------------------------------------------------------------*

** NE_main.m\
This script is the main script of the market clearing algorithm for the Nordic Test Case. It has different
options:
- Problem: it can be 'SingleSnapshot' for clearing the market for a specific hour, or 'TimeSeries' for 
  clearing the market for a time window that goes from 'hourB' to 'hourE' that can be customized.
- Load shedding: load shedding can be included (1) or not included (0). If inlcuded, the value of lost 
  load is set to 500 euro/MWh, but can be customized
- Market clearing: it can be 'zonal_ATC', based on available transmission capacity, or 'zonal_PTDF', 
  based on flow-based market-coupling
- Solver: here the settings for the optimization problem can be set (e.g. mosek, gurobi etc)

** NE_DataFunction.m\
This function imports the data of generators, loads and the network from RG_UTCE.m, RG_Nordic.m, RG_FBMC.m,
NE_TimeSeriesParameters.m, NE_estimatedPTDF.m and NE_Capacities_ATC.m.

** RG_UTCE.m, RG_Nordic.m and RG_FBMC.m\
These files contain the data of buses, generators, loads, AC branches and HVDC lines. The data is stored in 
the matpower format.

** NE_TimeSeriesParameters.m\
This file contains the load, wind and solar coefficients for each zone for each hour of 2017.

** NE_makeBbus.m\
This function calculates the bus susceptance matrix.

** NE_estimatedPTDF.m\
This file contains the estimated PTDF matrix to be used for flow-based market clearing.

** NE_Capacities_ATC.m\
This file contains the available transmission capacities between bidding zones for each hour of 2017.

** NE_Optimization_SingleSnapshot.m and NE_Optimization_TimeSeries.m\
These scripts contain the formulation of the optimization problems for a single snapshot or for the time
series.

** NE_Results_SingleSnapshot.m and NE_Results_TimeSeries.m\
These scripts extract the outcome of the market clearing problem.


*-------------------------------------------------------------------------------------------------------*\
CITATION

If you use this model for published work, please cite the following paper:

"Andrea Tosatto, Spyros Chatzivasileiadis, HVDC Loss Factors in the Nordic Power Market, Electric Power Systems Research, vol. 190, Jan. 2021, https://doi.org/10.1016/j.epsr.2020.106710."

*-------------------------------------------------------------------------------------------------------*
