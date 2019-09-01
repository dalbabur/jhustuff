function [tout,yout] = my_forward_euler(func,t0,tf,init,step_size)
    step_num = 1;
    yout(1) = init;
    for i=(t0+step_size):step_size:tf
         step_num = step_num + 1;
         tout(step_num) = i;
         yout(step_num) =  yout(step_num-1) + ...
             func(yout(step_num-1),i-step_size)*step_size;
    end