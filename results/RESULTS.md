# Pilot empirical test of the Gyroscope model against V-Dem
Run 2026-07-27. Data: V-Dem v14 country-year (vdeminstitute/vdemdata), 1990-2020.
Panel: 4,578 country-years, 179 countries, with a 5-year forward window.

## Construct mapping used
| Model axis | V-Dem indicator | Note |
|---|---|---|
| Consensus (horizontal) | `v2cacamps` reversed | polarisation into antagonistic camps |
| Power concentration (vertical) | `v2pepwrsoc` reversed / `v2exrescon` reversed | two alternatives tested |
| Realised change (outcome) | 5-year forward change in `v2x_polyarchy`, `v2x_libdem` | magnitude = observed speed |

Model speed computed with the corrected term  S = ||v|| x (1 + net_x).

## Result 1 — raw correlations run against the prediction
| predictor | r with abs(delta) | p |
|---|---|---|
| model speed, signed (corrected) | **-0.2457** | 6.2e-64 |
| model speed, symmetric (old) | -0.1103 | 7.3e-14 |
| vector magnitude only | -0.1349 | 4.9e-20 |
| raw polarisation | **+0.2260** | 4.1e-54 |

The model predicts a POSITIVE correlation. Observed is negative. Note the corrected
signed term correlates more strongly than the old symmetric one, but in the wrong
direction, so this is not evidence for the fix.

## Result 2 — most of that is a ceiling effect
corr(baseline polyarchy, abs delta) = -0.213; corr(baseline, model speed) = +0.204.
Consolidated democracies are simultaneously less polarised and less able to move.

| specification | b(speed) | p |
|---|---|---|
| 1. speed only | -0.0904 | 5.8e-20 |
| 2. + baseline level | -0.0776 | 1.1e-12 |
| 3. + headroom | -0.0549 | 5.3e-06 |
| 4. + country fixed effects | -0.0375 | 0.313 |
| 5. + country and year fixed effects | **-0.0249** | **0.503** |

Within countries over time, the model's predicted speed has no detectable
relationship with realised institutional change.

## Result 3 — robustness, 12 specifications
2 outcomes x 3 windows (3/5/10y) x 2 power proxies, all with country and year
fixed effects and SEs clustered by country. The model predicts b > 0.
**No specification produced a significant positive coefficient.** Six were null,
six were significantly negative.

## Interpretation
This is not a clean test, and the reason matters. The model's horizontal axis is
defined as alignment toward ONE SPECIFIC IDENTIFIED proposed change. `v2cacamps`
measures generalised societal polarisation with no referent. The single-referent
definition, adopted to answer the earlier PSPR criticism, is exactly what makes
country-level panel indicators unsuitable.

Two conclusions follow:
1. The model is not supported by this test, and the authors should not claim
   panel-level validation.
2. The model probably CANNOT be validated with country-year panel data at all.
   Testing it requires reform-specific measurement.

## Recommended design instead: referendums
A referendum satisfies the model's own definition almost exactly.
- single identified proposed change (the ballot question)
- alignment measured directly (yes/no vote shares, pre-vote polling series)
- power alignment observable (government position, parliamentary majority, media)
- outcome observable (passed/failed, and time to implementation = speed)

Sources: Centre for Research on Direct Democracy (c2d), national electoral
commissions, Comparative Constitutions Project for constitutional amendments.
Roughly 800 national referendums since 1990 are documented and free to access.

---

# Study 2 — referent-specific test using V-Party

Study 1 failed partly because `v2cacamps` has no referent. V-Party fixes that: it
codes each party's position on a NAMED policy dimension, plus its seat share. So a
specific policy becomes the proposed change, parties become the actors, seat share
becomes power. This satisfies the model's single-referent definition.

Actors placed at (alignment, power), assigned to octants, weighted by seat share,
aggregated with the closed form. Outcome: forward change in the matched V-Dem index.
All models include country fixed effects and SEs clustered by country.

## Three referent domains, pre-specified
| referent | outcome | n | speed -> abs(delta) | speed -> signed delta |
|---|---|---|---|---|
| `v2pagender` gender equality | `v2x_gender` | 1,667 | +0.006 (p=0.55) | +0.003 (p=0.77) |
| `v2paminor` minority rights | `v2xeg_eqprotec` | 1,680 | -0.012 (p=0.43) | +0.004 (p=0.78) |
| **`v2paplur` pluralism** | **`v2x_polyarchy`** | **1,680** | **+0.078 (p<0.001)** | **+0.100 (p<0.001)** |

One of three supports the model. It is also the domain where predictor and outcome are
most closely related (level-check r = +0.86), which is both the tightest test of the
construct and the most vulnerable to partial circularity.

## The decisive diagnostic: does the geometry earn its keep?
Pluralism domain, both predictors in one regression.

| specification | coefficient | p | R2 |
|---|---|---|---|
| model speed alone | +0.1001 | 1.6e-06 | 0.302 |
| plain seat-weighted consensus alone | +0.1455 | 2.1e-14 | **0.357** |
| both together, **speed** coefficient | **+0.0175** | **0.419** | 0.357 |
| both together, consensus coefficient | +0.1394 | 1.4e-11 | **0.357** |

**The circumplex machinery adds nothing over a single scalar.** Model speed is
significant alone only because it is correlated with consensus. Control for consensus
directly and speed contributes nothing, with identical R2 to three decimal places.

## Proposition 1 (power determines direction) is not supported
| specification | coefficient | p |
|---|---|---|
| power only | -0.0413 | 0.0004 |
| both, consensus coefficient | +0.1443 | 4.4e-12 |
| both, **power** coefficient | **-0.0021** | **0.871** |
| consensus x power interaction | -0.0289 | 0.123 |

This is not a lack of statistical power to detect it: the weighted power coordinate has
sd = 0.537 and spans -0.96 to +1.00, and largest-party seat share ranges 2 to 100.

## Robustness of the one positive result
Survives year fixed effects (b=+0.097, p<0.001), a lagged-change control for momentum
(b=+0.093, p<0.001), and 3-year (b=+0.106) and 10-year (b=+0.063, p=0.010) windows.

## Honest verdict
1. The underlying intuition is **supported**: alignment toward a specific proposed
   change predicts subsequent institutional change, robustly (b=+0.145, p=2e-14).
2. The **circumplex apparatus is not supported**. Eight octants, weighted vector
   aggregation and the speed formula do not improve on a seat-weighted mean of party
   positions.
3. **Proposition 1 is not supported** in this test.

Caveat that cuts the other way: seat share is a crude proxy for the model's power axis,
which is capacity to enact a particular change and involves agenda control and veto
points, not merely seats. A better power measure could change conclusion 3. It would
not obviously change conclusion 2.

---

# Study 3 — the best test the available data supports

Improvements on Study 2: power is now government status (senior govt 1.0, junior 0.5,
support 0.15, opposition -0.5, no seats -1.0) blended 70/30 with seat share, which is
capacity to enact rather than mere size; all seven pre-specified referent/outcome pairs
are reported rather than a chosen subset, with Holm correction; plus placebo and
out-of-sample tests.

## All seven referents
| referent | outcome | n | sanity r | speed b | p | Holm p |
|---|---|---|---|---|---|---|
| **commitment to pluralism** | `v2x_polyarchy` | 1675 | +0.860 | **+0.0897** | **0.0002** | **0.0016** |
| respect for opponents | `v2xlg_legcon` | 1661 | +0.396 | +0.0010 | 0.975 | 0.975 |
| gender equality | `v2x_gender` | 1662 | +0.557 | -0.0079 | 0.419 | 1.0 |
| minority rights | `v2xeg_eqprotec` | 1675 | +0.431 | -0.0115 | 0.526 | 1.0 |
| rejection of violence | `v2x_civlib` | 1675 | +0.775 | +0.0318 | 0.152 | 0.91 |
| clientelism | `v2xnp_client` | 1675 | +0.683 | +0.0061 | 0.687 | 1.0 |
| economic left-right | `v2xeg_eqdr` | 1675 | -0.091 | -0.0020 | 0.876 | 1.0 |

One of seven survives correction. The improved power measure did not rescue the others.

## Nested comparison on the one surviving referent
| specification | coefficient | p | R2 |
|---|---|---|---|
| model speed alone | +0.0897 | 0.0002 | 0.2953 |
| scalar consensus alone | +0.1455 | 2.1e-14 | **0.3562** |
| scalar power alone | -0.0358 | 0.0038 | 0.2880 |
| consensus + power, power coefficient | +0.0129 | 0.39 | 0.3570 |
| **model + consensus, MODEL coefficient** | **+0.0053** | **0.832** | 0.3563 |
| model + consensus, consensus coefficient | +0.1439 | 3.8e-12 | 0.3563 |

The circumplex adds **0.0001 of R2** over a single scalar. Power remains null even with
the improved capacity-to-enact measure.

## Placebo — both pass
Neither model speed (p=0.50) nor scalar consensus (p=0.083) predicts change that
already happened. The consensus finding is therefore not an artefact of reverse causation.

## Out-of-sample, train on half the countries, predict the other half
| predictor | out-of-sample r | RMSE |
|---|---|---|
| baseline, no predictor | +0.178 | 0.1022 |
| model speed | +0.204 | 0.1015 |
| **scalar consensus** | **+0.312** | **0.0985** |

Scalar consensus beats the model out of sample by a clear margin.

## Final verdict
This is as good as the test gets with data that exists.

**Supported, robustly:** party-system alignment toward a specific institutional change
predicts subsequent change in that institution. b = +0.145, p = 2e-14, 1,675
country-elections across 168 countries, surviving country and year fixed effects, a
momentum control, a placebo test and out-of-sample validation.

**Not supported:** the circumplex apparatus. Eight octants, weighted vector aggregation
and the speed formula do not outperform a seat-weighted mean of party positions, in
sample or out of sample.

**Not supported:** Proposition 1. Power contributes nothing once alignment is controlled,
under either power measure.
