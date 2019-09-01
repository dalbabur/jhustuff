
function show_ball_movie_with_wall2(t,x)
   hold off
   for i=1:50:length(t)
       hold off
       scatter(x(i),[0],500,'filled')
       hold on
       axis([min(x)-10 max(x)+10  -2 2])
       draw_wall(40)
       drawnow
   end