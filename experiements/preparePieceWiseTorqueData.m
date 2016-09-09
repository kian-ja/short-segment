dataTrials = cell(4,1);
dataTrials{1} = [4,5,7,8,9,10];
dataTrials{2} = [7,8,9,10,11,12];
dataTrials{3} = [5,6,7,8,9,10,11,12,13,14,15,16];
dataTrials{4} = [5,6,7,8,9,10];
dataPieceWiseTorque = cell(4,1);
filePath = '/Users/kian/Documents/publication/Jalaleddini-Kearney-Short-Segment/experiment/torque varying/';
fileName = cell(4,1);
fileName{1} = 'AV_300913.flb';
fileName{2} = 'KJ_250913.flb';
fileName{3} = 'MG_291013.flb';
fileName{4} = 'MR_300913.flb';
for i = 1 : 4
    fileNamePath = strcat(filePath,fileName{i});
    trials = dataTrials{i};
    for j = 1 : length(dataTrials{i})
        dataTemp = flb2mat(fileNamePath,'read_case',trials(j));
        dataTemp = dataTemp.Data;
        dataTemp = dataTemp(:,[1,2,4,5,6,7,9,10]);
        figure(1000)
        plot(dataTemp(:,2))
        disp(['The length of this trial was: ',num2str(size(dataTemp,1))])
        userInput = 'x';
        while ~( ((userInput == 'y')) || ((userInput == 'Y')) || ((userInput == 'n'))|| ((userInput == 'N')))
            %userInput = input('Include this data (Y/N)','s');
            userInput = 'y';
            if ((userInput == 'y') || (userInput == 'Y'))
                dataPieceWiseTorque{i} = [dataPieceWiseTorque{i};dataTemp];
            end
        end 
        close(1000)
    end
end
%%
save '/Users/kian/Documents/publication/Jalaleddini-Kearney-Short-Segment/experiment/torque varying/dataPieceWiseTorque.mat' dataPieceWiseTorque