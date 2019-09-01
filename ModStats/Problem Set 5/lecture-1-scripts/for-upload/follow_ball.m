function [tout,xout] = follow_ball(t0,tf)
    s= 1;
   h = 0.001;
   xout(1) = 0;
   vx = 5;
    for i=(t0+h):h:tf
         s = s + 1;
         tout(s) = i;
         xout(s) =  xout(s-1) + vx*h;
     end
