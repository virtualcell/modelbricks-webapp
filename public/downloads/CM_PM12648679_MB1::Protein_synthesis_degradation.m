function [T,Y,yinit,param, allNames, allValues] = CM_PM12648679_MB1__Protein_synthesis_degradation(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM12648679_MB1__Protein_synthesis_degradation(argTimeSpan,argYinit,argParam)
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
allNames = {'R';'Kf';'J_R_degradation';'S_init_uM';'K_S_total';'S';'J_R_synthesis';};

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
	50000.0;		% param(1) is 'Size_c0'
	0.0;		% param(2) is 'Kr'
	300.0;		% param(3) is 'mlabfix_T_'
	3.141592653589793;		% param(4) is 'mlabfix_PI_'
	9.64853321E-5;		% param(5) is 'mlabfix_F_nmol_'
	5.0;		% param(6) is 'kd'
	96485.3321;		% param(7) is 'mlabfix_F_'
	0.0;		% param(8) is 'R_init_uM'
	8314.46261815;		% param(9) is 'mlabfix_R_'
	6.02214179E11;		% param(10) is 'mlabfix_N_pmol_'
	1.0;		% param(11) is 'k'
	0.001660538783162726;		% param(12) is 'KMOLE'
	1.0E-9;		% param(13) is 'mlabfix_K_GHK_'
	1000.0;		% param(14) is 'K_millivolts_per_volt'
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
	Size_c0 = p(1);
	Kr = p(2);
	mlabfix_T_ = p(3);
	mlabfix_PI_ = p(4);
	mlabfix_F_nmol_ = p(5);
	kd = p(6);
	mlabfix_F_ = p(7);
	R_init_uM = p(8);
	mlabfix_R_ = p(9);
	mlabfix_N_pmol_ = p(10);
	k = p(11);
	KMOLE = p(12);
	mlabfix_K_GHK_ = p(13);
	K_millivolts_per_volt = p(14);
	% Functions
	Kf = kd;
	J_R_degradation = (Kf .* R);
	S_init_uM = t;
	K_S_total = (Size_c0 .* S_init_uM);
	S = (K_S_total ./ Size_c0);
	J_R_synthesis = (k .* S);
	% OutputFunctions

	rowValue = [R Kf J_R_degradation S_init_uM K_S_total S J_R_synthesis ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	R = y(1);
	% Constants
	Size_c0 = p(1);
	Kr = p(2);
	mlabfix_T_ = p(3);
	mlabfix_PI_ = p(4);
	mlabfix_F_nmol_ = p(5);
	kd = p(6);
	mlabfix_F_ = p(7);
	R_init_uM = p(8);
	mlabfix_R_ = p(9);
	mlabfix_N_pmol_ = p(10);
	k = p(11);
	KMOLE = p(12);
	mlabfix_K_GHK_ = p(13);
	K_millivolts_per_volt = p(14);
	% Functions
	Kf = kd;
	J_R_degradation = (Kf .* R);
	S_init_uM = t;
	K_S_total = (Size_c0 .* S_init_uM);
	S = (K_S_total ./ Size_c0);
	J_R_synthesis = (k .* S);
	% Rates
	dydt = [
		( - J_R_degradation + J_R_synthesis);    % rate for R
	];
end
