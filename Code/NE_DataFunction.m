function TestCase = NE_DataFunction(Options,mpc_UCTE,mpc_Nordic,mpc_FBMC,zones)
% Script creating the network model

TestCase = {};

TimeSeriesParameters = NE_TimeSeriesParameters;
if strcmp(Options.optimization,'DC_OPF') && strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
    PTDF = NE_estimatedPTDF;
    Capacities = NE_Capacities_ATC;
end



% Create the structure with data for each area

for i = 1:size(zones,2)
    
    if strcmp(Options.optimization,'EconomicDispatch')
        mpc = evalin('base',strcat('mpc_',char(zones{i})));
        
        TestCase.(char(zones{i})).Sb = mpc.baseMVA;
        
        % BUS DATA
        TestCase.(char(zones{i})).Bus = {};
        TestCase.(char(zones{i})).Bus.nbus = size(mpc.bus,1);
        
        % AREA DATA
        TestCase.(char(zones{i})).Area = {};
        TestCase.(char(zones{i})).Area.narea = mpc.bus(end,7);
        for j = 1:TestCase.(char(zones{i})).Area.narea
            TestCase.(char(zones{i})).Area.(strcat('Area_',num2str(j))) = [];
            for k = 1:TestCase.(char(zones{i})).Bus.nbus
                if mpc.bus(k,7) == j
                    TestCase.(char(zones{i})).Area.(strcat('Area_',num2str(j))) = [ TestCase.(char(zones{i})).Area.(strcat('Area_',num2str(j))); k];
                end
            end
            clear k;
        end
        clear j;
        TestCase.(char(zones{i})).Area.NodeToAreaMatrix = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{i})).Bus.nbus);
        for j = 1:TestCase.(char(zones{i})).Bus.nbus
            TestCase.(char(zones{i})).Area.NodeToAreaMatrix(mpc.bus(j,7),j) = 1;
        end
        clear j;
        
        % GENERATOR DATA
        if isfield(mpc,'gen')
            TestCase.(char(zones{i})).Generator = {};
            TestCase.(char(zones{i})).Generator.ngen = size(mpc.gen,1);
            TestCase.(char(zones{i})).Generator.BusGen = mpc.gen(:,1);
            % incidence matrix
            TestCase.(char(zones{i})).Generator.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{i})).Generator.ngen);
            for j = 1:TestCase.(char(zones{i})).Generator.ngen
                TestCase.(char(zones{i})).Generator.IncidenceMatrix(TestCase.(char(zones{i})).Generator.BusGen(j),j) = 1;
            end
            clear j;
            % generation bounds
            TestCase.(char(zones{i})).Generator.Pmax = mpc.gen(:,9)./TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Generator.Pmin = zeros(TestCase.(char(zones{i})).Generator.ngen,1);
            % O&M costs
            if mpc.gencost(1,4) == 2
                TestCase.(char(zones{i})).Generator.LinCost = mpc.gencost(:,5)'.*TestCase.(char(zones{i})).Sb;
                if any(mpc.gencost(:,6))
                    TestCase.(char(zones{i})).Generator.FixCost = mpc.gencost(:,6)';
                end
            elseif mpc.gencost(1,4) == 3
                TestCase.(char(zones{i})).Generator.QuadCost = mpc.gencost(:,5)'.*(TestCase.(char(zones{i})).Sb^2);
                TestCase.(char(zones{i})).Generator.LinCost = mpc.gencost(:,6)'.*TestCase.(char(zones{i})).Sb;
                if any(mpc.gencost(:,7))
                    TestCase.(char(zones{i})).Generator.FixCost = mpc.gencost(:,7)';
                end
            end
        end
        
        % WIND DATA
        if isfield(mpc,'wind')
            TestCase.(char(zones{i})).Wind = {};
            TestCase.(char(zones{i})).Wind.nwind = size(mpc.wind,1);
            TestCase.(char(zones{i})).Wind.BusWind = mpc.wind(:,1);
            % incidence matrix
            TestCase.(char(zones{i})).Wind.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{i})).Wind.nwind);
            for j = 1:TestCase.(char(zones{i})).Wind.nwind
                TestCase.(char(zones{i})).Wind.IncidenceMatrix(TestCase.(char(zones{i})).Wind.BusWind(j),j) = 1;
            end
            clear j;
            % coefficient incidence matrix
            TestCase.(char(zones{i})).Wind.CoefficientIncidenceMatrix = zeros(TestCase.(char(zones{i})).Wind.nwind,TestCase.(char(zones{i})).Area.narea);
            for j = 1:TestCase.(char(zones{i})).Wind.nwind
                for k = 1:TestCase.(char(zones{i})).Area.narea
                    if ismember(TestCase.(char(zones{i})).Wind.BusWind(j),TestCase.(char(zones{i})).Area.(strcat('Area_',num2str(k))))
                        K = k;
                    end
                end
                TestCase.(char(zones{i})).Wind.CoefficientIncidenceMatrix(j,K) = 1;
                clear k K;
            end
            clear j;
            % maximum production
            TestCase.(char(zones{i})).Wind.Pmax = mpc.wind(:,2)./TestCase.(char(zones{i})).Sb;
            % wind coefficients
            TestCase.(char(zones{i})).Wind.Coefficients = TimeSeriesParameters.(char(zones{i})).Wind;
        end
        
        % SOLAR DATA
        if isfield(mpc,'solar')
            TestCase.(char(zones{i})).Solar = {};
            TestCase.(char(zones{i})).Solar.nsolar = size(mpc.solar,1);
            TestCase.(char(zones{i})).Solar.BusSolar = mpc.solar(:,1);
            % incidence matrix
            TestCase.(char(zones{i})).Solar.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{i})).Solar.nsolar);
            for j = 1:TestCase.(char(zones{i})).Solar.nsolar
                TestCase.(char(zones{i})).Solar.IncidenceMatrix(TestCase.(char(zones{i})).Solar.BusSolar(j),j) = 1;
            end
            clear j;
            % coefficient incidence matrix
            TestCase.(char(zones{i})).Solar.CoefficientIncidenceMatrix = zeros(TestCase.(char(zones{i})).Solar.nsolar,TestCase.(char(zones{i})).Area.narea);
            for j = 1:TestCase.(char(zones{i})).Solar.nsolar
                for k = 1:TestCase.(char(zones{i})).Area.narea
                    if ismember(TestCase.(char(zones{i})).Solar.BusSolar(j),TestCase.(char(zones{i})).Area.(strcat('Area_',num2str(k))))
                        K = k;
                    end
                end
                TestCase.(char(zones{i})).Solar.CoefficientIncidenceMatrix(j,K) = 1;
                clear k K;
            end
            clear j;
            % maximum production
            TestCase.(char(zones{i})).Solar.Pmax = mpc.solar(:,2)./TestCase.(char(zones{i})).Sb;
            % solar coefficients
            TestCase.(char(zones{i})).Solar.Coefficients = TimeSeriesParameters.(char(zones{i})).Solar;
        end
        
        % LOAD DATA
        if isfield(mpc,'load')
            TestCase.(char(zones{i})).Load = {};
            TestCase.(char(zones{i})).Load.nload = size(mpc.load,1);
            TestCase.(char(zones{i})).Load.BusLoad = mpc.load(:,1);
            % incidence matrix
            TestCase.(char(zones{i})).Load.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{i})).Load.nload);
            for j = 1:TestCase.(char(zones{i})).Load.nload
                TestCase.(char(zones{i})).Load.IncidenceMatrix(TestCase.(char(zones{i})).Load.BusLoad(j),j) = 1;
            end
            clear j;
            % coefficient incidence matrix
            if isfield(mpc,'interHVDC')
                TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix = zeros(TestCase.(char(zones{i})).Load.nload,TestCase.(char(zones{i})).Bus.nbus);
                for j = 1:TestCase.(char(zones{i})).Load.nload
                    TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix(j,TestCase.(char(zones{i})).Load.BusLoad(j)) = 1;
                end
                clear j;
            else
                TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix = zeros(TestCase.(char(zones{i})).Load.nload,TestCase.(char(zones{i})).Area.narea);
                for j = 1:TestCase.(char(zones{i})).Load.nload
                    for k = 1:TestCase.(char(zones{i})).Area.narea
                        if ismember(TestCase.(char(zones{i})).Load.BusLoad(j),TestCase.(char(zones{i})).Area.(strcat('Area_',num2str(k))))
                            K = k;
                        end
                    end
                    TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix(j,K) = 1;
                    clear k K;
                end
                clear j;
            end
            % maximum consumption
            TestCase.(char(zones{i})).Load.Pmax = mpc.load(:,2)./TestCase.(char(zones{i})).Sb;
            % tan_phi
            TestCase.(char(zones{i})).Load.TanPhi = mpc.load(:,3);
            % load coefficients
            TestCase.(char(zones{i})).Load.Coefficients = TimeSeriesParameters.(char(zones{i})).Load;
        end
        
        % NETWORK DATA
        % AC System
        if isfield(mpc,'branch')
            TestCase.(char(zones{i})).Network.ACsystem = {};
            TestCase.(char(zones{i})).Network.ACsystem.nlineAC = size(mpc.branch,1);
            TestCase.(char(zones{i})).Network.ACsystem.From = mpc.branch(:,1);
            TestCase.(char(zones{i})).Network.ACsystem.To = mpc.branch(:,2);
            for j = 1:TestCase.(char(zones{i})).Network.ACsystem.nlineAC
                if mpc.branch(j,4)<=0
                    mpc.branch(j,4)=0.0001;
                end
            end
            clear j;
            % Reference node
            for j = 1:TestCase.(char(zones{i})).Bus.nbus
                if mpc.bus(j,2) == 3
                    TestCase.(char(zones{i})).Network.ACsystem.ReferenceBus = j;
                end
            end
            clear j;
            % Bus susceptance matrix
            TestCase.(char(zones{i})).Network.ACsystem.Bbus = NE_makeBbus(mpc);
            % Line susceptance matrix
            TestCase.(char(zones{i})).Network.ACsystem.Bline = zeros(TestCase.(char(zones{i})).Network.ACsystem.nlineAC,TestCase.(char(zones{i})).Bus.nbus);
            for j = 1:TestCase.(char(zones{i})).Network.ACsystem.nlineAC
                TestCase.(char(zones{i})).Network.ACsystem.Bline(j,TestCase.(char(zones{i})).Network.ACsystem.From(j)) = 1/mpc.branch(j,4);
                TestCase.(char(zones{i})).Network.ACsystem.Bline(j,TestCase.(char(zones{i})).Network.ACsystem.To(j)) = -(1/mpc.branch(j,4));
            end
            clear j
            % PTDF matrix
            TestCase.(char(zones{i})).Network.ACsystem.PTDF = NE_makePTDF(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{i})).Network.ACsystem.ReferenceBus,...
                TestCase.(char(zones{i})).Network.ACsystem.Bbus,TestCase.(char(zones{i})).Network.ACsystem.Bline);
            % AC line incidence matrix
            TestCase.(char(zones{i})).Network.ACsystem.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{i})).Network.ACsystem.nlineAC);
            for j = 1:TestCase.(char(zones{i})).Network.ACsystem.nlineAC
                TestCase.(char(zones{i})).Network.ACsystem.IncidenceMatrix(TestCase.(char(zones{i})).Network.ACsystem.From(j),j) = 1;
                TestCase.(char(zones{i})).Network.ACsystem.IncidenceMatrix(TestCase.(char(zones{i})).Network.ACsystem.To(j),j) = -1;
            end
            clear j;
            % Line parameters 
            TestCase.(char(zones{i})).Network.ACsystem.R = mpc.branch(:,3);
            TestCase.(char(zones{i})).Network.ACsystem.B = 1./mpc.branch(:,4);
        end
        % Internal HVDC lines
        if isfield(mpc,'branchHVDC')
            TestCase.(char(zones{i})).Network.HVDCinternal = {};
            TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC = size(mpc.branchHVDC,1);
            TestCase.(char(zones{i})).Network.HVDCinternal.From = mpc.branchHVDC(:,1);
            TestCase.(char(zones{i})).Network.HVDCinternal.To = mpc.branchHVDC(:,2);
            TestCase.(char(zones{i})).Network.HVDCinternal.A = mpc.branchHVDC(:,4).*TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Network.HVDCinternal.B = mpc.branchHVDC(:,5);
            TestCase.(char(zones{i})).Network.HVDCinternal.C = mpc.branchHVDC(:,6)./TestCase.(char(zones{i})).Sb;
            % HVDC line incidence matrix
            TestCase.(char(zones{i})).Network.HVDCinternal.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC);
            for j = 1:TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC
                TestCase.(char(zones{i})).Network.HVDCinternal.IncidenceMatrix(TestCase.(char(zones{i})).Network.HVDCinternal.From(j),j) = 1;
                TestCase.(char(zones{i})).Network.HVDCinternal.IncidenceMatrix(TestCase.(char(zones{i})).Network.HVDCinternal.To(j),j) = -1;
            end
            clear j;
        end
        % External HVDC interconnectors
        if isfield(mpc,'interHVDC')
            TestCase.(char(zones{i})).Network.HVDCinterconnectors = {};
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.nintHVDC = size(mpc.interHVDC,1);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zfrom = mpc.interHVDC(:,1);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zto = mpc.interHVDC(:,3);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.From = mpc.interHVDC(:,2);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.To = mpc.interHVDC(:,4);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.A = mpc.interHVDC(:,6).*TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.B = mpc.interHVDC(:,7);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.C = mpc.interHVDC(:,8)./TestCase.(char(zones{i})).Sb;
        end
    elseif strcmp(Options.optimization,'DC_OPF') && strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
        % DATA FOR FLOW-BASED MARKET COUPLING
        
        mpc = evalin('base',strcat('mpc_',char(zones{i})));
        
        TestCase.(char(zones{i})).Sb = mpc.baseMVA;
        
        % AREA DATA
        TestCase.(char(zones{i})).Area = {};
        TestCase.(char(zones{i})).Area.narea = mpc.bus(end,7);
        TestCase.(char(zones{i})).Area.nbus = size(mpc.bus,1);
        for j = 1:TestCase.(char(zones{i})).Area.narea
            TestCase.(char(zones{i})).Area.(char(strcat('Area_',num2str(j)))) = {};
            TestCase.(char(zones{i})).Area.(char(strcat('Area_',num2str(j)))).nbus = 0;
            TestCase.(char(zones{i})).Area.(char(strcat('Area_',num2str(j)))).bus = [];
            for k = 1:TestCase.(char(zones{i})).Area.nbus
                if mpc.bus(k,7) == j
                    TestCase.(char(zones{i})).Area.(char(strcat('Area_',num2str(j)))).bus = [TestCase.(char(zones{i})).Area.(char(strcat('Area_',num2str(j)))).bus; mpc.bus(k,1)];
                end
            end
            clear k;
            TestCase.(char(zones{i})).Area.(char(strcat('Area_',num2str(j)))).nbus = length(TestCase.(char(zones{i})).Area.(char(strcat('Area_',num2str(j)))).bus);
        end
        clear j;
        
        % GENERATOR DATA
        if isfield(mpc,'gen')
            TestCase.(char(zones{i})).Generator = {};
            TestCase.(char(zones{i})).Generator.ngen = size(mpc.gen,1);
            TestCase.(char(zones{i})).Generator.AreaGen = mpc.bus(mpc.gen(:,1),7);
            % incidence matrix
            TestCase.(char(zones{i})).Generator.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{i})).Generator.ngen);
            for j = 1:TestCase.(char(zones{i})).Generator.ngen
                TestCase.(char(zones{i})).Generator.IncidenceMatrix(TestCase.(char(zones{i})).Generator.AreaGen(j),j) = 1;
            end
            clear j;
            % generation bounds
            TestCase.(char(zones{i})).Generator.Pmax = mpc.gen(:,9)./TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Generator.Pmin = zeros(TestCase.(char(zones{i})).Generator.ngen,1);
            % O&M costs
            if mpc.gencost(1,4) == 2
                TestCase.(char(zones{i})).Generator.LinCost = mpc.gencost(:,5)'.*TestCase.(char(zones{i})).Sb;
                if any(mpc.gencost(:,6))
                    TestCase.(char(zones{i})).Generator.FixCost = mpc.gencost(:,6)';
                end
            elseif mpc.gencost(1,4) == 3
                TestCase.(char(zones{i})).Generator.QuadCost = mpc.gencost(:,5)'.*(TestCase.(char(zones{i})).Sb^2);
                TestCase.(char(zones{i})).Generator.LinCost = mpc.gencost(:,6)'.*TestCase.(char(zones{i})).Sb;
                if any(mpc.gencost(:,7))
                    TestCase.(char(zones{i})).Generator.FixCost = mpc.gencost(:,7)';
                end
            end
        end
        % WIND DATA
        if isfield(mpc,'wind')
            TestCase.(char(zones{i})).Wind = {};
            TestCase.(char(zones{i})).Wind.nwind = size(mpc.wind,1);
            TestCase.(char(zones{i})).Wind.AreaWind = mpc.bus(mpc.wind(:,1),7);
            % incidence matrix
            TestCase.(char(zones{i})).Wind.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{i})).Wind.nwind);
            for j = 1:TestCase.(char(zones{i})).Wind.nwind
                TestCase.(char(zones{i})).Wind.IncidenceMatrix(TestCase.(char(zones{i})).Wind.AreaWind(j),j) = 1;
            end
            clear j;
            % coefficient incidence matrix
            TestCase.(char(zones{i})).Wind.CoefficientIncidenceMatrix = TestCase.(char(zones{i})).Wind.IncidenceMatrix';
            % maximum production
            TestCase.(char(zones{i})).Wind.Pmax = mpc.wind(:,2)./TestCase.(char(zones{i})).Sb;
            % wind coefficients
            TestCase.(char(zones{i})).Wind.Coefficients = TimeSeriesParameters.(char(zones{i})).Wind;
        end
        
        % SOLAR DATA
        if isfield(mpc,'solar')
            TestCase.(char(zones{i})).Solar = {};
            TestCase.(char(zones{i})).Solar.nsolar = size(mpc.solar,1);
            TestCase.(char(zones{i})).Solar.AreaSolar = mpc.bus(mpc.solar(:,1),7);
            % incidence matrix
            TestCase.(char(zones{i})).Solar.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{i})).Solar.nsolar);
            for j = 1:TestCase.(char(zones{i})).Solar.nsolar
                TestCase.(char(zones{i})).Solar.IncidenceMatrix(TestCase.(char(zones{i})).Solar.AreaSolar(j),j) = 1;
            end
            clear j;
            % coefficient incidence matrix
            TestCase.(char(zones{i})).Solar.CoefficientIncidenceMatrix = TestCase.(char(zones{i})).Solar.IncidenceMatrix';
            % maximum production
            TestCase.(char(zones{i})).Solar.Pmax = mpc.solar(:,2)./TestCase.(char(zones{i})).Sb;
            % solar coefficients
            TestCase.(char(zones{i})).Solar.Coefficients = TimeSeriesParameters.(char(zones{i})).Solar;
        end
        
        % LOAD DATA
        if isfield(mpc,'load')
            TestCase.(char(zones{i})).Load = {};
            TestCase.(char(zones{i})).Load.nload = size(mpc.load,1);
            TestCase.(char(zones{i})).Load.AreaLoad = mpc.bus(mpc.load(:,1),7);
            % incidence matrix
            TestCase.(char(zones{i})).Load.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{i})).Load.nload);
            for j = 1:TestCase.(char(zones{i})).Load.nload
                TestCase.(char(zones{i})).Load.IncidenceMatrix(TestCase.(char(zones{i})).Load.AreaLoad(j),j) = 1;
            end
            clear j;
            % coefficient incidence matrix
            if isfield(mpc,'interHVDC')
                BUSLOAD = mpc.load(:,1);
                BUSINCIDENCE = zeros(size(mpc.bus,1),TestCase.(char(zones{i})).Load.nload);
                for j = 1:TestCase.(char(zones{i})).Load.nload
                    BUSINCIDENCE(BUSLOAD(j),j) = 1;
                end
                clear j;
                TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix = BUSINCIDENCE';
                clear BUSLOAD BUSINCIDENCE;
            else
                TestCase.(char(zones{i})).Load.CoefficientIncidenceMatrix = TestCase.(char(zones{i})).Load.IncidenceMatrix';
            end
            % maximum consumption
            TestCase.(char(zones{i})).Load.Pmax = mpc.load(:,2)./TestCase.(char(zones{i})).Sb;
            % tan_phi
            TestCase.(char(zones{i})).Load.TanPhi = mpc.load(:,3);
            % load coefficients
            TestCase.(char(zones{i})).Load.Coefficients = TimeSeriesParameters.(char(zones{i})).Load;
        end
        
        % NETWORK DATA
        % AC System
        if isfield(mpc,'branch')
            TestCase.(char(zones{i})).Network.ACsystem = {};
            nlineAC = size(mpc.branch,1);
            for j = 1:nlineAC
                mpc.branch(j,1) = mpc.bus(mpc.branch(j,1),7);
                mpc.branch(j,2) = mpc.bus(mpc.branch(j,2),7);
            end
            clear j;
            BRANCH = [];
            for j = 1:nlineAC
                if mpc.branch(j,1) == mpc.branch(j,2)
                else
                    BRANCH = [BRANCH; mpc.branch(j,:)];
                end
            end
            clear j;
            BRANCH_NEW = [];
            for j = 1:TestCase.(char(zones{i})).Area.narea
                for k = 1:TestCase.(char(zones{i})).Area.narea
                    INT = BRANCH(BRANCH(:,1) == j & BRANCH(:,2) == k,:);
                    if isempty(INT)
                    else
                        R = 0; X = 0; B = 0;
                        for r = 1:size(INT,1)
                            if INT(r,3) == 0
                                INT(r,3) = 0.00001;
                                R = R + 1/INT(r,3);
                            else
                                R = R + 1/INT(r,3);
                            end
                            X = X + 1/INT(r,4);
                            B = B + INT(r,5);
                        end
                        clear r;
                        BRANCH_NEW = [BRANCH_NEW; j k 1/R 1/X B sum(INT(:,6)) sum(INT(:,7)) sum(INT(:,8)) 1 0 1 -360 360];
                    end
                    clear R X B INT;
                end
                clear k;
            end
            clear j;
            mpc.branch = BRANCH_NEW;
            clear BRANCH BRANCH_NEW;
            
            TestCase.(char(zones{i})).Network.ACsystem.nlineAC = size(mpc.branch,1);
            TestCase.(char(zones{i})).Network.ACsystem.From = mpc.branch(:,1);
            TestCase.(char(zones{i})).Network.ACsystem.To = mpc.branch(:,2);
            % Resistances
            TestCase.(char(zones{i})).Network.ACsystem.R = mpc.branch(:,3);
            % PTDF matrix
            TestCase.(char(zones{i})).Network.ACsystem.PTDF = PTDF.(char(zones{i}));
            % AC line incidence matrix
            TestCase.(char(zones{i})).Network.ACsystem.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{i})).Network.ACsystem.nlineAC);
            for j = 1:TestCase.(char(zones{i})).Network.ACsystem.nlineAC
                TestCase.(char(zones{i})).Network.ACsystem.IncidenceMatrix(TestCase.(char(zones{i})).Network.ACsystem.From(j),j) = 1;
                TestCase.(char(zones{i})).Network.ACsystem.IncidenceMatrix(TestCase.(char(zones{i})).Network.ACsystem.To(j),j) = -1;
            end
            clear j;
            % Line capacities
            if strcmp(Options.marketclearing,'zonal_PTDF')
                TestCase.(char(zones{i})).Network.ACsystem.Capacities = {};
                for j = 1:8761
                    TestCase.(char(zones{i})).Network.ACsystem.Capacities.Upper(:,j) = mpc.branch(:,6)/TestCase.(char(zones{i})).Sb;
                    TestCase.(char(zones{i})).Network.ACsystem.Capacities.Lower(:,j) = -mpc.branch(:,6)/TestCase.(char(zones{i})).Sb;
                end
                clear j;
            elseif strcmp(Options.marketclearing,'zonal_ATC')
                TestCase.(char(zones{i})).Network.ACsystem.Capacities = {};
                TestCase.(char(zones{i})).Network.ACsystem.Capacities.Upper = Capacities.(char(zones{i})).AC.Upper./TestCase.(char(zones{i})).Sb;
                TestCase.(char(zones{i})).Network.ACsystem.Capacities.Lower = -Capacities.(char(zones{i})).AC.Lower./TestCase.(char(zones{i})).Sb;
            end
        end
        
        % Internal HVDC lines
        if isfield(mpc,'branchHVDC')
            TestCase.(char(zones{i})).Network.HVDCinternal = {};
            TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC = size(mpc.branchHVDC,1);
            TestCase.(char(zones{i})).Network.HVDCinternal.From = mpc.bus(mpc.branchHVDC(:,1),7);
            TestCase.(char(zones{i})).Network.HVDCinternal.To = mpc.bus(mpc.branchHVDC(:,2),7);
            TestCase.(char(zones{i})).Network.HVDCinternal.A = mpc.branchHVDC(:,4).*TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Network.HVDCinternal.B = mpc.branchHVDC(:,5);
            TestCase.(char(zones{i})).Network.HVDCinternal.C = mpc.branchHVDC(:,6)./TestCase.(char(zones{i})).Sb;
            
            % Line capacities
            TestCase.(char(zones{i})).Network.HVDCinternal.Capacities = {};
            TestCase.(char(zones{i})).Network.HVDCinternal.Capacities.Upper = Capacities.(char(zones{i})).HVDC.Upper./TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Network.HVDCinternal.Capacities.Lower = -Capacities.(char(zones{i})).HVDC.Lower./TestCase.(char(zones{i})).Sb;
            % HVDC line incidence matrix
            TestCase.(char(zones{i})).Network.HVDCinternal.IncidenceMatrix = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC);
            for j = 1:TestCase.(char(zones{i})).Network.HVDCinternal.nlineHVDC
                TestCase.(char(zones{i})).Network.HVDCinternal.IncidenceMatrix(TestCase.(char(zones{i})).Network.HVDCinternal.From(j),j) = 1;
                TestCase.(char(zones{i})).Network.HVDCinternal.IncidenceMatrix(TestCase.(char(zones{i})).Network.HVDCinternal.To(j),j) = -1;
            end
            clear j;
        end
        
        % External HVDC interconnectors
        if isfield(mpc,'interHVDC')
            TestCase.(char(zones{i})).Network.HVDCinterconnectors = {};
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.nintHVDC = size(mpc.interHVDC,1);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zfrom = mpc.interHVDC(:,1);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zto = mpc.interHVDC(:,3);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.From = [];
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.To = [];
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.A = mpc.interHVDC(:,6).*TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.B = mpc.interHVDC(:,7);
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.C = mpc.interHVDC(:,8)./TestCase.(char(zones{i})).Sb;

            for k = 1:TestCase.(char(zones{i})).Network.HVDCinterconnectors.nintHVDC
                mpc_TEMP = evalin('base',strcat('mpc_',char(zones{TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zfrom(k)})));
                TestCase.(char(zones{i})).Network.HVDCinterconnectors.From = [
                    TestCase.(char(zones{i})).Network.HVDCinterconnectors.From; mpc_TEMP.bus(mpc.interHVDC(k,2),7)];
                clear mpc_TEMP;
                mpc_TEMP = evalin('base',strcat('mpc_',char(zones{TestCase.(char(zones{i})).Network.HVDCinterconnectors.Zto(k)})));
                TestCase.(char(zones{i})).Network.HVDCinterconnectors.To = [
                    TestCase.(char(zones{i})).Network.HVDCinterconnectors.To; mpc_TEMP.bus(mpc.interHVDC(k,4),7)];
                clear mpc_TEMP;
            end
            clear k;
            % Line capacities
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.Capacities = {};
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.Capacities.Upper = Capacities.(char(zones{i})).HVDC.Upper./TestCase.(char(zones{i})).Sb;
            TestCase.(char(zones{i})).Network.HVDCinterconnectors.Capacities.Lower = -Capacities.(char(zones{i})).HVDC.Lower./TestCase.(char(zones{i})).Sb;
        end
    end
end
clear i;

% Calculate the incidence matrices for HVDC interconnectors
if strcmp(Options.optimization,'EconomicDispatch') || strcmp(Options.optimization,'DC_OPF') && strcmp(Options.marketclearing,'nodal')
    for i = 1:size(zones,2)
        TestCase.(char(zones{i})).HVDCinterconnectors = {};
        for j = 1:size(zones,2)
            if isfield(TestCase.(char(zones{j})).Network,'HVDCinterconnectors')
                TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j}))) = zeros(TestCase.(char(zones{i})).Bus.nbus,TestCase.(char(zones{j})).Network.HVDCinterconnectors.nintHVDC);
                for k = 1:TestCase.(char(zones{j})).Network.HVDCinterconnectors.nintHVDC
                    if TestCase.(char(zones{j})).Network.HVDCinterconnectors.Zfrom(k) == i
                        TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j})))(TestCase.(char(zones{j})).Network.HVDCinterconnectors.From(k),k) = 1;
                    elseif TestCase.(char(zones{j})).Network.HVDCinterconnectors.Zto(k) == i
                        TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j})))(TestCase.(char(zones{j})).Network.HVDCinterconnectors.To(k),k) = -1;
                    end
                end
                clear k;
            end
        end
        clear j;
    end
    clear i;
elseif strcmp(Options.optimization,'DC_OPF') && strcmp(Options.marketclearing,'zonal_PTDF') || strcmp(Options.marketclearing,'zonal_ATC')
    for i = 1:size(zones,2)
        TestCase.(char(zones{i})).HVDCinterconnectors = {};
        for j = 1:size(zones,2)
            if isfield(TestCase.(char(zones{j})).Network,'HVDCinterconnectors')
                TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j}))) = zeros(TestCase.(char(zones{i})).Area.narea,TestCase.(char(zones{j})).Network.HVDCinterconnectors.nintHVDC);
                for k = 1:TestCase.(char(zones{j})).Network.HVDCinterconnectors.nintHVDC
                    if TestCase.(char(zones{j})).Network.HVDCinterconnectors.Zfrom(k) == i
                        TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j})))(TestCase.(char(zones{j})).Network.HVDCinterconnectors.From(k),k) = 1;
                    elseif TestCase.(char(zones{j})).Network.HVDCinterconnectors.Zto(k) == i
                        TestCase.(char(zones{i})).HVDCinterconnectors.(strcat('IncidenceMatrix_',char(zones{j})))(TestCase.(char(zones{j})).Network.HVDCinterconnectors.To(k),k) = -1;
                    end
                end
                clear k;
            end
        end
        clear j;
    end
    clear i;
end

clear TimeSeriesParameters;
if strcmp(Options.optimization,'DC_OPF') && strcmp(Options.marketclearing,'zonal_PTDF')
    clear PTDF Capacities;
end

end

