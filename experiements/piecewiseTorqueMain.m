%preparePieceWiseTorqueData%Run if data is not saved
clear
clc
close all
filePath = '/Users/kian/Documents/publication/Jalaleddini-Kearney-Short-Segment/experiment/torque varying/';
load '/Users/kian/Documents/publication/Jalaleddini-Kearney-Short-Segment/experiment/torque varying/dataPieceWiseTorque.mat'
%%
samplingTime = 0.001;
data = dataPieceWiseTorque{4};
position = data(:,1);
torque = data(:,2);
command = data(:,8);
    
commandLevels = [0.2 0.4; -0.1 0.1; -0.4 -0.2];
%commandLevels = [0.35 0.45; 0.045 0.055; -0.01 0.01; -0.055 -0.045 ; -0.45 -0.35];
jumpIndex = cell(size(commandLevels,1),1);

for i = 1 : size(commandLevels,1)
    [jumpStart,jumpEnd] = findSegment(command,commandLevels(i,:));
    f = find( jumpEnd < jumpStart + 2000);
    jumpStart(f) = [];
    jumpEnd(f) = [];
    jumpIndex{i} = [jumpStart jumpEnd];
    plot(command)
    hold on
    plot(jumpStart,command(jumpStart),'o')
    plot(jumpEnd,command(jumpEnd),'go')
    pause
    close all
end
%%
%clc
order = 2;
segmentOnsetEnd = jumpIndex{3};
segmentLength = 5000;
segmentOnsetEnd(:,1) = segmentOnsetEnd(:,2) - 5000;

monteCarloIteration = 100;
segmentLengthMC = 500;
segmentNunMC = 100;
for i = 1 : monteCarloIteration
    selectedSegment = randi([1 size(segmentOnsetEnd,1)],segmentNunMC,1);
    selectedSegmentOnset = randi([1 segmentLength-segmentLengthMC],segmentNunMC,1);
    onsetPointer = segmentOnsetEnd(selectedSegment,1) + selectedSegmentOnset;
    position = segdat(position,'onsetPointer',onsetPointer,...
    'segLength',ones(length(onsetPointer),1)*segmentLengthMC,'domainIncr',samplingTime...
    ,'comment','Position','chanNames','Joint angular position (rad)');
    torque = segdat(torque,'onsetPointer',onsetPointer,...
    'segLength',ones(length(onsetPointer),1)*segmentLengthMC,'domainIncr',samplingTime...
    ,'comment','Torque','chanNames','Joint torque (Nm)');
    z = cat(2,position,torque);
    sysID = pcas_short_segment_exp_new_intrinsic_irf1 (z,'maxordernle',8,'hanklesize',20,'delayinput',0.03,'orderselectmethod',order);
    
end


%[intrinsic, reflex, tqI, tqR, tqT, vafs] = SS_SDSS_stiffnessID (z);

disp(['Stiffness (K) is : ',num2str(-sum(sysID{1}.dataSet)/100)])
disp(['SS-SDSS VAF total is : ,',num2str(num2str(sysID{3}(1)))])
%disp(['VAF intrinsic is : ,',num2str(num2str(sysID{3}(2)))])
%disp(['VAF reflex is : ,',num2str(num2str(sysID{3}(3)))])
reflex = sysID{2};
figure
subplot(1,2,1)
plot(reflex{1})
subplot(1,2,2)
plot(reflex{2})
[intrinsic, reflex, tqI, tqR, tqT] = SDSS_stiffnessID (nldat(z),'orderselectmethod',order);
v = vaf(decimate(z(:,2),10),tqT);
disp(['SDSS VAF total  is : ,',num2str(num2str(v.dataSet))])