function [T,Y,yinit,param, allNames, allValues] = CM_PM12648679_MB3__Protein_phosphorylation_sigmoidal(argTimeSpan,argYinit,argParam)
% [T,Y,yinit,param] = CM_PM12648679_MB3__Protein_phosphorylation_sigmoidal(argTimeSpan,argYinit,argParam)
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
allNames = {'PR';'S_init_uM';'K_S_total';'S';'Vmax_protein_phos';'K_R_total';'R';'J_protein_phos';'J_protein_dephos';};

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
	0.0;		% yinit(1) is the initial condition for 'PR'
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
	300.0;		% param(2) is 'mlabfix_T_'
	3.141592653589793;		% param(3) is 'mlabfix_PI_'
	9.64853321E-5;		% param(4) is 'mlabfix_F_nmol_'
	1.0;		% param(5) is 'Vmax_protein_dephos'
	1.0;		% param(6) is 'Km_protein_dephos'
	96485.3321;		% param(7) is 'mlabfix_F_'
	1.0;		% param(8) is 'R_init_uM'
	8314.46261815;		% param(9) is 'mlabfix_R_'
	6.02214179E11;		% param(10) is 'mlabfix_N_pmol_'
	1.0;		% param(11) is 'Km_protein_phos'
	0.0;		% param(12) is 'PR_init_uM'
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
	PR = y(1);
	% Constants
	Size_c0 = p(1);
	mlabfix_T_ = p(2);
	mlabfix_PI_ = p(3);
	mlabfix_F_nmol_ = p(4);
	Vmax_protein_dephos = p(5);
	Km_protein_dephos = p(6);
	mlabfix_F_ = p(7);
	R_init_uM = p(8);
	mlabfix_R_ = p(9);
	mlabfix_N_pmol_ = p(10);
	Km_protein_phos = p(11);
	PR_init_uM = p(12);
	KMOLE = p(13);
	mlabfix_K_GHK_ = p(14);
	K_millivolts_per_volt = p(15);
	% Functions
	S_init_uM = t;
	K_S_total = (Size_c0 .* S_init_uM);
	S = (K_S_total ./ Size_c0);
	Vmax_protein_phos = S;
	K_R_total = ((Size_c0 .* R_init_uM) + (Size_c0 .* PR_init_uM));
	R = ((K_R_total - (Size_c0 .* PR)) ./ Size_c0);
	J_protein_phos = ((Vmax_protein_phos .* R) ./ (Km_protein_phos + R));
	J_protein_dephos = ((Vmax_protein_dephos .* PR) ./ (Km_protein_dephos + PR));
	% OutputFunctions

	rowValue = [PR S_init_uM K_S_total S Vmax_protein_phos K_R_total R J_protein_phos J_protein_dephos ];
end

% -------------------------------------------------------
% ode rate
function dydt = f(t,y,p,y0)
	% State Variables
	PR = y(1);
	% Constants
	Size_c0 = p(1);
	mlabfix_T_ = p(2);
	mlabfix_PI_ = p(3);
	mlabfix_F_nmol_ = p(4);
	Vmax_protein_dephos = p(5);
	Km_protein_dephos = p(6);
	mlabfix_F_ = p(7);
	R_init_uM = p(8);
	mlabfix_R_ = p(9);
	mlabfix_N_pmol_ = p(10);
	Km_protein_phos = p(11);
	PR_init_uM = p(12);
	KMOLE = p(13);
	mlabfix_K_GHK_ = p(14);
	K_millivolts_per_volt = p(15);
	% Functions
	S_init_uM = t;
	K_S_total = (Size_c0 .* S_init_uM);
	S = (K_S_total ./ Size_c0);
	Vmax_protein_phos = S;
	K_R_total = ((Size_c0 .* R_init_uM) + (Size_c0 .* PR_init_uM));
	R = ((K_R_total - (Size_c0 .* PR)) ./ Size_c0);
	J_protein_phos = ((Vmax_protein_phos .* R) ./ (Km_protein_phos + R));
	J_protein_dephos = ((Vmax_protein_dephos .* PR) ./ (Km_protein_dephos + PR));
	% Rates
	dydt = [
		(J_protein_phos - J_protein_dephos);    % rate for PR
	];
end
