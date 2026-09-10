"""Apply CODING_PROTOCOL.md to a case and run the model. Coding is entered as a table
of (bloc, power, alignment, weight) derived from pre-decision material only."""
import numpy as np
CEN=np.array([22.5,67.5,112.5,157.5,202.5,247.5,292.5,337.5])
NAMES=['Reinforce','Negotiate in Opposition','Negotiate in Consensus','Reject',
       'Resist','Obey','Adapt','Encourage']
TYPE={0:'Rapid Change',45:'Radical Change',90:'Political Change',135:'Inertia',
      180:'Status Quo',225:'Withdrawal',270:'Passive Change',315:'Active Change'}
TA=np.array(sorted(TYPE))

def run(case, actors):
    dist=np.zeros(8); rows=[]
    for name,p,a,w in actors:
        th=np.degrees(np.arctan2(p,a))%360
        o=min(int(th//45),7); dist[o]+=w
        rows.append((name,p,a,w,th,NAMES[o]))
    d=dist/dist.sum()
    x=0.35*np.sum(d*np.cos(np.radians(CEN))); y=0.65*np.sum(d*np.sin(np.radians(CEN)))
    m=np.hypot(x,y)
    print("="*86); print(f"CASE: {case}"); print("="*86)
    print(f"{'bloc':<34}{'power':>7}{'align':>7}{'wt':>5}{'angle':>8}   octant")
    print("-"*86)
    for r in rows: print(f"{r[0]:<34}{r[1]:>+7.2f}{r[2]:>+7.2f}{r[3]:>5.0f}{r[4]:>7.1f}d   {r[5]}")
    print("-"*86)
    print("octant distribution:")
    for i,n in enumerate(NAMES):
        if d[i]>0: print(f"    {n:<26}{100*d[i]:>6.1f}%")
    if m<=1e-12:
        print("\n  PREDICTION: null vector, no direction, zero speed"); return
    nx,ny=x/m,y/m; ang=np.degrees(np.arctan2(ny,nx))%360
    dd=np.minimum(np.abs(ang-TA),360-np.abs(ang-TA))
    q=('Transformation' if nx>=0 and ny>=0 else 'Stabilisation' if nx<0<=ny
       else 'Segregation' if nx<0 else 'Mobilisation')
    print(f"\n  PREDICTION   direction {ang:.1f} deg   speed {m*(1+nx):.4f}")
    print(f"               change type: {TYPE[int(TA[np.argmin(dd)])]}")
    print(f"               quadrant   : {q}")

# ---- Brexit, referent "the UK leaves the EU", decision date 23 June 2016 ----------
# Every value below is from the public record on or before that date.
brexit=[
 ("HM Government (Cameron cabinet)",  +1.00, -1.00, 10),  # officially Remain
 ("House of Commons majority",        +0.70, -0.50, 15),  # ~3/4 of MPs pro-Remain
 ("Conservative parliamentary party", +0.40,  0.00, 20),  # publicly split near 50/50
 ("Labour parliamentary party",       +0.28, -1.00, 14),  # officially Remain
 ("SNP",                              +0.07, -1.00,  5),  # officially Remain
 ("UKIP",                             +0.00, +1.00,  5),  # committed Leave
 ("CBI / business federations",       +0.20, -1.00,  8),  # officially Remain
 ("TUC / unions",                     +0.20, -0.50,  5),  # Remain with reservations
 ("Pro-Leave national press",          0.00, +1.00,  8),  # committed Leave
 ("Mass public (referendum result)",  -0.60, +0.04, 10),  # 51.9% Leave -> 2(.519)-1
]
run("Brexit — UK leaves the EU (decision 23 June 2016)", brexit)
