"""Congruence test, not a horse race.

Question: when actors are placed mechanically from V-Party, does the model's predicted
direction and speed match what the country actually did? Reported as hit rates against
chance, which is the claim 'the model reproduces observed trajectories'.
"""
import numpy as np, pandas as pd
from scipy import stats
exec(open('study3.py').read().split("if __name__")[0])

def congruence(pos,out,label,window=5):
    M=build(pos,out,window)
    if len(M)<300: print(f"{label}: too few"); return None
    # predicted movement toward the referent = horizontal component of the model vector
    ang=np.radians(M.ang.values)
    M=M.assign(pred_x=np.cos(ang))
    M=M[M.delta.abs()>1e-6]
    hit=(np.sign(M.pred_x)==np.sign(M.delta))
    n=len(M); h=hit.mean()
    # binomial test against chance
    p=stats.binomtest(int(hit.sum()),n,0.5,alternative='greater').pvalue
    rho,prho=stats.spearmanr(M.speed,M.delta.abs())
    return dict(label=label,n=n,hit=h,p=p,rho=rho,prho=prho)

PAIRS=[('v2paplur','v2x_polyarchy','commitment to pluralism'),
       ('v2paopresp','v2xlg_legcon','respect for opponents'),
       ('v2pagender','v2x_gender','gender equality'),
       ('v2paminor','v2xeg_eqprotec','minority rights'),
       ('v2paviol','v2x_civlib','rejection of violence'),
       ('v2paclient','v2xnp_client','clientelism'),
       ('v2pariglef','v2xeg_eqdr','economic left-right')]

print("="*88)
print("CONGRUENCE TEST  — does the model reproduce the observed trajectory?")
print("  actors placed mechanically from V-Party; no human coding, no outcome knowledge")
print("="*88)
print(f"{'referent':<26}{'n':>6}{'direction hit rate':>20}{'p vs chance':>13}{'speed rho':>11}")
print("-"*88)
res=[]
for a,b,l in PAIRS:
    r=congruence(a,b,l)
    if r:
        res.append(r)
        star='***' if r['p']<.001 else '**' if r['p']<.01 else '*' if r['p']<.05 else ''
        print(f"{l:<26}{r['n']:>6}{100*r['hit']:>17.1f}%{r['p']:>13.3g}{star:<3}{r['rho']:>8.3f}")
print("-"*88)
w=np.array([r['n'] for r in res]); hh=np.array([r['hit'] for r in res])
print(f"  weighted mean direction hit rate across all seven referents: {100*np.average(hh,weights=w):.1f}%")
print(f"  chance is 50%. Referents beating chance at p<0.05: "
      f"{sum(1 for r in res if r['p']<0.05)} of {len(res)}")
