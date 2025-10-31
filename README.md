# README

## Project overview

This project guides you from fundamentals to advanced implementation and experiments of the mass spring damper example in the paper titled "Switched event based control for nonlinear cyber physical systems under deception attacks". The goal is to learn theory and build working MATLAB code that reproduces the paper style simulations and extends them with experiments.

This README is beginner friendly. It explains the file structure, what each file does, how to run each phase, what each plot shows, and common pitfalls and fixes.

---

## Quick start

1. Open MATLAB and set the project root folder to this repository root.
2. Run the environment check script

```matlab
run('phase0_env_check.m')
```

3. Follow phase by phase instructions. To run the full experiment and analysis you can run

```matlab
run('08_Experiments_and_plots/phase9_experiments.m')
run('08_Experiments_and_plots/phase9_analyze.m')
run('08_Experiments_and_plots/phase9_report.m')
```

These three commands run experiments create figures and produce a short report.

---

## Required software and toolboxes

1. MATLAB latest release recommended.
2. Control System Toolbox. This is used for state space creation transfer function and many utility routines.
3. YALMIP for LMI solving. Install instructions are below.
4. A semidefinite program solver such as SDPT3 or MOSEK for reliable LMI solves. SDPT3 is open source and commonly used with YALMIP. MOSEK is commercial but fast.
5. A LaTeX distribution is optional if you want to compile the fallback tex report manually.

### How to install YALMIP and SDPT3 quickly

In MATLAB command prompt run these commands after downloading archives or using Git

```matlab
% add YALMIP to path replace path_to_yalmip with real path
addpath(genpath('path_to_yalmip'));
savepath;
% check YALMIP
which yalmip
% install SDPT3 via add on explorer or addpath if you downloaded source
addpath(genpath('path_to_sdpt3'));
savepath;
```

If you prefer automated package managers use the MATLAB Add On Explorer to install Control System Toolbox and SDPT3.

---

## File structure and purpose

Top level files and folders

1. `README.md` this file
2. `00_notes/Switched_Systems_CheatSheet.tex` compact theory cheat sheet for LTI systems Lyapunov switched systems and LMI recipe
3. `phase0_env_check.m` create project folders and check toolboxes

Phase folders and main content

1. `01_LTI_basics/`

   * `msd_model.m` returns A B C D and params for linear mass spring damper
   * `phase1_simulate.m` simulate step impulse and free responses and verify ss and tf match
   * `phase2_analysis.m` eigenvalues controllability observability and Bode Nyquist plots
   * `phase2_sensitivity.m` sweep parameters and show pole trajectories

2. `02_Lyapunov_LMI/`

   * `phase4_lyap_check.m` solve Lyapunov equation plot V decay
   * `phase4_switch_example.m` switched example showing possible instability under naive switching
   * `phase4_lmi_design.m` small LMI example using YALMIP
   * `phase8_ts_lmi_design.m` LMI design for TS fuzzy gains
   * `phase8_apply_and_test.m` apply recovered gains and test in switched ETM simulation
   * `phase8_summary.m` quick summary and plots

3. `03_Control_design/`

   * `pole_place_design.m` state feedback via pole placement
   * `lqr_design.m` LQR design and comparison
   * `observer_design.m` Luenberger observer simulation
   * `pid_baseline.m` PID baseline example

4. `04_Sampling_network/`

   * `zoh_discretize.m` compute Phi Gamma matrices consistent with zero order hold
   * `phase5_sampling_effects.m` study sampling period influence
   * `phase5_packet_loss.m` simulate Bernoulli packet loss
   * `event_trigger_baseline.m` simple threshold event trigger simulation

5. `05_Nonlinear_fuzzy/`

   * `nonlinear_msd.m` nonlinear plant function used by solvers
   * `phase6_nonlinear_sim.m` compare nonlinear and linear models
   * `ts_fuzzy_build.m` build TS fuzzy local linearizations and membership functions
   * `phase6_fuzzy_control.m` design local gains blend them and simulate closed loop

6. `06_Event_triggered/`

   * `deception_attack_schedule.m` create sleeping and active attack schedule and raw signal
   * `switched_etm_decision.m` decide transmissions based on mode and error rules
   * `phase7_switched_etm_sim.m` main switched ETM simulation that compares periodic sampling and switched ETM
   * `plot_phase7_results.m` plotting helper for Phase 7
   * `phase7_summary.m` prints and plots key Phase 7 results

7. `08_Experiments_and_plots/`

   * `phase9_experiments.m` run parameter sweep experiments and save raw results
   * `phase9_analyze.m` compute metrics create summary table and plots
   * `save_figure.m` helper to save figures as PNG and PDF
   * `phase9_report.m` publish a short report using MATLAB publish or create a LaTeX fallback

Saved data and figures

1. `01_LTI_basics/phase1_results.mat` created by Phase 1 simulate script
2. `06_Event_triggered/phase7_results.mat` results from Phase 7 simulation
3. `02_Lyapunov_LMI/phase8_lmi_solution.mat` saved LMI solution that contains P and K arrays
4. `08_Experiments_and_plots/phase9_summary.mat` raw experiment results and later analysis files and figures will be saved in `08_Experiments_and_plots/figures`

---

## How to run phase by phase

All commands assume MATLAB current folder is the project root.

### Phase 0 environment check

```matlab
run('phase0_env_check.m')
```

This creates folder structure and prints toolbox availability.

### Phase 1 basics

```matlab
run('01_LTI_basics/phase1_simulate.m')
run('01_LTI_basics/phase2_analysis.m')
run('01_LTI_basics/phase2_sensitivity.m')
```

Inspect the four plots from phase1 simulate. They show step response impulse response free response and the phase portrait. The printed numeric error shows the difference between state space step and transfer function step results. Expect near machine precision.

### Phase 2 and Phase 3 controllers

Run the controller design scripts in `03_Control_design` in this order.

Each script prints key values and produces plots for comparison. The observer script simulates a Luenberger estimator and reports estimation error.

### Phase 4 LMI

Before running `phase4_lmi_design.m` ensure YALMIP and a solver are installed. If solver fails try installing SDPT3 or MOSEK.

### Phase 5 sampling and event trigger

Run the scripts in `04_Sampling_network` to observe sampling effects packet loss and a simple event trigger baseline.

### Phase 6 nonlinear and TS fuzzy

Run these scripts in this order

```matlab
run('05_Nonlinear_fuzzy/phase6_nonlinear_sim.m')
run('05_Nonlinear_fuzzy/phase6_fuzzy_control.m')
```

Phase 6 produces a plot that compares nonlinear open loop with linearized model and a closed loop plot showing fuzzy controlled position.

### Phase 7 switched ETM with deception attack

Run the main sim

```matlab
run('06_Event_triggered/phase7_switched_etm_sim.m')
```

This prints counts of transmissions for switched ETM and for periodic sampling and creates a 3 panel plot. Panel one is position versus time with red markers at transmission instants. Panel two is the control input. Panel three is a stair plot showing attack mode where 1 denotes sleeping and 2 denotes active.

Important things to notice in Phase 7

1. In active intervals you will typically see fewer transmissions with the switched ETM if parameters are set to be conservative in active mode.
2. Because the attack injects false data the controller sees corrupted state. We force mode transition transmissions to prevent long drift.
3. If simulation diverges reduce the integration step or use MATLAB integrator for accuracy.

### Phase 8 LMI co design

Run the LMI design for TS fuzzy gains

```matlab
run('02_Lyapunov_LMI/phase8_ts_lmi_design.m')
run('02_Lyapunov_LMI/phase8_apply_and_test.m')
```

If the solver reports infeasible try relaxing the small negative margin or scale matrices.

### Phase 9 experiments and report

Run the full experiments and analysis with

```matlab
run('08_Experiments_and_plots/phase9_experiments.m')
run('08_Experiments_and_plots/phase9_analyze.m')
run('08_Experiments_and_plots/phase9_report.m')
```

This produces a CSV table and figures in `08_Experiments_and_plots/figures` and tries to publish a PDF report. If `publish` is not available a LaTeX file is created.

---

## What each main plot represents and what to inspect

1. Step and impulse plots from Phase 1 show the open loop plant response. Inspect overshoot rise time and damping.
2. Phase portrait shows energy decay and stability. Check trajectory spirals toward origin for underdamped cases.
3. Bode and Nyquist plots from Phase 2 show frequency response. Inspect resonance peak and phase margin.
4. Controller comparison plots show closed loop step responses. Inspect which method lowers settling time and which uses less control effort.
5. Lyapunov function plot from Phase 4 shows V(t) decreasing. This verifies a quadratic Lyapunov function candidate.
6. Event trigger plot from Phase 5 shows position with markers at transmission instants. Inspect how many markers appear relative to periodic sampling.
7. Phase 7 three panel plot shows position and transmission instants control input and attack mode. Important to check that transmissions occur at mode transitions and that switched ETM reduces load in active intervals.
8. Phase 9 analysis plots include MSSE versus transmission rate scatter and a heatmap of average transmission count. These visually represent the trade off between communication cost and control performance.

---

## Important notes and tips

1. Use step by step approach. Finish Phase 1 and Phase 2 until you understand poles zeros and responses before moving forward.
2. Keep the cheat sheet `00_notes/Switched_Systems_CheatSheet.tex` open when working on LMIs and switched stability. It maps theory to code.
3. Numerical scaling matters. If LMIs are infeasible try scaling A B matrices or relax small margins.
4. Euler integration is used in many example scripts for simplicity. If you see numerical instability switch to `ode45` or reduce time step `h`.
5. Use the saved .mat result files to avoid rerunning expensive simulations. For example `phase7_results.mat` and `phase9_summary.mat` contain raw data for plotting and analysis.

---

## Common problems and quick fixes

1. YALMIP not found

   * Fix add YALMIP to MATLAB path via `addpath(genpath('path_to_yalmip'))` and `savepath` then restart MATLAB

2. SDPT3 or solver not found or errors

   * Install SDPT3 from MATLAB Add On Explorer or from source and add to path. Alternatively configure YALMIP to use another solver such as MOSEK

3. Plots show divergence or weird spikes

   * Reduce time step `h` or use `ode45` integration. Check that control gains are not excessively large by printing `max(abs(K))`

4. Transmissions never happen or always happen

   * Tune ETM parameters `delta` and `delta_active` in `phase7_switched_etm_sim.m`. Lower `delta` increases transmissions. Increase `delta_active` makes active mode more conservative.

---

## Reproducibility

1. All scripts set random seed `rng(0)` where randomness is used. This ensures consistent attack schedule and repeating experiments.
2. Save intermediate results with `save` commands as provided. Use these files to reproduce plots without rerunning full simulations.

---

## Suggested exercises for learning

1. Replace Euler integration with `ode45` in Phase 6 and Phase 7 and compare results.
2. Add measurement noise and see how the switched ETM schedules change.
3. Implement minimum inter transmission time and quantify its effect on communication and performance.
4. Try varying the number of fuzzy rules and observe how LMIs scale and feasible regions change.

---

## Citation

If you use this project in a report please cite the original paper

Fan Yang Zhou Gu Shen Yan. Switched event based control for nonlinear cyber physical systems under deception attacks. Nonlinear Dynamics 106 2245 2257 2021.

---

## License and contact

This project is provided for learning and research. Use it freely for non commercial learning. If you want help adapting code for your specific environment or want further explanations run the phase by phase scripts and send the printed errors or the saved mat files and I will help.

If you want I can now also create a short project overview PDF that lists exact commands to run in sequence and includes thumbnail images of key plots. Would you like that?
