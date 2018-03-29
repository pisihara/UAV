%% Main Script for Puerto Rico UAV Disaster Response Fleet NEWER VERSION

clear all; close all; format long;
simdata='UAV.xlsx'; %% where output data is recorded
%% SIMULATION PARAMETERS
numsim=10;  %% number of simulations
steps=80;  %% total number of time steps in simulation 
deltat=15; %% time increment reprsented by 1 step (in minutes)
k=1/3;  %% mean steps between requests is 1/k 
lospeed=50;  %% slower UAV speed (pixel/time step)
hispeed=100; %% faster UAV speed 

for n=1:numsim  %% Main loop to execute simulation run #n
    day(1,n)=n;
clear requestTime
%% Create Map
figure
MAP=imread('PuertoRico.png'); image(MAP); axis=[0 900 100 450]; hold on;  
rect=[150 200 400 150];
%% Create new UAV fleet 
clear PRfleet;
PRFleet=fleetManager; %% manages Puerto Rico UAV fleet
PRFleet.map='PuertoRico.png'; %% UAV Fleet is deployed to Puerto Rico
PRFleet.numUAVS=5;       %%Size of UAV fleet
PRFleet.hiSpeedUAVS=1;   %% Number of Hi-Speed UAVs
PRFleet.totalDistance=0;  %%Keep track of distance travelled by all UAVs in the fleet
%% Create Home Bases of UAVs 
for i=1:2
PRFleet.base(5*(i-1)+1,1)=700; PRFleet.base(5*(i-1)+1,2)=150;  %Base 1&6 coordinates:  x=700  y-150 
PRFleet.base(5*(i-1)+2,1)=800; PRFleet.base(5*(i-1)+2,2)=300;  %Base 2 
PRFleet.base(5*(i-1)+3,1)=320; PRFleet.base(5*(i-1)+3,2)=120;  %Base 3   
PRFleet.base(5*(i-1)+4,1)=90; PRFleet.base(5*(i-1)+4,2)=300;  %Base 4  
PRFleet.base(5*(i-1)+5,1)=225; PRFleet.base(5*(i-1)+5,2)=400;  %Base 5 
end
%% Specify Individual UAV Properties
 for i=1:PRFleet.numUAVS
 PRFleet.UAV(i,1).ID=i; %% Create UAV
 PRFleet.UAV(i,1).speed=lospeed; %%speed 
 PRFleet.UAV(i,1).payload=10; %% in kg
 PRFleet.UAV(i,1).x=PRFleet.base(i,1); %%  station UAVs 
 PRFleet.UAV(i,1).y=PRFleet.base(i,2); %%  
 PRFleet.UAV(i,1).requestID=0; %% Initially all UAVs are unassigned
 PRFleet.UAV(i,1).distance=0;  %% Initially UAVs have not travelled (pixles)
 PRFleet.UAV(i,1).priority=1; 
 end
 for i=1:PRFleet.hiSpeedUAVS
 PRFleet.UAV(i,1).speed=hispeed; %%Increase higher speed UAVs
 end
 %% Plot UAV Bases 
 for i=1:5
  text(PRFleet.base(i,1),PRFleet.base(i,2),strcat('[]FLEET BASE',num2str(i)),'color','blue','FontSize',10);
  hold on;
 end
%% Create new request manager 
 clear PRreqManager
 PRreqManager=requestManager;
 %% Specify first request
 clear requestData;
 requestID=1;  requestData(1,1)=1; 
 requestData(1,2)=1; % 1st request marks beginning of simulation
 [PRreqManager, requestData, activeRequests, PRFleet]=newRequest(PRreqManager,requestID,requestData,PRFleet,k,1);
  %% Update map showing response to first request
    [PRFleet,PRreqManager,requestData]=PRFleet.plot(PRreqManager,1,requestID,requestData);
    text(-100,-30, num2str(1),'color','black','FontSize',4); %% mark step on map      
     hold on;
  %% Generate next request   
  requestID=requestID+1;
  [PRreqManager, requestData, activeRequests, PRFleet] =newRequest(PRreqManager,requestID,requestData, PRFleet, k,1);    

  %% Beginning of Main loop for simulation
 for simStep=2:steps  %% simStep keeps track of simulation step number
 pause(1)
 requestData(simStep,1)=simStep; %% keep track of simulation step
 if simStep<=floor(steps/2)
 text(-100+20*(simStep-1),-30, num2str(simStep),'color','black','FontSize',4); %% mark step on map   
 else
 text(-100+20*(simStep-floor(steps/2)),-10, num2str(simStep),'color','black','FontSize',4); %% mark step on map 
 end
 hold on;
  
%% Process Current Requests (No new request)
   if simStep<requestData(requestID,2) 
    %% Create list of active requests
    j=0;
    clear activeRequests;
     for i=1:requestID
      if PRreqManager(i,1).status ~= 2 & simStep > requestData(i,2)
             j=j+1;
      activeRequests(j,1)=PRreqManager(i,1).ID;
      end
     end
   %% Optimize Fleet Assignment
     if j>0
     [PRFleet PRreqManager]=distanceMinimizer(PRFleet,PRreqManager,activeRequests);
     end
   %% Update map showing response to active requests
     [PRFleet,PRreqManager,requestData]=PRFleet.plot(PRreqManager,simStep,requestID,requestData);
     hold on;
   end

  %% Process a New Request
    if simStep>=requestData(requestID,2) 
    requestID=requestID+1;
    [PRreqManager, requestData, activeRequests, PRFleet] =newRequest(PRreqManager,requestID,requestData, PRFleet, k,simStep);
    %% Update map showing response to active requests
    [PRFleet,PRreqManager,requestData]=PRFleet.plot(PRreqManager,simStep,requestID,requestData);
     hold on;
    end 
 end
%% Compute simulation statistics for run #n
  summarydata(n,1)=PRFleet.numUAVS; %% #UAVs
  summarydata(n,2)=PRFleet.hiSpeedUAVS; %% # hi-speed UAVs
  summarydata(n,3)=requestID;  %% total requests
  summarydata(n,4)=0; %% number hi priority requests
  summarydata(n,5)=0; %% number lo priority requests
  summarydata(n,6)=0;  %% number responses completed
  summarydata(n,7)=0;  %% number HP response completed
  summarydata(n,8)=0; %% number LP responses completed
  summarydata(n,9)=0;  %% total time for completed responses
  summarydata(n,10)=0;  %%hi priority response time
  summarydata(n,11)=0; %% lo priority response time
  summarydata(n,12)=0;  %% total mean response time
  summarydata(n,13)=0;  %% mean hi priority response time
  summarydata(n,14)=0; %% mean lo priority response time
 for i=1:length(requestData(:,1))  %% Priority of requests
    if requestData(i,3)==1
    summarydata(n,4)= summarydata(n,4)+1;
    end
    if requestData(i,3)==1000
    summarydata(n,5)= summarydata(n,5)+1;    
    end
    if requestData(i,4)>0  %%Total number and time to complete requests
    summarydata(n,6)=summarydata(n,6)+1;
    summarydata(n,9)=summarydata(n,9)+requestData(i,6);
    end
   if requestData(i,4)>0 & requestData(i,3)==1  %% HP number and completion time
    summarydata(n,7)=summarydata(n,7)+1;
    summarydata(n,10)=summarydata(n,10)+requestData(i,6);
   end
   if requestData(i,4)>0 & requestData(i,3)==1000  %% LP number and completion time
    summarydata(n,8)=summarydata(n,8)+1;
    summarydata(n,11)=summarydata(n,11)+requestData(i,6);
   end
 end
 summarydata(n,12)=summarydata(n,9)/ summarydata(n,6);  %%mean responsetime (all requests)
 summarydata(n,13)=summarydata(n,10)/summarydata(n,7);  %%mean HP response time
 summarydata(n,14)=summarydata(n,11)/summarydata(n,8);  %% mean LP responses time

 %% Compute UAV flight distance
 summarydata(n,15)=0; %%total flight distance for simulation n
 for i=1:PRFleet.numUAVS
  if PRFleet.UAV(i,1).distance(1,1)>0
  summarydata(n,15+i)=round(PRFleet.UAV(i,1).distance(1,1)/5.2781);  %% summarydata(n,13+i) gives UAV i flight distance
  else
  summarydata(n,15+i)=0;
  end
  summarydata(n,15)=summarydata(n,15)+summarydata(n,15+i);
 end
end   %% End of simulation runs

%% Compute Stats for all Simulations
mtfd=0; %%mean total flight distance
mtr=0;  %% mean total requests
mrc=0;  %% mean requests completed=0;
mhpr=0; %% mean number hp requests
mhprc=0; %% mean number hp requests completed
mhprt=0; %% mean hp response time
mlpr=0; %% mean number lp requests
mlprc=0;  %%mean lp requests completed 
mlprct=0; %% mean lo priority completion time

for i=1:numsim
mtfd= mtfd +summarydata(i,15);
mtr=mtr+summarydata(i,3);
mrc=mrc+summarydata(i,6);
mhpr=mhpr+summarydata(i,4);
mhprc=mhprc+summarydata(i,7);
mhprt=mhprt+summarydata(i,13);
mlpr=mlpr+summarydata(i,5);
mlprc=mlprc+summarydata(i,8);
mlprct=mlprct+summarydata(i,14);
end
mtfd=mtfd/numsim; mtr=mtr/numsim;  mrc=mrc/numsim; 
mhpr=mhpr/numsim; mhprc=mhprc/numsim; mhprt=mhprt/numsim; 
mlpr=mlpr/numsim; mlprc=mlprc/numsim; mlprct=mlprct/numsim;

cumulative(1,n)=numsim;  %% number of simulations
cumulative(2,n)=steps;  %% number of time steps in each simulation 
cumulative(3,n)=deltat; %% time increment represented by 1 step (in minutes)
cumulative(4,n)=k;  %%mean steps between requests is 1/k 
cumulative(5,n)=PRFleet.numUAVS; %% #UAVs
cumulative(6,n)=lospeed;  %% lo speed UAV
cumulative(7,n)=hispeed;  %% hi speed UAV
cumulative(8,n)=mtfd; % mean total flight distance 
cumulative(9,n)=mtr; % mean total requests 
cumulative(10,n)=mrc;  %% mean requests completed=0;
cumulative(11,n)=mhpr; %% mean number hp requests
cumulative(12,n)=mhprc; %% mean number hp requests completed
cumulative(13,n)=mhprt; %% mean hp response time
cumulative(14,n)=mlpr; %% mean number lp requests
cumulative(15,n)=mlprc;  %%mean lp requests completed 
cumulative(16,n)=mlprct; %% mean lo priority completion time

%% Summary Plot of All Simulations  
for i=1:n
 sim(i,1)=i;
 hi(i,1)=summarydata(i,13);
 lo(i,1)=summarydata(i,14);
end
 him=mean(hi(:,1));
 lom=mean(lo(:,1));
for i=1:n
 himean(i,1)=him;
 lomean(i,1)=lom;
end
figure
plot(sim,hi,'r');
hold on;
plot(sim,himean,'--r');
hold on;
plot(sim,lo,'b');
hold on;
plot(sim,lomean,'--b');
hold on
legend('Hi Priority Response Time','Mean Hi Priority',  'Lo Priority Response Time','Mean Lo Priority','location','southwest');
xlabel('Simulation Number');
ylabel('# Steps (1 step=15 min.) ');
