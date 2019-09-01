function [contact] = at_vertical_wall(x,y,vx,vy,wallx,tstep,r)
    contact = x+vx*tstep+r >= wallx || x+vx*tstep-r <= -wallx ;
end