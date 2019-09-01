function [contact] = at_horizontal_wall(x,y,vx,vy,wally,tstep,r)
    contact = y+vy*tstep+r >= wally || y+vy*tstep-r <= -wally;
end