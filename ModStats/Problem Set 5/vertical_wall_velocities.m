function [vx2,vy2]=vertical_wall_velocities(vx1,vy1)
    [vx2,vy2]=deal([vx1,vy1].*[-1,1]);
end