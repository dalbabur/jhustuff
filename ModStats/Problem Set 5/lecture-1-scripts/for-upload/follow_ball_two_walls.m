function [tout,xout] = follow_ball_two_walls(t0,tf)
    s= 1;
    h = 0.0011;
    xwall1 = -10;
    xwall2 = 40;
    xout(1) = 0;
    vx = 5;
    r = 2;  % Marker size and r correspond
    for i=(t0+h):h:tf
        s = s + 1;
        if xout(s-1) > (xwall2-r) || xout(s-1) < (xwall1 + r)
            vx = -vx;
        end
        tout(s) = i;
        xout(s) =  xout(s-1) + vx*h;
    end
