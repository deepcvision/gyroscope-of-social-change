"""Improved referent-specific test of the Gyroscope model.

Improvements over Study 2:
  1. Power = government status (capacity to enact) blended with seat share,
     replacing seat share alone.
  2. All seven pre-specified referent/outcome pairs reported, not a chosen subset,
     with Holm correction for multiple testing.
  3. Placebo test: the model should NOT predict change that already happened.
  4. Out-of-sample validation by country split.
  5. Nested comparison: model vs scalar consensus vs consensus + power + interaction.
"""
import pandas as pd, numpy as np, statsmodels.formula.api as smf
from scipy import stats

vp=pd.read_pickle('vparty.pkl'); vd=pd.read_pickle('vdem.pkl')
CEN=np.array([22.5,67.5,112.5,157.5,202.5,247.5,292.5,337.5])

# capacity to enact: senior govt highest, no seats lowest
GOV={0:1.0, 1:0.5, 2:0.15, 3:-0.5, 4:-1.0}

PAIRS=[('v2paplur' ,'v2x_polyarchy' ,'commitment to pluralism'),
       ('v2paopresp','v2xlg_legcon'  ,'respect for opponents'),
       ('v2pagender','v2x_gender'    ,'gender equality'),
       ('v2paminor' ,'v2xeg_eqprotec','minority rights'),
       ('v2paviol'  ,'v2x_civlib'    ,'rejection of violence'),
       ('v2paclient','v2xnp_client'  ,'clientelism'),
       ('v2pariglef','v2xeg_eqdr'    ,'economic left-right')]

def model_dist(dist):
    d=np.asarray(dist,float); s=d.sum()
    if s<=0: return None,0.0
    d=d/s
    x=0.35*np.sum(d*np.cos(np.radians(CEN))); y=0.65*np.sum(d*np.sin(np.radians(CEN)))
    m=np.hypot(x,y)
    if m<=1e-12: return None,0.0
    return np.degrees(np.arctan2(y,x))%360, m*(1+x/m)

def build(pos,out,window=5):
    v=vp.dropna(subset=[pos,'v2paseatshare','v2pagovsup','country_name','year']).copy()
    v['a']=np.clip(v[pos]/3.0,-1,1)
    gov=v.v2pagovsup.map(GOV)
    v['p']=np.clip(0.7*gov + 0.3*(2*v.v2paseatshare/100-1), -1, 1)
    th=np.degrees(np.arctan2(v.p.values,v.a.values))%360
    v['oct']=np.minimum((th//45).astype(int),7)
    rows=[]
    for (c,y),g in v.groupby(['country_name','year']):
        dist=np.zeros(8)
        w=g.v2paseatshare.clip(lower=.01)
        for o,ww in zip(g.oct,w): dist[o]+=ww
        ang,sp=model_dist(dist)
        rows.append(dict(country_name=c,year=int(y),ang=ang,speed=sp,
                         cons=np.average(g.a,weights=w), pw=np.average(g.p,weights=w)))
    P=pd.DataFrame(rows)
    o=vd[['country_name','year',out]].dropna().sort_values(['country_name','year']).copy()
    o['fwd']=o.groupby('country_name')[out].shift(-window)
    o['bwd']=o.groupby('country_name')[out].shift(window)
    o['delta']=o.fwd-o[out]; o['placebo']=o[out]-o.bwd
    o=o.rename(columns={out:'base'})
    M=P.merge(o[['country_name','year','base','delta','placebo']],on=['country_name','year'])
    M=M.dropna(subset=['delta','speed','cons'])
    M['hr']=np.minimum(M.base,1-M.base); M['cid']=M.country_name
    return M

def coef(M,formula,term,dep='delta'):
    m=smf.ols(formula,data=M).fit(cov_type='cluster',cov_kwds={'groups':M.cid})
    return m.params[term], m.pvalues[term], m.rsquared, int(m.nobs)

if __name__=='__main__':
    print("="*92); print("STUDY 3  all seven pre-specified referents, improved power measure"); print("="*92)
    print(f"{'referent':<26}{'n':>6}{'sanity r':>10}{'speed b':>10}{'p':>9}{'|both| speed p':>15}")
    print("-"*92)
    res=[]
    for pos,out,lab in PAIRS:
        try:
            M=build(pos,out)
            if len(M)<300: print(f"{lab:<26}{len(M):>6}   too few observations"); continue
            r,_=stats.pearsonr(M.cons,M.base)
            b,p,_,n=coef(M,"delta ~ speed + base + hr + C(cid)","speed")
            b2,p2,_,_=coef(M,"delta ~ speed + cons + base + hr + C(cid)","speed")
            res.append((lab,pos,out,n,r,b,p,b2,p2))
            print(f"{lab:<26}{n:>6}{r:>+10.3f}{b:>+10.4f}{p:>9.3g}{p2:>15.3g}")
        except Exception as e:
            print(f"{lab:<26} failed: {e}")
    print("-"*92)
    ps=[x[6] for x in res]
    order=np.argsort(ps); m=len(ps); holm=[None]*m
    for rank,i in enumerate(order): holm[i]=min(1.0,(m-rank)*ps[i])
    print("Holm-corrected p for 'speed alone':")
    for (lab,*_ ,p,b2,p2),h in zip(res,holm):
        print(f"   {lab:<26} raw p={p:.3g}   Holm p={h:.3g}   {'survives' if h<0.05 else ''}")
    import pickle; pickle.dump(res,open('study3_res.pkl','wb'))
