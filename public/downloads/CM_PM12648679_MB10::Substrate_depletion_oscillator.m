function [T,Y,yinit,param, allNames, allValues] = CM_PM12648679_MB10__Substrate_depletion_oscillator(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM12648679_MB10__Substrate_depletion_oscillator(argTimeSpan,argYinit,argParam)
%
% input:
%     argTimeSpan is a vector of start and stop times (e.g. timeSpan = [0 10.0])
%     argYinit is a vector of initial conditions for the state variables (optional)
%     argParam is a vector of values for the parameters (optional)
%
% output:
%     T is the vector of times
%     Y is the vector of state variables
%     yinit is the initial conditions that were used
%     param is the parameter vector that was used
%     allNames is the output solution variable names
%     allValues is the output solution variable values corresponding to the names
%
%     example of running this file: [T,Y,yinit,param,allNames,allValues] = myMatlabFunc; <-(your main function name)
%

%
% Default time span
%
timeSpan = [0.0 1.0];

% output variable lengh and names
numVars = 14;
allNames = {'X';'R';'S';'J_X_synthesis';'J_R_degradation';'Ep';'J_X_conversion_to_R';'Km4';'Km3';'E';'J_E_phosphorylation';'Ep_init_mol_litre_1';'E_init_mol_litre_1';'J_E_dephosphorylation';};

if nargin >= 1
	if length(argTimeSpan) > 0
		%
		% TimeSpan overridden by function arguments
		%
		timeSpan = argTimeSpan;
	end
end
%
% Default Initial Conditions
%
yinit = [
	0.0;		% yinit(1) is the initial condition for 'X'
	0.0;		% yinit(2) is the initial condition for 'R'
];
if nargin >= 2
	if length(argYinit) > 0
		%
		% initial conditions overridden by function arguments
		%
		yinit = argYinit;
	end
end
%
% Default Parameters
%   constants are only those "Constants" from the Math Description that are just floating point numbers (no identifiers)
%   note: constants of the form "A_init" are really initial conditions and are treated in "yinit"
%
param = [
	0.0;		% param(1) is 'X_init_mol_litre_1'
	96485.3321;		% param(2) is 'mlabfix_F_'
	9.64853321E-5;		% param(3) is 'mlabfix_F_nmol_'
	8314.46261815;		% param(4) is 'mlabfix_R_'
	1.0;		% param(5) is 'Size_env'
	1.0;		% param(6) is 'Et'
	1.0E-9;		% param(7) is 'mlabfix_K_GHK_'
	0.05;		% param(8) is 'J4'
	0.05;		% param(9) is 'J3'
	0.001660538783162726;		% param(10) is 'KMOLE'
	0.0;		% param(11) is 'R_init_mol_litre_1'
	0.3;		% param(12) is 'k4'
	1.0;		% param(13) is 'k3'
	1.0;		% param(14) is 'k2'
	1.0;		% param(15) is 'k1'
	0.4;		% param(16) is 'k0'
	300.0;		% param(17) is 'mlabfix_T_'
	6.02214179E11;		% param(18) is 'mlabfix_N_pmol_'
	1000.0;		% param(19) is 'K_millivolts_per_volt'
	0.01;		% param(20) is 'k0_prime'
	0.0;		% param(21) is 'S_init_mol_litre_1'
	3.141592653589793;		% param(22) is 'mlabfix_PI_'
];
if nargin >= 3
	if length(argParam) > 0
		%
		% parameter values overridden by function arguments
		%
		param = argParam;
	end
end
%
% invoke the integrator
%
[T,Y] = ode15s(@f,timeSpan,yinit,odeset('OutputFcn',@odeplot),param,yinit);

% get the solution
all = zeros(length(T), numVars);
for i = 1:length(T)
	all(i,:) = getRow(T(i), Y(i,:), yinit, param);
end

allValues = all;
end

% -------------------------------------------------------
% get row data
function rowValue = getRow(t,y,y0,p)
	% State Variables
	X = y(1);
	R = y(2);
	% Constants
	X_init_mol_litre_1 = p(1);
	mlabfix_F_ = p(2);
	mlabfix_F_nmol_ = p(3);
	mlabfix_R_ = p(4);
	Size_env = p(5);
	Et = p(6);
	mlabfix_K_GHK_ = p(7);
	J4 = p(8);
	J3 = p(9);
	KMOLE = p(10);
	R_init_mol_litre_1 = p(11);
	k4 = p(12);
	k3 = p(13);
	k2 = p(14);
	k1 = p(15);
	k0 = p(16);
	mlabfix_T_ = p(17);
	mlabfix_N_pmol_ = p(18);
	K_millivolts_per_volt = p(19);
	k0_prime = p(20);
	S_init_mol_litre_1 = p(21);
	mlabfix_PI_ = p(22);
	% Functions
	S = S_init_mol_litre_1;
	J_X_synthesis = (k1 .* S);
	J_R_degradation = (k2 .* R);
	Ep = (((2.0 .* (k3 .* R) .* J4) ./ ((k4 - (k3 .* R)) + (J3 .* k4) + (J4 .* (k3 .* R)) + (((((k4 - (k3 .* R)) + (J3 .* k4) + (J4 .* (k3 .* R))) ^ 2.0) - (4.0 .* (k4 - (k3 .* R)) .* (k3 .* R) .* J4)) ^ (1.0 ./ 2.0)))) .* Et);
	J_X_conversion_to_R = ((k0_prime + (k0 .* Ep)) .* X);
	Km4 = (J4 .* Et);
	Km3 = (J3 .* Et);
	E = (Et - Ep);
	J_E_phosphorylation = (k3 .* R .* E ./ (Km3 + E));
	Ep_init_mol_litre_1 = (((2.0 .* (k3 .* R_init_mol_litre_1) .* J4) ./ ((k4 - (k3 .* R_init_mol_litre_1)) + (J3 .* k4) + (J4 .* (k3 .* R_init_mol_litre_1)) + (((((k4 - (k3 .* R_init_mol_litre_1)) + (J3 .* k4) + (J4 .* (k3 .* R_init_mol_litre_1))) ^ 2.0) - (4.0 .* (k4 - (k3 .* R_init_mol_litre_1)) .* (k3 .* R_init_mol_litre_1) .* J4)) ^ (1.0 ./ 2.0)))) .* Et);
	E_init_mol_litre_1 = (Et - Ep_init_mol_litre_1);
	J_E_dephosphorylation = (k4 .* Ep ./ (Km4 + Ep));
	% OutputFunctions

	rowValue = [X R S J_X_synthesis J_R_degradation Ep J_X_conversion_to_R Km4 Km3 E J_E_phosphorylation Ep_init_mol_litre_1 E_init_mol_litre_1 J_E_dephosphorylation ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	X = y(1);
	R = y(2);
	% Constants
	X_init_mol_litre_1 = p(1);
	mlabfix_F_ = p(2);
	mlabfix_F_nmol_ = p(3);
	mlabfix_R_ = p(4);
	Size_env = p(5);
	Et = p(6);
	mlabfix_K_GHK_ = p(7);
	J4 = p(8);
	J3 = p(9);
	KMOLE = p(10);
	R_init_mol_litre_1 = p(11);
	k4 = p(12);
	k3 = p(13);
	k2 = p(14);
	k1 = p(15);
	k0 = p(16);
	mlabfix_T_ = p(17);
	mlabfix_N_pmol_ = p(18);
	K_millivolts_per_volt = p(19);
	k0_prime = p(20);
	S_init_mol_litre_1 = p(21);
	mlabfix_PI_ = p(22);
	% Functions
	S = S_init_mol_litre_1;
	J_X_synthesis = (k1 .* S);
	J_R_degradation = (k2 .* R);
	Ep = (((2.0 .* (k3 .* R) .* J4) ./ ((k4 - (k3 .* R)) + (J3 .* k4) + (J4 .* (k3 .* R)) + (((((k4 - (k3 .* R)) + (J3 .* k4) + (J4 .* (k3 .* R))) ^ 2.0) - (4.0 .* (k4 - (k3 .* R)) .* (k3 .* R) .* J4)) ^ (1.0 ./ 2.0)))) .* Et);
	J_X_conversion_to_R = ((k0_prime + (k0 .* Ep)) .* X);
	Km4 = (J4 .* Et);
	Km3 = (J3 .* Et);
	E = (Et - Ep);
	J_E_phosphorylation = (k3 .* R .* E ./ (Km3 + E));
	Ep_init_mol_litre_1 = (((2.0 .* (k3 .* R_init_mol_litre_1) .* J4) ./ ((k4 - (k3 .* R_init_mol_litre_1)) + (J3 .* k4) + (J4 .* (k3 .* R_init_mol_litre_1)) + (((((k4 - (k3 .* R_init_mol_litre_1)) + (J3 .* k4) + (J4 .* (k3 .* R_init_mol_litre_1))) ^ 2.0) - (4.0 .* (k4 - (k3 .* R_init_mol_litre_1)) .* (k3 .* R_init_mol_litre_1) .* J4)) ^ (1.0 ./ 2.0)))) .* Et);
	E_init_mol_litre_1 = (Et - Ep_init_mol_litre_1);
	J_E_dephosphorylation = (k4 .* Ep ./ (Km4 + Ep));
	% Rates
	dydt = [
		( - J_X_conversion_to_R + J_X_synthesis);    % rate for X
		(J_X_conversion_to_R - J_R_degradation);    % rate for R
	];
end
