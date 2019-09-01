


function show_ball_movie(t,x)
   hold off
   for i=1:50:length(t)
       scatter(x(i),[0],500,'filled')
       axis([0 75 -2 2])
       drawnow

   end