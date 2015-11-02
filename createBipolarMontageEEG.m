%% createBipolarMontageEEG
% Function to create bipolar montage for EEG in line with micro-electrodes
%
% Inputs: (optional)
% folderMontage: folder path. This path should contain bipChInfoActiCap64.mat and
%           actiCap64.mat (or depending on the case bipChInfoBrainCap64.mat and
%           brainCap64.mat). Recommended path is Montages folder on present working
%           directory as my other programs using topoplot search for channel
%           locations in this folder.
%
% maxChanKnown: This is the max number of channels whose original reference 
%               channel position is available in actiCap64.mat/brainCap64.mat; 
%               default: 96
%
% gridType: 'actiCap64.mat | brainCap64.mat' as the case may be; 
%           default: actiCap64.mat
%
% This program uses readlocs and topoplot functions of EEGLAB toolbox.
%
% Output of the program is channel location file saved in .xyz format
% (bipolarChanlocsActiCap64.xyz) that could be accessed by EEGLAB and also 
% in a .mat format (bipolarChanlocsActiCap64.mat) that could be
% readily given as input to my programs using topoplot. It is necessary to
% set 'nosedir' in topoplot to '-Y' in custom programs before using these
% outputs.
%
% Created by Murty V P S Dinavahi 01-09-2015
%

function createBipolarMontageEEG(maxChanKnown,folderMontage,gridType)

% Set defaults
if nargin<1;    maxChanKnown = 96;  end    
if nargin<2 || (nargin<1 && isempty(folderMontage))
    folderMontage = fullfile(pwd,'Montages');
end
if nargin<3;    gridType = 'actiCap64.mat'; end

% load variables
load(fullfile(folderMontage,['bipChInfo' upper(gridType(1)) gridType(2:end)]));
load(fullfile(folderMontage,gridType));
unipolarChanlocs = chanlocs;
clear chanlocs;

% calculate chanlocs
for i=1:size(bipolarLocs,1)
    chan1 = bipolarLocs(i,1);
    chan2 = bipolarLocs(i,2);
    
    if chan1<(maxChanKnown+1)
        unipolarChan1 = unipolarChanlocs(chan1);
    else
        unipolarChan1.X = chanlocs(chan1,2);
        unipolarChan1.Y = chanlocs(chan1,3);
        unipolarChan1.Z = chanlocs(chan1,4);
    end
    
    if chan2<(maxChanKnown+1)
        unipolarChan2 = unipolarChanlocs(chan2);
    else
        unipolarChan2.X = chanlocs(chan2,2);
        unipolarChan2.Y = chanlocs(chan2,3);
        unipolarChan2.Z = chanlocs(chan2,4);
    end
    
    chanlocs(i,1) = i;
    chanlocs(i,2) = (unipolarChan1.X + unipolarChan2.X)/2;
    chanlocs(i,3) = (unipolarChan1.Y + unipolarChan2.Y)/2;
    chanlocs(i,4) = (unipolarChan1.Z + unipolarChan2.Z)/2;
    chanlocs(i,5) = i;
    
end

% save output
save(fullfile(folderMontage,'bipolarChanlocsActiCap64.xyz'),'chanlocs','-ASCII');
filename = fullfile(folderMontage,'bipolarChanlocsActiCap64.xyz');
eloc = readlocs( filename, 'importmode', 'native');
topoplot([],eloc,'style','blank','electrodes','numbers','nosedir','-Y');
save(fullfile(folderMontage,'bipolarChanlocsActiCap64.mat'),'eloc');
end