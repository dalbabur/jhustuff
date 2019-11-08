function mol = frac2mol(frac)
    frac = frac/100;
    MWe = 46.07;
    MWw= 18.01;
    y = 1-frac;
    e = frac/MWe;
    w = y/MWw;
    mol = e./(e+w);

end