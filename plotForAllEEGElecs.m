%% plotForAllEEGElecs
%
% plotForAllEEGElecs plots ERP/FFT/STFT (specified as plotType) for a given 
% dataset (entered as Data) for all electrodes (specified chanlocs)
% simultaneously for a given figure. This is to enable comparison of activity 
% across all electrodes at the same time.
%
% Created by Murty V P S Dinavahi (09-11-15)
% Modified by MD (03-12-15): addded option to view a given plot in a given
%                               figure when clicked upon it.
%
function plotForAllEEGElecs(chanlocs,Data,plotType)
    
    plotLegendText = {};
    
    % Defaults
    squeezeFac = 1.0;
    fitFac = 1.1;
    
    if nargin<3; plotType = 'ERP'; else plotType = upper(plotType); end % Default: ERP
    
    switch plotType
        case 'ERP'            
            erpData = Data.erp;
            erpTime = Data.time;
            chanNums = size(erpData,1);
        case 'FFT'
            stimData = Data.stim;
            blData = Data.bl;
            fAxis = Data.fAxis;
            chanNums = size(stimData,1);
        case 'STFT'            
            powerData = Data.power;
            chanNums = size(powerData,1);
            tdata = Data.t;
            fdata = Data.f;
    end
    
    if chanNums == 64
        plotSize = 0.04;        
    elseif chanNums == 109
        plotSize = 0.025;
    else
        plotSize = 0.04;
    end

    % Get x and y co-ordinates
    [~,~,Th,Rd] = readlocs(chanlocs);
    Th = pi/180*Th; 
    [x,y]     = pol2cart(Th,Rd);

    x    = x*squeezeFac;    
    y    = y*squeezeFac; 
    
    % Rotate in case of bipolar montaging
    if chanNums > 64 % This is a rudimentary way of defining bipolar monatges
        rotate = pi/2;
        allcoords = (y + x*sqrt(-1))*exp(sqrt(-1)*rotate);
        x = imag(allcoords);
        y = real(allcoords);
    
    end
    
    % Select the channel for plotting tick labels
    if chanNums == 109
        labChan = 90;
    else
        labChan = 28;
    end
        

    % Shift origin to 0,0 of figure
    x = x + 0.5;
    y = y + 0.5;

    % Fit plots to figure window
    x = x/(fitFac*max(x));
    y = y/(fitFac*max(y));    
    
    % Draw the plot
    fH = figure;
    plotH = cell(chanNums,1);
    for i = 1:chanNums
        figure(fH);
        plotH{i} = subplot('Position',[y(i) x(i) plotSize plotSize]);
         
        switch plotType
            case 'ERP'                 
                subplot(plotH{i}); plot(erpTime,erpData(i,:)); axis tight;
                
                ylim([-15 15]);
            case 'FFT'                
                subplot(plotH{i}); plot(fAxis,stimData(i,:),'b'); axis tight; hold on;
%                 subplot(plotH); plot(fAxis,blData(i,:),'g'); axis tight; hold off;
                ylim([0 5]);
                xlim([0 100]);
            case 'STFT'
                clear stftData;
                stftData = squeeze(powerData(i,:,:));
                subplot(plotH{i}); pcolor(tdata,fdata,stftData'); shading interp;
                ylim([0 100]); caxis([-5 5]);
        end
        if i ~= labChan
            set(plotH{i},'xticklabel',[]); set(plotH{i},'yticklabel',[]);
        end
        xlabel(num2str(i));
        set(plotH{i},'ButtonDownFcn',{@displayPlot,i});
    end
end

function displayPlot(varargin)

    ph = varargin{1};
    phNum = varargin{3};
    phColor = getColorRGB(phNum);

    phChild = get(varargin{1},'children');
    
    xData = get(phChild,'XData');
    yData = get(phChild,'YData');
    
    xLim = get(ph,'xlim');
    yLim = get(ph,'ylim');
    
    figure(1255654);
    axesHandle = gca;
    axesChild = get(axesHandle,'children');
    xDataPlot = get(axesChild,'XData');
    if size(xDataPlot,1)>1; xDataPlot = xDataPlot{1,:}; end
    
    plotType = get(phChild,'Type');
    axesType = get(axesChild,'Type');
    
    if strcmp(plotType,'line')
        
        if strcmp(axesType,'surface')
            cla(axesHandle,'reset');        
        elseif length(xDataPlot) ~= length(xData)            
            cla(axesHandle,'reset');
        elseif xDataPlot ~= xData
            cla(axesHandle,'reset');
        end
        
        legendString = get(axesHandle,'UserData');
        legendString = cat(2,legendString,{['elec ' num2str(phNum)]});
        
        hold all; plot(xData,yData,'Color',phColor,'linewidth',2);
        
        legend(legendString);
        set(axesHandle,'UserData',legendString);
        
    elseif strcmp(plotType,'surface')
        
        cla(axesHandle,'reset');
        cData = get(phChild,'CData');
        cLim = get(ph,'clim');
        
        pcolor(xData,yData,cData); shading interp;
        title(['Difference in power from baseline for electrode ' num2str(phNum)],'FontSize',15);
        caxis(cLim); colorbar;
        
    end    
    
    xlim(xLim); ylim(yLim);  
    set(axesHandle,'FontSize',15);
    
end
    