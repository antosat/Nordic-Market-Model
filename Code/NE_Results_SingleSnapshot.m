%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Results Single Snapshot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Results = {};

for i = 1:size(zones,2)
    
    Results.(char(zones{i})) = {};
    
    % Primal variables
    if isfield(TestCase.(char(zones{i})),'Generator')
        Results.(char(zones{i})).GeneratorOutput = [value(evalin('base',strcat('g_out_',zones{i}))).*TestCase.(char(zones{i})).Sb ...
            TestCase.(char(zones{i})).Generator.Pmax-abs(value(evalin('base',strcat('g_out_',zones{i})))) <= 1E-06 ];
    end
    
    if strcmp(Options.optimization,'EconomicDispatch')
        Results.(char(zones{i})).ImportExport = value(evalin('base',strcat('impexp_',zones{i}))).*TestCase.(char(zones{i})).Sb;
    elseif strcmp(Options.optimization,'DC_OPF')
        if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
            if strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
                 Results.(char(zones{i})).FlowAC = [TestCase.(char(zones{i})).Network.ACsystem.From TestCase.(char(zones{i})).Network.ACsystem.To ...
                    value(evalin('base',strcat('f_ac_',zones{i}))).*TestCase.(char(zones{i})).Sb ...
                    TestCase.(char(zones{i})).Network.ACsystem.Capacities.Upper(:,Options.hour)-abs(value(evalin('base',strcat('f_ac_',zones{i})))) <= 1E-02 ...
                    -TestCase.(char(zones{i})).Network.ACsystem.Capacities.Lower(:,Options.hour)-abs(value(evalin('base',strcat('f_ac_',zones{i})))) <= 1E-02];
            end
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinternal')
            if strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
                Results.(char(zones{i})).FlowDC = [TestCase.(char(zones{i})).Network.HVDCinternal.From TestCase.(char(zones{i})).Network.HVDCinternal.To ...
                    value(evalin('base',strcat('f_hvdc_',zones{i}))).*TestCase.(char(zones{i})).Sb ...
                    TestCase.(char(zones{i})).Network.HVDCinternal.Capacities.Upper(:,Options.hour)-abs(value(evalin('base',strcat('f_hvdc_',zones{i})))) <= 1E-02 ...
                    -TestCase.(char(zones{i})).Network.HVDCinternal.Capacities.Lower(:,Options.hour)-abs(value(evalin('base',strcat('f_hvdc_',zones{i})))) <= 1E-02];
            end
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinterconnectors')
            if strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
                Results.(char(zones{i})).FlowINTER = [TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zfrom TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zto ...
                    TestCase.(char(zones{i})).Network.HVDCinterconnectors.From TestCase.(char(zones{i})).Network.HVDCinterconnectors.To ...
                    value(evalin('base',strcat('f_inter_',zones{i}))).*TestCase.(char(zones{i})).Sb ...
                    TestCase.(char(zones{i})).Network.HVDCinterconnectors.Capacities.Upper(:,Options.hour)-abs(value(evalin('base',strcat('f_inter_',zones{i})))) <= 1E-02 ...
                    -TestCase.(char(zones{i})).Network.HVDCinterconnectors.Capacities.Lower(:,Options.hour)-abs(value(evalin('base',strcat('f_inter_',zones{i})))) <= 1E-02];
            end
        end
    end
    if Options.loadshed == 1
        Results.(char(zones{i})).LoadShedding = value(evalin('base',strcat('d_shed_',zones{i}))).*TestCase.(char(zones{i})).Sb;
    end
    
    % Dual variables
    if strcmp(Options.optimization,'DC_OPF')
        if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
            Results.(char(zones{i})).Lambda = dual(Constraints(strcat('Lambda_',char(zones{i}))))./TestCase.(char(zones{i})).Sb;
            Results.(char(zones{i})).MuLB_Fac = dual(Constraints(strcat('MuLb_fac_',char(zones{i}))))./TestCase.(char(zones{i})).Sb;
            Results.(char(zones{i})).MuUB_Fac = dual(Constraints(strcat('MuUb_fac_',char(zones{i}))))./TestCase.(char(zones{i})).Sb;
            Results.(char(zones{i})).LMP = Results.(char(zones{i})).Lambda + TestCase.(char(zones{i})).Network.ACsystem.PTDF'*(Results.(char(zones{i})).MuLB_Fac-Results.(char(zones{i})).MuUB_Fac);
        else
            Results.(char(zones{i})).LMP = dual(Constraints(strcat('Lambda_',char(zones{i}))))./TestCase.(char(zones{i})).Sb;
        end
    elseif strcmp(Options.optimization,'EconomicDispatch')
        Results.(char(zones{i})).SystemPrice = dual(Constraints(strcat('Lambda_',char(zones{i}))))./TestCase.(char(zones{i})).Sb;
    end
end
clear i;

%% Clear workspace
clear(primvarnames{:})
clear Constraints Objective PowerBalance PowerInjections;
clear areas zones primvarnames dualvarnames;
clear mpc_UCTE mpc_Nordic mpc_FBMC NE_opt;
if Options.loadshed == 1
    clear VOLL_UCTE VOLL_Nordic VOLL_FBMC;
end
if strcmp(Options.optimization,'EconomicDispatch')
    clear SumImpExp;
end

    
