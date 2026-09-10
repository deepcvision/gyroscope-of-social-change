#!/bin/bash
# Fetch V-Dem and cache it as vdem.pkl (the pickle is ~1 GB, so it is not shipped).
curl -sSL -o vdem.RData \
  "https://raw.githubusercontent.com/vdeminstitute/vdemdata/master/data/vdem.RData"
python3 -c "
import pyreadr
r = pyreadr.read_r('vdem.RData')
list(r.values())[0].to_pickle('vdem.pkl')
print('cached vdem.pkl')
"
