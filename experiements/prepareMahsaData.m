data = flb2mat('results/AV_190315.flb','read_case',5);
data = data.Data;
position = data(:,1);
torque = data(:,2);
desiredTorque = data(:,10);
samplingTime = 0.001;
%%
%Design a 2 sided filter with break frquency of 0.1 Hz
%Low pass filter the torque
%use the LPF torque for segmentation
%%
order = 2;
numLevels = 10;
minTQ = min(desiredTorque);
maxTQ = max(desiredTorque);
levels = linspace(minTQ,maxTQ,numLevels);
jumpIndex = cell(numLevels - 1,1);
for i = 5 : numLevels - 1
    commandLevels = [levels(i) levels(i+1)];
    [jumpStart,jumpEnd] = findSegment(desiredTorque,commandLevels);
    %f = find( jumpEnd < jumpStart + 2000);
    %jumpStart(f) = [];
    %jumpEnd(f) = [];
    jumpIndex{i} = [jumpStart jumpEnd];
    plot(desiredTorque)
    hold on
    for j = 1 : length(jumpStart)
        plot(jumpStart(j):jumpEnd(j),desiredTorque(jumpStart(j):jumpEnd(j)),'r')
    %plot(jumpEnd,desiredTorque(jumpEnd),'go')
        
    end
    pause
	close all
    positionSeg = segdat(position,'onsetPointer',jumpStart,...
            'segLength',jumpEnd-jumpStart,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
	torqueSeg = segdat(torque,'onsetPointer',jumpStart,...
            'segLength',jumpEnd-jumpStart,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
        z = cat(2,positionSeg,torqueSeg);
	sysID = pcas_short_segment_exp_new_intrinsic_irf1 (z,'maxordernle',8,'hanklesize',20,'delayinput',0.04,'orderselectmethod',order,'stationarity_check',0);
end

