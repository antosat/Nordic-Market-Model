%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Results Time Series %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Results = {};
Results.Error = [];
input = {};
k = 1;

for j = Options.hourB:Options.hourE
    percentage = k/length(Options.hourB:Options.hourE)*100 % percentage
    Input = []; % parameters for the optimizer
    for i = 1:size(zones,2)
        input{end+1,1} = strcat('Pload_',char(zones{i}));
        assignin('base',strcat('Pload_',char(zones{i})),(TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix*TestCase.(char(zones{i})).Load.Coefficients(:,j)).*TestCase.(char(zones{i})).Load.Pmax);
        Input = [Input; evalin('base',strcat('Pload_',char(zones{i})))];
        if isfield(TestCase.(char(zones{i})),'Wind')
            input{end+1,1} = strcat('Pwind_',char(zones{i}));
            assignin('base',strcat('Pwind_',char(zones{i})),(TestCase.(char(zones{i})).Wind.CoefficientIncidenceMatrix*TestCase.(char(zones{i})).Wind.Coefficients(:,j)).*TestCase.(char(zones{i})).Wind.Pmax);
            Input = [Input; evalin('base',strcat('Pwind_',char(zones{i})))];
        end
        if isfield(TestCase.(char(zones{i})),'Solar')
            input{end+1,1} = strcat('Psol_',char(zones{i}));
            assignin('base',strcat('Psol_',char(zones{i})),(TestCase.(char(zones{i})).Solar.CoefficientIncidenceMatrix*TestCase.(char(zones{i})).Solar.Coefficients(:,j)).*TestCase.(char(zones{i})).Solar.Pmax);
            Input = [Input; evalin('base',strcat('Psol_',char(zones{i})))];
        end
        if strcmp(Options.optimization,'DC_OPF') && strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
            if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
                input{end+1,1} = strcat('F_ac_up_',char(zones{i}));
                input{end+1,1} = strcat('F_ac_low_',char(zones{i}));
                assignin('base',strcat('F_ac_up_',char(zones{i})),(TestCase.(char(zones{i})).Network.ACsystem.Capacities.Upper(:,j)));
                assignin('base',strcat('F_ac_low_',char(zones{i})),(TestCase.(char(zones{i})).Network.ACsystem.Capacities.Lower(:,j)));
                Input = [Input; evalin('base',strcat('F_ac_up_',char(zones{i}))); evalin('base',strcat('F_ac_low_',char(zones{i})))];
            end
            if isfield(TestCase.(char(zones{i})).Network,'HVDCinternal')
                input{end+1,1} = strcat('F_dc_up_',char(zones{i}));
                input{end+1,1} = strcat('F_dc_low_',char(zones{i}));
                assignin('base',strcat('F_dc_up_',char(zones{i})),(TestCase.(char(zones{i})).Network.HVDCinternal.Capacities.Upper(:,j)));
                assignin('base',strcat('F_dc_low_',char(zones{i})),(TestCase.(char(zones{i})).Network.HVDCinternal.Capacities.Lower(:,j)));
                Input = [Input; evalin('base',strcat('F_dc_up_',char(zones{i}))); evalin('base',strcat('F_dc_low_',char(zones{i})))];
            end
            if isfield(TestCase.(char(zones{i})).Network,'HVDCinterconnectors')
                input{end+1,1} = strcat('F_intdc_up_',char(zones{i}));
                input{end+1,1} = strcat('F_intdc_low_',char(zones{i}));
                assignin('base',strcat('F_intdc_up_',char(zones{i})),(TestCase.(char(zones{i})).Network.HVDCinterconnectors.Capacities.Upper(:,j)));
                assignin('base',strcat('F_intdc_low_',char(zones{i})),(TestCase.(char(zones{i})).Network.HVDCinterconnectors.Capacities.Lower(:,j)));
                Input = [Input; evalin('base',strcat('F_intdc_up_',char(zones{i}))); evalin('base',strcat('F_intdc_low_',char(zones{i})))];
            end
        end
    end
    clear i;
    
    % Solve the optimization problem
    [results, error] = NE_opt(Input);
    
    Results.(char(strcat('Hour_',num2str(j)))).Objective = results(1);
    Results.Error(k,:) = [j error];
    k = k+1;
    clear Input results error;
end
clear j k;

%% Clear workspace
clear(primvarnames{:})
clear(parameters{:})
clear(input{:})
clear Constraints Objective PowerBalance PowerInjections Parameters NE_opt;
clear areas zones primvarnames dualvarnames parameters input;
clear mpc_UCTE mpc_Nordic mpc_FBMC percentage;
