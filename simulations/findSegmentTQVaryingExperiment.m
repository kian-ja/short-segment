function [DFIndexJumpsStart,DFIndexJumpsEnd] = findSegmentTQVaryingExperiment(command,commandLevels,minSegLen)
if nargin < 3
    minSegLen = Inf;
end
DFIndex = find((command>commandLevels(1) & (command<commandLevels(2))));
DFIndexDiff = DFIndex(2:end) - DFIndex(1:end-1);
DFIndexDiff(DFIndexDiff<2) = 0;
DFIndexJumps = find((DFIndexDiff > 1));
DFIndexJumps = [1;DFIndexJumps;length(DFIndexDiff)];
DFIndexJumpsStart = DFIndex(DFIndexJumps(1:end-1)+10);
DFIndexJumpsEnd = DFIndex(DFIndexJumps(2:end)-10);

for i = 1 : length (DFIndexJumpsStart)
    jumpStartDiv10000 = floor(DFIndexJumpsStart(i)/10000);
    %DFIndexJumpsStartShift = DFIndexJumpsStart(i) - jumpStartDiv10000;
    DFIndexJumpsEndShift = DFIndexJumpsEnd(i) - jumpStartDiv10000*10000;
    if DFIndexJumpsEndShift>10000

        DFIndexJumpsStartNew = [DFIndexJumpsStart(1:i); (jumpStartDiv10000 + 1)*10000+1;DFIndexJumpsStart(i+1:end)];
        DFIndexJumpsEndNew = [DFIndexJumpsEnd(1:i-1); (jumpStartDiv10000 + 1)*10000;DFIndexJumpsEnd(i:end)];
        DFIndexJumpsStart = DFIndexJumpsStartNew;
        DFIndexJumpsEnd = DFIndexJumpsEndNew;
    end
end
f = find( DFIndexJumpsEnd < DFIndexJumpsStart + minSegLen);
DFIndexJumpsStart(f) = [];
DFIndexJumpsEnd(f) = [];

end