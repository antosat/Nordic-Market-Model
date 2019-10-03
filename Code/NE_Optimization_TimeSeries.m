%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Optimization problem - Time Series %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% List variable names
primvarnames = {};
dualvarnames = {};
parameters = {};
Parameters = [];

for i = 1:size(zones,2)
    
    % Variables
    if isfield(TestCase.(char(zones{i})),'Generator')
        primvarnames{end+1,1} = strcat('g_out_',char(zones{i}));
        assignin('base',strcat('g_out_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Generator.ngen,1)); 
    end
    if strcmp(Options.optimization,'EconomicDispatch')
        primvarnames{end+1,1} = strcat('impexp_',char(zones{i}));
        assignin('base',strcat('impexp_',char(zones{i})),sdpvar(1,1));
    elseif strcmp(Options.optimization,'DC_OPF')
        if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
            primvarnames{end+1,1} = strcat('f_ac_',char(zones{i}));
            assignin('base',strcat('f_ac_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.ACsystem.nlineAC,1));
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinternal')
            primvarnames{end+1,1} = strcat('f_hvdc_',char(zones{i}));
            assignin('base',strcat('f_hvdc_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC,1));
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinterconnectors')
            primvarnames{end+1,1} = strcat('f_inter_',char(zones{i}));
            assignin('base',strcat('f_inter_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.HVDCinterconnectors.nintHVDC,1));
        end
    end
    if Options.loadshed == 1
        primvarnames{end+1,1} = strcat('d_shed_',char(zones{i}));
        assignin('base',strcat('d_shed_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Load.nload,1));
        assignin('base',strcat('VOLL_',char(zones{i})),ones(1,TestCase.(char(zones{i})).Load.nload).*Options.VOLL.*TestCase.(char(zones{i})).Sb); % Value of Lost Load
    end
    
    % Parameters as variables for the simulation
    parameters{end+1,1} = strcat('p_load_',char(zones{i}));
    assignin('base',strcat('p_load_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Load.nload,1));
    Parameters = [Parameters; evalin('base',strcat('p_load_',char(zones{i})))];
    if isfield(TestCase.(char(zones{i})),'Wind')
        parameters{end+1,1} = strcat('p_wind_',char(zones{i}));
        assignin('base',strcat('p_wind_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Wind.nwind,1));
        Parameters = [Parameters; evalin('base',strcat('p_wind_',char(zones{i})))];
    end
    if isfield(TestCase.(char(zones{i})),'Solar')
        parameters{end+1,1} = strcat('p_sol_',char(zones{i}));
        assignin('base',strcat('p_sol_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Solar.nsolar,1));
        Parameters = [Parameters; evalin('base',strcat('p_sol_',char(zones{i})))];
    end
    if strcmp(Options.optimization,'DC_OPF') && strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
        if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
            parameters{end+1,1} = strcat('f_ac_up_',char(zones{i}));
            parameters{end+1,1} = strcat('f_ac_low_',char(zones{i}));
            assignin('base',strcat('f_ac_up_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.ACsystem.nlineAC,1));
            assignin('base',strcat('f_ac_low_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.ACsystem.nlineAC,1));
            Parameters = [Parameters; evalin('base',strcat('f_ac_up_',char(zones{i}))); evalin('base',strcat('f_ac_low_',char(zones{i})))];
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinternal')
            parameters{end+1,1} = strcat('f_dc_up_',char(zones{i}));
            parameters{end+1,1} = strcat('f_dc_low_',char(zones{i}));
            assignin('base',strcat('f_dc_up_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC,1));
            assignin('base',strcat('f_dc_low_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC,1));
            Parameters = [Parameters; evalin('base',strcat('f_dc_up_',char(zones{i}))); evalin('base',strcat('f_dc_low_',char(zones{i})))];
        end
         if isfield(TestCase.(char(zones{i})).Network,'HVDCinterconnectors')
            parameters{end+1,1} = strcat('f_intdc_up_',char(zones{i}));
            parameters{end+1,1} = strcat('f_intdc_low_',char(zones{i}));
            assignin('base',strcat('f_intdc_up_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.HVDCinterconnectors.nintHVDC,1));
            assignin('base',strcat('f_intdc_low_',char(zones{i})),sdpvar(TestCase.(char(zones{i})).Network.HVDCinterconnectors.nintHVDC,1));
            Parameters = [Parameters; evalin('base',strcat('f_intdc_up_',char(zones{i}))); evalin('base',strcat('f_intdc_low_',char(zones{i})))];
        end
    end
    
    % Dual variables
    if isfield(TestCase.(char(zones{i})),'Generator')
        dualvarnames{end+1,1} = strcat('MuLb_gout_',char(zones{i}));
        dualvarnames{end+1,1} = strcat('MuUb_gout',char(zones{i}));
    end
    dualvarnames{end+1,1} = strcat('Lambda_',char(zones{i}));
    if strcmp(Options.optimization,'DC_OPF')
        if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
            dualvarnames{end+1,1} = strcat('Phi_fac_',char(zones{i}));
            dualvarnames{end+1,1} = strcat('MuLb_fac_',char(zones{i}));
            dualvarnames{end+1,1} = strcat('MuUb_fac_',char(zones{i}));
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinternal')
            dualvarnames{end+1,1} = strcat('MuLb_fhvdc_',char(zones{i}));
            dualvarnames{end+1,1} = strcat('MuUb_fhvdc_',char(zones{i}));
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinterconnectors')
            dualvarnames{end+1,1} = strcat('MuLb_finter_',char(zones{i}));
            dualvarnames{end+1,1} = strcat('MuUb_finter_',char(zones{i}));
        end
    end
    if Options.loadshed == 1
        dualvarnames{end+1,1} = strcat('MuLb_dshed_',char(zones{i}));
        dualvarnames{end+1,1} = strcat('MuUb_dshed_',char(zones{i}));
    end
end
clear i;

%% Objective function
Objective = 0;

for i = 1:size(zones,2)
    
    % Objective function
    if isfield(TestCase.(char(zones{i})),'Generator')
        Objective = Objective + TestCase.(char(zones{i})).Generator.LinCost*evalin('base',strcat('g_out_',char(zones{i})));
        
        if isfield(TestCase.(char(zones{i})).Generator,'FixCost')
            Objective = Objective + sum(TestCase.(char(zones{i})).Generator.FixCost);
        end
        if isfield(TestCase.(char(zones{i})).Generator,'QuadCost')
            Objective = Objective + TestCase.(char(zones{i})).Generator.QuadCost*(evalin('base',strcat('g_out_',char(zones{i}))).^2);
        end
    end
    
    if Options.loadshed == 1
        Objective = Objective + evalin('base',strcat('VOLL_',char(zones{i})))*evalin('base',strcat('d_shed_',char(zones{i})));
    end
    
end
clear i;

%% Constraints
Constraints = [];

if Options.loadshed == 1
    SumImpExp = 0;
end

for i = 1:size(zones,2)
    % Constraints
    
    if isfield(TestCase.(char(zones{i})),'Generator')
        Constraints = [ Constraints
            % Generator limits
            ( evalin('base',strcat('g_out_',char(zones{i}))) >= TestCase.(char(zones{i})).Generator.Pmin ):strcat('MuLb_gout_',char(zones{i}))
            ( evalin('base',strcat('g_out_',char(zones{i}))) <= TestCase.(char(zones{i})).Generator.Pmax ):strcat('MuUb_gout',char(zones{i}))
            ];
    end
    
    if Options.loadshed == 1
        Constraints = [ Constraints
            % Load shedding limits
            ( evalin('base',strcat('d_shed_',char(zones{i}))) >= 0 ):strcat('MuLb_dshed_',char(zones{i}))
            ( evalin('base',strcat('d_shed_',char(zones{i}))) <= max((TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix*TestCase.(char(zones{i})).Load.Coefficients(:,Options.hour)).*TestCase.(char(zones{i})).Load.Pmax,0) ):strcat('MuUb_dshed_',char(zones{i}))
        ];
    end
    
    if strcmp(Options.optimization,'EconomicDispatch')
        
        % LHS of power balance equation
        PowerBalance = sum(evalin('base',strcat('p_load_',char(zones{i}))))... Load
            -evalin('base',strcat('impexp_',char(zones{i}))); % Import (positive) or export (negative)

        if isfield(TestCase.(char(zones{i})),'Generator')
            PowerBalance = PowerBalance - sum(evalin('base',strcat('g_out_',char(zones{i})))); % Generator
        end
        if isfield(TestCase.(char(zones{i})),'Wind')
            PowerBalance = PowerBalance - sum(evalin('base',strcat('p_wind_',char(zones{i})))); % Wind
        end
        if isfield(TestCase.(char(zones{i})),'Solar')
            PowerBalance = PowerBalance - sum(evalin('base',strcat('p_sol_',char(zones{i})))); % Solar
        end        
        if Options.loadshed == 1
            PowerBalance = PowerBalance - sum(evalin('base',strcat('d_shed_',char(zones{i})))); % Load shedding
        end
        
        Constraints = [ Constraints
            ( PowerBalance == 0):strcat('Lambda_',char(zones{i}))
            ];
        
        % Import-export balance
        SumImpExp = SumImpExp + evalin('base',strcat('impexp_',char(zones{i})));
   
    elseif strcmp(Options.optimization,'DC_OPF')
        
        % LHS of power injections
        PowerInjections = -(TestCase.(char(zones{i})).Load.IncidenceMatrix)*(evalin('base',strcat('p_load_',char(zones{i})))); %Load
        % LHS of power balance
        PowerBalance = sum(evalin('base',strcat('p_load_',char(zones{i})))); %Load

        if isfield(TestCase.(char(zones{i})),'Generator')
            %Inclusion of generator
            PowerInjections = PowerInjections + (TestCase.(char(zones{i})).Generator.IncidenceMatrix)*(evalin('base',strcat('g_out_',char(zones{i})))); %Generator
            PowerBalance = PowerBalance - sum(evalin('base',strcat('g_out_',char(zones{i})))); %Generator
        end
        if isfield(TestCase.(char(zones{i})),'Wind')
            %Inclusion of wind
            PowerInjections = PowerInjections + (TestCase.(char(zones{i})).Wind.IncidenceMatrix)*(evalin('base',strcat('p_wind_',char(zones{i})))); %Wind
            PowerBalance = PowerBalance -sum(evalin('base',strcat('p_wind_',char(zones{i})))); %Wind
        end
        if isfield(TestCase.(char(zones{i})),'Solar')
            %Inclusion of solar
            PowerInjections = PowerInjections + (TestCase.(char(zones{i})).Solar.IncidenceMatrix)*(evalin('base',strcat('p_sol_',char(zones{i})))); % Solar
            PowerBalance = PowerBalance - sum(evalin('base',strcat('p_sol_',char(zones{i})))); %Solar
        end
        if strcmp(Options.marketclearing,'zonal_ATC')
            if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
                %Inclusion of AC lines
                PowerInjections = PowerInjections - (TestCase.(char(zones{i})).Network.ACsystem.IncidenceMatrix)*(evalin('base',strcat('f_ac_',char(zones{i})))); %AC lines
            end
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinternal')
            %Inclusion of internal HVDC lines
            PowerInjections = PowerInjections - (TestCase.(char(zones{i})).Network.HVDCinternal.IncidenceMatrix)*(evalin('base',strcat('f_hvdc_',char(zones{i})))); %Internal HVDC lines
        end
        for j = 1:size(zones,2)
            if isfield(TestCase.(char(zones{j})).Network,'HVDCinterconnectors')
                if sum(any(TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j}))))) >= 1
                    %Inclusion of HVDC interconnectors
                    PowerInjections = PowerInjections - (TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j}))))*(evalin('base',strcat('f_inter_',char(zones{j})))); %HVDC interconnectors
                    PowerBalance = PowerBalance + sum((TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j}))))*(evalin('base',strcat('f_inter_',char(zones{j}))))); %HVDC interconnectors
                end
            end
        end
        clear j;
        if Options.loadshed == 1
            %Inclusion of shedded load
            PowerInjections = PowerInjections + (TestCase.(char(zones{i})).Load.IncidenceMatrix)*(evalin('base',strcat('d_shed_',char(zones{i})))); %Load shedding
            PowerBalance = PowerBalance - sum(evalin('base',strcat('d_shed_',char(zones{i})))); %Load shedding
        end
        
        % AC constraints
        if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
            if strcmp(Options.marketclearing,'zonal_ATC') 
                Constraints = [ Constraints
                    ( evalin('base',strcat('f_ac_',char(zones{i}))) >= evalin('base',strcat('f_ac_low_',char(zones{i}))) ):strcat('MuLb_fac_',char(zones{i}))
                    ( evalin('base',strcat('f_ac_',char(zones{i}))) <= evalin('base',strcat('f_ac_up_',char(zones{i}))) ):strcat('MuUb_fac_',char(zones{i}))
                ];
            elseif strcmp(Options.marketclearing,'zonal_PTDF')
                Constraints = [ Constraints
                    % AC flows definition
                    ( evalin('base',strcat('f_ac_',char(zones{i}))) == (TestCase.(char(zones{i})).Network.ACsystem.PTDF)*PowerInjections ):strcat('Phi_fac_',char(zones{i}))
                    % AC line limits
                    ( evalin('base',strcat('f_ac_',char(zones{i}))) >= evalin('base',strcat('f_ac_low_',char(zones{i}))) ):strcat('MuLb_fac_',char(zones{i}))
                    ( evalin('base',strcat('f_ac_',char(zones{i}))) <= evalin('base',strcat('f_ac_up_',char(zones{i}))) ):strcat('MuUb_fac_',char(zones{i}))
                ];
            end
        end
                       
        % HVDC constraints
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinternal')
            if strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
                Constraints = [ Constraints
                    % Internal HVDC line limitis
                    ( evalin('base',strcat('f_hvdc_',char(zones{i}))) >= evalin('base',strcat('f_dc_low_',char(zones{i}))) ):strcat('MuLb_fhvdc_',char(zones{i}))
                    ( evalin('base',strcat('f_hvdc_',char(zones{i}))) <= evalin('base',strcat('f_dc_up_',char(zones{i}))) ):strcat('MuUb_fhvdc_',char(zones{i}))
                    ];
            end
        end
        if isfield(TestCase.(char(zones{i})).Network,'HVDCinterconnectors')
            if strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
                Constraints = [ Constraints
                    % External HVDC line limitis
                    ( evalin('base',strcat('f_inter_',char(zones{i}))) >= evalin('base',strcat('f_intdc_low_',char(zones{i}))) ):strcat('MuLb_finter_',char(zones{i}))
                    ( evalin('base',strcat('f_inter_',char(zones{i}))) <= evalin('base',strcat('f_intdc_up_',char(zones{i}))) ):strcat('MuUb_finter_',char(zones{i}))
                    ];
            end
        end
        
        % Power balance constraints
        if strcmp(Options.marketclearing,'zonal_ATC')
            Constraints = [ Constraints
                % Nodal balance equations
                ( -PowerInjections == 0 ):strcat('Lambda_',char(zones{i}))
            ];
        else
            if isfield(TestCase.(char(zones{i})).Network,'ACsystem')
                Constraints = [ Constraints
                    % System balance equation
                    ( PowerBalance == 0 ):strcat('Lambda_',char(zones{i}))
                    ];
            else
                Constraints = [ Constraints
                    % Nodal balance equations
                    ( -PowerInjections == 0 ):strcat('Lambda_',char(zones{i}))
                    ];
            end
        end
    end
end
clear i;

% Inter-zonal constraints
if strcmp(Options.optimization,'EconomicDispatch')
    Constraints = [ Constraints
        % Import-export balance
        SumImpExp == 0
    ];
end

%% Optimizer
NE_opt = optimizer(Constraints, Objective, Options.solver, Parameters, Objective);

