function mpc = RG_FBMC

% -------------------------------------------------------------------------------------------------------
% Nordic equivalent - RG_UCTE: DK1 & DE (Matpower)
% -------------------------------------------------------------------------------------------------------

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%bus_i type	Pd	   Qd  Gs  Bs area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
    1	1	0	0	0	0	1	1	0	400	3	1.05	0.95	;
    2	1	0	0	0	0	1	1	0	400	3	1.05	0.95	;
    3	1	0	0	0	0	2	1	0	400	3	1.05	0.95	;
    4	1	0	0	0	0	3	1	0	400	3	1.05	0.95	;
    5	1	0	0	0	0	4	1	0	400	3	1.05	0.95	;
    6	1	0	0	0	0	5	1	0	400	3	1.05	0.95	;
];


%% load data
% bus	p_max	tan_phi	base_kv
mpc.load = [
    1	615.00	0.0000	400	;
    2	600.00	0.0000	400	;
    3	723.00	0.0000	400	;
    4	600.00	0.0000	400	;
    5	700.00	0.0000	400	;
    6	1016.00	0.0000	400	;
];




%% branch data
%	fzone fbus tzone tbus	rateA	A B C 
mpc.interHVDC = [
    1	3	2	2	600     0.0000253139565038	0       1.7590045490246900	1	;
    1	2	2	206	720     0.0000347423448933	0       2.1616202583650300	1	;
    1	27	2	146	1632	0.0000167872295098	0       8.2405459992488500	1	;
    2	1	3	2	600     0.0000314910115233	0       1.9659497836577200	1	;
    2	144	3	3	723     0.0000430000000000	0.00618	1.4971000000000000	1	;
    2	212	3	1	615     0.0000408936547320	0       1.6632931584544500	1	;
    2	216	3	4	600     0.0000448338674310	0       1.5906729634002300	1	;
    2	215	3	5	700     0.0000220566706020	0       2.6477685950413200	1	;
    2	221	3	6	1016	0.0000333273381295	0       4.4000000000000000	1	;

];

end

