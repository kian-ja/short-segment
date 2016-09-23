position = zeros(1200000,1);
torque = zeros(1200000,1);
emg = zeros(1200000,1);

for i = 1 : 10
    data = flb2mat('results/MG2_220916.flb','read_case',i);
    data = data.Data;
    position((i-1)*120000+1:i*120000) = data(:,1);
    torque((i-1)*120000+1:i*120000) = data(:,2);
    emg((i-1)*120000+1:i*120000) = abs(data(:,7));
end
subject1.position = position;
subject1.torque = torque;
subject1.emg = emg;
save results/experimentalTQVaryingData subject1


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


