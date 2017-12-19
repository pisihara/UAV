classdef fleetManager  %%manages all UAVs
    properties
        map   %% ontains map file of response regiob
        numUAVS  %% number of UAVs in the fleet
        hiSpeedUAVS %% humber of hi-speed UAVS
        numIdle  %% number of UAVs currently idle
        base     %% (i,1)=x coord   (i,2)= y coord  (i,3) = number of UAV at base 
        UAV      %% ID; speed; payload; x; y; requestID
        totalDistance  %%Total distance taveled by all UAVs [pixles, kilometers]
      end
    
    methods
        function path(obj,ID,x0,x1,y0,y1,numpts,priority)     
          if priority ==1 
              linecolor='red';
          else
              linecolor='blue';
          end
          text(obj.UAV(ID,1).x,obj.UAV(ID,1).y,num2str(ID),'color',linecolor,'FontSize',5);
          hold on;
           dx=x1-x0;
           dy=y1-y0;
           for pt=1:numpts
            x(pt,1)=x0+pt*dx/numpts;
            y(pt,1)=y0+pt*dy/numpts;
           end
           plot(x,y,'color',linecolor)
           hold on;
        end
        
               
        function [obj,requestManager,requestData]=plot(obj, requestManager,simStep,requestID,requestData)
        
          %% Plot Location of all Requests 
          for j=1:requestID
          if requestManager(j,1).priority==1
          text(requestManager(j,1).x,requestManager(j,1).y,strcat('X',num2str(j)),'color','red','FontSize',8);
          hold on;
          end
          if requestManager(j,1).priority>1
          text(requestManager(j,1).x,requestManager(j,1).y,strcat('X',num2str(j)),'color','blue','FontSize',8);
          hold on; 
          end
          end  
                   
        %% Compute the UAV flight path
     for i=1:obj.numUAVS
         if obj.UAV(i,1).requestID > 0
            x0(i,1)=obj.UAV(i,1).x;
            y0(i,1)=obj.UAV(i,1).y;
            x1(i,1)=requestManager(obj.UAV(i,1).requestID,1).x;
            y1(i,1)=requestManager(obj.UAV(i,1).requestID,1).y;
            flightdistance(i,1)=sqrt((x0(i,1)-x1(i,1))^2+(y0(i,1)-y1(i,1))^2);
            numsteps(i,1)=floor(flightdistance(i,1));
            xdirection(i,1)=(x1(i,1)-x0(i,1))/numsteps(i,1);
            ydirection(i,1)=(y1(i,1)-y0(i,1))/numsteps(i,1);
         %% Simulate the flight path
         if obj.UAV(i,1).speed<flightdistance(i,1)
            obj.UAV(i,1).x=x0(i,1)+obj.UAV(i,1).speed*xdirection(i,1);
            obj.UAV(i,1).y=y0(i,1)+obj.UAV(i,1).speed*ydirection(i,1);
            obj.path(i,x0(i,1),obj.UAV(i,1).x,y0(i,1),obj.UAV(i,1).y,50,requestManager(obj.UAV(i,1).requestID,1).priority) 
         end
         %% COMPLETION OF A REQUEST       
            if  obj.UAV(i,1).speed>=flightdistance(i,1) && requestManager(obj.UAV(i,1).requestID,1).status<2
            laststeptime=flightdistance(i,1)/obj.UAV(i,1).speed;
            requestData(obj.UAV(i,1).requestID,4)=round(simStep+laststeptime+1,2);  %% time completed
            requestData(obj.UAV(i,1).requestID,5)=obj.UAV(i,1).ID ;  %% UAV completing request
            requestData(obj.UAV(i,1).requestID,6)=requestData(obj.UAV(i,1).requestID,4)-requestData(obj.UAV(i,1).requestID,2);  %% time to complete request
            
            obj.UAV(i,1).x=requestManager(obj.UAV(i,1).requestID,1).x;  %% Move UAV to request location
            obj.UAV(i,1).y=requestManager(obj.UAV(i,1).requestID,1).y;
            if  requestManager(obj.UAV(i,1).requestID,1).priority==1;
             obj.path(i,x0(i,1),obj.UAV(i,1).x,y0(i,1),obj.UAV(i,1).y,50,requestManager(obj.UAV(i,1).requestID,1).priority);             
             hold on;
            else
             obj.path(i,x0(i,1),obj.UAV(i,1).x,y0(i,1),obj.UAV(i,1).y,50,requestManager(obj.UAV(i,1).requestID,1).priority);
             hold on;
            end      
            requestManager(obj.UAV(i,1).requestID,1).status=2;  %%request has been fulfilled
            requestManager(obj.UAV(i,1).requestID,1).completiontime=requestData(obj.UAV(i,1).requestID,4); %%mark completion time
            end
         %%Update flight distances
         obj.totalDistance = obj.totalDistance + sqrt((x0(i,1)-obj.UAV(i,1).x)^2 +(y0(i,1)-obj.UAV(i,1).y)^2); 
         obj.UAV(i,1).distance=  obj.UAV(i,1).distance + sqrt((x0(i,1)-obj.UAV(i,1).x)^2 +(y0(i,1)-obj.UAV(i,1).y)^2);        
       end
     end
    end
   end
end
 