function [jumpsStart,jumpsEnd] = findSegmentDirection(command,commandLevels,commandDiff,minSegLen)
if nargin < 4
    minSegLen = Inf;
end
jumpsStart = cell(2,1);
jumpsEnd = cell(2,1);
DFIndex = find((command>commandLevels(1)) & (command<commandLevels(2)) & (commandDiff>=0));
DFIndexDiff = DFIndex(2:end) - DFIndex(1:end-1);
DFIndexDiff(DFIndexDiff<1000) = 0;
DFIndexJumps = find((DFIndexDiff > 1000));
DFIndexJumps = [1;DFIndexJumps;length(DFIndexDiff)];
jumpStartTemp = DFIndex(DFIndexJumps(1:end-1)+10);
jumpsEndTemp = DFIndex(DFIndexJumps(2:end));

f = find( jumpsEndTemp < jumpStartTemp + minSegLen);
jumpStartTemp(f) = [];
jumpsEndTemp(f) = [];
jumpsStart{1} = jumpStartTemp;
jumpsEnd{1} = jumpsEndTemp;

DFIndex = find((command>commandLevels(1)) & (command<commandLevels(2)) & (commandDiff<0));
DFIndexDiff = DFIndex(2:end) - DFIndex(1:end-1);
DFIndexDiff(DFIndexDiff<1000) = 0;
DFIndexJumps = find((DFIndexDiff > 1000));
DFIndexJumps = [1;DFIndexJumps;length(DFIndexDiff)];

jumpStartTemp = DFIndex(DFIndexJumps(1:end-1)+10);
jumpsEndTemp = DFIndex(DFIndexJumps(2:end)-10);

f = find( jumpsEndTemp < jumpStartTemp + minSegLen);
jumpStartTemp(f) = [];
jumpsEndTemp(f) = [];
jumpsStart{2} = jumpStartTemp;
jumpsEnd{2} = jumpsEndTemp;

    
end