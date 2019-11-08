function frac = mol2frac(mol)
    MWe = 46.07;
    MWw= 18.01;
    y = 1-mol;
    frac = mol.*MWe./(mol*MWe+MWw*y)*100;
end