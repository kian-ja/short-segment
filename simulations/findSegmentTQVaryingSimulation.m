function [DFIndexJumpsStart,DFIndexJumpsEnd] = findSegmentTQVaryingSimulation(command,commandLevels,minSegLen)
if nargin < 3
    minSegLen = Inf;
end
excludeTransitions = 1;
transitionInterval = 60000;
DFIndex = find((command>commandLevels(1) & (command<commandLevels(2))));
DFIndexDiff = DFIndex(2:end) - DFIndex(1:end-1);
DFIndexDiff(DFIndexDiff<2) = 0;
DFIndexJumps = find((DFIndexDiff > 1));
DFIndexJumps = [1;DFIndexJumps;length(DFIndexDiff)];
DFIndexJumpsStart = DFIndex(DFIndexJumps(1:end-1)+10);
DFIndexJumpsEnd = DFIndex(DFIndexJumps(2:end)-10);
if excludeTransitions
    for i = 1 : length (DFIndexJumpsStart)
        jumpStartDiv60000 = floor(DFIndexJumpsStart(i)/transitionInterval);
        %DFIndexJumpsStartShift = DFIndexJumpsStart(i) - jumpStartDiv10000;
        DFIndexJumpsEndShift = DFIndexJumpsEnd(i) - jumpStartDiv60000*transitionInterval;
        if DFIndexJumpsEndShift>transitionInterval
            DFIndexJumpsStartNew = [DFIndexJumpsStart(1:i); (jumpStartDiv60000 + 1)*transitionInterval+4;DFIndexJumpsStart(i+1:end)];
            DFIndexJumpsEndNew = [DFIndexJumpsEnd(1:i-1)-2; (jumpStartDiv60000 + 1)*transitionInterval-4;DFIndexJumpsEnd(i:end)];
            DFIndexJumpsStart = DFIndexJumpsStartNew;
            DFIndexJumpsEnd = DFIndexJumpsEndNew;
        end
    end
end

f = find( DFIndexJumpsEnd < DFIndexJumpsStart + minSegLen);
DFIndexJumpsStart(f) = [];
DFIndexJumpsEnd(f) = [];

end