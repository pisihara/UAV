classdef requestManager
    properties
       ID             %% each request is assigned an ID number
       type           %% medical=1  food/water=2
       timeofrequest  %% time request was received  eg. 14.27
       priority       %% 1=hi  1000=lo  
       x              %% x coordinate of delivery location
       y              %% y coordinate of delivery location
       status         %% 0=unassigned  1=assigned   2=completed
       completiontime %% Keeps track of time of completion time
       end
    
    methods
        function [obj, requestData, activeRequests, fleet] =newRequest(obj,requestID,requestData,fleet,k, simStep)
            requestData(requestID,1)=requestID; %% 1st column of RequestData contains Request ID
            obj(requestID,1).ID=requestID;  
            obj(requestID,1).status=0; %% Request is not yet assigned 
            type=1;  %% Allows for various types of hi/lo priority requests
            obj(requestID,1).type=1;
            %% New Request Priority
            if rand <.75  %% 75% chance that request is lo priority
            priority=1000;   %% 1000 = lo priority; 1=hi priority.
            else
            priority=1; 
            end
            requestData(requestID,3)=priority;
            obj(requestID,1).priority=requestData(requestID,3);
            %% New Request Location
            rectangle=requestLocation;  %% Randomizes location of request 
            x = rand(); y=rand;
            obj(requestID,1).x = rectangle(1,1) + x*(rectangle(1,2)-rectangle(1,1));  % x-coordinate 
            obj(requestID,1).y = rectangle(1,3) + y*(rectangle(1,4)-rectangle(1,3));  % y-coordinate  
%             % Plot location
%             text(obj(requestID,1).x,obj(requestID,1).y,strcat('X',num2str(requestID)),'color','blue','FontSize',8);
%             hold on;
            %% New Request Time
            p = rand;  %% Randomize Time of request
            if requestID>1
            requestData(requestID,2)= requestData(requestID-1,2)+round(log(1-p)/(-k),2);    %% Time of new request 
            else
            requestData(requestID,2)= 1;     
            end
            obj(requestID,1).timeofrequest=requestData(requestID,2);
            
            %% Update activeRequests
            j=0;
            clear activeRequests;
            for i=1:requestID
            if obj(i,1).status ~= 2 & simStep >= requestData(i,2)
            j=j+1;
            activeRequests(j,1)=obj(i,1).ID;
            end
            end
            
             %% Optimize Fleet Assignment
             if j>0
            [fleet obj]=distanceMinimizer(fleet,obj,activeRequests);
             else
            activeRequests(1,1)=0;
            end
        end
    end
end