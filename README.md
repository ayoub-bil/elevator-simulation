# Discrete-Event Simulation of an Elevator System

MS-E2170 Discrete Event Simulation, Aalto University, Spring 2026

## Overview
Simulation model of a 10-floor office building elevator system 
with two elevators and FCFS dispatching. The study examines how 
passenger arrival rate and door time affect waiting times and 
utilization.

## Parameters studied
| Parameter    | Values tested   |
|--------------|-----------------|
| Arrival rate | 100, 200, 300/h |
| Door time    | 3, 5, 7 s       |
| Replications | 30              |

## Key findings
- At baseline (λ = 200/h, door time 5s): mean waiting time 44s, 
  utilization 0.83
- Arrival rate was the dominant factor driving system performance
- Door time effect is secondary but amplifies under heavy load

## Files
- `elevator.m` — initialization and main simulation runs
- `elevator_simulation.m` — core simulation function (FCFS logic)
- `elevator_analysis.m` — sensitivity analysis, verification and plots

## Language
MATLAB
