"""Referent-specific test: parties as actors, seat share as power, a named policy as
the proposed change. This satisfies the model's single-referent definition."""
import pandas as pd, numpy as np, statsmodels.formula.api as smf
from scipy import stats

vp=pd.read_pickle('vparty.pkl'); vd=pd.read_pickle('vdem.pkl')
CEN=np.array([22.5,67.5,112.5,157.5,202.5,247.5,292.5,337.5])   # octant centres

def octant_of(a,p):
    """Assign an actor at (alignment a, power p) to one of the eight octants."""
    th=np.degrees(np.arctan2(p,a))%360
    return np.minimum((th//45).astype(int),7)

def model(dist):
    """Closed form. dist = 8 weights."""
    d=np.asarray(dist,float); s=d.sum()
    if s<=0: return None,0.0
    d=d/s
    x=0.35*np.sum(d*np.cos(np.radians(CEN))); y=0.65*np.sum(d*np.sin(np.radians(CEN)))
    m=np.hypot(x,y)
    if m<=1e-12: return None,0.0
    nx=x/m
    return np.degrees(np.arctan2(y,x))%360, m*(1+nx)

def run(pos_var, outcome, window=5, scale=3.0, label=''):
    v=vp.dropna(subset=[pos_var,'v2paseatshare','country_name','year']).copy()
    v['a']=np.clip(v[pos_var]/scale,-1,1)                 # alignment to the named change
    v['p']=np.clip(2*v.v2paseatshare/100-1,-1,1)          # power: >50% seats can act alone
    v['oct']=octant_of(v.a.values,v.p.values)
    rows=[]
    for (c,y),g in v.groupby(['country_name','year']):
        dist=np.zeros(8)
        for o,w in zip(g.oct,g.v2paseatshare): dist[o]+=w
        ang,sp=model(dist)
        rows.append(dict(country_name=c,year=int(y),ang=ang,speed=sp,
                         wmean=np.average(g.a,weights=g.v2paseatshare.clip(lower=.01))))
    P=pd.DataFrame(rows)
    o=vd[['country_name','year',outcome]].dropna().sort_values(['country_name','year']).copy()
    o['fwd']=o.groupby('country_name')[outcome].shift(-window)
    o['delta']=o.fwd-o[outcome]; o=o.rename(columns={outcome:'base'})
    M=P.merge(o[['country_name','year','base','delta']],on=['country_name','year'],how='inner').dropna(subset=['delta','speed'])
    M['absdelta']=M.delta.abs(); M['hr']=np.minimum(M.base,1-M.base)
    M['cid']=M.country_name
    print(f"\n{'='*76}\n{label}\n  referent: {pos_var}   outcome: {outcome}   window: {window}y\n{'='*76}")
    print(f"  n = {len(M)} country-elections, {M.cid.nunique()} countries")
    r,p=stats.pearsonr(M.wmean,M.base)
    print(f"  sanity, seat-weighted party position vs outcome LEVEL: r={r:+.3f} p={p:.1e}"
          f"  {'(sign OK)' if r>0 else '(SIGN INVERTED - check codebook)'}")
    for lab,f,col in [("speed -> |delta|","absdelta ~ speed + base + hr + C(cid)",'speed'),
                      ("speed -> signed delta","delta ~ speed + base + hr + C(cid)",'speed'),
                      ("consensus -> signed delta","delta ~ wmean + base + hr + C(cid)",'wmean')]:
        try:
            m=smf.ols(f,data=M).fit(cov_type='cluster',cov_kwds={'groups':M.cid})
            b,pv=m.params[col],m.pvalues[col]
            star='***' if pv<.001 else '**' if pv<.01 else '*' if pv<.05 else ''
            print(f"    {lab:<28} b={b:+.4f}  p={pv:.3g}{star}")
        except Exception as e: print("    failed",e)
    return M

if __name__=='__main__':
    run('v2pagender','v2x_gender',5,3.0,'TEST A  gender equality')
    run('v2paminor','v2xeg_eqprotec',5,3.0,'TEST B  minority rights / equal protection')
    run('v2paplur','v2x_polyarchy',5,3.0,'TEST C  commitment to pluralism / democracy')
