%% EEG Analysis Toolbox
% Created by Murty V P S Dinavahi (19-10-2014)


function DisplayEEGAnalysis%(dataLog)%(expDate,protocolName,folderSourceString,gridType)

% Initialise
[dataLog,folderName] = getFolderDetails;
monkeyName = strjoin(dataLog(1,2));
gridType=strjoin(dataLog(2,2));
expDate = strjoin(dataLog(3,2));
protocolName = strjoin(dataLog(4,2));
%electrodesToStore = (cell2mat(dataLog(7,2)));
elecSampleRate = dataLog{9,2};

% Get folders
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
folderSpikes = fullfile(folderSegment,'Spikes');

% load LFP Information
[analogChannelsStored,timeVals,~,analogInputNums,electrodesStored] = loadlfpInfo(folderLFP);
[neuralChannelsStored,SourceUnitIDs] = loadspikeInfo(folderSpikes);

% Get Combinations
[~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);

% Get Analog Channel List %
[analogChannelStringList,analogChannelStringArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums);

% Get properties of the Stimulus
% stimResults = loadStimResults(folderExtract);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
panelHeight = 0.40; panelStartHeight = 0.10; eGridStartHeight=0.51;
staticPanelWidth = 0.25; staticStartPos = 0.025;
dynamicPanelWidth = 0.25; dynamicStartPos = 0.025;
EEGPanelWidth = 0.2; EEGStartPos = 0.275;
plotOptionsPanelWidth = 0.25; plotOptionsStartPos = 0.475;
backgroundColor = 'w';

% Define Variables
signalRange = [-0.1 0.5];
fftRange = [0 250];
baseline = [-0.2 0];
stimPeriod = [0.2 0.4];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Preprocessing Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(500);
hPreprocessingPanel = uipanel('Title','Preprocessing','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[staticPanelWidth+0.035 eGridStartHeight staticPanelWidth panelHeight]);

% Analog channel
uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.90 0.5 0.10],...
    'Style','text','String','Analog Channel','FontSize',fontSizeMedium);
hAnalogChannel = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.5 0.90 0.5 0.10], ...
    'Style','popup','String',analogChannelStringList,'FontSize',fontSizeMedium);

% Neural channel
uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.80 0.5 0.10],...
    'Style','text','String','Neural Channel','FontSize',fontSizeMedium);
    
if ~isempty(neuralChannelsStored)
    neuralChannelString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs);
    hNeuralChannel = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [0.5 0.80 0.5 0.10], ...
        'Style','popup','String',neuralChannelString,'FontSize',fontSizeMedium);
else
    hNeuralChannel = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
        'Position', [0.5 0.80 0.5 0.10], ...
        'Style','text','String','Not found','FontSize',fontSizeMedium);
end

% Referencing
uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.70 1 0.10],...
    'Style','text','String','Referencing','FontSize',fontSizeMedium);

uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.60 0.5 0.10],...
    'Style','text','String','Type','FontSize',fontSizeMedium);
hReferenceType = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.5 0.60 0.5 0.10], ...
    'Style','popup','String',['Single Wire|Average|Bipolar'],'FontSize',fontSizeMedium);

uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.50 0.4 0.10],...
    'Style','text','String','Bipolar Reference:','FontSize',fontSizeMedium);
hBipolarReferenceChannel = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.5 0.50 0.5 0.10], ...
    'Style','popup','String',analogChannelStringList,'FontSize',fontSizeMedium);

% Visual rejection of trials
uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.35 1 0.10],...
    'Style','text','String','Visual rejection of trials','FontSize',fontSizeMedium);

uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.25 0.45 0.10],...
    'Style','text','String','Upper Limit (mV)','FontSize',fontSizeMedium);
hUpperLim = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.5 0.25 0.45 0.10], ...
    'Style','edit','String','1000','FontSize',fontSizeMedium);

uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0.15 0.45 0.10],...
    'Style','text','String','Lower Limit (mV)','FontSize',fontSizeMedium);
hLowerLim = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.5 0.15 0.45 0.10], ...
    'Style','edit','String','-1000','FontSize',fontSizeMedium);

uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0 0 0.33 0.10],...
    'Style','pushbutton','String','Apply','FontSize',fontSizeMedium,...
    'Callback',{@Apply_Callback});

hDCToggle = uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0.34 0 0.33 0.10],...
    'Style','togglebutton','String','Correct DC Shift','FontSize',fontSizeMedium,...
    'Callback',{@Apply_Callback});

uicontrol('Parent',hPreprocessingPanel,'Unit','Normalized', ...
    'Position',[0.68 0 0.32 0.10],...
    'Style','pushbutton','String','Save Data to file','FontSize',fontSizeMedium,...
    'Callback',{@Apply_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Screening Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hFilteringPanel = uipanel('Title','Screening','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[(staticPanelWidth+0.02)*2 eGridStartHeight staticPanelWidth panelHeight]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Information Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hInformationPanel = uipanel('Title','Information','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[(staticPanelWidth)*3 eGridStartHeight staticPanelWidth-0.01 panelHeight]);

% Title
uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'Position',[0.1 0.90 0.8 0.10],...
    'Style','text','String','For the given Parameters','FontSize',fontSizeMedium);


% Total Trials
uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'Position',[0 0.80 0.5 0.10],...
    'Style','text','String','Total Trials','FontSize',fontSizeMedium);
hTotalTrials = uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [0.5 0.80 0.5 0.10], ...
        'Style','text','String','','FontSize',fontSizeMedium);

% Bad Trials
uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'Position',[0 0.70 0.5 0.10],...
    'Style','text','String','Bad Trials','FontSize',fontSizeMedium);
hBadTrials = uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.5 0.70 0.5 0.10], ...
    'Style','text','String','','FontSize',fontSizeMedium);

% Visually Rejected Trials
uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'Position',[0 0.60 0.5 0.10],...
    'Style','text','String','Visually Rejected Trials','FontSize',fontSizeMedium);
hVisBadTrials = uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.5 0.60 0.5 0.10], ...
    'Style','text','String','','FontSize',fontSizeMedium);

% Total Analysable Trials
uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'Position',[0 0.50 0.5 0.10],...
    'Style','text','String','Analysable Trials','FontSize',fontSizeMedium);
hAnalysableTrials = uicontrol('Parent',hInformationPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.5 0.50 0.5 0.10], ...
    'Style','text','String','','FontSize',fontSizeMedium);

% Messages
hMessagePanel = uipanel('Parent',hInformationPanel,'Title','Messages','fontSize', fontSizeMedium, ...
    'Unit','Normalized','Position',[0.05 0 0.90 0.50]);
hMessageText = uicontrol('Parent',hMessagePanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [0.05 0.05 0.90 0.90], ...
    'Style','text','String','','FontSize',fontSizeMedium);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dynamic panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dynamicHeight = 0.06; dynamicGap=0.015; dynamicTextWidth = 0.6;
hDynamicPanel = uipanel('Title','Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[dynamicStartPos panelStartHeight dynamicPanelWidth panelHeight]);

% Auditory Azimuth
aaString = getStringFromValues(aaValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-0*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Auditory Azimuth','FontSize',fontSizeSmall);
hAudAziVal = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-0*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',aaString,'FontSize',fontSizeSmall);

% Auditory Elevation
aeString = getStringFromValues(aeValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-1*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Auditory Elevation','FontSize',fontSizeSmall);
hAudElevVal = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-1*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',aeString,'FontSize',fontSizeSmall);

% Ripple Frequency
asString = getStringFromValues(asValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Ripple Frequency','FontSize',fontSizeSmall);
hAudSFVal = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',asString,'FontSize',fontSizeSmall);

% Ripple Phase
aoString = getStringFromValues(aoValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Ripple Phase','FontSize',fontSizeSmall);
hAudOriVal = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',aoString,'FontSize',fontSizeSmall);

% Ripple Velocity
atString = getStringFromValues(atValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-4*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Ripple Velocity','FontSize',fontSizeSmall);
hAudTFVal = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-4*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',atString,'FontSize',fontSizeSmall);

% Auditory volume
avString = getStringFromValues(avValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Auditory volume (100%)','FontSize',fontSizeSmall);
hAudVolumeVal = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',avString,'FontSize',fontSizeSmall);

% Sigma
sigmaString = getStringFromValues(sValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-6*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Sigma (Deg)','FontSize',fontSizeSmall);
hSigma = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-6*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',sigmaString,'FontSize',fontSizeSmall);

% Spatial Frequency
spatialFreqString = getStringFromValues(fValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-7*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Spatial Freq (CPD)','FontSize',fontSizeSmall);
hSpatialFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-7*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',spatialFreqString,'FontSize',fontSizeSmall);

% Orientation
orientationString = getStringFromValues(oValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-8*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Orientation (Deg)','FontSize',fontSizeSmall);
hOrientation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-8*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',orientationString,'FontSize',fontSizeSmall);

% Contrast
contrastString = getStringFromValues(cValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-9*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Contrast (%)','FontSize',fontSizeSmall);
hContrast = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-9*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',contrastString,'FontSize',fontSizeSmall);

% Temporal Frequency
temporalFreqString = getStringFromValues(tValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-10*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Temporal Freq (Hz)','FontSize',fontSizeSmall);
hTemporalFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-10*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',temporalFreqString,'FontSize',fontSizeSmall);

% For orientation and SF
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-11.5*(dynamicHeight+dynamicGap) 1 dynamicHeight],...
    'Style','text','String','For sigma,ori,SF,C & TF plots','FontSize',fontSizeSmall);
% Azimuth
azimuthString = getStringFromValues(aValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-12.5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
    'Style','text','String','Azimuth (Deg)','FontSize',fontSizeSmall);
hAzimuth = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-12.5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',azimuthString,'FontSize',fontSizeSmall);

% Elevation
elevationString = getStringFromValues(eValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-13.5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Elevation (Deg)','FontSize',fontSizeSmall);
hElevation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [dynamicTextWidth 1-13.5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',elevationString,'FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Analysis Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AnalysisOptionsHeight = 0.1;

hAnalysisOptionsPanel = uipanel('Title','Analysis Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[EEGStartPos panelStartHeight EEGPanelWidth panelHeight]);

uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0 9*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','text','String','Analysis Type','FontSize',fontSizeMedium);
hTFAType = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 9*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','popup','String','ERP|FFT|dFFT|MTFFT|STFT|MP','FontSize',fontSizeMedium);

% Baseline Period
uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0 8*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','text','String','Basline Period (s)','FontSize',fontSizeMedium);
hBaselineMin = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.5 8*AnalysisOptionsHeight 0.25 AnalysisOptionsHeight], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeMedium);
hBaselineMax = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.75 8*AnalysisOptionsHeight 0.25 AnalysisOptionsHeight], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeMedium);

% Stimulus Period
uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0 7*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','text','String','Stim period (s)','FontSize',fontSizeMedium);
hStimPeriodMin = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.5 7*AnalysisOptionsHeight 0.25 AnalysisOptionsHeight], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeMedium);
hStimPeriodMax = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.75 7*AnalysisOptionsHeight 0.25 AnalysisOptionsHeight], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeMedium);


% Tapers
uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0 6*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','text','String','No. of Tapers','FontSize',fontSizeMedium);
hTapers = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 6*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','edit','String','3','FontSize',fontSizeMedium);

% Fs
uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0 5*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','text','String','Fs','FontSize',fontSizeMedium);
hFs = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 5*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','edit','String',num2str(elecSampleRate),'FontSize',fontSizeMedium);

% Moving Window Size
uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0 4*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','text','String','Moving Window Size','FontSize',fontSizeMedium);
hWinStep = uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 4*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','edit','String','0.01','FontSize',fontSizeMedium);

% Plot button
uicontrol('Parent',hAnalysisOptionsPanel,'Unit','Normalized', ...
    'Position',[0.25 2*AnalysisOptionsHeight 0.5 AnalysisOptionsHeight], ...
    'Style','pushbutton','String','Plot','FontSize',fontSizeMedium, ...
    'Callback',{@Plot_Callback});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting options panel %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timingHeight = 0.1; timingTextWidth = 0.5; timingBoxWidth = 0.25;
hPlotOptionsPanel = uipanel('Title','Plotting Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[plotOptionsStartPos panelStartHeight plotOptionsPanelWidth panelHeight]);

% signalRange = [-0.1 0.5];
% fftRange = [0 250];
% baseline = [-0.2 0];
% %stimPeriod = [0.2 0.4];

% Plot Colour
[colorString, colorNames] = getColorString;
ColorLabel = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Plot Color','FontSize',fontSizeMedium);

hChooseColor = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-timingHeight timingTextWidth timingHeight], ...
    'Style','popup','String',colorString,'FontSize',fontSizeMedium);

% Heading
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Parameter','FontSize',fontSizeMedium);

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth 1-2*timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Min','FontSize',fontSizeMedium);

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth+timingBoxWidth 1-2*timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Max','FontSize',fontSizeMedium);

% ERP Range
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','pushbutton','String','ERP Range (s)','FontSize',fontSizeMedium,...
    'Callback',{@SigRange_Callback});
hSigMin = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeMedium);
hSigMax = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeMedium);

% x-axis Range
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','pushbutton','String','x-axis Range','FontSize',fontSizeMedium,...
    'Callback',{@rescaleX_Callback});
hXMin = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(1)),'FontSize',fontSizeMedium);
hXMax = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(2)),'FontSize',fontSizeMedium);

% y-axis Range
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-6*timingHeight timingTextWidth timingHeight], ...
    'Style','pushbutton','String','y-axis Range','FontSize',fontSizeMedium,...
    'Callback',{@rescaleY_Callback});
hYMin = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','0','FontSize',fontSizeMedium);
hYMax = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','1','FontSize',fontSizeMedium);

% Colour Axis
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
    'Style','pushbutton','String','Colour Axis','FontSize',fontSizeMedium, ...
    'Callback',{@CAxis_Callback});
hCAxisMin = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','-0.2','FontSize',fontSizeMedium);
hCAxisMax = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth+timingBoxWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','0.2','FontSize',fontSizeMedium);

% Other controls
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','pushbutton','String','cla','FontSize',fontSizeMedium, ...
    'Callback',{@cla_Callback});

hHoldOn = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','togglebutton','String','hold on','FontSize',fontSizeMedium, ...
    'Callback',{@holdOn_Callback});


% % Stim Period
% uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
%     'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
%     'Style','text','String','Stim period (s)','FontSize',fontSizeSmall);
% hStimPeriodMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
%     'BackgroundColor', backgroundColor, ...
%     'Position',[timingTextWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
%     'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall);
% hStimPeriodMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
%     'BackgroundColor', backgroundColor, ...
%     'Position',[timingTextWidth+timingBoxWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
%     'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Advanced panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hAdvancedPanel = uipanel('Title','Advanced','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[plotOptionsStartPos+plotOptionsPanelWidth panelStartHeight plotOptionsPanelWidth panelHeight]);

% Timing
uicontrol('Parent',hAdvancedPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Time Range (s)','FontSize',fontSizeMedium);

hTimeMin = uicontrol('Parent',hAdvancedPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeMedium);

hTimeMax = uicontrol('Parent',hAdvancedPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeMedium);

uicontrol('Parent',hAdvancedPanel,'Unit','Normalized', ...
    'Position',[0 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','pushbutton','String','RMS Value','FontSize',fontSizeMedium, ...
    'Callback',{@RMS_Callback});

RMSString = getRMS_String;
hRMSpopup = uicontrol('Parent',hAdvancedPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','popup','String',RMSString,'FontSize',fontSizeMedium);

uicontrol('Parent',hAdvancedPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','pushbutton','String','RMS Distribution','FontSize',fontSizeMedium, ...
    'Callback',{@RMSDist_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get plots and message handles

% Get electrode array information
electrodeGridPos = [staticStartPos eGridStartHeight staticPanelWidth panelHeight];

% if ~isempty(dataLog{7,2})
% switch length(electrodesStored)
%     case 64
%         gridLayout = 1;
%     case 21
%         gridLayout = 3;
% end
gridLayout = 2;
    hElectrodes = showElectrodeLocations(electrodeGridPos,analogChannelsStored(get(hAnalogChannel,'val')), ...
        colorNames(get(hChooseColor,'val')),[],1,0,gridType,dataLog,gridLayout);
% else
%     hElectrodes = uicontrol('style','text','string','No Electrodes','pos',electrodeGridPos);
% end

% Make plot for RFMap, centerRFMap and main Map
if length(aValsUnique)>=5
    mapRatio = 2/3; % this sets the relative ratio of the mapping plots versus orientation plots
else
    mapRatio = 1/2;
end

startXPos = staticStartPos; endXPos = 0.95; startYPos = 0.05; mainRFHeight = 0.90; centerGap = 0.05;
mainRFWidth = mapRatio*(endXPos-startXPos-centerGap);
otherPlotsWidth = (1-mapRatio)*(endXPos-startXPos-centerGap);

% Main plot handles 
numRows = length(eValsUnique); numCols = length(aValsUnique);
gridPos=[endXPos-mainRFWidth startYPos mainRFWidth 0.65*mainRFHeight]; gap = 0.002;
% plotHandles = getPlotHandles(numRows,numCols,gridPos,gap);

uicontrol('Unit','Normalized','Position',[0 0.950 1 0.05],...
    'Style','text','String',[monkeyName expDate protocolName],'FontSize',fontSizeLarge);

% Other functions

% Remaining Grid size
remainingWidth = otherPlotsWidth;
remainingHeight= mainRFHeight;

otherGapSize = 0.04;
otherHeight = (remainingHeight-4*otherGapSize)/5;

AudAziGrid = [startXPos startYPos+ 4*(otherHeight+otherGapSize)  remainingWidth*2 otherHeight];
AudSFGrid     = [startXPos startYPos+ 3*(otherHeight+otherGapSize)   remainingWidth*2 otherHeight];
AudOriGrid  = [startXPos startYPos+ 2*(otherHeight+otherGapSize) remainingWidth*2 otherHeight];
AudTFGrid  = [startXPos startYPos+ 1*(otherHeight+otherGapSize) remainingWidth*2 otherHeight];
AudVolGrid        = [startXPos startYPos+ 0*(otherHeight+otherGapSize) remainingWidth*2 otherHeight];

temporalFreqGrid = [startXPos startYPos+ 0*(otherHeight+otherGapSize)  remainingWidth otherHeight];
contrastGrid     = [startXPos startYPos+ 1*(otherHeight+otherGapSize)   remainingWidth otherHeight];
orientationGrid  = [startXPos startYPos+ 2*(otherHeight+otherGapSize) remainingWidth otherHeight];
spatialFreqGrid  = [startXPos startYPos+ 3*(otherHeight+otherGapSize) remainingWidth otherHeight];
sigmaGrid        = [startXPos startYPos+ 4*(otherHeight+otherGapSize) remainingWidth otherHeight];

%Plot handles
figure; hold on;
% rawWavePos = [endXPos-mainRFWidth startYPos+(3/4)*mainRFHeight mainRFWidth/2 (1/4)*mainRFHeight];
hAudAziPlot = getPlotHandles(1,length(aaValsUnique),AudAziGrid,0.002);
hAudSFPlot     = getPlotHandles(1,length(asValsUnique),AudSFGrid,0.002);
hAudOriPlot  = getPlotHandles(1,length(aoValsUnique),AudOriGrid,0.002);
hAudVolumePlot        = getPlotHandles(1,length(avValsUnique),AudVolGrid,0.002);
hAudTFPlot  = getPlotHandles(1,length(atValsUnique),AudTFGrid,0.002);
hold off;

figure; hold on; 
hTemporalFreqPlot = getPlotHandles(1,length(tValsUnique),temporalFreqGrid,0.002);
hContrastPlot     = getPlotHandles(1,length(cValsUnique),contrastGrid,0.002);
hOrientationPlot  = getPlotHandles(1,length(oValsUnique),orientationGrid,0.002);
hSpatialFreqPlot = getPlotHandles(1,length(fValsUnique),spatialFreqGrid,0.002);
hSigmaPlot = getPlotHandles(1,length(sValsUnique),sigmaGrid,0.002);

rawWavePlotHandle = subplot('position',[endXPos-mainRFWidth startYPos+(3/4)*mainRFHeight mainRFWidth (1/4)*mainRFHeight]);
plotHandles = getPlotHandles(numRows,numCols,gridPos,gap); 
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Plot_Callback(~,~)
        
        % Intitialise
        set(hMessageText,'String', '');
        
        % Parameter Variables
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAziVal,'val');
        ae=get(hAudElevVal,'va');
        ao=get(hAudOriVal,'val');
        as=get(hAudSFVal,'val');
        av=get(hAudVolumeVal,'val');
        at=get(hAudTFVal,'val');
        
        % TFA Variables
%         dtapers = str2double(get(hTapers,'string'));
%         dFs = str2double(get(hFs,'string'));        
%         dWinStep = str2double(get(hWinStep,'string'));
        analysisType = get(hTFAType,'val');
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        STMin = str2double(get(hStimPeriodMin,'string'));
        STMax = str2double(get(hStimPeriodMax,'string'));        
        
        % Other Variables
        plotColor = colorNames(get(hChooseColor,'val'));
%         holdOnState = get(hHoldOn,'val');
        
        % Get Data
        [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
        
        if isempty(Data)
            set(hMessageText,'String', 'No analysable trials to plot.');
            return
        end
        % Raw signal plot
        plot(rawWavePlotHandle,timeVals,Data);
        axis (rawWavePlotHandle,'tight');        
        
        % ERP
        if analysisType == 1            
                plotERP(hAudAziPlot,a,e,s,f,o,c,t,[],ae,as,ao,av,at,plotColor);
                plotERP(hAudSFPlot,a,e,s,f,o,c,t,aa,ae,[],ao,av,at,plotColor);
                plotERP(hAudOriPlot,a,e,s,f,o,c,t,aa,ae,as,[],av,at,plotColor);
                plotERP(hAudTFPlot,a,e,s,f,o,c,t,aa,ae,as,ao,av,[],plotColor);
                plotERP(hAudVolumePlot,a,e,s,f,o,c,t,aa,ae,as,ao,[],at,plotColor);
                plotERP(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at,plotColor);
                
                plotERP(hTemporalFreqPlot,a,e,s,f,o,c,[],aa,ae,as,ao,av,at,plotColor);
                plotERP(hContrastPlot,a,e,s,f,o,[],t,aa,ae,as,ao,av,at,plotColor);
                plotERP(hOrientationPlot,a,e,s,f,[],c,t,aa,ae,as,ao,av,at,plotColor);
                plotERP(hSpatialFreqPlot,a,e,s,[],o,c,t,aa,ae,as,ao,av,at,plotColor);
                plotERP(hSigmaPlot,a,e,[],f,o,c,t,aa,ae,as,ao,av,at,plotColor);
            
        % FFT    
        elseif analysisType == 2
            if (BLMin<timeVals(1))
                set(hMessageText,'String', ['Baseline Min is out of range. Minimum value for this signal is ' num2str(timeVals(1)) '. Kindly reset the Baseline period.']);
            elseif (STMin>timeVals(length(timeVals)))
                set(hMessageText,'String', ['Stimulus Max is out of range. Maximum value for this signal is ' num2str(timeVals(length(timeVals))) '. Kindly reset the Stimulus period.']);
            elseif (BLMax<=BLMin)
                set(hMessageText,'String', 'Baseline Min is more than or equal to Baseline Max. Kindly reset the Baseline period.');
            elseif (STMax<=STMin)
                set(hMessageText,'String', 'Stimulus Min is more than or equal to Stimulus Max. Kindly reset the Stimulus period.');
            elseif (uint16((BLMax-BLMin)*10^4) ~= uint16((STMax-STMin)*10^4))
                set(hMessageText,'String', 'Baseline and Stimulus Periods do not match. Kindly reset these periods.');
            else
                plotFFT(hAudAziPlot,a,e,s,f,o,c,t,[],ae,as,ao,av,at,plotColor);
                plotFFT(hAudSFPlot,a,e,s,f,o,c,t,aa,ae,[],ao,av,at,plotColor);
                plotFFT(hAudOriPlot,a,e,s,f,o,c,t,aa,ae,as,[],av,at,plotColor);
                plotFFT(hAudTFPlot,a,e,s,f,o,c,t,aa,ae,as,ao,av,[],plotColor);
                plotFFT(hAudVolumePlot,a,e,s,f,o,c,t,aa,ae,as,ao,[],at,plotColor);
                plotFFT(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at,plotColor);
                
                plotFFT(hTemporalFreqPlot,a,e,s,f,o,c,[],aa,ae,as,ao,av,at,plotColor);
                plotFFT(hContrastPlot,a,e,s,f,o,[],t,aa,ae,as,ao,av,at,plotColor);
                plotFFT(hOrientationPlot,a,e,s,f,[],c,t,aa,ae,as,ao,av,at,plotColor);
                plotFFT(hSpatialFreqPlot,a,e,s,[],o,c,t,aa,ae,as,ao,av,at,plotColor);
                plotFFT(hSigmaPlot,a,e,[],f,o,c,t,aa,ae,as,ao,av,at,plotColor);
            end
        
        % dFFT
        elseif analysisType == 3
            if (BLMin<timeVals(1))
                set(hMessageText,'String', ['Baseline Min is out of range. Minimum value for this signal is ' num2str(timeVals(1)) '. Kindly reset the Baseline period.']);
            elseif (STMin>timeVals(length(timeVals)))
                set(hMessageText,'String', ['Stimulus Max is out of range. Maximum value for this signal is ' num2str(timeVals(length(timeVals))) '. Kindly reset the Stimulus period.']);
            elseif (BLMax<=BLMin)
                set(hMessageText,'String', 'Baseline Min is more than or equal to Baseline Max. Kindly reset the Baseline period.');
            elseif (STMax<=STMin)
                set(hMessageText,'String', 'Stimulus Min is more than or equal to Stimulus Max. Kindly reset the Stimulus period.');
            elseif (uint16((BLMax-BLMin)*10^4) ~= uint16((STMax-STMin)*10^4))
                set(hMessageText,'String', 'Baseline and Stimulus Periods do not match. Kindly reset these periods.');
            else
                plotDiffFFT(hAudAziPlot,a,e,s,f,o,c,t,[],ae,as,ao,av,at,plotColor);
                plotDiffFFT(hAudSFPlot,a,e,s,f,o,c,t,aa,ae,[],ao,av,at,plotColor);
                plotDiffFFT(hAudOriPlot,a,e,s,f,o,c,t,aa,ae,as,[],av,at,plotColor);
                plotDiffFFT(hAudTFPlot,a,e,s,f,o,c,t,aa,ae,as,ao,av,[],plotColor);
                plotDiffFFT(hAudVolumePlot,a,e,s,f,o,c,t,aa,ae,as,ao,[],at,plotColor);
                plotDiffFFT(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at,plotColor);
                
                plotDiffFFT(hTemporalFreqPlot,a,e,s,f,o,c,[],aa,ae,as,ao,av,at,plotColor);
                plotDiffFFT(hContrastPlot,a,e,s,f,o,[],t,aa,ae,as,ao,av,at,plotColor);
                plotDiffFFT(hOrientationPlot,a,e,s,f,[],c,t,aa,ae,as,ao,av,at,plotColor);
                plotDiffFFT(hSpatialFreqPlot,a,e,s,[],o,c,t,aa,ae,as,ao,av,at,plotColor);
                plotDiffFFT(hSigmaPlot,a,e,[],f,o,c,t,aa,ae,as,ao,av,at,plotColor);
            end
        % Multi-taper FFT    
        elseif analysisType == 4
            if (BLMin<timeVals(1))
                set(hMessageText,'String', ['Baseline Min is out of range. Minimum value for this signal is ' num2str(timeVals(1)) '. Kindly reset the Baseline period.']);
            elseif (STMin>timeVals(length(timeVals)))
                set(hMessageText,'String', ['Stimulus Max is out of range. Maximum value for this signal is ' num2str(timeVals(length(timeVals))) '. Kindly reset the Stimulus period.']);
            elseif (BLMax<=BLMin)
                set(hMessageText,'String', 'Baseline Min is more than or equal to Baseline Max. Kindly reset the Baseline period.');
            elseif (STMax<=STMin)
                set(hMessageText,'String', 'Stimulus Min is more than or equal to Stimulus Max. Kindly reset the Stimulus period.');
            elseif (uint16((BLMax-BLMin)*10^4) ~= uint16((STMax-STMin)*10^4))
                set(hMessageText,'String', 'Baseline and Stimulus Periods do not match. Kindly reset these periods.');
            else                               
                plotMT_FFT(hAudAziPlot,a,e,s,f,o,c,t,[],ae,as,ao,av,at);
                plotMT_FFT(hAudSFPlot,a,e,s,f,o,c,t,aa,ae,[],ao,av,at);
                plotMT_FFT(hAudOriPlot,a,e,s,f,o,c,t,aa,ae,as,[],av,at);
                plotMT_FFT(hAudTFPlot,a,e,s,f,o,c,t,aa,ae,as,ao,av,[]);
                plotMT_FFT(hAudVolumePlot,a,e,s,f,o,c,t,aa,ae,as,ao,[],at);
                plotMT_FFT(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
                
                plotMT_FFT(hTemporalFreqPlot,a,e,s,f,o,c,[],aa,ae,as,ao,av,at);
                plotMT_FFT(hContrastPlot,a,e,s,f,o,[],t,aa,ae,as,ao,av,at);
                plotMT_FFT(hOrientationPlot,a,e,s,f,[],c,t,aa,ae,as,ao,av,at);
                plotMT_FFT(hSpatialFreqPlot,a,e,s,[],o,c,t,aa,ae,as,ao,av,at);
                plotMT_FFT(hSigmaPlot,a,e,[],f,o,c,t,aa,ae,as,ao,av,at);
            end            
        
        % STFT    
        elseif analysisType == 5
            
            if (BLMin<timeVals(1))
                set(hMessageText,'String', ['Baseline Min is out of range. Minimum value for this signal is ' num2str(timeVals(1)) '. Kindly reset the Baseline period.']);
            elseif (BLMax<=BLMin)
                set(hMessageText,'String', 'Baseline Min is more than or equal to Baseline Max. Kindly reset the Baseline period.');
            else                  
%                 makeSpecgram(hAudAziPlot,a,e,s,f,o,c,[],av,at);
%                 makeSpecgram(hAudSFPlot,a,e,s,f,o,[],t,av,at);
%                 makeSpecgram(hAudOriPlot,a,e,s,f,[],c,t,av,at);
%                 makeSpecgram(hAudTFPlot,a,e,s,f,o,c,t,av,[]);
%                 makeSpecgram(hAudVolumePlot,a,e,s,f,o,c,t,[],at);
%                 makeSpecgram(plotHandles,a,e,s,f,o,c,t,av,at);
                
                makeSpecgram(hAudAziPlot,a,e,s,f,o,c,t,[],ae,as,ao,av,at);
                makeSpecgram(hAudSFPlot,a,e,s,f,o,c,t,aa,ae,[],ao,av,at);
                makeSpecgram(hAudOriPlot,a,e,s,f,o,c,t,aa,ae,as,[],av,at);
                makeSpecgram(hAudTFPlot,a,e,s,f,o,c,t,aa,ae,as,ao,av,[]);
                makeSpecgram(hAudVolumePlot,a,e,s,f,o,c,t,aa,ae,as,ao,[],at);
                makeSpecgram(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
                
                makeSpecgram(hTemporalFreqPlot,a,e,s,f,o,c,[],aa,ae,as,ao,av,at);
                makeSpecgram(hContrastPlot,a,e,s,f,o,[],t,aa,ae,as,ao,av,at);
                makeSpecgram(hOrientationPlot,a,e,s,f,[],c,t,aa,ae,as,ao,av,at);
                makeSpecgram(hSpatialFreqPlot,a,e,s,[],o,c,t,aa,ae,as,ao,av,at);
                makeSpecgram(hSigmaPlot,a,e,[],f,o,c,t,aa,ae,as,ao,av,at);
            end

            
        % Matching Pursuit
        elseif analysisType == 6
            set(hMessageText,'String', 'Not Ready');
        end
        
        if ~isempty(dataLog{7,2})
            paintPos;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [Data,timeVals] = Apply_Callback(~,~)
        
        % Intitialise
        set(hMessageText,'String', '');
        analogChannelPos = get(hAnalogChannel,'val');
        analogChannelString = analogChannelStringArray{analogChannelPos};
        
        % Parameter Variables
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAziVal,'val');
        ae=get(hAudElevVal,'val');
        ao=get(hAudOriVal,'val');
        as=get(hAudSFVal,'val');
        av=get(hAudVolumeVal,'val');
        at=get(hAudTFVal,'val');
        
        if strcmp(analogChannelString,'elec0')
            set(hMessageText,'string','No electrodes. Select Ainp instead!!');
            return
        else
            [Data,timeVals]=getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
        end
        
        if isempty(Data)
            set(hMessageText,'String', 'No analysable trials to plot.');
            return
        end
        
        plot(rawWavePlotHandle,timeVals,Data);
        axis (rawWavePlotHandle,'tight');
        if ~isempty(dataLog{7,2})
            paintPos;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [tempData,tempTimeVals]=getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at)
        
%       channelNumber = analogChannelsStored(analogChannelPos);
%       RefNumber = analogChannelsStored(RefChannelPos);
%       plotColor = colorNames(get(hChooseColor,'val'));
%       holdOnState = get(hHoldOn,'val');
        
        analogChannelPos = get(hAnalogChannel,'val');
        RefChannelPos = get(hBipolarReferenceChannel,'val');
        analogChannelString = analogChannelStringArray{analogChannelPos};
        RefChannelString = analogChannelStringArray{RefChannelPos};
        upLim = str2double(get(hUpperLim,'string'));
        lowLim = str2double(get(hLowerLim,'string'));
        DCToggle = get(hDCToggle,'val');

        if strcmp(analogChannelString,'elec0')
            anaCh = 'None';
            timInfo = 'None';
        else
            anaCh = fullfile(folderLFP,[analogChannelString '.mat']);
            timInfo = fullfile(folderLFP,'lfpInfo.mat');
        end
       
        
        badElec=dataLog{8, 2};
              
        dRefType = get(hReferenceType,'val');
                
        if (dRefType == 3) % Bipolar Referencing
            if  (strcmp(RefChannelString,'elec0') == 0)
                refCh = fullfile(folderLFP,[RefChannelString '.mat']);
                file.Reference = 'Bipolar';
            else
                refCh = 'None';
                set(hMessageText,'string','No electrodes. Plotting Single wire referencing. Select Ainp for Bipolar Referencing!!');
                file.Reference = 'Single Wire';
            end    
        elseif (dRefType == 2) % Average Referencing 
            if ~isempty(dataLog{7,2})
                refCh = fullfile(folderLFP,'lfpAverage.mat');
                file.Reference = 'Average';
            else
                refCh = 'None';
                set(hMessageText,'string','No electrodes. Plotting Single wire referencing. Average Referencing not possible!!');
                file.Reference = 'Single Wire';
            end
        else
            refCh = 'None'; % Single Wire Referencing
            file.Reference = 'Single Wire';
        end
        
        clear Data;
        clear timeVals;
        
        [tempData,tempTimeVals,trialNums,goodTrials,badVisualTrials]=ExtractGoodData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderExtract,anaCh,timInfo,badElec,refCh,upLim,lowLim,DCToggle);
        if trialNums>0
            badTrials = setdiff(trialNums,goodTrials);
            
            if DCToggle == 1
                DCCor = 'Yes';
            else
                DCCor = 'No';
            end

            file.ParameterCombination = strcat(num2str(a),num2str(e),num2str(s),num2str(f),num2str(o),num2str(c),num2str(t),num2str(av),num2str(at));
            file.AnalysisElectrode = analogChannelString;
            file.ReferenceElectrode = RefChannelString;
            file.DCCorrection = DCCor;
            file.Data = tempData;
            file.timeVals = tempTimeVals;
            assignin('base','ParameterData',file);

            set(hTotalTrials,'String',num2str(length(trialNums)));
            set(hBadTrials,'String',num2str(length(badTrials)));
            set(hVisBadTrials,'String',num2str(length(badVisualTrials)));
            set(hAnalysableTrials,'String',num2str(size(tempData,1)));
            set(hMessageText,'string','Task Complete');
            
        elseif strcmp(anaCh,'None')
            set(hMessageText,'string','No electrodes. Select Ainp instead!!');
            
        else
            set(hMessageText,'string','No trials available for this parameter combination!!');
            set(hTotalTrials,'String','0');
            set(hBadTrials,'String','0');
            set(hVisBadTrials,'String','0');
            set(hAnalysableTrials,'String','0');
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plotERP(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at,plotColor)
        [~,numCols] = size(plotHandles);
        check = 0;
        for i=1:numCols              
            if isempty(aa)
                aa=1:length(aaValsUnique);
                for j=1:length(aaValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa(j),ae,as,ao,av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Audio Azi');
                end
                check = 1;                
             elseif isempty(ao)
                ao=1:length(aoValsUnique);
                for j=1:length(aoValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao(j),av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Audio Ori');
                end
                check = 1;
            elseif isempty(as)
                as=1:length(asValsUnique);
                for j=1:length(asValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as(j),ao,av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Audio SF');
                end
                check = 1;
            elseif isempty(av)
                av=1:length(avValsUnique);
                for j=1:length(avValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av(j),at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Volume');
                end
                check = 1;
            elseif isempty(at)
                at=1:length(atValsUnique);
                for j=1:length(atValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at(j));
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Audio TF');
                end
                check = 1;
            elseif isempty(s)
                s=1:length(sValsUnique);
                for j=1:length(sValsUnique)                    
                    [Data,timeVals] = getData(a,e,s(j),f,o,c,t,aa,ae,as,ao,av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Sigma');
                end
                check = 1;
            elseif isempty(f)
                f=1:length(fValsUnique);
                for j=1:length(fValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f(j),o,c,t,aa,ae,as,ao,av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Spat. Freq.');
                end
                check = 1;
            elseif isempty(o)
                o=1:length(oValsUnique);
                for j=1:length(oValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o(j),c,t,aa,ae,as,ao,av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Orientation');
                end
                check = 1;
            elseif isempty(c)
                c=1:length(cValsUnique);
                for j=1:length(cValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c(j),t,aa,ae,as,ao,av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'Contrast');
                end
                check = 1;
            elseif isempty(t)
                t=1:length(tValsUnique);
                for j=1:length(tValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t(j),aa,ae,as,ao,av,at);
                    erp = mean(Data,1);
                    plot(plotHandles(j),timeVals,erp,'Color',plotColor);
                    axis(plotHandles(j),'tight');
                    set(plotHandles(j),'Ydir','reverse');
                    title(plotHandles(j),'TF');
                end
                check = 1;
            elseif (check == 0)
                [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
                erp = mean(Data,1);
                plot(plotHandles,timeVals,erp,'Color',plotColor);
                axis(plotHandles,'tight');
                set(plotHandles,'Ydir','reverse');
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plotFFT(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at,plotColor)
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        STMin = str2double(get(hStimPeriodMin,'string'));
        STMax = str2double(get(hStimPeriodMax,'string'));
        dFs = str2double(get(hFs,'string'));
        
        if (dFs==0)
            set(hMessageText,'string','Fs is set to zero!!');
            return
        end
        
        blRange = ([BLMin BLMax]);
        stRange = ([STMin STMax]);
        NBL = uint16(dFs*diff(blRange)); 
        NST = uint16(dFs*diff(stRange));
        
        [~,numCols] = size(plotHandles);
        check = 0;
        for i=1:numCols            
            if isempty(aa)
                aa=1:length(aaValsUnique);
                for j=1:length(aaValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa(j),ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(as)
                as=1:length(asValsUnique);
                for j=1:length(asValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as(j),ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(ao)
                ao=1:length(aoValsUnique);
                for j=1:length(aoValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao(j),av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(av)
                av=1:length(avValsUnique);
                for j=1:length(avValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av(j),at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(at)
                at=1:length(atValsUnique);
                for j=1:length(atValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at(j));
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(s)
                s=1:length(sValsUnique);
                for j=1:length(sValsUnique)                    
                    [Data,timeVals] = getData(a,e,s(j),f,o,c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(f)
                f=1:length(fValsUnique);
                for j=1:length(fValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f(j),o,c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(o)
                o=1:length(oValsUnique);
                for j=1:length(oValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o(j),c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(c)
                c=1:length(cValsUnique);
                for j=1:length(cValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c(j),t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(t)
                t=1:length(tValsUnique);
                for j=1:length(tValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t(j),aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif (check == 0)
                j=1;
                [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
                blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                stPos= find(timeVals>=stRange(1),1) + (1:NST);
                [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                plot(plotHandles(j),fAxisBL,log10(FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
            end
        end
        function [yfft,fAxis]=takeFFT(Data,timeVals)
            
%             dBLMin=(str2double(get(hBaselineMin,'string')));
%             dBLMax=(str2double(get(hBaselineMax,'string')));
%             BLMin = find(timeVals >= dBLMin,1,'first')+1;
%             BLMax = find(timeVals <= dBLMax,1,'last');
%             dSTMin = str2double(get(hStimPeriodMin,'string'));
%             dSTMax = str2double(get(hStimPeriodMax,'string'));
%             STMin = find(timeVals >= dSTMin,1,'first');
%             STMax = find(timeVals <= dSTMax,1,'last');
            Fs = str2double(get(hFs,'string'));
            
            N = length(timeVals);%((BLMin):BLMax));
            L = N/Fs;        
            fAxis = (0:1:(N-1))*(1/L);
            
            yfft = (mean(abs(fft(Data,[],2))));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plotDiffFFT(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at,plotColor)
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        STMin = str2double(get(hStimPeriodMin,'string'));
        STMax = str2double(get(hStimPeriodMax,'string'));
        dFs = str2double(get(hFs,'string'));
        
        if (dFs==0)
            set(hMessageText,'string','Fs is set to zero!!');
            return
        end
        
%         blRange = int16(([BLMin BLMax]).*10000);
%         stRange = int16(([STMin STMax]).*10000);
        
        blRange = ([BLMin BLMax]);
        stRange = ([STMin STMax]);
        NBL = int16(dFs*diff(blRange)); 
        NST = int16(dFs*diff(stRange));
        
        [~,numCols] = size(plotHandles);
        check = 0;
        for i=1:numCols            
            if isempty(aa)
                aa=1:length(aaValsUnique);
                for j=1:length(aaValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa(j),ae,as,ao,av,at);
                    blPos= find(uint16(timeVals*10^4)>=uint16(blRange(1)*10^4),1) + (1:NBL);
                    stPos= find(uint16(timeVals*10^4)>=uint16(stRange(1)*10^4),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end 
                check = 1;
            elseif isempty(as)
                as=1:length(asValsUnique);
                for j=1:length(asValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as(j),ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(ao)
                ao=1:length(aoValsUnique);
                for j=1:length(aoValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao(j),av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(av)
                av=1:length(avValsUnique);
                for j=1:length(avValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av(j),at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(at)
                at=1:length(atValsUnique);
                for j=1:length(atValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at(j));
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(s)
                s=1:length(sValsUnique);
                for j=1:length(sValsUnique)                    
                    [Data,timeVals] = getData(a,e,s(j),f,o,c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(f)
                f=1:length(fValsUnique);
                for j=1:length(fValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f(j),o,c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(o)
                o=1:length(oValsUnique);
                for j=1:length(oValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o(j),c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(c)
                c=1:length(cValsUnique);
                for j=1:length(cValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c(j),t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(t)
                t=1:length(tValsUnique);
                for j=1:length(tValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t(j),aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                    [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                    plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                     plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif (check == 0)
                j=1;
                [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
                blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                stPos= find(timeVals>=stRange(1),1) + (1:NST);
                [FFT_BL,fAxisBL]=takeFFT(Data(:,blPos),timeVals(blPos));
                [FFT_ST,fAxisST]=takeFFT(Data(:,stPos),timeVals(stPos));
                plot(plotHandles(j),fAxisBL,log10(FFT_ST./FFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
%                 plot(plotHandles(j),fAxisST,log10(FFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
            end
        end
        function [yfft,fAxis]=takeFFT(Data,timeVals)
            Fs = str2double(get(hFs,'string'));
            
            N = length(timeVals);%((BLMin):BLMax));
            L = N/Fs;        
            fAxis = (0:1:(N-1))*(1/L);
            
            yfft = (mean(abs(fft(Data,[],2))));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function makeSpecgram(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at)
        
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        dtapers = str2double(get(hTapers,'string'));
        dFs = str2double(get(hFs,'string'));
        blRange = ([BLMin BLMax]);                       
        numTapers = [ceil((dtapers+1)/2) dtapers];
        [params]=defparams(numTapers,dFs);
        dWinStep = str2double(get(hWinStep,'string'));
        
        if (dFs==0)
            set(hMessageText,'string','Fs is set to zero!!');
            return
        end
        
        [~,numCols] = size(plotHandles);
        check = 0;
        for i=1:numCols
            if isempty(aa)
                aa=1:length(aaValsUnique);
                for j=1:length(aaValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa(j),ae,as,ao,av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(as)
                as=1:length(asValsUnique);
                for j=1:length(asValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as(j),ao,av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(ao)
                ao=1:length(aoValsUnique);
                for j=1:length(aoValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao(j),av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(av)
                av=1:length(avValsUnique);
                for j=1:length(avValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av(j),at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(at)
                at=1:length(atValsUnique);
                for j=1:length(atValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at(j));
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(s)
                s=1:length(sValsUnique);
                for j=1:length(sValsUnique)                    
                    [Data,timeVals] = getData(a,e,s(j),f,o,c,t,aa,ae,as,ao,av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(f)
                f=1:length(fValsUnique);
                for j=1:length(fValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f(j),o,c,t,aa,ae,as,ao,av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(o)
                o=1:length(oValsUnique);
                for j=1:length(oValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o(j),c,t,aa,ae,as,ao,av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(c)
                c=1:length(cValsUnique);
                for j=1:length(cValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c(j),t,aa,ae,as,ao,av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif isempty(t)
                t=1:length(tValsUnique);
                for j=1:length(tValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t(j),aa,ae,as,ao,av,at);
                    plotHandle = plotHandles(j);
                    pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
                end
                check = 1;
            elseif (check == 0)
                j=1;
                [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
                plotHandle = plotHandles(j);
                pchangespecgramc(Data,timeVals,params,blRange,dWinStep ,dFs,plotHandle);
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plotMT_FFT(plotHandles,a,e,s,f,o,c,t,aa,ae,as,ao,av,at)
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        STMin = str2double(get(hStimPeriodMin,'string'));
        STMax = str2double(get(hStimPeriodMax,'string'));
        dtapers = str2double(get(hTapers,'string'));
        dFs = str2double(get(hFs,'string'));
        
        if (dFs==0)
            set(hMessageText,'string','Fs is set to zero!!');
            return
        end
        
        blRange = ([BLMin BLMax]);
        stRange = ([STMin STMax]);
        NBL = uint16(dFs*diff(blRange)); 
        NST = uint16(dFs*diff(stRange));
%         blPos= find(timeVals>=blRange(1),1) + (1:NBL);
%         stPos= find(timeVals>=stRange(1),1) + (1:NST);
                             
        numTapers = [ceil((dtapers+1)/2) dtapers];
        [params]=defparams(numTapers,dFs);
        
        plotColor = colorNames(get(hChooseColor,'val'));        
        
        [~,numCols] = size(plotHandles);
        check = 0;
        for i=1:numCols
            if isempty(aa)
                aa=1:length(aaValsUnique);
                for j=1:length(aaValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa(j),ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(as)
                as=1:length(asValsUnique);
                for j=1:length(asValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as(j),ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(ao)
                ao=1:length(aoValsUnique);
                for j=1:length(aoValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao(j),av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(av)
                av=1:length(avValsUnique);
                for j=1:length(avValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av(j),at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(at)
                at=1:length(atValsUnique);
                for j=1:length(atValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at(j));
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(s)
                s=1:length(sValsUnique);
                for j=1:length(sValsUnique)                    
                    [Data,timeVals] = getData(a,e,s(j),f,o,c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(f)
                f=1:length(fValsUnique);
                for j=1:length(fValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f(j),o,c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(o)
                o=1:length(oValsUnique);
                for j=1:length(oValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o(j),c,t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(c)
                c=1:length(cValsUnique);
                for j=1:length(cValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c(j),t,aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif isempty(t)
                t=1:length(tValsUnique);
                for j=1:length(tValsUnique)                    
                    [Data,timeVals] = getData(a,e,s,f,o,c,t(j),aa,ae,as,ao,av,at);
                    blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                    stPos= find(timeVals>=stRange(1),1) + (1:NST);
                    [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                    [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                    plot(plotHandles(j),fAxisBL,(log10(mtFFT_BL)),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                    plot(plotHandles(j),fAxisST,log10(mtFFT_ST)','Color','k','LineWidth',2); hold (plotHandles(j),'off');
                end
                check = 1;
            elseif (check == 0)
                j=1;
                [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,ae,as,ao,av,at);
                blPos= find(timeVals>=blRange(1),1) + (1:NBL);
                stPos= find(timeVals>=stRange(1),1) + (1:NST);
                [mtFFT_BL,fAxisBL]=takeMT_FFT(Data(:,blPos),params);
                [mtFFT_ST,fAxisST]=takeMT_FFT(Data(:,stPos),params);
                plot(plotHandles(j),fAxisBL,log10(mtFFT_BL),'Color',plotColor,'LineWidth',2); hold (plotHandles(j),'on');
                plot(plotHandles(j),fAxisST,log10(mtFFT_ST),'Color','k','LineWidth',2); hold (plotHandles(j),'off');
            end
        end
        function [SubT,fAxis]=takeMT_FFT(Data,params)
            for r=1:size(Data,1)                
                [SubTin,fAxisTin] = mtspectrumc((Data(r,:)),params);
                if (r==1)
                    SubTsum=SubTin;
                    fAxisSum = fAxisTin;
                else
                    SubTsum=SubTsum+SubTin;
                    fAxisSum = fAxisSum+fAxisTin;
                end                
            end
            SubT=SubTsum/size(Data,1);
            fAxis = fAxisSum/size(Data,1);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function paintPos
        analogChannelPos = get(hAnalogChannel,'val');
        if (strcmp(dataLog{2,2},'EEG') && (analogChannelPos>dataLog{7,2}))
            set(hMessageText,'string','Ainp, not an EEG electrode');
            return
        end
        
        RefChannelPos = get(hBipolarReferenceChannel,'val');           
        channelNumber = analogChannelsStored(analogChannelPos);
        RefNumber = analogChannelsStored(RefChannelPos);
                       
        plotColor = colorNames(get(hChooseColor,'val'));
        holdOnState = get(hHoldOn,'val');
        
        dRefType = get(hReferenceType,'val');
        
        if (dRefType == 3) % Bipolar Referencing         
            showElectrodeLocations(electrodeGridPos,[channelNumber RefNumber],{plotColor,'y'},hElectrodes,holdOnState,0,gridType,dataLog{1,2},gridLayout);
        elseif (dRefType == 2) % Average Referencing           
            showElectrodeLocations(electrodeGridPos,channelNumber,plotColor,hElectrodes,holdOnState,0,gridType,dataLog{1,2},gridLayout);
        else            
            showElectrodeLocations(electrodeGridPos,channelNumber,plotColor,hElectrodes,holdOnState,0,gridType,dataLog{1,2},gridLayout);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function CAxis_Callback(~,~)
        dCAxisMin = str2double(get(hCAxisMin,'string'));
        dCAxisMax = str2double(get(hCAxisMax,'string'));
        
        cAxisGivenPlotHandle(plotHandles,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hAudAziPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hAudSFPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hAudOriPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hAudTFPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hAudVolumePlot,dCAxisMin,dCAxisMax);
        
        cAxisGivenPlotHandle(hTemporalFreqPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hContrastPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hOrientationPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hSpatialFreqPlot,dCAxisMin,dCAxisMax);
        cAxisGivenPlotHandle(hSigmaPlot,dCAxisMin,dCAxisMax);
        
        function cAxisGivenPlotHandle(plotHandle,dCAxisMin,dCAxisMax)
            [numRows,numCols] = size(plotHandle);
            for i=1:numRows
                for j=1:numCols
                    caxis(plotHandle(i,j),[dCAxisMin dCAxisMax]);
                end
            end
        end
        
%         caxis(plotHandles,[dCAxisMin dCAxisMax]);  
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleX_Callback(~,~)
        analysisType = get(hTFAType,'val');
        if analysisType > 1
            xMin = str2double(get(hXMin,'String'));
            xMax = str2double(get(hXMax,'String'));

            rescaleData(plotHandles,[xMin xMax],getYLims(plotHandles));
            rescaleData(hAudAziPlot,[xMin xMax],getYLims(hAudAziPlot));
            rescaleData(hAudSFPlot,[xMin xMax],getYLims(hAudSFPlot));
            rescaleData(hAudOriPlot,[xMin xMax],getYLims(hAudOriPlot));
            rescaleData(hAudTFPlot,[xMin xMax],getYLims(hAudTFPlot));
            rescaleData(hAudVolumePlot,[xMin xMax],getYLims(hAudVolumePlot));
            
            rescaleData(hTemporalFreqPlot,[xMin xMax],getYLims(hTemporalFreqPlot));
            rescaleData(hContrastPlot,[xMin xMax],getYLims(hContrastPlot));
            rescaleData(hOrientationPlot,[xMin xMax],getYLims(hOrientationPlot));
            rescaleData(hSpatialFreqPlot,[xMin xMax],getYLims(hSpatialFreqPlot));
            rescaleData(hSigmaPlot,[xMin xMax],getYLims(hSigmaPlot));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleY_Callback(~,~)
        
        yMin = str2double(get(hYMin,'String'));
        yMax = str2double(get(hYMax,'String'));
        
        xMin = str2double(get(hXMin,'String'));
        xMax = str2double(get(hXMax,'String'));

        
        yLims = [yMin yMax];
        
        rescaleData(plotHandles,[xMin xMax],yLims);
        rescaleData(hAudAziPlot,[xMin xMax],yLims);
        rescaleData(hAudSFPlot,[xMin xMax],yLims);
        rescaleData(hAudOriPlot,[xMin xMax],yLims);
        rescaleData(hAudTFPlot,[xMin xMax],yLims);
        rescaleData(hAudVolumePlot,[xMin xMax],yLims);
        
        
        rescaleData(hTemporalFreqPlot,[xMin xMax],yLims);
        rescaleData(hContrastPlot,[xMin xMax],yLims);
        rescaleData(hOrientationPlot,[xMin xMax],yLims);
        rescaleData(hSpatialFreqPlot,[xMin xMax],yLims);
        rescaleData(hSigmaPlot,[xMin xMax],yLims);
        
%         rescaleData(plotHandles,getXLims(plotHandles),yLims);
%         rescaleData(hTemporalFreqPlot,getXLims(hTemporalFreqPlot),yLims);
%         rescaleData(hContrastPlot,getXLims(hContrastPlot),yLims);
%         rescaleData(hOrientationPlot,getXLims(hOrientationPlot),yLims);
%         rescaleData(hSpatialFreqPlot,getXLims(hSpatialFreqPlot),yLims);
%         rescaleData(hSigmaPlot,getXLims(hSigmaPlot),yLims);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SigRange_Callback(~,~)
        analysisType = get(hTFAType,'val');
        if analysisType == 1
            xMin = str2double(get(hSigMin,'String'));
            xMax = str2double(get(hSigMax,'String'));
            
            xLims = [xMin xMax];

            rescaleData(plotHandles,xLims,getYLims(plotHandles));
            rescaleData(hAudAziPlot,xLims,getYLims(hAudAziPlot));
            rescaleData(hAudSFPlot,xLims,getYLims(hAudSFPlot));
            rescaleData(hAudOriPlot,xLims,getYLims(hAudOriPlot));
            rescaleData(hAudTFPlot,xLims,getYLims(hAudTFPlot));
            rescaleData(hAudVolumePlot,xLims,getYLims(hAudVolumePlot));
            
            rescaleData(hTemporalFreqPlot,xLims,getYLims(hAudAziPlot));
            rescaleData(hContrastPlot,xLims,getYLims(hAudSFPlot));
            rescaleData(hOrientationPlot,xLims,getYLims(hAudOriPlot));
            rescaleData(hSpatialFreqPlot,xLims,getYLims(hAudTFPlot));
            rescaleData(hSigmaPlot,xLims,getYLims(hAudVolumePlot));
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function holdOn_Callback(source,~)
        holdOnState = get(source,'Value');
        
        holdOnGivenPlotHandle(plotHandles,holdOnState);
        holdOnGivenPlotHandle(hAudAziPlot,holdOnState);
        holdOnGivenPlotHandle(hAudSFPlot,holdOnState);
        holdOnGivenPlotHandle(hAudOriPlot,holdOnState);
        holdOnGivenPlotHandle(hAudTFPlot,holdOnState);
        holdOnGivenPlotHandle(hAudVolumePlot,holdOnState);
        
        holdOnGivenPlotHandle(hTemporalFreqPlot,holdOnState);
        holdOnGivenPlotHandle(hContrastPlot,holdOnState);
        holdOnGivenPlotHandle(hOrientationPlot,holdOnState);
        holdOnGivenPlotHandle(hSpatialFreqPlot,holdOnState);
        holdOnGivenPlotHandle(hSigmaPlot,holdOnState);
        
        if ~isempty(dataLog{7,2})
            if holdOnState
                set(hElectrodes,'Nextplot','add');
            else
                set(hElectrodes,'Nextplot','replace');
            end
        end

        function holdOnGivenPlotHandle(plotHandles,holdOnState)
            
            [numRows,numCols] = size(plotHandles);
            if holdOnState
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','add');

                    end
                end
            else
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','replace');
                    end
                end
            end
        end 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        
        claGivenPlotHandle(plotHandles);
        claGivenPlotHandle(hAudAziPlot);
        claGivenPlotHandle(hAudSFPlot);
        claGivenPlotHandle(hAudOriPlot);
        claGivenPlotHandle(hAudTFPlot);
        claGivenPlotHandle(hAudVolumePlot);
        
        claGivenPlotHandle(hTemporalFreqPlot);
        claGivenPlotHandle(hContrastPlot);
        claGivenPlotHandle(hOrientationPlot);
        claGivenPlotHandle(hSpatialFreqPlot);
        claGivenPlotHandle(hSigmaPlot);
        
        cla(rawWavePlotHandle);
        
        set(hMessageText,'String', '');
        set(hTotalTrials,'String', '');
        set(hBadTrials,'String', '');
        set(hVisBadTrials,'String', '');
        set(hAnalysableTrials,'String', '');
        
        function claGivenPlotHandle(plotHandles)
            [numRows,numCols] = size(plotHandles);
            for i=1:numRows
                for j=1:numCols
                    cla(plotHandles(i,j));
                end
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function RMS_String = getRMS_String
        
        RMS_String = '';
        
        if length(avValsUnique) > 1
            RMS_String = [RMS_String '|Across Auditory Volume'];
        end
        
        if length(atValsUnique) > 1
            RMS_String = [RMS_String '|Across Auditory Type'];
        end
        
        if length(sValsUnique) > 1
            RMS_String = [RMS_String '|Across Sigma'];
        end
        
        if length(fValsUnique) > 1
            RMS_String = [RMS_String '|Across Spatial Frequency'];
        end
        
        if length(oValsUnique) > 1
            RMS_String = [RMS_String '|Across Orientation'];
        end
        
        if length(cValsUnique) > 1
            RMS_String = [RMS_String '|Across Contrast'];
        end
        
        if length(tValsUnique) > 1
            RMS_String = [RMS_String '|Across Temporal Frequency'];
        end
        
        if length(aValsUnique) > 1
            RMS_String = [RMS_String '|Across Azimuth'];
        end
        
        if length(eValsUnique) > 1
            RMS_String = [RMS_String '|Across Elevation'];
        end
        
        if isempty(RMS_String)
            RMS_String = 'Only one combi available';
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function RMS_Callback (~,~)
        
        RMSStringList = get(hRMSpopup,'String');
        RMSPopupVal = get(hRMSpopup,'val');
        RMS_String = strtrim(RMSStringList(RMSPopupVal,:));
        
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAziVal,'val');
        ao=get(hAudOriVal,'val');
        as=get(hAudSFVal,'val');
        av=get(hAudVolumeVal,'val');
        at=get(hAudTFVal,'val');
        dFs = str2double(get(hFs,'string'));
        
        s1 = 'Across Auditory Volume';
        
        if (dFs==0)
            set(hMessageText,'string','Fs is set to zero!!');
            return
        end
        
        minTime = str2double(get(hTimeMin,'String'));
        maxTime = str2double(get(hTimeMax,'String'));
        TimeRange = ([minTime maxTime]);
        nTR = (dFs*diff(TimeRange)); 
        
        if strcmp(RMS_String,'Across Azimuth')
%             aT = 1:1:length(aValsUnique);
            for j=1:length(aValsUnique)                    
                        [Data,timeVals] = getData(j,e,s,f,o,c,t,aa,as,ao,av,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(aValsUnique,erpRMS,'*','r');
            
        elseif strcmp(RMS_String,'Across Elevation')
%             eT = 1:1:length(eValsUnique);
            for j=1:length(eValsUnique)                    
                        [Data,timeVals] = getData(a,j,s,f,o,c,t,aa,as,ao,av,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(eValsUnique,erpRMS,'*','r');
            
        elseif strcmp(RMS_String,'Across Sigma')
%             sT = 1:1:length(sValsUnique);
            for j=1:length(sValsUnique)                    
                        [Data,timeVals] = getData(a,e,j,f,o,c,t,aa,as,ao,av,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(sValsUnique,erpRMS,'*','r');
            
        elseif strcmp(RMS_String,'Across Spatial Frequency')
%             fT = 1:1:length(fValsUnique);
            for j=1:length(fValsUnique)                    
                        [Data,timeVals] = getData(a,e,s,j,o,c,t,aa,as,ao,av,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(fValsUnique,erpRMS,'*','r');
            
        elseif strcmp(RMS_String,'Across Orientation')
%             oT = 1:1:length(oValsUnique);
            for j=1:length(oValsUnique)                    
                        [Data,timeVals] = getData(a,e,s,f,j,c,t,aa,as,ao,av,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(oValsUnique,erpRMS,'*','r');
            
        elseif strcmp(RMS_String,'Across Contrast')
%             cT = 1:1:length(cValsUnique);
            for j=1:length(cValsUnique)                    
                        [Data,timeVals] = getData(a,e,s,f,o,j,t,aa,as,ao,av,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(cValsUnique,erpRMS,'*','r');
            
        elseif strcmp(RMS_String,'Across Temporal Frequency')
%             tT = 1:1:length(tValsUnique);
            for j=1:length(tValsUnique)                    
                        [Data,timeVals] = getData(a,e,s,f,o,c,j,aa,as,ao,av,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(tValsUnique,erpRMS,'*','r');
            
        elseif strcmp(RMS_String,'Across Auditory Volume')
%             avT = 1:1:length(avValsUnique);
            for j=1:length(avValsUnique)
                disp(['Getting data for volume: ' num2str(avValsUnique(j))]);
                [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,as,ao,j,at);
                TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                disp(['Calculating RMS for volume: ' num2str(avValsUnique(j))]);
                erp = mean(Data,1);
                erpRMS(1,j) = rms(erp(1,TRPos));
            end
            disp('Calculating statistics');
            stats = regstats(erpRMS,avValsUnique,'linear');
%             assignin('base','Stats',stats);
            
%             if ~exist('count','var')
%                 count = 1;
%             else
%                 count = count + 1;
%             end
%             
%             assignin('base','count',count);
% 
%             count = 2;
%             
%             regStatsTable.beta1(count) = stats.beta(2,1);
%             assignin('base','regStatsTable',regStatsTable);

            StatsLog.AudioType = at;
            StatsLog.beta1 = stats.beta(2,1);
            StatsLog.rsquare = stats.rsquare;
            StatsLog.pValue = stats.tstat.pval(2,1);
            assignin('base','StatsLog',StatsLog);
            
            figure; scatter(avValsUnique,erpRMS,'*','r'); lsline;  
            
        elseif strcmp(RMS_String,'Across Auditory Type')
%             atT = 1:1:length(atValsUnique);
            for j=1:length(atValsUnique)                    
                        [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,as,ao,av,j);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        erp = mean(Data,1);
                        erpRMS(1,j) = rms(erp(1,TRPos));
            end
            figure; scatter(atValsUnique,erpRMS,'*','r');
%         else
%             return
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function RMSDist_Callback (~,~)
        
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAziVal,'val');
        ao=get(hAudOriVal,'val');
        as=get(hAudSFVal,'val');
        av=get(hAudVolumeVal,'val');
        at=get(hAudTFVal,'val');
        dFs = dataLog{10, 2};
        
        minTime = str2double(get(hTimeMin,'String'));
        maxTime = str2double(get(hTimeMax,'String'));
        TimeRange = ([minTime maxTime]);
        nTR = (dFs*diff(TimeRange)); 
        
        for j=1:length(avValsUnique)                    
                        [Data,timeVals] = getData(a,e,s,f,o,c,t,aa,as,ao,j,at);
                        TRPos= find(timeVals>=TimeRange(1),1) + (1:nTR);
                        for z=1:size(Data,1)
                            trialRMS(j,z) = rms((Data(z,TRPos)));
                            trialNum(j,z)=z;
                        end
        end
%         figure; scatter(avValsUnique,erpRMS,'*','r'); 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xLims = getXLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
XMin = inf;
XMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        tmpAxisVals = axis(plotHandles(row,column));
        if tmpAxisVals(1) < XMin
            XMin = tmpAxisVals(1);
        end
        if tmpAxisVals(2) > XMax
            XMax = tmpAxisVals(2);
        end
    end
end

xLims=[XMin XMax];
end
function yLims = getYLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
yMin = inf;
yMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        tmpAxisVals = axis(plotHandles(row,column));
        if tmpAxisVals(3) < yMin
            yMin = tmpAxisVals(3);
        end
        if tmpAxisVals(4) > yMax
            yMax = tmpAxisVals(4);
        end
    end
end

yLims=[yMin yMax];
end
function rescaleData(plotHandles,xLims,yLims)

[numRows,numCols] = size(plotHandles);
labelSize=12;
for i=1:numRows
    for j=1:numCols
        axis(plotHandles(i,j),[xLims yLims]);
        if (i==numRows && rem(j,2)==1)
            if j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        else
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        end
    end
end

% Remove Labels on the four corners
%set(plotHandles(1,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(1,numCols),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,numCols),'XTickLabel',[],'YTickLabel',[]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outString = getStringFromValues(valsUnique,decimationFactor)

if length(valsUnique)==1
    outString = convertNumToStr(valsUnique(1),decimationFactor);
else
    outString='';
    for i=1:length(valsUnique)
        outString = cat(2,outString,[convertNumToStr(valsUnique(i),decimationFactor) '|']);
    end
    outString = [outString 'all'];
end

    function str = convertNumToStr(num,f)
        if num > 16384
            num=num-32768;
        end
        str = num2str(num/f);
    end
end
function [outString,outArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums)
outString='';
count=1;
for i=1:length(analogChannelsStored)
    outArray{count} = ['elec' num2str(analogChannelsStored(i))]; %#ok<AGROW>
    outString = cat(2,outString,[outArray{count} '|']);
    count=count+1;
end
if ~isempty(analogInputNums)
    for i=1:length(analogInputNums)
        outArray{count} = ['ainp' num2str(analogInputNums(i))]; %#ok<AGROW>
        outString = cat(2,outString,[outArray{count} '|']);
        count=count+1;
    end
end
end
function outString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs)
outString='';
for i=1:length(neuralChannelsStored)
    outString = cat(2,outString,[num2str(neuralChannelsStored(i)) ', SID ' num2str(SourceUnitIDs(i)) '|']);
end 
end
function [colorString, colorNames] = getColorString

colorNames = 'gybrkcm';
colorString = 'green|yellow|blue|red|black|cyan|magenta';

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%c%%%%%%%%%
%%%%%%%%%%%%c%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load Data
% function [analogChannelsStored,timeVals,goodStimPos,analogInputNums,electrodesStored] = loadlfpInfo(folderLFP) %#ok<*STOUT>
% load(fullfile(folderLFP,'lfpInfo'));
% 
% if ~exist('analogInputNums','var'); analogInputNums=[]; end;
% if ~exist('goodStimPos','var'); goodStimPos = []; end;
% 
% end
% function [neuralChannelsStored,SourceUnitID] = loadspikeInfo(folderSpikes)
% fileName = fullfile(folderSpikes,'spikeInfo.mat');
% if exist(fileName,'file')
%     load(fileName);
% else
%     neuralChannelsStored=[];
%     SourceUnitID=[];
% end
% end


