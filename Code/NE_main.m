%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% DC-OPF Nordic test network %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;

%% Input
zones = {'UCTE','Nordic','FBMC'};
mpc_UCTE = RG_UCTE;
mpc_Nordic = RG_Nordic;
mpc_FBMC = RG_FBMC;

%% Options
Options = {};

Options.problem = 'TimeSeries'; % 'SingleSnapshot';'TimeSeries'
if strcmp(Options.problem,'SingleSnapshot')
    % scenario max load: 114
    Options.hour = 114;
elseif strcmp(Options.problem,'TimeSeries')
    Options.hourB = 1;
    Options.hourE = 8761;
end
Options.loadshed = 0;
if Options.loadshed == 1
    Options.VOLL = 500; % Value of Lost Load in euro/MWh
end
Options.optimization = 'DC_OPF'; %'EconomicDispatch';'DC_OPF'
if strcmp(Options.optimization,'DC_OPF')
    Options.marketclearing = 'zonal_ATC'; %'zonal_PTDF';'zonal_ATC'
end
Options.solver = sdpsettings('solver','mosek','verbose',1,'savesolveroutput',1);

%% Load test case
TestCase = NE_DataFunction(Options,mpc_UCTE,mpc_Nordic,mpc_FBMC,zones);


%% Optimizaiton problem
if strcmp(Options.problem,'SingleSnapshot')
    NE_Optimization_SingleSnapshot
    NE_opt = optimize(Constraints, Objective, Options.solver);
elseif strcmp(Options.problem,'TimeSeries')
    NE_Optimization_TimeSeries
end

%% Results
if strcmp(Options.problem,'SingleSnapshot')
    NE_Results_SingleSnapshot
elseif strcmp(Options.problem,'TimeSeries')
    NE_Results_TimeSeries
end





