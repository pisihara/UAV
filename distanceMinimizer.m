function [fleetManager,reqManager]=distanceMinimizer(fleetManager,reqManager,activerequests)
    n=length(activerequests);   m=fleetManager.numUAVS;
 %% Find weighted distances between UAVs and Requests
  for i=1:n
    for j=1:m
    d(i,j)= min([10^9,reqManager(activerequests(i,1),1).priority+(1/fleetManager.UAV(j,1).speed) * sqrt((reqManager(activerequests(i,1),1).x - fleetManager.UAV(j,1).x)^2 + (reqManager(activerequests(i,1),1).y - fleetManager.UAV(j,1).y)^2)]);
    end
  end        
 %% Optimize assignment of UAVs to requests 
 for i=1:m
     fleetManager.UAV(i,1).requestID=0; %%unassign all UAVs
 end
 
 if n >= m
   %% Choose m out of numREQ
     c = combnk(1:n,m);
   %% find smallest length
     for i=1:nchoosek(n,m)
       distance(i,1)=0;
         for j=1:m
         distance(i,1)= distance(i,1) + d(c(i,j),j);     
         end
     end
    [~,besti]=min(distance(:,1));
    for j=1:m
       fleetManager.UAV(j,1).requestID=activerequests(c(besti,j),1);
       reqManager(activerequests(c(besti,j),1),1).status=1; %% Request is being responded to
    end
    
 elseif m>n
    %%choose n of m UAVS
     c = combnk(1:m,n);
      for j=1:nchoosek(m,n)
      distance(1,j)=0;
         for i=1:n
         distance(1,j)= distance(1,j) + d(i,c(j,i));
         end
      end
     [~,bestj]=min(distance(1,:));  %% UAV c(bestj,1)->R1,...,UAV c(bestj,n)->Rn  
        
     for j=1:n
     fleetManager.UAV(c(bestj,j),1).requestID=activerequests(j,1);
     reqManager(activerequests(j,1),1).status=1; %% Request is being responded to
     end
  end     
             
end
    