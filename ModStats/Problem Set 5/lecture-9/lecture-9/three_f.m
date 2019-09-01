
function out = three_f(in)

x = in(1);
y = in(2);
z = in(3);

out(1) = sin(x) + y.^2 + log(z) - 7;
out(2) = 3*x + 2^y - z^3 + 1;
out(3) = x+y+z-5;
