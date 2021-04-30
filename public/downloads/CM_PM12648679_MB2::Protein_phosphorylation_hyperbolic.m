function [T,Y,yinit,param, allNames, allValues] = CM_PM12648679_MB2__Protein_phosphorylation_hyperbolic(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM12648679_MB2__Protein_phosphorylation_hyperbolic(argTimeSpan,argYinit,argParam)
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
numVars = 8;
allNames = {'RP';'S_init_uM';'K_S_total';'S';'K_R_total';'R';'J_R_phosphorylation';'J_R_dephosphorylation';};

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
	0.0;		% yinit(1) is the initial condition for 'RP'
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
	1.0;		% param(6) is 'kf'
	1.0;		% param(7) is 'Kf'
	96485.3321;		% param(8) is 'mlabfix_F_'
	1.0;		% param(9) is 'R_init_uM'
	8314.46261815;		% param(10) is 'mlabfix_R_'
	0.0;		% param(11) is 'RP_init_uM'
	6.02214179E11;		% param(12) is 'mlabfix_N_pmol_'
	0.001660538783162726;		% param(13) is 'KMOLE'
	1.0E-9;		% param(14) is 'mlabfix_K_GHK_'
	1000.0;		% param(15) is 'K_millivolts_per_volt'
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
	RP = y(1);
	% Constants
	Size_c0 = p(1);
	Kr = p(2);
	mlabfix_T_ = p(3);
	mlabfix_PI_ = p(4);
	mlabfix_F_nmol_ = p(5);
	kf = p(6);
	Kf = p(7);
	mlabfix_F_ = p(8);
	R_init_uM = p(9);
	mlabfix_R_ = p(10);
	RP_init_uM = p(11);
	mlabfix_N_pmol_ = p(12);
	KMOLE = p(13);
	mlabfix_K_GHK_ = p(14);
	K_millivolts_per_volt = p(15);
	% Functions
	S_init_uM = t;
	K_S_total = (Size_c0 .* S_init_uM);
	S = (K_S_total ./ Size_c0);
	K_R_total = ((Size_c0 .* R_init_uM) + (Size_c0 .* RP_init_uM));
	R = ((K_R_total - (Size_c0 .* RP)) ./ Size_c0);
	J_R_phosphorylation = (kf .* R .* S);
	J_R_dephosphorylation = ((Kf .* RP) - (Kr .* R));
	% OutputFunctions

	rowValue = [RP S_init_uM K_S_total S K_R_total R J_R_phosphorylation J_R_dephosphorylation ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	RP = y(1);
	% Constants
	Size_c0 = p(1);
	Kr = p(2);
	mlabfix_T_ = p(3);
	mlabfix_PI_ = p(4);
	mlabfix_F_nmol_ = p(5);
	kf = p(6);
	Kf = p(7);
	mlabfix_F_ = p(8);
	R_init_uM = p(9);
	mlabfix_R_ = p(10);
	RP_init_uM = p(11);
	mlabfix_N_pmol_ = p(12);
	KMOLE = p(13);
	mlabfix_K_GHK_ = p(14);
	K_millivolts_per_volt = p(15);
	% Functions
	S_init_uM = t;
	K_S_total = (Size_c0 .* S_init_uM);
	S = (K_S_total ./ Size_c0);
	K_R_total = ((Size_c0 .* R_init_uM) + (Size_c0 .* RP_init_uM));
	R = ((K_R_total - (Size_c0 .* RP)) ./ Size_c0);
	J_R_phosphorylation = (kf .* R .* S);
	J_R_dephosphorylation = ((Kf .* RP) - (Kr .* R));
	% Rates
	dydt = [
		(J_R_phosphorylation - J_R_dephosphorylation);    % rate for RP
	];
end
