function [DFIndexJumpsStart,DFIndexJumpsEnd] = findSegment(command,commandLevels,minSegLen)
if nargin < 3
    minSegLen = Inf;
end
DFIndex = find((command>commandLevels(1) & (command<commandLevels(2))));
DFIndexDiff = DFIndex(2:end) - DFIndex(1:end-1);
DFIndexDiff(DFIndexDiff<1000) = 0;
DFIndexJumps = find((DFIndexDiff > 1000));
DFIndexJumps = [1;DFIndexJumps;length(DFIndexDiff)];
DFIndexJumpsStart = DFIndex(DFIndexJumps(1:end-1)+10);
DFIndexJumpsEnd = DFIndex(DFIndexJumps(2:end)-10);

f = find( DFIndexJumpsEnd < DFIndexJumpsStart + minSegLen);
DFIndexJumpsStart(f) = [];
DFIndexJumpsEnd(f) = [];

end