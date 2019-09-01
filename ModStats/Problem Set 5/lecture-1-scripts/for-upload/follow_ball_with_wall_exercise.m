function [tout,xout] = follow_ball_with_wall_exercise(t0,tf)
    s= 1;
    h = 0.001;
    x_wall = 40;
    xout(1) = 0;
    vx = 5;
    for i=(t0+h):h:tf
        s = s + 1;
        % Fill in here!
        tout(s) = i;
        xout(s) =  xout(s-1) + vx*h;
    end
