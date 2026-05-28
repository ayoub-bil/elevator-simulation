function [d, u, t_arrival] = elevator_simulation(T_end, n_floors, n_elevators, lambda, t_floor, t_door)
% Simulation of an elevator system
% ----------------------------------
% T_end         simulation period (seconds)
% n_floors      number of floors
% n_elevators   number of elevators
% lambda        passenger arrival rate (passengers/second)
% t_floor       travel time per floor (seconds)
% t_door        door open/close time (seconds)
% ----------------------------------
% d             waiting times of served passengers
% u             elevator utilization
% t_arrival     arrival times of passengers
% ----------------------------------
% FCFS dispatching rule
% Mixed traffic: passengers may travel between any two different floors
% No new arrivals after T_end, but passengers already in the system
%   are served until the queue is empty
% ----------------------------------


t  = 0;                 % Simulation clock
ta = exprnd(1/lambda);  % Time of next passenger arrival
if ta > T_end
    ta = inf;           % No new arrivals after T_end
end              

% Elevator states
elevator_floor     = ones(n_elevators, 1);   % Current floor (all start at floor 1)
elevator_free_time = inf(n_elevators, 1);    % When each elevator becomes free

% Queue
queue_arrival = [];   % Arrival times of queued passengers
queue_origin  = [];   % Origin floors
queue_dest    = [];   % Destination floors

% Statistics
d         = [];                     % Waiting times
t_arrival = [];                     % Arrival times of all passengers
busy_time = zeros(n_elevators, 1);  % Accumulated busy time per elevator


% The main simulation loop
while (ta < inf) || ~isempty(queue_arrival) || (min(elevator_free_time) < inf)

    % Next departure = earliest elevator becoming free
    td = min(elevator_free_time);

    % Next event is arrival
    if ta < td

        % Update simulation clock
        t = ta;

        % Generate passenger request
        origin = randi(n_floors);
        dest   = randi(n_floors);
        while dest == origin
            dest = randi(n_floors);
        end

        % Add passenger to queue
        queue_arrival = [queue_arrival; t];
        queue_origin  = [queue_origin;  origin];
        queue_dest    = [queue_dest;    dest];

        % Store arrival time
        t_arrival = [t_arrival; t];

        % Generate next arrival
        ta = ta + exprnd(1/lambda);

        % No new arrivals after T_end
        if ta > T_end
            ta = inf;
        end

    % Next event is elevator becoming free
    else

        % Update simulation clock
        t = td;

        % Find which elevator just became free
        elevator_index = find(elevator_free_time == td, 1);

        % Mark elevator as free
        elevator_free_time(elevator_index) = inf;

    end
    % After each event: assign waiting passengers to free elevators
    free_elevators = find(elevator_free_time == inf);

    while ~isempty(queue_arrival) && ~isempty(free_elevators)

        % FCFS: always take first passenger in queue
        passenger_index = 1;
        origin = queue_origin(passenger_index);
        dest   = queue_dest(passenger_index);

        % First free elevator
        elevator_index = free_elevators(1);

        % Record waiting time
        d(end+1,1) = t - queue_arrival(passenger_index);

        % Calculate service time:
        % 1) travel from elevator current floor to origin
        % 2) door at origin
        % 3) travel from origin to destination
        % 4) door at destination
        service_time = abs(elevator_floor(elevator_index) - origin) * t_floor ...
                     + t_door ...
                     + abs(dest - origin) * t_floor ...
                     + t_door;

        % Update elevator state
        elevator_free_time(elevator_index) = t + service_time;
        elevator_floor(elevator_index)     = dest;
        busy_time(elevator_index) = busy_time(elevator_index) ...
                                  + max(0, min(service_time, T_end - t));


        % Remove passenger from queue
        queue_arrival(passenger_index) = [];
        queue_origin(passenger_index)  = [];
        queue_dest(passenger_index)    = [];

        % Update free elevators list
        free_elevators = find(elevator_free_time == inf);

    end
 
end



% Calculate utilization
% busy_time contains accumulated busy time per elevator
% Divide by total possible busy time (n_elevators * T_end)
u = sum(busy_time) / (n_elevators * T_end);

end