function rectangle=RequestLocation
% Our map of Puerto Rico is partitioned into 11 rectangular regions. There are 
% 11 rectangular regions from which a UAV could be requested.
% Generate a random number to see which rectangle the request came from, 
% giving higher probabilities to regions where there is more than one
% hospital. 
   p = rand();
   if ((0<=p)&&(p<=0.06))         % Rectangle 1
       xmin = 50;
       xmax = 150;
       ymin = 120;
       ymax = 280;
      elseif((0.06<p)&&(p<=0.12))    % Rectangle 2
       xmin = 150;
       xmax = 350;
       ymin = 120;
       ymax = 200;
   elseif((0.12<p)&&(p<=0.18))    % Rectangle 3
       xmin = 350;
       xmax = 550;
       ymin = 120;
       ymax = 200;
   elseif((0.18<p)&&(p<=0.48))   % Rectangle 4: There are five hospital in this region
       xmin = 550;               % hence the 30% probability.
       xmax = 820;
       ymin = 120;
       ymax = 320;
   elseif((0.48<p)&&(p<=0.54))   % Rectangle 5
       xmin = 820;
       xmax = 940;
       ymin = 200;
       ymax = 300;
   elseif((0.60<p)&&(p<=0.66))   % Rectangle 6
       xmin = 700; 
       xmax = 820;
       ymin = 320;
       ymax = 480;
   elseif((0.66<p)&&(p<=0.72))   % Rectangle 7
       xmin = 550;
       xmax = 700;
       ymin = 320;
       ymax = 500;
    elseif((0.72<p)&&(p<=0.78))   % Rectangle 8
       xmin = 350;
       xmax = 550;
       ymin = 350;
       ymax = 480;
   elseif((0.78<p)&&(p<=0.84))   % Rectangle 9
       xmin = 150;
       xmax = 350;
       ymin = 350;
       ymax = 480;
     elseif((0.84<p)&&(p<=0.90))   % Rectangle 10
       xmin = 40;
       xmax = 150;
       ymin = 280;
       ymax = 480;
     else                          % Rectangle 11
       xmin = 150;
       xmax = 550;
       ymin = 200;
       ymax = 350;
   end
   rectangle=[xmin xmax ymin ymax];





