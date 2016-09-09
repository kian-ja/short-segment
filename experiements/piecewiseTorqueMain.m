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
segmentOnsetEnd = jumpIndex{1};
segmentLength = 500;
position = segdat(position,'onsetPointer',segmentOnsetEnd(:,2)-segmentLength,'segLength',ones(size(segmentOnsetEnd,1),1)*segmentLength,'domainIncr',samplingTime...
,'comment','Position','chanNames','Joint angular position (rad)');
torque = segdat(torque,'onsetPointer',segmentOnsetEnd(:,2)-segmentLength,'segLength',ones(size(segmentOnsetEnd,1),1)*segmentLength,'domainIncr',samplingTime...
,'comment','Torque','chanNames','Joint torque (Nm)');
z = cat(2,position,torque);
%[intrinsic, reflex, tqI, tqR, tqT, vafs] = SS_SDSS_stiffnessID (z);
sysID = pcas_short_segment_exp_new_intrinsic_irf1 (z,'maxordernle',8,'hanklesize',20,'stationarity_check',0,'delayinput',0.03,'orderselectmethod',2);
disp(['Stiffness (K) is : ',num2str(-sum(sysID{1}.dataSet)/100)])
disp(['VAF total is : ,',num2str(num2str(sysID{3}(1)))])
disp(['VAF intrinsic is : ,',num2str(num2str(sysID{3}(2)))])
disp(['VAF reflex is : ,',num2str(num2str(sysID{3}(3)))])
reflex = sysID{2};
figure
subplot(1,2,1)
plot(reflex{1})
subplot(1,2,2)
plot(reflex{2})
[intrinsic, reflex, tqI, tqR, tqT] = SDSS_stiffnessID (nldat(z));
v = vaf(decimate(z(:,2),10),tqT);
disp(['VAF total using SDSS is : ,',num2str(num2str(v.dataSet))])