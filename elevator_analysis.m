%
% MS-E2170 Discrete Event Simulation D
% Simulation of an elevator system
%
% Sensitivity analysis and verification
%
% NOTE: Run elevator.m first
% Created: 08-04-2026 B.A.

%% Sensitivity analysis

% Initialize variables
mean_wait    = zeros(n_lambda, n_door);
mean_wait_ci = zeros(n_lambda, n_door);

max_wait     = zeros(n_lambda, n_door);
max_wait_ci  = zeros(n_lambda, n_door);

util_mean    = zeros(n_lambda, n_door);
util_ci      = zeros(n_lambda, n_door);


% Calculate means and confidence intervals
for jj = 1:n_lambda
    for kk = 1:n_door

        % Replication results
        mean_rep = squeeze(d_mean(:,jj,kk));
        max_rep  = squeeze(d_max(:,jj,kk));
        util_rep = squeeze(u_mean(:,jj,kk));

        % Mean waiting time
        mean_wait(jj,kk)    = mean(mean_rep);
        mean_wait_ci(jj,kk) = tinv(1 - alpha/2, M - 1) * sqrt(var(mean_rep)/M);

        % Maximum waiting time
        max_wait(jj,kk)     = mean(max_rep);
        max_wait_ci(jj,kk)  = tinv(1 - alpha/2, M - 1) * sqrt(var(max_rep)/M);

        % Utilization
        util_mean(jj,kk)    = mean(util_rep);
        util_ci(jj,kk)      = tinv(1 - alpha/2, M - 1) * sqrt(var(util_rep)/M);

    end
end

%% Print sensitivity results

fprintf('\nSensitivity analysis\n')
fprintf('---------------------------------------------------------------------------------------------\n')
fprintf('%-10s %-12s %-22s %-22s %-18s\n', ...
    'Lambda', 'Door time', 'Mean waiting time', 'Maximum waiting time', 'Utilization')
fprintf('---------------------------------------------------------------------------------------------\n')

for jj = 1:n_lambda
    for kk = 1:n_door
        fprintf('%-10s %-12s %8.2f %c %-8.2f %8.2f %c %-8.2f %8.2f %c %-8.2f\n', ...
            lambda_labels{jj}, ...
            door_labels{kk}, ...
            mean_wait(jj,kk), 177, mean_wait_ci(jj,kk), ...
            max_wait(jj,kk),  177, max_wait_ci(jj,kk), ...
            util_mean(jj,kk), 177, util_ci(jj,kk));
    end
end

%% Baseline case

fprintf('\nBaseline case\n')
fprintf('------------------------------\n')
fprintf('Lambda              %s\n', lambda_labels{baseline_lambda_index})
fprintf('Door time           %s\n', door_labels{baseline_door_index})
fprintf('Mean waiting time   %.2f %c %.2f\n', ...
    mean_wait(baseline_lambda_index, baseline_door_index), 177, ...
    mean_wait_ci(baseline_lambda_index, baseline_door_index))
fprintf('Maximum waiting time %.2f %c %.2f\n', ...
    max_wait(baseline_lambda_index, baseline_door_index), 177, ...
    max_wait_ci(baseline_lambda_index, baseline_door_index))
fprintf('Utilization         %.2f %c %.2f\n', ...
    util_mean(baseline_lambda_index, baseline_door_index), 177, ...
    util_ci(baseline_lambda_index, baseline_door_index))

%% Verification

fprintf('\nVerification:\n')
fprintf('--------------------------------\n')

% Baseline factor levels
lambda_ver = baseline_lambda;
door_ver   = baseline_door;

% Test 1) one elevator vs two elevators
d_ver1 = zeros(M,2);

for ii = 1:M
    rng(base_seed + 5000 + ii)

    [d, ~] = elevator_simulation(T_end, n_floors, 1, ...
        lambda_ver, t_floor, door_ver);
    d_ver1(ii,1) = mean(d);

    rng(base_seed + 6000 + ii)

    [d, ~] = elevator_simulation(T_end, n_floors, 2, ...
        lambda_ver, t_floor, door_ver);
    d_ver1(ii,2) = mean(d);
end

fprintf('\nTest 1: One elevator vs two elevators (baseline lambda and door time)\n')
fprintf('1 elevator mean waiting time: %.2f\n', mean(d_ver1(:,1)))
fprintf('2 elevators mean waiting time: %.2f\n', mean(d_ver1(:,2)))

% Test 2) low lambda vs high lambda
d_ver2 = zeros(M,2);

for ii = 1:M
    rng(base_seed + 7000 + ii)

    [d, ~] = elevator_simulation(T_end, n_floors, n_elevators, ...
        lambdas(1), t_floor, door_ver);
    d_ver2(ii,1) = mean(d);

    rng(base_seed + 8000 + ii)

    [d, ~] = elevator_simulation(T_end, n_floors, n_elevators, ...
        lambdas(end), t_floor, door_ver);
    d_ver2(ii,2) = mean(d);
end

fprintf('\nTest 2: Low lambda vs high lambda (door time fixed at baseline)\n')
fprintf('Low lambda mean waiting time:  %.2f\n', mean(d_ver2(:,1)))
fprintf('High lambda mean waiting time: %.2f\n', mean(d_ver2(:,2)))

% Test 3) short door time vs long door time
d_ver3 = zeros(M,2);

for ii = 1:M
    rng(base_seed + 9000 + ii)

    [d, ~] = elevator_simulation(T_end, n_floors, n_elevators, ...
        lambda_ver, t_floor, door_times(1));
    d_ver3(ii,1) = mean(d);

    rng(base_seed + 10000 + ii)

    [d, ~] = elevator_simulation(T_end, n_floors, n_elevators, ...
        lambda_ver, t_floor, door_times(end));
    d_ver3(ii,2) = mean(d);
end

fprintf('\nTest 3: Short door time vs long door time (lambda fixed at baseline)\n')
fprintf('Short door time mean waiting time: %.2f\n', mean(d_ver3(:,1)))
fprintf('Long door time mean waiting time:  %.2f\n', mean(d_ver3(:,2)))

%% Plotting

% --- Plot 1) Mean waiting time vs arrival rate ---
f1 = figure('Name', 'Mean waiting time vs arrival rate');
ax1 = axes('Parent', f1);
hold(ax1, 'on')
title(ax1, 'Mean waiting time vs arrival rate')
xlabel(ax1, 'Arrival rate (passengers/h)')
ylabel(ax1, 'Mean waiting time (s)')

for kk = 1:n_door
    errorbar(ax1, lambda_plot, mean_wait(:,kk), mean_wait_ci(:,kk), '-o', 'LineWidth', 1.5)
end

xticks(ax1, lambda_plot)
legend(ax1, door_labels, 'Location', 'northwest')
grid(ax1, 'on')


% --- plot 2) Utilization vs arrival rate ---
f2 = figure('Name', 'Utilization vs arrival rate');
ax2 = axes('Parent', f2);
hold(ax2, 'on')
title(ax2, 'Utilization vs arrival rate')
xlabel(ax2, 'Arrival rate (passengers/h)')
ylabel(ax2, 'Utilization')

for kk = 1:n_door
    errorbar(ax2, lambda_plot, util_mean(:,kk), util_ci(:,kk), '-o', 'LineWidth', 1.5)
end

xticks(ax2, lambda_plot)
legend(ax2, door_labels, 'Location', 'northwest')
grid(ax2, 'on')


% -- plot 3 Heatmap of mean waiting time ---
f3 = figure('Name', 'Heatmap of mean waiting time');
ax3 = axes('Parent', f3);
imagesc(ax3, mean_wait')
set(ax3, 'YDir', 'normal')
title(ax3, 'Heatmap of mean waiting time')
xlabel(ax3, 'Arrival rate (passengers/h)')
ylabel(ax3, 'Door time (s)')
xticks(ax3, 1:n_lambda)
xticklabels(ax3, lambda_plot)
yticks(ax3, 1:n_door)
yticklabels(ax3, door_times)
cb = colorbar;
ylabel(cb, 'Mean waiting time (s)')


% --- plot 4 Grouped bar chart of mean waiting time ---
f4 = figure('Name', 'Mean waiting time grouped bar');
ax4 = axes('Parent', f4);
hold(ax4, 'on')

b4 = bar(ax4, mean_wait, 'grouped');

title(ax4, 'Mean waiting time by arrival rate')
xlabel(ax4, 'Arrival rate (passengers/h)')
ylabel(ax4, 'Mean waiting time (s)')
xticks(ax4, 1:n_lambda)
xticklabels(ax4, lambda_plot)
legend(ax4, door_labels, 'Location', 'northwest')
grid(ax4, 'on')

for kk = 1:n_door
    x = b4(kk).XEndPoints;
    e=errorbar(ax4, x, mean_wait(:,kk), mean_wait_ci(:,kk), ...
        'k', 'LineStyle', 'none', 'LineWidth', 1);
    e.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

% --- Plot 5 Grouped bar chart of utilization --
f5 = figure('Name', 'Utilization by arrival rate');
ax5 = axes('Parent', f5);
hold(ax5, 'on')

b5 = bar(ax5, util_mean, 'grouped');

title(ax5, 'Utilization by arrival rate')
xlabel(ax5, 'Arrival rate (passengers/h)')
ylabel(ax5, 'Utilization')
xticks(ax5, 1:n_lambda)
xticklabels(ax5, lambda_plot)
legend(ax5, door_labels, 'Location', 'northwest')
grid(ax5, 'on')

for kk = 1:n_door
    x = b5(kk).XEndPoints;
    e=errorbar(ax5, x, util_mean(:,kk), util_ci(:,kk), ...
        'k', 'LineStyle', 'none', 'LineWidth', 1);
    e.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

% --- Plot 6 Grouped bar chart of maximum waiting time -
f6 = figure('Name', 'Mean maximum waiting time by arrival rate');
ax6 = axes('Parent', f6);
hold(ax6, 'on')

b6 = bar(ax6, max_wait, 'grouped');

title(ax6, 'Mean maximum waiting time by arrival rate')
xlabel(ax6, 'Arrival rate (passengers/h)')
ylabel(ax6, 'Maximum waiting time (s)')
xticks(ax6, 1:n_lambda)
xticklabels(ax6, lambda_plot)
legend(ax6, door_labels, 'Location', 'northwest')
grid(ax6, 'on')

for kk = 1:n_door
    x = b6(kk).XEndPoints;
    e=errorbar(ax6, x, max_wait(:,kk), max_wait_ci(:,kk), ...
        'k', 'LineStyle', 'none', 'LineWidth', 1);
    e.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

% --- Plot 7 Replication scatter ---
f7 = figure('Name', 'Replication-level scatter');
ax7 = axes('Parent', f7);
hold(ax7, 'on')

title(ax7, 'Replication-level scatter: utilization vs mean waiting time')
xlabel(ax7, 'Utilization')
ylabel(ax7, 'Mean waiting time (s)')

for jj = 1:n_lambda
    for kk = 1:n_door
        scatter(ax7, ...
            u_mean(:,jj,kk), ...
            d_mean(:,jj,kk), ...
            40, 'filled', ...
            'DisplayName', [lambda_labels{jj}, ', ', door_labels{kk}])
    end
end

legend(ax7, 'Location', 'eastoutside')
grid(ax7, 'on')

% --- Plot 8 Arrival time vs waiting time (baseline run) 
rng(base_seed + 999)

[d_scatter, ~, t_arrival_scatter] = elevator_simulation( ...
    T_end, n_floors, n_elevators, baseline_lambda, t_floor, baseline_door);

f8 = figure('Name', 'Arrival time vs waiting time');
ax8 = axes('Parent', f8);
scatter(ax8, t_arrival_scatter/60, d_scatter, 20, 'filled')

title(ax8, 'Arrival time vs waiting time (baseline run)')
xlabel(ax8, 'Arrival time (min)')
ylabel(ax8, 'Waiting time (s)')
grid(ax8, 'on')

