# Gyroscope of Social Change — model and empirical tests

Circumplex model of collective social change. A population is described by its
distribution over eight behavioural octants on two axes, power and alignment toward a
specified change. The model returns a direction, read as a type of change, and a speed.

## What is here
- `code/model.m` — MATLAB implementation. `exact_change()` is the closed-form solver
  and should be used for reported results; the Monte Carlo path is for the agent
  scatter and the stability diagnostics only.
- `code/vdem_test.py` — Study 1, country-panel test against V-Dem.
- `code/vparty_test.py` — Study 2, referent-specific test using V-Party.
- `code/study3.py` — Study 3, the full test: seven pre-specified referents, government
  status as power, Holm correction, placebo and out-of-sample validation.
- `code/get_data.sh` — fetches V-Dem and V-Party.
- `results/RESULTS.md` — all three studies with full output.

## Analytical result
The aggregation admits a closed form. Each octant contributes a vector along its own
centre direction, weighted by its share of the population:

    net_x = 0.35 * SUM p_k cos(c_k)
    net_y = 0.65 * SUM p_k sin(c_k)

so the stochastic agent placement contributes only sampling noise. Two identities
follow and hold for any positive weighting: an all-high-power population gives exactly
90.00 degrees, an all-low-power population exactly 270.00 degrees. A population spread
evenly over the eight octants is an exact null vector, with zero speed and no direction.

## Empirical status — read before using
The circumplex apparatus is **not** empirically supported. Across seven pre-specified
referent domains, only one survives multiple-testing correction, and there the model
adds 0.0001 of R-squared over a seat-weighted mean of party positions, and loses to that
scalar out of sample. The power axis contributes nothing once alignment is controlled.

Further, the scalar that does work is equivalent to the Party-System Democracy Index of
Angiolillo, Wiebrecht and Lindberg (2025, British Journal of Political Science), which
aggregates party commitment to pluralism weighted by seat share over 3,151 elections in
178 countries. That work precedes this and is more thorough.

## Data
Neither V-Dem nor V-Party is redistributed here. `get_data.sh` downloads both from the
V-Dem Institute. Please cite them directly.

## Repository contents
- `code/model.m` — MATLAB implementation. `exact_change()` is the closed-form solver and
  should be used for reported results; the Monte Carlo path drives the agent scatter and
  the stability diagnostics only. The header documents the authoritative octant map.
- `code/vdem_test.py` — Study 1, country-panel test against V-Dem.
- `code/vparty_test.py` — Study 2, referent-specific test using V-Party.
- `code/study3.py` — Study 3, seven pre-specified referents, government status as the
  power coordinate, Holm correction, placebo and out-of-sample validation.
- `code/congruence.py` — Study 4, the congruence test: does placing actors by rule
  reproduce the observed trajectory.
- `code/code_case.py` — applies `CODING_PROTOCOL.md` to a single hand-coded case.
- `CODING_PROTOCOL.md` — rules for placing actors from material dated at or before the
  decision point, so that a case coding cannot be influenced by knowing the outcome.
- `results/RESULTS.md` — all four studies with full output.
- `code/get_data.sh` — fetches V-Dem and V-Party.

## Reproducing
```
cd code && ./get_data.sh && python3 study3.py && python3 congruence.py
```
Requires `pyreadr`, `pandas`, `numpy`, `scipy`, `statsmodels`.
