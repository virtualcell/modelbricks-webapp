function [T,Y,yinit,param, allNames, allValues] = CM_PM12648679_MB8__Negative_feedback_homeostasis(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM12648679_MB8__Negative_feedback_homeostasis(argTimeSpan,argYinit,argParam)
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
numVars = 12;
allNames = {'R';'S';'J_R_degradation';'E';'Ep';'J_R_synthesis';'Km4';'Km3';'E_init_mol_litre_1';'Ep_init_mol_litre_1';'J_E_phosphorylation';'J_E_dephosphorylation';};

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
	0.0;		% yinit(1) is the initial condition for 'R'
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
	1.0;		% param(1) is 'Et'
	0.01;		% param(2) is 'J4'
	0.01;		% param(3) is 'J3'
	300.0;		% param(4) is 'mlabfix_T_'
	3.141592653589793;		% param(5) is 'mlabfix_PI_'
	9.64853321E-5;		% param(6) is 'mlabfix_F_nmol_'
	1.0;		% param(7) is 'k4'
	0.5;		% param(8) is 'k3'
	1.0;		% param(9) is 'k2'
	96485.3321;		% param(10) is 'mlabfix_F_'
	1.0;		% param(11) is 'k0'
	8314.46261815;		% param(12) is 'mlabfix_R_'
	6.02214179E11;		% param(13) is 'mlabfix_N_pmol_'
	0.0;		% param(14) is 'S_init_mol_litre_1'
	0.001660538783162726;		% param(15) is 'KMOLE'
	0.0;		% param(16) is 'R_init_mol_litre_1'
	1.0E-9;		% param(17) is 'mlabfix_K_GHK_'
	1.0;		% param(18) is 'Size_env'
	1000.0;		% param(19) is 'K_millivolts_per_volt'
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
	R = y(1);
	% Constants
	Et = p(1);
	J4 = p(2);
	J3 = p(3);
	mlabfix_T_ = p(4);
	mlabfix_PI_ = p(5);
	mlabfix_F_nmol_ = p(6);
	k4 = p(7);
	k3 = p(8);
	k2 = p(9);
	mlabfix_F_ = p(10);
	k0 = p(11);
	mlabfix_R_ = p(12);
	mlabfix_N_pmol_ = p(13);
	S_init_mol_litre_1 = p(14);
	KMOLE = p(15);
	R_init_mol_litre_1 = p(16);
	mlabfix_K_GHK_ = p(17);
	Size_env = p(18);
	K_millivolts_per_volt = p(19);
	% Functions
	S = S_init_mol_litre_1;
	J_R_degradation = (k2 .* R .* S);
	E = (Et .* ((2.0 .* k3 .* J4) ./ (((k4 .* R) - k3) + (J3 .* (k4 .* R)) + (J4 .* k3) + ((((((k4 .* R) - k3) + (J3 .* (k4 .* R)) + (J4 .* k3)) ^ 2.0) - (4.0 .* ((k4 .* R) - k3) .* k3 .* J4)) ^ (1.0 ./ 2.0)))));
	Ep = (Et - E);
	J_R_synthesis = (k0 .* E);
	Km4 = (J4 .* Et);
	Km3 = (J3 .* Et);
	E_init_mol_litre_1 = (Et .* ((2.0 .* k3 .* J4) ./ (((k4 .* R_init_mol_litre_1) - k3) + (J3 .* (k4 .* R_init_mol_litre_1)) + (J4 .* k3) + ((((((k4 .* R_init_mol_litre_1) - k3) + (J3 .* (k4 .* R_init_mol_litre_1)) + (J4 .* k3)) ^ 2.0) - (4.0 .* ((k4 .* R_init_mol_litre_1) - k3) .* k3 .* J4)) ^ (1.0 ./ 2.0)))));
	Ep_init_mol_litre_1 = (Et - E_init_mol_litre_1);
	J_E_phosphorylation = (k4 .* R .* E ./ (Km4 + E));
	J_E_dephosphorylation = (k3 .* Ep ./ (Km3 + Ep));
	% OutputFunctions

	rowValue = [R S J_R_degradation E Ep J_R_synthesis Km4 Km3 E_init_mol_litre_1 Ep_init_mol_litre_1 J_E_phosphorylation J_E_dephosphorylation ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	R = y(1);
	% Constants
	Et = p(1);
	J4 = p(2);
	J3 = p(3);
	mlabfix_T_ = p(4);
	mlabfix_PI_ = p(5);
	mlabfix_F_nmol_ = p(6);
	k4 = p(7);
	k3 = p(8);
	k2 = p(9);
	mlabfix_F_ = p(10);
	k0 = p(11);
	mlabfix_R_ = p(12);
	mlabfix_N_pmol_ = p(13);
	S_init_mol_litre_1 = p(14);
	KMOLE = p(15);
	R_init_mol_litre_1 = p(16);
	mlabfix_K_GHK_ = p(17);
	Size_env = p(18);
	K_millivolts_per_volt = p(19);
	% Functions
	S = S_init_mol_litre_1;
	J_R_degradation = (k2 .* R .* S);
	E = (Et .* ((2.0 .* k3 .* J4) ./ (((k4 .* R) - k3) + (J3 .* (k4 .* R)) + (J4 .* k3) + ((((((k4 .* R) - k3) + (J3 .* (k4 .* R)) + (J4 .* k3)) ^ 2.0) - (4.0 .* ((k4 .* R) - k3) .* k3 .* J4)) ^ (1.0 ./ 2.0)))));
	Ep = (Et - E);
	J_R_synthesis = (k0 .* E);
	Km4 = (J4 .* Et);
	Km3 = (J3 .* Et);
	E_init_mol_litre_1 = (Et .* ((2.0 .* k3 .* J4) ./ (((k4 .* R_init_mol_litre_1) - k3) + (J3 .* (k4 .* R_init_mol_litre_1)) + (J4 .* k3) + ((((((k4 .* R_init_mol_litre_1) - k3) + (J3 .* (k4 .* R_init_mol_litre_1)) + (J4 .* k3)) ^ 2.0) - (4.0 .* ((k4 .* R_init_mol_litre_1) - k3) .* k3 .* J4)) ^ (1.0 ./ 2.0)))));
	Ep_init_mol_litre_1 = (Et - E_init_mol_litre_1);
	J_E_phosphorylation = (k4 .* R .* E ./ (Km4 + E));
	J_E_dephosphorylation = (k3 .* Ep ./ (Km3 + Ep));
	% Rates
	dydt = [
		(J_R_synthesis - J_R_degradation);    % rate for R
	];
end
