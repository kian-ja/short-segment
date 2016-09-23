clear
load results/filterTorque
position = [];
torque = [];
emg = [];
voluntaryTorque = [];
figure
time = 0 : 0.001: 120 - 0.001;
freq = 2 * pi * 0.1;
for i = 1 : 10
    data = flb2mat('results/MG2_220916.flb','read_case',i);
    data = data.Data;
    positionThisTrial = data(:,1) - mean(data(:,1));
    emgThisTrial = abs(data(:,7));
    torqueThisTrial = data(:,2) - mean(data(:,2));
    voluntaryTorqueThisTrial = nlsim(filterTorque,nldat(torqueThisTrial,'domainIncr',0.001));
    voluntaryTorqueThisTrial = voluntaryTorqueThisTrial.dataSet;
    voluntaryTorqueThisTrial = smooth(voluntaryTorqueThisTrial,1500);
    [amplitude,phase] = fitSinusoid(time', voluntaryTorqueThisTrial);
    voluntaryTorquePredicted = amplitude * sin (2*pi*0.1*time +phase);
    if phase < 0
        samplesTrim = floor(-phase/freq*1000);
    else
        samplesTrim = floor((2*pi-phase)/freq*1000);
    end
    endOfTrial = 0;
    freqSample = 10000;
    k = 1;
    while (~endOfTrial)
        if (k*freqSample+samplesTrim > length(torqueThisTrial))
            endOfTrial = 1;
        else
            positionThisPeriod = positionThisTrial((k-1)*freqSample+1+samplesTrim:k*freqSample+samplesTrim);
            torqueThisPeriod = torqueThisTrial((k-1)*freqSample+1+samplesTrim:k*freqSample+samplesTrim);
            emgThisPeriod = emgThisTrial((k-1)*freqSample+1+samplesTrim:k*freqSample+samplesTrim);
            voluntaryTorqueThisPeriod = voluntaryTorqueThisTrial((k-1)*freqSample+1+samplesTrim:k*freqSample+samplesTrim);
%             subplot(2,1,1)
%             clf
%             plot(positionThisPeriod)
%             subplot(2,1,2)
            clf
            plot(torqueThisPeriod)
            hold on
            plot(voluntaryTorqueThisPeriod,'lineWidth',2)
            accept = input('accept(y/n)?','s');
            if accept == 'y'
                position = [position;positionThisPeriod];
                torque = [torque;torqueThisPeriod];
                emg = [emg;emgThisPeriod];
                voluntaryTorque = [voluntaryTorque;voluntaryTorqueThisPeriod];
            end
            close
        end
        k = k + 1;
    end
end
%%
subject1.position = position;
subject1.torque = torque;
subject1.emg = emg;
subject1.voluntaryTorque = voluntaryTorque;
save results/experimentalTQVaryingData subject1
%%

figure
time = 0:0.001:10-0.001;
subplot(3,1,1)
plot(time, position(16001:26000));
title('Position')
ylabel('Position (rad)')
set(gca,'Xtick',[],'XTickLabel',[])

box off
subplot(3,1,2)
plot(time, torque(16001:26000));
ylim([-25,10])
box off
title('Torque')
ylabel('torque (Nm)')
set(gca,'Xtick',[],'XTickLabel',[])
set(gca,'Ytick',[-20,-10,0,10],'YTickLabel',[-20,-10,0,10])
subplot(3,1,3)

plot(time, emg(16001:26000));
box off
title('Gastrocnemius EMG')
xlabel('Time (s)')
ylabel('EMG (mv)')
set(gca,'Xtick',[0:2:10],'XTickLabel',{0,2,4,6,8,10})


