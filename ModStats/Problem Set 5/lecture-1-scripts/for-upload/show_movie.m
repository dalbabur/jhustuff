
function show_movie(t,x)
   figure(1)
   hold off

   for i=1:50:length(t)
       figure(1)
       scatter(x(i),[0],500,'filled')
       axis([0 75 -2 2])
       drawnow

   end