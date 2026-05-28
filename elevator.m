clc; clear;

% MS-E2170 Discrete Event Simulation D
% Project: Simulation of an elevator system
% Sensitivity analysis with mixed traffic

% Created: 08-04-2026 B.A.

%% Initialization

% Number of replications
M = 30;

% Significance level
alpha = 0.05;

% Length of simulation period (seconds)
T_end = 60*60;

% Number of floors
n_floors = 10;

% Number of elevators
n_elevators = 2;

% Travel time per floor (seconds)
t_floor = 3;

% Door time (seconds)
door_times = [3 5 7];
door_labels = {'3 s', '5 s', '7 s'};

% Passenger arrival rate (arrivals per second)
lambda_plot = [100 200 300];
lambdas = lambda_plot / 3600;
lambda_labels = {'100/h', '200/h', '300/h'};

% Number of factor levels
n_lambda = length(lambdas);
n_door   = length(door_times);

% Baseline case
baseline_lambda = 200 / 3600;
baseline_door   = 5;

baseline_lambda_index = find(lambdas == baseline_lambda);
baseline_door_index   = find(door_times == baseline_door);


%% Simulation

%rng('shuffle')
%base_seed = randi(100000);
base_seed = 12345;   % fixed seed for final reported results

% Initialize variable
d_mean = zeros(M, n_lambda, n_door);
d_max  = zeros(M, n_lambda, n_door);
u_mean = zeros(M, n_lambda, n_door);


% Loop through factor combinations
for jj = 1:n_lambda
    for kk = 1:n_door

        % Current factor levels
        lambda = lambdas(jj);
        t_door = door_times(kk);
        
        % Loop through replications
        for ii = 1:M
            % Set seed
            rng(base_seed + 1000*jj + 100*kk + ii)

            % Run simulation
            [d, u] = elevator_simulation(T_end, n_floors, n_elevators, ...
                lambda, t_floor, t_door);

            % Store replication results
            d_mean(ii,jj,kk) = mean(d);
            d_max(ii,jj,kk)  = max(d);
            u_mean(ii,jj,kk) = u;

        end
    end
end


%% Print basic results


fprintf('\nMean waiting times\n')
fprintf('-----------------------------\n')
fprintf('%-10s %-10s %-18s\n', 'Lambda', 'Door time', 'Mean waiting time')
fprintf('-----------------------------\n')

for jj = 1:n_lambda
    for kk = 1:n_door
        fprintf('%-10s %-10s %-18.2f\n', ...
            lambda_labels{jj}, ...
            door_labels{kk}, ...
            mean(d_mean(:,jj,kk)))
    end
end

