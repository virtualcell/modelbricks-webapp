function [T,Y,yinit,param, allNames, allValues] = CM_PM25628036_MB1__GEF_activation(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM25628036_MB1__GEF_activation(argTimeSpan,argYinit,argParam)
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
numVars = 7;
allNames = {'Active_GEF';'Activator';'K_GEF_total';'GEF';'J_GEF_activation';'J_GEF_inactivation';'J_Activator_degradation';};

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
	0.0;		% yinit(1) is the initial condition for 'Active_GEF'
	1.0;		% yinit(2) is the initial condition for 'Activator'
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
	300.0;		% param(1) is 'mlabfix_T_'
	1.0;		% param(2) is 'Activator_init_umol_l_1'
	3.141592653589793;		% param(3) is 'mlabfix_PI_'
	9.64853321E-5;		% param(4) is 'mlabfix_F_nmol_'
	1.0;		% param(5) is 'Size_default'
	0.5;		% param(6) is 'k3'
	0.1;		% param(7) is 'k2'
	96485.3321;		% param(8) is 'mlabfix_F_'
	24.5;		% param(9) is 'KmGEFRho'
	1.0;		% param(10) is 'k1'
	0.0;		% param(11) is 'Active_GEF_init_umol_l_1'
	8314.46261815;		% param(12) is 'mlabfix_R_'
	6.02214179E11;		% param(13) is 'mlabfix_N_pmol_'
	5.64;		% param(14) is 'kcatGEF'
	0.31;		% param(15) is 'GEF_init_umol_l_1'
	0.001660538783162726;		% param(16) is 'KMOLE'
	1.0;		% param(17) is 'KmGEFGDI'
	1.0E-9;		% param(18) is 'mlabfix_K_GHK_'
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
	Active_GEF = y(1);
	Activator = y(2);
	% Constants
	mlabfix_T_ = p(1);
	Activator_init_umol_l_1 = p(2);
	mlabfix_PI_ = p(3);
	mlabfix_F_nmol_ = p(4);
	Size_default = p(5);
	k3 = p(6);
	k2 = p(7);
	mlabfix_F_ = p(8);
	KmGEFRho = p(9);
	k1 = p(10);
	Active_GEF_init_umol_l_1 = p(11);
	mlabfix_R_ = p(12);
	mlabfix_N_pmol_ = p(13);
	kcatGEF = p(14);
	GEF_init_umol_l_1 = p(15);
	KMOLE = p(16);
	KmGEFGDI = p(17);
	mlabfix_K_GHK_ = p(18);
	K_millivolts_per_volt = p(19);
	% Functions
	K_GEF_total = ((Size_default .* GEF_init_umol_l_1) + (Size_default .* Active_GEF_init_umol_l_1));
	GEF = ((K_GEF_total - (Size_default .* Active_GEF)) ./ Size_default);
	J_GEF_activation = (Activator .* GEF .* k1);
	J_GEF_inactivation = (Active_GEF .* k2);
	J_Activator_degradation = (Activator .* k3);
	% OutputFunctions

	rowValue = [Active_GEF Activator K_GEF_total GEF J_GEF_activation J_GEF_inactivation J_Activator_degradation ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	Active_GEF = y(1);
	Activator = y(2);
	% Constants
	mlabfix_T_ = p(1);
	Activator_init_umol_l_1 = p(2);
	mlabfix_PI_ = p(3);
	mlabfix_F_nmol_ = p(4);
	Size_default = p(5);
	k3 = p(6);
	k2 = p(7);
	mlabfix_F_ = p(8);
	KmGEFRho = p(9);
	k1 = p(10);
	Active_GEF_init_umol_l_1 = p(11);
	mlabfix_R_ = p(12);
	mlabfix_N_pmol_ = p(13);
	kcatGEF = p(14);
	GEF_init_umol_l_1 = p(15);
	KMOLE = p(16);
	KmGEFGDI = p(17);
	mlabfix_K_GHK_ = p(18);
	K_millivolts_per_volt = p(19);
	% Functions
	K_GEF_total = ((Size_default .* GEF_init_umol_l_1) + (Size_default .* Active_GEF_init_umol_l_1));
	GEF = ((K_GEF_total - (Size_default .* Active_GEF)) ./ Size_default);
	J_GEF_activation = (Activator .* GEF .* k1);
	J_GEF_inactivation = (Active_GEF .* k2);
	J_Activator_degradation = (Activator .* k3);
	% Rates
	dydt = [
		(J_GEF_activation - J_GEF_inactivation);    % rate for Active_GEF
		 - J_Activator_degradation;    % rate for Activator
	];
end
