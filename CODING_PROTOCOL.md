# Coding protocol for placing actors in the Gyroscope circumplex

Purpose: make each case's octant distribution follow from stated rules applied to
material dated at or before the decision point, so that the placement cannot be
influenced by knowing what happened afterwards. This is the single change that turns
the case studies from illustration into evidence.

## Step 0 — fix the referent and the decision date
Write one sentence naming the specific proposed change, and the date the decision was
taken. Everything used for coding must predate that date. Record it before proceeding.

  Example. Referent: "the United Kingdom leaves the European Union."
  Decision date: 23 June 2016.

## Step 1 — enumerate actors
Actors are institutional blocs, not individuals. Voters are not coded separately
because they occupy a single power level, which would collapse the vertical axis.
Include every bloc with a formal or organised role in the decision:
  executive, legislative factions by party, subnational governments with veto rights,
  organised interests (business federations, unions, churches), major media groups,
  and the mass public as one bloc.

## Step 2 — assign power, from formal role only
Power is capacity to enact or block THIS change, read off institutional position:

| role | power |
|---|---|
| executive with authority to implement | +1.0 |
| legislative majority or coalition | +0.7 |
| veto player (upper chamber, court, federal unit) | +0.6 |
| legislative party, scaled by seat share | +0.4 x (seats / largest party seats) |
| organised interest with statutory consultation right | +0.2 |
| organised interest without one, major media | 0.0 |
| mass public | -0.6 |
| disenfranchised or unorganised groups | -1.0 |

Do not adjust for how influential a bloc turned out to be. Formal role only.

## Step 3 — assign alignment toward the referent
From the bloc's position on the record at or before the decision date:

| stated position | alignment |
|---|---|
| formally committed to the change | +1.0 |
| supportive with stated reservations | +0.5 |
| neutral, no position, or internally split near 50/50 | 0.0 |
| opposed with stated willingness to negotiate | -0.5 |
| formally committed against | -1.0 |

For the mass public use the vote share or the final pre-decision poll:
alignment = 2 x (share in favour) - 1.

## Step 4 — assign weight
Weight each bloc by its size in the relevant arena: seat share for legislative blocs,
membership or turnover share for organised interests, population share for the public.
Weights are normalised to sum to 100 within the case.

## Step 5 — place and aggregate
Each actor's angle is atan2(power, alignment). Assign to the octant containing that
angle. Sum weights within octants to give the distribution, then run `exact_change()`.

## Step 6 — record the prediction BEFORE consulting the outcome
Write down direction, change type, quadrant and speed. Save the file. Only then look
at what happened.

## Step 7 — state the observable, then compare
Fix these two before looking:
  - Direction is matched against the documented trajectory of the referent over the
    following five years, classified into the model's eight change types by a reader
    who has not seen the prediction.
  - Speed is time from decision to substantive implementation, banded as
    under 1 year / 1 to 3 years / over 3 years / never implemented.

Report every case, including the misses. A protocol that only reports hits is the
circularity problem in a different costume.

## Note on what this can and cannot show
Congruence across a set of independently coded cases supports the claim that the model
reproduces observed trajectories. It does not establish that the model predicts better
than a simpler measure, which requires a different design. State that limit explicitly
rather than letting a referee state it for you.
