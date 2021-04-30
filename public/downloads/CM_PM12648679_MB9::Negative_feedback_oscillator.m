function [T,Y,yinit,param, allNames, allValues] = CM_PM12648679_MB9__Negative_feedback_oscillator(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM12648679_MB9__Negative_feedback_oscillator(argTimeSpan,argYinit,argParam)
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
allNames = {'Rp';'X';'Yp';'S';'J_X_synthesis';'Y';'R';'J_Y_phosphorylation';'J_X_degradation';'J_R_dephosphorylation';'J_Y_dephosphorylation';'R_init_mol_litre_1';'Y_init_mol_litre_1';'J_R_phosphorylation';};

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
	0.0;		% yinit(1) is the initial condition for 'Rp'
	0.0;		% yinit(2) is the initial condition for 'X'
	0.0;		% yinit(3) is the initial condition for 'Yp'
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
	1.0;		% param(1) is 'Rt'
	0.0;		% param(2) is 'X_init_mol_litre_1'
	96485.3321;		% param(3) is 'mlabfix_F_'
	0.01;		% param(4) is 'Km6'
	0.01;		% param(5) is 'Km5'
	9.64853321E-5;		% param(6) is 'mlabfix_F_nmol_'
	0.01;		% param(7) is 'Km4'
	0.01;		% param(8) is 'Km3'
	8314.46261815;		% param(9) is 'mlabfix_R_'
	1.0;		% param(10) is 'Size_env'
	1.0E-9;		% param(11) is 'mlabfix_K_GHK_'
	0.001660538783162726;		% param(12) is 'KMOLE'
	0.05;		% param(13) is 'k6'
	0.1;		% param(14) is 'k5'
	0.2;		% param(15) is 'k4'
	0.1;		% param(16) is 'k3'
	0.01;		% param(17) is 'k2'
	1.0;		% param(18) is 'k1'
	0.0;		% param(19) is 'k0'
	300.0;		% param(20) is 'mlabfix_T_'
	6.02214179E11;		% param(21) is 'mlabfix_N_pmol_'
	1.0;		% param(22) is 'Yt'
	1000.0;		% param(23) is 'K_millivolts_per_volt'
	10.0;		% param(24) is 'k2_prime'
	0.0;		% param(25) is 'S_init_mol_litre_1'
	0.0;		% param(26) is 'Rp_init_mol_litre_1'
	3.141592653589793;		% param(27) is 'mlabfix_PI_'
	0.0;		% param(28) is 'Yp_init_mol_litre_1'
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
	Rp = y(1);
	X = y(2);
	Yp = y(3);
	% Constants
	Rt = p(1);
	X_init_mol_litre_1 = p(2);
	mlabfix_F_ = p(3);
	Km6 = p(4);
	Km5 = p(5);
	mlabfix_F_nmol_ = p(6);
	Km4 = p(7);
	Km3 = p(8);
	mlabfix_R_ = p(9);
	Size_env = p(10);
	mlabfix_K_GHK_ = p(11);
	KMOLE = p(12);
	k6 = p(13);
	k5 = p(14);
	k4 = p(15);
	k3 = p(16);
	k2 = p(17);
	k1 = p(18);
	k0 = p(19);
	mlabfix_T_ = p(20);
	mlabfix_N_pmol_ = p(21);
	Yt = p(22);
	K_millivolts_per_volt = p(23);
	k2_prime = p(24);
	S_init_mol_litre_1 = p(25);
	Rp_init_mol_litre_1 = p(26);
	mlabfix_PI_ = p(27);
	Yp_init_mol_litre_1 = p(28);
	% Functions
	S = S_init_mol_litre_1;
	J_X_synthesis = (k0 + (k1 .* S));
	Y = (Yt - Yp);
	R = (Rt - Rp);
	J_Y_phosphorylation = (k3 .* X .* (Yt - Yp) ./ (Km3 + Yt - Yp));
	J_X_degradation = ((k2 + (k2_prime .* Rp)) .* X);
	J_R_dephosphorylation = (k6 .* Rp ./ (Km6 + Rp));
	J_Y_dephosphorylation = (k4 .* Yp ./ (Km4 + Yp));
	R_init_mol_litre_1 = (Rt - Rp_init_mol_litre_1);
	Y_init_mol_litre_1 = (Yt - Yp_init_mol_litre_1);
	J_R_phosphorylation = (k5 .* Yp .* (Rt - Rp) ./ (Km5 + Rt - Rp));
	% OutputFunctions

	rowValue = [Rp X Yp S J_X_synthesis Y R J_Y_phosphorylation J_X_degradation J_R_dephosphorylation J_Y_dephosphorylation R_init_mol_litre_1 Y_init_mol_litre_1 J_R_phosphorylation ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	Rp = y(1);
	X = y(2);
	Yp = y(3);
	% Constants
	Rt = p(1);
	X_init_mol_litre_1 = p(2);
	mlabfix_F_ = p(3);
	Km6 = p(4);
	Km5 = p(5);
	mlabfix_F_nmol_ = p(6);
	Km4 = p(7);
	Km3 = p(8);
	mlabfix_R_ = p(9);
	Size_env = p(10);
	mlabfix_K_GHK_ = p(11);
	KMOLE = p(12);
	k6 = p(13);
	k5 = p(14);
	k4 = p(15);
	k3 = p(16);
	k2 = p(17);
	k1 = p(18);
	k0 = p(19);
	mlabfix_T_ = p(20);
	mlabfix_N_pmol_ = p(21);
	Yt = p(22);
	K_millivolts_per_volt = p(23);
	k2_prime = p(24);
	S_init_mol_litre_1 = p(25);
	Rp_init_mol_litre_1 = p(26);
	mlabfix_PI_ = p(27);
	Yp_init_mol_litre_1 = p(28);
	% Functions
	S = S_init_mol_litre_1;
	J_X_synthesis = (k0 + (k1 .* S));
	Y = (Yt - Yp);
	R = (Rt - Rp);
	J_Y_phosphorylation = (k3 .* X .* (Yt - Yp) ./ (Km3 + Yt - Yp));
	J_X_degradation = ((k2 + (k2_prime .* Rp)) .* X);
	J_R_dephosphorylation = (k6 .* Rp ./ (Km6 + Rp));
	J_Y_dephosphorylation = (k4 .* Yp ./ (Km4 + Yp));
	R_init_mol_litre_1 = (Rt - Rp_init_mol_litre_1);
	Y_init_mol_litre_1 = (Yt - Yp_init_mol_litre_1);
	J_R_phosphorylation = (k5 .* Yp .* (Rt - Rp) ./ (Km5 + Rt - Rp));
	% Rates
	dydt = [
		(J_R_phosphorylation - J_R_dephosphorylation);    % rate for Rp
		(J_X_synthesis - J_X_degradation);    % rate for X
		(J_Y_phosphorylation - J_Y_dephosphorylation);    % rate for Yp
	];
end
