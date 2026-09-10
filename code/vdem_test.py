"""Pilot test of the Gyroscope model against V-Dem. Reproduces empirical/RESULTS.md.

Requires: pyreadr, pandas, numpy, scipy, statsmodels
Data:     https://raw.githubusercontent.com/vdeminstitute/vdemdata/master/data/vdem.RData
"""
import pandas as pd, numpy as np, statsmodels.formula.api as smf
from scipy import stats

df = pd.read_pickle('vdem.pkl')          # produced by pyreadr.read_r('vdem.RData')
z  = lambda s: (s - s.mean()) / s.std()

def build(outcome='v2x_polyarchy', window=5, power='v2pepwrsoc'):
    d = df[['country_id','year','v2cacamps',outcome,power]].copy()
    d = d[(d.year >= 1990) & (d.year <= 2020)].dropna()
    d = d.sort_values(['country_id','year'])
    d['delta']    = d.groupby('country_id')[outcome].shift(-window) - d[outcome]
    d = d.dropna(subset=['delta'])
    d['A'] = np.clip(-z(d.v2cacamps)/2.5, -1, 1)      # consensus
    d['P'] = np.clip(-z(d[power])/2.5,     -1, 1)      # power concentration
    rx, ry = 0.35*d.A, 0.65*d.P
    mag = np.hypot(rx, ry); nx = rx / mag.replace(0, np.nan)
    d['speed']    = mag * (1 + nx)                     # corrected, signed
    d['speed_sym']= mag * (1 + nx.abs())               # old, symmetric
    d['absdelta'] = d.delta.abs()
    d['bl'] = d[outcome]; d['hr'] = np.minimum(d.bl, 1-d.bl)
    d['cid'] = d.country_id.astype(int).astype(str)
    return d.dropna(subset=['speed','absdelta'])

if __name__ == '__main__':
    d = build()
    print('n =', len(d), 'countries =', d.cid.nunique())
    for nm, v in [('signed','speed'), ('symmetric','speed_sym')]:
        r, p = stats.pearsonr(d[v], d.absdelta)
        print(f'  {nm:<10} r={r:+.4f} p={p:.2e}')
    for lab, f in [('no controls',  'absdelta ~ speed'),
                   ('+ level/room', 'absdelta ~ speed + bl + hr'),
                   ('+ country FE', 'absdelta ~ speed + bl + hr + C(cid)'),
                   ('+ year FE',    'absdelta ~ speed + bl + hr + C(cid) + C(year)')]:
        m = smf.ols(f, data=d).fit(cov_type='cluster', cov_kwds={'groups': d.cid})
        print(f'  {lab:<14} b={m.params["speed"]:+.4f} p={m.pvalues["speed"]:.3g}')
