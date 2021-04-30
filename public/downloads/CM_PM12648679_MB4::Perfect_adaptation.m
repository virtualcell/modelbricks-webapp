function [T,Y,yinit,param, allNames, allValues] = CM_PM12648679_MB4__Perfect_adaptation(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM12648679_MB4__Perfect_adaptation(argTimeSpan,argYinit,argParam)
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
numVars = 9;
allNames = {'X';'S';'R';'J_X_synthesis';'J_R_degradation';'Kf';'J_X_degradation';'J_R_synthesis';'event0.triggerFunction';};

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
	1.0;		% yinit(2) is the initial condition for 'S'
	0.0;		% yinit(3) is the initial condition for 'R'
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
	96485.3321;		% param(1) is 'mlabfix_F_'
	9.64853321E-5;		% param(2) is 'mlabfix_F_nmol_'
	8314.46261815;		% param(3) is 'mlabfix_R_'
	1.0E-9;		% param(4) is 'mlabfix_K_GHK_'
	0.0;		% param(5) is 'R_init_uM'
	0.0;		% param(6) is 'Kr'
	0.0;		% param(7) is 'event0.delay'
	0.001660538783162726;		% param(8) is 'KMOLE'
	1.0;		% param(9) is 'k4'
	1.0;		% param(10) is 'k3'
	16.0;		% param(11) is 'event0.t3'
	2.0;		% param(12) is 'k2'
	12.0;		% param(13) is 'event0.t2'
	2.0;		% param(14) is 'k1'
	8.0;		% param(15) is 'event0.t1'
	4.0;		% param(16) is 'event0.t0'
	300.0;		% param(17) is 'mlabfix_T_'
	6.02214179E11;		% param(18) is 'mlabfix_N_pmol_'
	50000.0;		% param(19) is 'Size_c0'
	1.0;		% param(20) is 'S_init_uM'
	1000.0;		% param(21) is 'K_millivolts_per_volt'
	0.0;		% param(22) is 'X_init_uM'
	3.141592653589793;		% param(23) is 'mlabfix_PI_'
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
	S = y(2);
	R = y(3);
	% Constants
	mlabfix_F_ = p(1);
	mlabfix_F_nmol_ = p(2);
	mlabfix_R_ = p(3);
	mlabfix_K_GHK_ = p(4);
	R_init_uM = p(5);
	Kr = p(6);
	event0.delay = p(7);
	KMOLE = p(8);
	k4 = p(9);
	k3 = p(10);
	event0.t3 = p(11);
	k2 = p(12);
	event0.t2 = p(13);
	k1 = p(14);
	event0.t1 = p(15);
	event0.t0 = p(16);
	mlabfix_T_ = p(17);
	mlabfix_N_pmol_ = p(18);
	Size_c0 = p(19);
	S_init_uM = p(20);
	K_millivolts_per_volt = p(21);
	X_init_uM = p(22);
	mlabfix_PI_ = p(23);
	% Functions
	J_X_synthesis = (k3 .* S);
	J_R_degradation = (k2 .* X .* R);
	Kf = k4;
	J_X_degradation = (Kf .* X);
	J_R_synthesis = (k1 .* S);
	event0.triggerFunction = (((t >= event0.t0) && (t <= (event0.t0 + 2.0))) || ((t >= event0.t1) && (t <= (event0.t1 + 2.0))) || ((t >= event0.t2) && (t <= (event0.t2 + 2.0))) || ((t >= event0.t3) && (t <= (event0.t3 + 2.0))));
	% OutputFunctions

	rowValue = [X S R J_X_synthesis J_R_degradation Kf J_X_degradation J_R_synthesis event0.triggerFunction ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	X = y(1);
	S = y(2);
	R = y(3);
	% Constants
	mlabfix_F_ = p(1);
	mlabfix_F_nmol_ = p(2);
	mlabfix_R_ = p(3);
	mlabfix_K_GHK_ = p(4);
	R_init_uM = p(5);
	Kr = p(6);
	event0.delay = p(7);
	KMOLE = p(8);
	k4 = p(9);
	k3 = p(10);
	event0.t3 = p(11);
	k2 = p(12);
	event0.t2 = p(13);
	k1 = p(14);
	event0.t1 = p(15);
	event0.t0 = p(16);
	mlabfix_T_ = p(17);
	mlabfix_N_pmol_ = p(18);
	Size_c0 = p(19);
	S_init_uM = p(20);
	K_millivolts_per_volt = p(21);
	X_init_uM = p(22);
	mlabfix_PI_ = p(23);
	% Functions
	J_X_synthesis = (k3 .* S);
	J_R_degradation = (k2 .* X .* R);
	Kf = k4;
	J_X_degradation = (Kf .* X);
	J_R_synthesis = (k1 .* S);
	event0.triggerFunction = (((t >= event0.t0) && (t <= (event0.t0 + 2.0))) || ((t >= event0.t1) && (t <= (event0.t1 + 2.0))) || ((t >= event0.t2) && (t <= (event0.t2 + 2.0))) || ((t >= event0.t3) && (t <= (event0.t3 + 2.0))));
	% Rates
	dydt = [
		( - J_X_degradation + J_X_synthesis);    % rate for X
		0.0;    % rate for S
		(J_R_synthesis - J_R_degradation);    % rate for R
	];
end
