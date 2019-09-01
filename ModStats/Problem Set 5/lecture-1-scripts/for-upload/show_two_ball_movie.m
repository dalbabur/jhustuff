
function show_two_ball_movie(t,x)
   hold off
   for i=1:50:length(t)
       hold off
       scatter(x(i,1),[0],700,[0.9 0.5 0.05],'filled')
       hold on
       scatter(x(i,2),[0],700,[0.9 0.05 0.1],'filled')
       axis([min(min(x))-10 max(max(x))+10  -2 2])
       draw_wall(40)
       draw_wall(-10)
       drawnow
   end