%% plotEEGAllElec
% 
% Plots ERP of a specified electrode, RMS amplitude of ERP in a given
% duration across all electrodes as a scalp map, and change of power of a
% specified frequency band in a given time range from a specified baseline
% period, calculated using STFT.
% Also plots ERP/FFT/STFT for all electrodes simultaneously for comparison.
%
% Syntax: plotEEGAllElec(dataLog)
% dataLog input is optional; It is a cell containing all the info regarding the
% extraction of the data. If this argument is not passed, a dialog box
% would appear asking for dataLog.mat file. e.g.:
% dataLog = 
%
%     'subjectName'              'BAB'          
%     'gridType'                 'EEG'         
%     'expDate'                  '080715'      
%     'protocolName'             'GAV_0001'
%     'timeStartFromBaseLine'    [          -1]
%     'deltaT'                   [           3]
%     'electrodesToStore'         [1x64 double]
%     'badTrials'                            []
%     'elecSampleRate'           [        2500]
%     'AinpSampleRate'           [        2500]
%     'LLData'                   'YES'         
%     'LLExtract'                'YES'         
%     'Reallign'                 'NO'          
%     'folderSourceString'       'D:'          
%     'Montage'                  'actiCap64'   
%     'Re-Ref Elec'              'None'   
%
% This program uses topoplot and readlocs functions of EEGLAB and routines of the 
% chronux toolbox, and currently supports GAV protocol only. Minor changes are
% required to incorporate other protocols as far as getting data is concerned, 
% but please do not change the general structure of the program unless
% required.
%
% Requisites:
% 1. EEGLAB
% 2. Chronux toolbox
% 3. Montages file of the electrode cap, stored as 'chanlocs' variable in
% .mat file, containing info of the electrode positions on the cap. This
% folder (called 'Montages') showd be placed in the present working
% directory to be detectable by the program.
% 4. Important functions:
%       loadlfpInfo.m
%       loadChanLocs.m
%       loadParameterCombinations.m
%       loadAnalogData.m
%       getFolderDetails.m
%       plotForAllEEGElecs.m
%       conv2Log.m
%
% Revision History:
% 03-07-15: Created by Murty V P S Dinavahi (MD)
% 03-09-15: Modified by MD, Added options for bipolar (nearest neighbour)
%   montaging.
% 09-11-15: Modified by MD, Added options for plotting ERP/FFT/STFT for all
%   electrodes simultaneously for comparison between electrodes.

function plotEEGAllElec(dataLog)
%% Initialise

if ~exist('dataLog','var')
    try
        dataLog = evalin('base','dataLog');
    catch
        fileExt = {'*.mat'};
        [hdrfile,path] = uigetfile(fileExt, 'Select dataLog file...');
        if hdrfile(1) == 0, return; end
        fname = fullfile(path,hdrfile);
        dataL = load(fname);
        dataLog = dataL.dataLog;
    end
end

[~,folderName]=getFolderDetails(dataLog);
protocolName = dataLog{4,2};
timeStartFromBaseline = dataLog{5,2};
deltaT = dataLog{6,2};
gridMontage = dataLog{15,2};
subjectName = strjoin(dataLog(1,2));
expDate = strjoin(dataLog(3,2));

%% Load Data
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');

[analogChannelsStored,timeVals,~,analogInputNums,~] = loadlfpInfo(folderLFP);
chanlocs = loadChanLocs(gridMontage);

% The following variables are stored instance variables to account for cost of
% computation
plotData = [];
goodPos = [];
Data = [];
dSPower = [];
t2 = [];
f2 = [];
allBadTrials=[];
trialNums=[];
resetParamsFlag = 1;
refChangeFlag = 1;
paramChangeFlag = 1;
resetVisAinpFlag = 1;
resetAudAinpFlag = 1;
resetERPElecFlag = 1;
resetERPRange = 1;
TFPlotFlag = 1;
resetEpochRangeFlag = 1;

%% Get Combinations
[~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique,aaValsUnique,aeValsUnique,asValsUnique,aoValsUnique,avValsUnique,atValsUnique] = loadParameterCombinations(folderExtract);

%% Default MTM params
mtmParams.Fs = dataLog{9,2};
mtmParams.tapers=[2 3];
mtmParams.trialave=0;
mtmParams.err=0;
mtmParams.pad=-1;

movingWin = [0.4 0.01];

%% Figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16; fontSizeTiny = 8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
panelHeight = 0.3; panelStartHeight = 0.68;
staticPanelWidth = 0.22; staticStartPos = 0.025; 
dynamicPanelWidth = 0.18; dynamicStartPos = 0.245; 
timingPanelWidth = 0.18; timingStartPos = dynamicStartPos+dynamicPanelWidth;
tfPanelWidth = 0.18; tfStartPos = timingStartPos+timingPanelWidth;
plotOptionsPanelWidth = 0.18; plotOptionsStartPos = tfStartPos+tfPanelWidth;
backgroundColor = 'w';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameters panel %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%% Visual Parameters %%%%%%%%%%%%%%%%%%%%%%%%%
    
figure('numbertitle', 'off','name',[subjectName expDate protocolName]);
dynamicHeight = 0.06; dynamicGap=0.015; dynamicTextWidth = 0.6;
hDynamicPanel = uipanel('Title','Stimulus Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[dynamicStartPos panelStartHeight dynamicPanelWidth panelHeight]);

    % Sigma
    sigmaString = getStringFromValuesGRF(sValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-1*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Sigma (Deg)','FontSize',fontSizeTiny);
    hSigma = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-1*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',sigmaString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Spatial Frequency
    spatialFreqString = getStringFromValuesGRF(fValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Spatial Freq (CPD)','FontSize',fontSizeTiny);
    hSpatialFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',spatialFreqString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Orientation
    orientationString = getStringFromValuesGRF(oValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Orientation (Deg)','FontSize',fontSizeTiny);
    hOrientation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',orientationString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Contrast
    contrastString = getStringFromValuesGRF(cValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-4*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Contrast (%)','FontSize',fontSizeTiny);
    hContrast = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-4*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',contrastString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Temporal Frequency
    temporalFreqString = getStringFromValuesGRF(tValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Temporal Freq (Hz)','FontSize',fontSizeTiny);
    hTemporalFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',temporalFreqString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Azimuth
    azimuthString = getStringFromValuesGRF(aValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-6*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
        'Style','text','String','Azimuth (Deg)','FontSize',fontSizeTiny);
    hAzimuth = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-6*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',azimuthString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Elevation
    elevationString = getStringFromValuesGRF(eValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-7*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Elevation (Deg)','FontSize',fontSizeTiny);
    hElevation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position',...
        [dynamicTextWidth 1-7*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',elevationString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Auditory Parameters %%%%%%%%%%%%%%%%%%%%%%%
    % Ripple Frequency
    rippleFreqString = getStringFromValuesGRF(asValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-8*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Ripple/tone Freq (Hz)','FontSize',fontSizeTiny);
    hRipFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-8*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',rippleFreqString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Phase
    ripplePhaseString = getStringFromValuesGRF(aoValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-9*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Ripple Phase (Deg)','FontSize',fontSizeTiny);
    hRipPhase = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-9*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',ripplePhaseString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % ModDepth
    modDepthString = getStringFromValuesGRF(avValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-10*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Mod. Depth/Vol (%)','FontSize',fontSizeTiny);
    hRipModDepth = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-10*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',modDepthString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Ripple Velocity
    ripVelString = getStringFromValuesGRF(atValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-11*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Ripple Velocity (Hz)','FontSize',fontSizeTiny);
    hRipVelocity = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-11*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',ripVelString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Auditory Azimuth
    audAzimuthString = getStringFromValuesGRF(aaValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-12*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
        'Style','text','String','Auditory Azimuth (Deg)','FontSize',fontSizeTiny);
    hAudAzimuth = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-12*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',audAzimuthString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});

    % Auditory Elevation
    audElevationString = getStringFromValuesGRF(aeValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-13*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Auditory Elevation (Deg)','FontSize',fontSizeTiny);
    hAudElevation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position',...
        [dynamicTextWidth 1-13*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',audElevationString,'FontSize',fontSizeTiny,'Callback',{@resetParams_Callback});
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timings panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timingHeight = 0.1; timingTextWidth = 0.5; timingBoxWidth = 0.20;  
hTimingsPanel = uipanel('Title','Timing','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[timingStartPos panelStartHeight timingPanelWidth panelHeight]);

signalRange = [timeStartFromBaseline deltaT+timeStartFromBaseline];
baseline = [-0.5 0];
stimPeriod = [0.25 0.75];

% Signal Range
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Parameter','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Min','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth+timingBoxWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Max','FontSize',fontSizeMedium);

% Epoch Range
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Epoch Range (s)','FontSize',fontSizeSmall);
hEpochMin = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-2*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeSmall,'Callback',{@resetEpochRangeFlag_Callback});
hEpochMax = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-2*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeSmall,'Callback',{@resetEpochRangeFlag_Callback});

% ERP
% ERP Range
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-4*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','ERP:','FontSize',fontSizeSmall);
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','ERP Range (s)','FontSize',fontSizeSmall);
hERPMin = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',0,'FontSize',fontSizeSmall,'Callback',{@resetERPRangeFlag_Callback});
hERPMax = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',0.25,'FontSize',fontSizeSmall,'Callback',{@resetERPRangeFlag_Callback});

% TFA
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Time-Frequency plot:','FontSize',fontSizeSmall);

% Baseline
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Basline (s)','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback});
hBaselineMax = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall,'Callback',{@resetMTMParams_Callback});

% Stim Period
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-9*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim period (s)','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-9*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall); 
hStimPeriodMax = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-9*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall); 

% Frequency Band
fBandLow = 30; fBandHigh = 80;
uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'Position',[0 1-10*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','freqBand range','FontSize',fontSizeSmall);
hfBandLow = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-10*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fBandLow),'FontSize',fontSizeSmall); 
hfBandHigh = uicontrol('Parent',hTimingsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-10*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fBandHigh),'FontSize',fontSizeSmall); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% TF Options panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hTFParamPanel = uipanel('Title','TF Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[tfStartPos panelStartHeight tfPanelWidth panelHeight]);

% Tapers TW
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','TW','FontSize',fontSizeSmall);

hMTMTapersTW = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',mtmParams.tapers(1),'FontSize',fontSizeTiny,'Callback',{@resetMTMParams_Callback}); 

% Tapers 'k'
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','k','FontSize',fontSizeSmall);

hMTMTapersK = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-2*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',mtmParams.tapers(2),'FontSize',fontSizeTiny,'Callback',{@resetMTMParams_Callback}); 
% Window length
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','wLen','FontSize',fontSizeSmall);

hMTMwLen = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',movingWin(1),'FontSize',fontSizeTiny,'Callback',{@resetMTMParams_Callback}); 

% Window translation step
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-4*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','wStep','FontSize',fontSizeSmall);
hMTMwStep = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-4*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',movingWin(2),'FontSize',fontSizeTiny,'Callback',{@resetMTMParams_Callback}); 

% Fs
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Fs','FontSize',fontSizeSmall);
hMTMFs = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',mtmParams.Fs,'FontSize',fontSizeTiny,'Callback',{@resetMTMParams_Callback}); 

% Channel for TF
[analogChannelStringList,~] = getAnalogStringFromValues(analogChannelsStored,analogInputNums);
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-7*timingHeight timingTextWidth timingHeight],...
    'Style','text','String','Elec for TF: ','FontSize',fontSizeSmall);
hTFElec = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-7*timingHeight timingTextWidth timingHeight], ...
    'Style','popup','String',analogChannelStringList,'FontSize',fontSizeSmall,'Callback',{@resetERPElecFlag_Callback});

% Elecs for pooling: TF
uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight],...
    'Style','text','String','Elec for TF (pool): ','FontSize',fontSizeSmall);
hTFElecPool = uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','edit','FontSize',fontSizeSmall,'Callback',{@resetERPElecFlag_Callback});

uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0.1 1-9*timingHeight 0.8 timingHeight],...
    'Style','pushbutton','String','Plot TF Plots','FontSize',fontSizeSmall,'Callback',{@plotTF_Callback});

uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0.1 1-10*timingHeight 0.37 timingHeight],...
    'Style','pushbutton','String','Plot TF All Elec','FontSize',fontSizeSmall,'Callback',{@plotTFAllElec_Callback});

uicontrol('Parent',hTFParamPanel,'Unit','Normalized', ...
    'Position',[0.53 1-10*timingHeight 0.37 timingHeight],...
    'Style','pushbutton','String','Plot FFT All Elec','FontSize',fontSizeSmall,'Callback',{@plotFFTAllElec_Callback});

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% ERP Options panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hOptionsPanel = uipanel('Title','ERP Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[plotOptionsStartPos panelStartHeight plotOptionsPanelWidth panelHeight]);

% Visual Stimulus Ainp
[outAinpString] = getAinpStringFromValues(analogChannelsStored,analogInputNums);
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-1*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Visual Ainp Elec:','FontSize',fontSizeSmall);
hVisAinp = uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [timingTextWidth 1-1*timingHeight timingTextWidth timingHeight], ...
    'Style','popup','String',[outAinpString '|None'],'FontSize',fontSizeSmall,'Callback',{@resetVisAinpFlag_Callback});

if strncmp(protocolName,'GAV',3)
    set(hVisAinp,'val',(length(analogInputNums)-1))
end

% Ainp Elec for Auditory stimulus
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Auditory Ainp Elec:','FontSize',fontSizeSmall);
hAudAinp = uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [timingTextWidth 1-2*timingHeight timingTextWidth timingHeight], ...
    'Style','popup','String',[outAinpString '|None'],'FontSize',fontSizeSmall,'Callback',{@resetAudAinpFlag_Callback});

if strncmp(protocolName,'GAV',3)
    set(hAudAinp,'val',length(analogInputNums))
end


% Referencing
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight],...
    'Style','text','String','Referencing: ','FontSize',fontSizeSmall);
hRefChannel = uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','popup','String',(['Single Wire|Hemisphere|Average|Bipolar|' analogChannelStringList]),'FontSize',fontSizeSmall,'Callback',{@resetRef_Callback});

% Channel for ERP
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-4*timingHeight timingTextWidth timingHeight],...
    'Style','text','String','Elec for ERP: ','FontSize',fontSizeSmall);
hERPElec = uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-4*timingHeight timingTextWidth timingHeight], ...
    'Style','popup','String',analogChannelStringList,'FontSize',fontSizeSmall,'Callback',{@resetERPElecFlag_Callback});

% Plot and clear all buttons
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.1 1-5*timingHeight 0.8 timingHeight],...
    'Style','pushbutton','String','Plot ERP','FontSize',fontSizeSmall,'Callback',{@plot_Callback});

uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.1 1-6*timingHeight 0.8 timingHeight],...
    'Style','pushbutton','String','Clear all','FontSize',fontSizeSmall,'Callback',{@cla_Callback});

uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.1 1-7*timingHeight 0.8 timingHeight],...
    'Style','pushbutton','String','Plot ERP All Elecs','FontSize',fontSizeSmall,'Callback',{@plotERPAllElecs_Callback});

% Elecs for pooling: ERP
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight],...
    'Style','text','String','Elec for ERP (pool): ','FontSize',fontSizeSmall);
hERPElecPool = uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [timingTextWidth 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','edit','FontSize',fontSizeSmall,'Callback',{@resetERPElecFlag_Callback});

% Plot button for electrode pooling
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.1 1-9*timingHeight 0.8 timingHeight],...
    'Style','pushbutton','String','Pool elecs and Plot ERP ','FontSize',fontSizeSmall,'Callback',{@plotPoolElecs_Callback});


%%%%%%%%%%%%%%%%%%%%%%%%%%% Electrode locations %%%%%%%%%%%%%%%%%%%%%%%%%%%

electrodeCapPos = [staticStartPos panelStartHeight staticPanelWidth panelHeight];
capHandle = subplot('Position',electrodeCapPos);
subplot(capHandle); topoplot([],chanlocs,'electrodes','numbers','style','blank','drawaxis','off'); 
text(0.1,0.9,gridMontage,'unit','normalized','fontsize',9,'Parent',capHandle);

capStartHeight = 0.1; capWidth = 0.32; capHeight = 1-panelStartHeight+0.2;

erpPos = [staticStartPos capStartHeight+2*(capHeight/3) capWidth capHeight/3];
erpRefPos = [staticStartPos capStartHeight+(capHeight/3) capWidth capHeight/3];
audStimPos = [staticStartPos capStartHeight+(capHeight/6) capWidth capHeight/6];
visStimPos = [staticStartPos capStartHeight capWidth capHeight/6];

plotVisStimHandle = subplot('Position',visStimPos); axis off;
plotAudStimHandle = subplot('Position',audStimPos); axis off;
plotERPRefHandle = subplot('Position',erpRefPos); axis off;
plotERPHandle = subplot('Position',erpPos); axis off;

electrodeCapPosERP = [staticStartPos+capWidth capStartHeight capWidth capHeight];
capERPHandle = subplot('Position',electrodeCapPosERP); axis off;

electrodeCapPosERPRef = [staticStartPos+2*capWidth capStartHeight capWidth capHeight];
capERPRefHandle = subplot('Position',electrodeCapPosERPRef); axis off;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plot_Callback(~,~)
        
        % Intitialise     
        cla_Callback;
        
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAzimuth,'val');
        ae=get(hAudElevation,'va');
        as=get(hRipFreq,'val');
        ao=get(hRipPhase,'val');        
        av=get(hRipModDepth,'val');
        at=get(hRipVelocity,'val');
        
        refChanIndex = get(hRefChannel,'val');
        
        % ERP and TFA Variables
        ERPElec = get(hERPElec,'val');
        ERPPoolElecs = str2num(get(hERPElecPool,'string'));
        if isempty(ERPPoolElecs)
            ERPPoolElecs = ERPElec;
        end
        
        visAinp = get(hVisAinp,'val');
        audAinp = get(hAudAinp,'val');
        epochMin = str2double(get(hEpochMin,'string'));
        epochMax = str2double(get(hEpochMax,'string'));
        ERPMin = str2double(get(hERPMin,'string'));
        ERPMax = str2double(get(hERPMax,'string'));
        
        tERP = (timeVals>=epochMin) & (timeVals<=epochMax);
        blPeriod = (timeVals<=0);
        if ~blPeriod
            blPeriod = tERP;
        end
        
        mtmParams.Fs = str2double(get(hMTMFs,'String'));
        mtmParams.tapers(1) = str2double(get(hMTMTapersTW,'String'));
        mtmParams.tapers(2) = str2double(get(hMTMTapersK,'String'));
        
        movingWin(1) = str2double(get(hMTMwLen,'String'));
        movingWin(2) = str2double(get(hMTMwStep,'String'));
        
        % Get Data
        if resetParamsFlag
            [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,analogChannelsStored);            
        end
        
        if refChangeFlag
            [Data,goodPos] = bipolarRef(trialNums,allBadTrials);
        end        
        
        % Plot Visual Stimulus
        if visAinp<length(analogInputNums)+1
            if resetVisAinpFlag || resetEpochRangeFlag
                clear erp;   
                try
                    visData = getAinpDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,visAinp);
                    erp = mean(visData(:,tERP),1);
                    plot(plotVisStimHandle,timeVals(tERP),erp); xlim(plotVisStimHandle,[epochMin epochMax]);
                catch
                    disp('No Analog Data or Analog Data could not be read!')
                end
            end
        end
        
        % Plot Auditory Stimulus
        if audAinp<length(analogInputNums)+1
            if resetAudAinpFlag || resetEpochRangeFlag
                clear erp;  
                try
                    audData = getAinpDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,audAinp);
                    erp = mean(audData(:,tERP),1);
                    plot(plotAudStimHandle,timeVals(tERP),erp); xlim(plotAudStimHandle,[epochMin epochMax]);
                catch
                    disp('No Analog Data or Analog Data could not be read!')
                end
            end
        end
        
        % Plot ERP
        if resetERPElecFlag || resetEpochRangeFlag || refChangeFlag
            clear erp erpRef;
            
            erpRefData = squeeze(Data(ERPElec,goodPos{ERPElec},tERP));
            if refChanIndex ~= 4
                erpData = squeeze(plotData(ERPElec,goodPos{ERPElec},tERP));
            else
                erpData = erpRefData;
            end            
            
            if length(goodPos{ERPElec}) == 1
                erpData = erpData';
            end
            
            erp = mean((erpData - repmat(mean(erpData(:,blPeriod),2),1,size(erpData,2))),1); % Correct for DC Shift (baseline correction)
            erpRef = mean((erpRefData - repmat(mean(erpRefData(:,blPeriod),2),1,size(erpRefData,2))),1); % Correct for DC Shift (baseline correction)
            
            plot(plotERPHandle,timeVals(tERP),erp); xlim(plotERPHandle,[epochMin epochMax]);
            text(0.1,0.9,['ERP; n = ' num2str(length(goodPos{ERPElec})) '. Y-axis reveresed.'],'unit','normalized','fontsize',9,'Parent',plotERPHandle);
            set(plotERPHandle,'Ydir','reverse');
            
            plot(plotERPRefHandle,timeVals(tERP),erpRef); xlim(plotERPRefHandle,[epochMin epochMax]);
            text(0.1,0.9,['ERP Referenced; n = ' num2str(length(goodPos{ERPElec})) '. Y-axis reveresed.'],'unit','normalized','fontsize',9,'Parent',plotERPRefHandle);
            set(plotERPRefHandle,'Ydir','reverse');
        end
        
        % Plot ERP Topoplot
        if resetERPRange || refChangeFlag
            tERPTopo = (timeVals>=ERPMin) & (timeVals<=ERPMax);
            tERPTopoBL = (timeVals>=((-1)*ERPMax)) & (timeVals<=((-1)*ERPMin));

            if refChanIndex ~= 4
                erpTopoRef = getERPTopoData(Data,goodPos,tERPTopo,tERPTopoBL);                
                subplot(capERPRefHandle); topoplot(erpTopoRef,chanlocs,'electrodes','numbers','style','both','drawaxis','off'); 
                colorbar; title(['RMS Amplitude of ERP: ' num2str(ERPMin) ' to ' num2str(ERPMax) ' s - RMS of baseline. (Rereferenced)']);
            
                erpTopo = getERPTopoData(plotData,goodPos,tERPTopo,tERPTopoBL);
                subplot(capERPHandle); topoplot(erpTopo,chanlocs,'electrodes','numbers','style','both','drawaxis','off'); 
                colorbar; title(['RMS Amplitude of ERP: ' num2str(ERPMin) ' to ' num2str(ERPMax) ' s - RMS of baseline']);            
            else
                erpTopoRef = (rms(squeeze(mean((Data(:,:,tERPTopo)-repmat(mean(Data(:,:,blPeriod),3),1,1,size(Data(:,:,tERPTopo),3))),2))'))'...
                    -(rms(squeeze(mean((Data(:,:,tERPTopoBL)-repmat(mean(Data(:,:,blPeriod),3),1,1,size(Data(:,:,tERPTopoBL),3))),2))'))';
                subplot(capERPRefHandle); topoplot(erpTopoRef,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir','-Y'); 
                colorbar; title(['RMS Amplitude of ERP: ' num2str(ERPMin) ' to ' num2str(ERPMax) ' s - RMS of baseline. (Rereferenced)']);                
            end
            
           
        end
        
        % Reset all flags to 0
        resetParamsFlag = 0;
        refChangeFlag = 0;
        paramChangeFlag = 0;
        resetVisAinpFlag = 0;
        resetAudAinpFlag = 0;
        resetERPElecFlag = 0;
        resetERPRange = 0;
        resetEpochRangeFlag = 0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function plotERPAllElecs_Callback(~,~)
        
        % Intitialise             
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAzimuth,'val');
        ae=get(hAudElevation,'va');
        as=get(hRipFreq,'val');
        ao=get(hRipPhase,'val');        
        av=get(hRipModDepth,'val');
        at=get(hRipVelocity,'val');
        
        % ERP Variables        
        epochMin = str2double(get(hEpochMin,'string'));
        epochMax = str2double(get(hEpochMax,'string'));
        
        tERP = (timeVals>=epochMin) & (timeVals<=epochMax);
        blPeriod = (timeVals<=0);
        if ~blPeriod
            blPeriod = tERP;
        end
        
        % Get Data
        if resetParamsFlag
            [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,analogChannelsStored);            
        end
        
        if refChangeFlag
            [Data,goodPos] = bipolarRef(trialNums,allBadTrials);
        end        
        
        % Calculate ERP
        erp = zeros(size(Data,1),length(tERP));
        for ERPElec = 1:size(Data,1)
            clear erpData;            
            erpData = squeeze(Data(ERPElec,goodPos{ERPElec},tERP));
            if length(goodPos{ERPElec}) == 1
                erpData = erpData';
            end
            erp(ERPElec,:) = mean((erpData - repmat(mean(erpData(:,blPeriod),2),1,size(erpData,2))),1); % Correct for DC Shift (baseline correction)
        end
        
        % Plot ERP
        erpPlotsData.erp = erp;
        erpPlotsData.time = timeVals(tERP);        
        plotForAllEEGElecs(chanlocs,erpPlotsData)
        
        % Reset all flags to 0
        resetParamsFlag = 0;
        refChangeFlag = 0;        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function plotTFAllElec_Callback(~,~)
        
        % Intitialise        
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAzimuth,'val');
        ae=get(hAudElevation,'va');
        as=get(hRipFreq,'val');
        ao=get(hRipPhase,'val');        
        av=get(hRipModDepth,'val');
        at=get(hRipVelocity,'val');
        
        % get timings and frequency band
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        
        % Get Data
        if resetParamsFlag
            [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,analogChannelsStored);            
        end
        
        if refChangeFlag
            [Data,goodPos] = bipolarRef(trialNums,allBadTrials);
        end   
        
        % Plot TF-plot
        if paramChangeFlag || TFPlotFlag
            clear dSPower
            hPD = waitbar(0,['Analysing electrode 1 of ' num2str(size(Data,1)) ' electrodes...']);
            for i=1:size(Data,1)
                waitbar((i/size(Data,1)),hPD,['Analysing electrode ' num2str(i) ' of ' num2str(size(Data,1)) ' electrodes...']);
                dataTF=Data(i,goodPos{i},:);
                dataTF=squeeze(dataTF);                    

                [~,dS1,t2,f2] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);
                dSPower(i,:,:) = dS1;
            end        
            close(hPD);
            clear hPD;
        end
        
        % Plot STFT
        stftData.power = dSPower;
        stftData.t = t2;
        stftData.f = f2;
        plotForAllEEGElecs(chanlocs,stftData,'STFT')
        
        TFPlotFlag = 0;
        resetParamsFlag = 0;
        refChangeFlag = 0;
        paramChangeFlag = 0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function plotFFTAllElec_Callback(~,~)
        % Intitialise             
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAzimuth,'val');
        ae=get(hAudElevation,'va');
        as=get(hRipFreq,'val');
        ao=get(hRipPhase,'val');        
        av=get(hRipModDepth,'val');
        at=get(hRipVelocity,'val');
        
        % FFT Variables
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        STMin = str2double(get(hStimPeriodMin,'string'));
        STMax = str2double(get(hStimPeriodMax,'string'));
        
        tBL = intersect(find(timeVals>=BLMin),find(timeVals<=BLMax)); % baseline time indices
        tST = intersect(find(timeVals>=STMin),find(timeVals<=STMax)); % stimulus time indices
        
        Fs = mtmParams.Fs;
        N = length(tST);%((BLMin):BLMax));
        L = N/Fs;        
        fAxis = (0:1:(N-1))*(1/L);
        
        % Get Data
        if resetParamsFlag
            [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,analogChannelsStored);            
        end
        
        if refChangeFlag
            [Data,goodPos] = bipolarRef(trialNums,allBadTrials);
        end        
        
        % Calculate FFT
        fftStim = zeros(size(Data,1),length(tST));
        fftBL = zeros(size(Data,1),length(tBL));
        for FFTElec = 1:size(Data,1)
            clear STData BLData;            
            STData = squeeze(Data(FFTElec,goodPos{FFTElec},tST));
            BLData = squeeze(Data(FFTElec,goodPos{FFTElec},tBL));
            fftStim(FFTElec,:) = conv2Log(mean(abs(fft(STData,[],2)),1));
            fftBL(FFTElec,:) = conv2Log(mean(abs(fft(BLData,[],2)),1));
        end
        
        % Plot FFT
        fftData.stim = fftStim;
        fftData.bl = fftBL;
        fftData.fAxis = fAxis;
        plotForAllEEGElecs(chanlocs,fftData,'FFT')
        
        % Reset all flags to 0
        resetParamsFlag = 0;
        refChangeFlag = 0;        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function plotTF_Callback(~,~)
        
        % Intitialise        
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        aa=get(hAudAzimuth,'val');
        ae=get(hAudElevation,'va');
        as=get(hRipFreq,'val');
        ao=get(hRipPhase,'val');        
        av=get(hRipModDepth,'val');
        at=get(hRipVelocity,'val');
        
        refChanIndex = get(hRefChannel,'val');
        
        % get timings and frequency band
        BLMin = str2double(get(hBaselineMin,'string'));
        BLMax = str2double(get(hBaselineMax,'string'));
        STMin = str2double(get(hStimPeriodMin,'string'));
        STMax = str2double(get(hStimPeriodMax,'string'));        
        fBandMin = str2double(get(hfBandLow,'string'));
        fBandMax = str2double(get(hfBandHigh,'string'));
        
        % get electrodes
        TFElec = get(hTFElec,'val');
        TFElecPool = str2num(get(hTFElecPool,'string'));
        if isempty(TFElecPool)
            TFElecPool = TFElec;
        end
        
        % Get Data
        if resetParamsFlag
            [plotData,trialNums,allBadTrials] = getDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,analogChannelsStored);            
        end
        
        if refChangeFlag
            [Data,goodPos] = bipolarRef(trialNums,allBadTrials);
        end   
        
        % Plot TF-plot
        if paramChangeFlag || TFPlotFlag
            clear dSPower
            hPD = waitbar(0,['Analysing electrode 1 of ' num2str(size(Data,1)) ' electrodes...']);
            for i=1:size(Data,1)
                waitbar((i/size(Data,1)),hPD,['Analysing electrode ' num2str(i) ' of ' num2str(size(Data,1)) ' electrodes...']);
                dataTF=Data(i,goodPos{i},:);
                dataTF=squeeze(dataTF);                    

                [~,dS1,t2,f2] = getSTFT(dataTF,movingWin,mtmParams,timeVals,BLMin,BLMax);
                dSPower(i,:,:) = dS1;
            end        
            close(hPD);
            clear hPD;
        end
        
        meanS1ST=[];
        for i=1:size(Data,1)
            tST =  (t2>=STMin) & (t2<=STMax);
            fPL=   (f2>=fBandMin) & (f2<=fBandMax);                
            dS1 = squeeze(dSPower(i,:,:));
            S1ST = dS1(tST,fPL);
            meanS1ST(i)=mean(mean(S1ST,2));
        end
        
        elecDataTF = squeeze(dSPower(TFElec,:,:));
        elecDataPoolTF = squeeze(mean(dSPower(TFElecPool,:,:),1));
            
        % Draw figure
        figure('numbertitle', 'off','name',['TF Plots: ' subjectName expDate protocolName]);
        capPos = [0.01 0.01 0.48 0.98];
        capSTHandle = subplot('Position',capPos); axis off;
        if refChanIndex ~=4
            subplot(capSTHandle); topoplot(meanS1ST,chanlocs,'electrodes','numbers','style','both','drawaxis','off'); colorbar; title('Change in power');
        else
            subplot(capSTHandle); topoplot(meanS1ST,chanlocs,'electrodes','numbers','style','both','drawaxis','off','nosedir','-Y'); colorbar; title('Change in power');
        end

        elecTFPlotPos = [0.51 0.55 0.48 0.35];
        hElecTFPlot = subplot('Position',elecTFPlotPos); 
        subplot(hElecTFPlot); pcolor(t2,f2,elecDataTF'); shading interp; colorbar; ylim([0 100]);
        title(hElecTFPlot,['TF plot of elec: ' num2str(TFElec)]);
        
        elecPoolTFPlotPos = [0.51 0.1 0.48 0.35];
        hElecPoolTFPlot = subplot('Position',elecPoolTFPlotPos);
        subplot(hElecPoolTFPlot); pcolor(t2,f2,elecDataPoolTF'); shading interp; colorbar; ylim([0 100]);
        title(hElecPoolTFPlot,['TF plot of pooled elecs: ' num2str(TFElecPool)]);
        
        TFPlotFlag = 0;
        resetParamsFlag = 0;
        refChangeFlag = 0;
        paramChangeFlag = 0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plotPoolElecs_Callback(~,~)
        
        % Initialise
        epochMin = str2double(get(hEpochMin,'string'));
        epochMax = str2double(get(hEpochMax,'string'));
        ERPMin = str2double(get(hERPMin,'string'));
        ERPMax = str2double(get(hERPMax,'string'));
        
        tERP = (timeVals>=epochMin) & (timeVals<=epochMax);
        blPeriod = (timeVals<=0);
        if ~blPeriod
            blPeriod = tERP;
        end
        
        if resetParamsFlag
            plot_Callback;            
        end
        
        % Pool data
        allElecData = [];
        ERPPoolElecs = str2num(get(hERPElecPool,'string'));
        if isempty(ERPPoolElecs)
            disp('Electrodes to pool not specified...');
            ERPPoolElecs = get(hERPElec,'val');
        end
            
        for iP = 1:length(ERPPoolElecs)
            elecData = squeeze(Data(ERPPoolElecs(iP),goodPos{ERPPoolElecs(iP)},:));
            allElecData = [allElecData;elecData];
        end
        
        clear erp erpData erpDataBLCor;
        erpData = allElecData(:,tERP);
        erpDataBLCor = (erpData - repmat(mean(erpData(:,blPeriod),2),1,size(erpData,2))); % Correct for DC Shift (baseline correction)
        erp = mean(erpDataBLCor,1);
        
        figure; 
        plot(timeVals(tERP),erp); 
        xlim([epochMin epochMax]);
        text(0.1,0.9,['ERP; n = ' num2str(size(erpData,1)) '. Y-axis reveresed.'],'unit','normalized','fontsize',9); %,'Parent',hPoolERPPlot);
        text(0.1,0.8,['Electrodes pooled: ' num2str(ERPPoolElecs)],'unit','normalized','fontsize',9); %,'Parent',hPoolERPPlot);
        set(gca,'Ydir','reverse');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [Data,goodPos] = bipolarRef(trialNums,allBadTrials)
        
        % Referencing
        refChanIndex = get(hRefChannel,'val');
        
        if refChanIndex == 1 % Single wire referencing
            for iBP = 1:size(allBadTrials,2)
                goodTrials = setdiff(trialNums,allBadTrials{iBP});
                goodPos{iBP} = find(ismember(trialNums,goodTrials));
            end
            Data = plotData;
            chanlocs = loadChanLocs(gridMontage,refChanIndex);
            
        elseif refChanIndex == 2 % hemisphere referencing
            [chanlocs,hemBipolarLocs] = loadChanLocs(gridMontage,refChanIndex);
            for iBP = 1:size(allBadTrials,2)
                badTrials1 = allBadTrials{hemBipolarLocs(iBP,1)};
                badTrials2 = allBadTrials{hemBipolarLocs(iBP,2)};
                badTrialsCommon = union(badTrials1,badTrials2);
                goodTrials = setdiff(trialNums,badTrialsCommon);
                goodPos{iBP} = find(ismember(trialNums,goodTrials));
            end
            hWD = waitbar(0,['Creating hem_bipolar data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);
            for iH = 1:size(plotData,1)
                waitbar((iH/size(plotData,1)),hWD,['Creating bipolar data for electrode ' num2str(iH) ' of ' num2str(size(plotData,1)) ' electrodes...']);
                Data(iH,:,:) = plotData(hemBipolarLocs(iH,1),:,:) - plotData(hemBipolarLocs(iH,2),:,:);
            end
            close(hWD);
            clear hWD;
        elseif refChanIndex == 3 % average referencing
            chanlocs = loadChanLocs(gridMontage,refChanIndex);
            for iBP = 1:size(allBadTrials,2)
                goodTrials = setdiff(trialNums,allBadTrials{iBP});
                goodPos{iBP} = find(ismember(trialNums,goodTrials));
            end
            hWD = waitbar(0,['Creating average referenced data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);
            aveData = mean(plotData,1);
            for iH = 1:size(plotData,1)
                waitbar((iH/size(plotData,1)),hWD,['Creating average referenced data for electrode ' num2str(iH) ' of ' num2str(size(plotData,1)) ' electrodes...']);
                Data(iH,:,:) = plotData(iH,:,:) - aveData;
            end
%             Data((iH+1),:,:) = (-1)*aveData;
            close(hWD);
            clear hWD;
        elseif refChanIndex == 4 % bipolar referencing
            [chanlocs,~,bipolarLocs] = loadChanLocs(gridMontage,refChanIndex);
            maxChanKnown = 96; % default set by MD while creating bipolar montage; this might be different for different montages!!!
            hWD = waitbar(0,['Creating bipolar data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);            
            
            for iH = 1:size(bipolarLocs,1)
                waitbar((iH/size(bipolarLocs,1)),hWD,['Creating bipolar data for electrode ' num2str(iH) ' of ' num2str(size(bipolarLocs,1)) ' electrodes...']);
                clear chan1 chan2 unipolarChan1 unipolarChan2 badTrialsChan1 badTrialsChan2 goodTrials
                chan1 = bipolarLocs(iH,1);
                chan2 = bipolarLocs(iH,2);                

                if chan1<(maxChanKnown+1)
                    unipolarChan1 = plotData(chan1,:,:);
                    badPosChan1 = allBadTrials{chan1};
                    badTrialsChan1 = allBadTrials{chan1};
                else
                    unipolarChan1 = Data(chan1,:,:);
                    badPosChan1 = badPos{chan1};
                    badTrialsChan1 = badTrialsCommon{chan1};
                end

                if chan2<(maxChanKnown+1)
                    unipolarChan2 = plotData(chan2,:,:);
                    badPosChan2 = allBadTrials{chan2};
                    badTrialsChan2 = allBadTrials{chan2};
                else
                    unipolarChan2 = Data(chan2,:,:);
                    badPosChan2 = badPos{chan2};
                    badTrialsChan2 = badTrialsCommon{chan2};
                end
                
                Data(iH,:,:) = unipolarChan1 - unipolarChan2;
                badPos{iH} = union(badPosChan1,badPosChan2);
                badTrialsCommon{iH} = union(badTrialsChan1,badTrialsChan2);
                goodTrials = setdiff(trialNums,badTrialsCommon{iH});
                goodPos{iH} = find(ismember(trialNums,goodTrials));
                
            end
            close(hWD);
            clear hWD;
        else
            refChanIndex = refChanIndex-4;
            chanlocs = loadChanLocs(gridMontage);
            hRD = waitbar(0,['Rereferencing data for electrode 1 of ' num2str(size(plotData,1)) ' electrodes...']);
            for iR = 1:size(plotData,1)
                waitbar((iR/size(plotData,1)),hRD,['Rereferencing data for electrode ' num2str(iR) ' of ' num2str(size(plotData,1)) ' electrodes...']);
                Data(iR,:,:) = plotData(iR,:,:) - plotData(refChanIndex,:,:);
                badPos{iR} = union(allBadTrials{iR},allBadTrials{refChanIndex});
                goodTrials = setdiff(trialNums,badPos{iR});
                goodPos{iR} = find(ismember(trialNums,goodTrials));
            end
%             Data((iR+1),:,:) = (-1)*plotData(refChanIndex,:,:);
            close(hRD);
            clear hRD;
        end
        
        refChangeFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function erp = getERPTopoData(Data,goodPos,tERPTopo,tERPTopoBL)
        erp = zeros(size(Data,1),1);
        for iE = 1:size(Data,1)
            dataStim = mean(mean(squeeze(Data(iE,goodPos{iE},tERPTopo)),1),2);        
            dataBL = mean(mean(squeeze(Data(iE,goodPos{iE},tERPTopoBL)),1),2);        
            erp(iE,1) = dataStim - dataBL;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetMTMParams_Callback(~,~)
        mtmParams.Fs = str2double(get(hMTMFs,'String'));
        mtmParams.tapers(1) = str2double(get(hMTMTapersTW,'String'));
        mtmParams.tapers(2) = str2double(get(hMTMTapersK,'String'));
        
        movingWin(1) = str2double(get(hMTMwLen,'String'));
        movingWin(2) = str2double(get(hMTMwStep,'String'));
        
        paramChangeFlag = 1;
        TFPlotFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        subplot(plotVisStimHandle); cla(gca,'reset'); axis off;
        subplot(plotAudStimHandle); cla(gca,'reset'); axis off;
        subplot(plotERPRefHandle); cla(gca,'reset'); axis off;
        subplot(plotERPHandle); cla(gca,'reset'); axis off;
        
        subplot(capERPHandle); cla(gca,'reset'); axis off;
        subplot(capERPRefHandle); cla(gca,'reset'); axis off;
        
        resetVisAinpFlag = 1;
        resetAudAinpFlag = 1;
        resetERPElecFlag = 1;
        resetERPRange = 1;
        resetEpochRangeFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetParams_Callback(~,~)
        resetParamsFlag = 1;
        refChangeFlag = 1;
        paramChangeFlag = 1;
        resetVisAinpFlag = 1;
        resetAudAinpFlag = 1;
        resetERPElecFlag = 1;
        resetERPRange = 1;
        TFPlotFlag = 1;
        resetEpochRangeFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetRef_Callback(~,~)
        refChanIndex = get(hRefChannel,'val');
        if refChanIndex == 4
            subplot(capHandle); cla(gca,'reset'); axis off;
            chanloc = loadChanLocs(gridMontage,refChanIndex);
            subplot(capHandle); topoplot([],chanloc,'electrodes','numbers','style','blank','drawaxis','off','nosedir','-Y'); 
            text(0.1,0.9,gridMontage,'unit','normalized','fontsize',9,'Parent',capHandle);
            
            bipAnalogChannelList = getBipAnalogChannelList(chanloc);
            set(hERPElec,'String',bipAnalogChannelList);
            set(hTFElec,'String',bipAnalogChannelList);
            
        else
            subplot(capHandle); cla(gca,'reset'); axis off;
            chanloc = loadChanLocs(gridMontage,refChanIndex);
            subplot(capHandle); topoplot([],chanloc,'electrodes','numbers','style','blank','drawaxis','off'); 
            text(0.1,0.9,gridMontage,'unit','normalized','fontsize',9,'Parent',capHandle);
            
            [analogChannelStringList,~] = getAnalogStringFromValues(analogChannelsStored,analogInputNums);
            set(hERPElec,'String',analogChannelStringList);
            set(hTFElec,'String',analogChannelStringList);
        end
        refChangeFlag = 1;
        paramChangeFlag = 1;
        TFPlotFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetVisAinpFlag_Callback(~,~)
        resetVisAinpFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetAudAinpFlag_Callback(~,~)
        resetAudAinpFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetERPElecFlag_Callback(~,~)
        resetERPElecFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetERPRangeFlag_Callback(~,~)
        resetERPRange = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resetEpochRangeFlag_Callback(~,~)
        resetEpochRangeFlag = 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outString,outArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums)
outString='';
count=1;
for i=1:length(analogChannelsStored)
    outArray{count} = ['elec' num2str(analogChannelsStored(i))]; %#ok<AGROW>
    outString = cat(2,outString,[outArray{count} '|']);
    count=count+1;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outString,outArray] = getAinpStringFromValues(analogChannelsStored,analogInputNums)
outString='';
count=1;
if ~isempty(analogInputNums)
    for i=1:length(analogInputNums)
        outArray{count} = ['ainp' num2str(analogInputNums(i))]; %#ok<AGROW>
        outString = cat(2,outString,[outArray{count} '|']);
        count=count+1;
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outString = getBipAnalogChannelList(chanloc)
    chanSize = size(chanloc,2);
    outString='';
    for iC = 1:chanSize
        outArray{iC} = ['elec' num2str(iC)];
        outString = cat(2,outString,[outArray{iC} '|']);
    end        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outString = getStringFromValuesGRF(valsUnique,decimationFactor)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ainpData = getAinpDataGAV(a,e,s,f,o,c,t,aa,ae,as,ao,av,at,folderName,folderLFP,analogInput)

    % Load Trial Numbers for the given Parameter Combinations
    folderExtract = fullfile(folderName,'extractedData');
    folderSegment = fullfile(folderName,'segmentedData');
    
    [parameterCombinations] = loadParameterCombinations(folderExtract);
    try
        load(fullfile(folderSegment,'badTrials.mat'));
    catch
        disp('No bad trials')
        badTrials = [];
    end
    trialNums = cell2mat(parameterCombinations(a,e,s,f,o,c,t,aa,ae,as,ao,av,at));
    
    % Extraction
    goodTrials = setdiff(trialNums,badTrials);
    analogData = loadAnalogData(fullfile(folderLFP,['ainp' num2str(analogInput) '.mat']));
    ainpData = analogData(goodTrials,:);
    clear analogData
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
