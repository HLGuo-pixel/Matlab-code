% ========================================================================
% Load multiple datasets (adjust variable names/number as needed)
% ========================================================================
numDatasets = 3; % Number of datasets (S1-S5)
allData = cell(1, numDatasets);
for k = 1:numDatasets
    allData{k} = eval(sprintf('Rep%d', k)); % Load S1-S5
end

% Extract common Time vector and group names from first dataset
Time = allData{1}{:, 1};
groupNames = allData{1}.Properties.VariableNames(2:end);
[numTimePoints, numGroups] = size(allData{1}{:, 2:end});

% Create 3D matrix [timepoints × groups × datasets]
abs3D = nan(numTimePoints, numGroups, numDatasets);
for k = 1:numDatasets
    abs3D(:,:,k) = allData{k}{:, 2:end};
end

% Calculate statistics (using STANDARD DEVIATION)
meanAbs = mean(abs3D, 3);
stdDev = std(abs3D, 0, 3); % Set to standard deviation

% ========================================================================
% Create main figure with error bars
% ========================================================================
mainFig = figure('Color', 'white', 'Position', [100, 100, 800, 600]);
ax = axes(mainFig);
hold(ax, 'on');

% Plot parameters (same styling as original)
colors = parula(numGroups);
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.'};
markers = markers(1:numGroups);

% Plot each group with error bars
for i = 1:numGroups
    errorbar(ax, Time, meanAbs(:,i), stdDev(:,i), ...
        'LineStyle', '-', ...
        'Marker', markers{i}, ...
        'Color', colors(i,:), ...
        'MarkerSize', 8, ...
        'LineWidth', 1.5, ...
        'CapSize', 10, ...
        'DisplayName', groupNames{i});
end

% ========================================================================
% Auto-calculate DISPLAY settings (same as original)
% ========================================================================
[xDisplayMin, xDisplayMax, xDisplayStep] = calculateDisplaySettings(min(Time), max(Time));
[yDisplayMin, yDisplayMax, yDisplayStep] = calculateDisplaySettings(min(meanAbs(:)), max(meanAbs(:)));

% Initialize DATA limits
xDataMin = min(Time);
xDataMax = max(Time);
yDataMin = min(meanAbs(:));
yDataMax = max(meanAbs(:));

% ========================================================================
% AXES CUSTOMIZATION (same as original UI code)
% ========================================================================
set(ax, ...
    'FontSize', 12, ...
    'FontName', 'Helvetica', ...
    'LineWidth', 2, ...
    'XColor', 'k', ...
    'YColor', 'k', ...
    'Box', 'on', ...
    'TickDir', 'in', ...
    'XLim', [xDataMin, xDataMax], ...
    'YLim', [yDataMin, yDataMax], ...
    'XTick', xDisplayMin:xDisplayStep:xDisplayMax, ...
    'YTick', yDisplayMin:yDisplayStep:yDisplayMax);

xlabel(ax, 'Time (min)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(ax, 'Absorbance (Abs)', 'FontSize', 14, 'FontWeight', 'bold');
legend(ax, 'Location', 'eastoutside', 'FontSize', 10, 'Interpreter', 'none');

% ========================================================================
% UI CONTROLS 
% ========================================================================
uiFig = uifigure('Name', 'Axis Control', 'Position', [300, 100, 400, 400]);


% ------------------------------------------------------------------------
% X-axis controls
% ------------------------------------------------------------------------
% X-axis DATA
uilabel(uiFig, 'Text', 'X-axis DATA', 'Position', [20, 350, 150, 20], 'FontWeight', 'bold');
uilabel(uiFig, 'Text', 'MIN:', 'Position', [20, 320, 40, 20]);
xDataMinEdit = uieditfield(uiFig, 'numeric', 'Position', [70, 320, 80, 22], 'Value', xDataMin);
uilabel(uiFig, 'Text', 'MAX:', 'Position', [20, 290, 40, 20]);
xDataMaxEdit = uieditfield(uiFig, 'numeric', 'Position', [70, 290, 80, 22], 'Value', xDataMax);

% X-axis DISPLAY (auto-calculated defaults)
uilabel(uiFig, 'Text', 'X-axis Display', 'Position', [20, 250, 150, 20], 'FontWeight', 'bold');
uilabel(uiFig, 'Text', 'MIN:', 'Position', [20, 220, 40, 20]);
xDisplayMinEdit = uieditfield(uiFig, 'numeric', 'Position', [70, 220, 80, 22], 'Value', xDisplayMin);
uilabel(uiFig, 'Text', 'MAX:', 'Position', [20, 190, 40, 20]);
xDisplayMaxEdit = uieditfield(uiFig, 'numeric', 'Position', [70, 190, 80, 22], 'Value', xDisplayMax);
uilabel(uiFig, 'Text', 'STEP:', 'Position', [20, 160, 40, 20]);
xDisplayStepEdit = uieditfield(uiFig, 'numeric', 'Position', [70, 160, 80, 22], 'Value', xDisplayStep);

% ------------------------------------------------------------------------
% Y-axis controls
% ------------------------------------------------------------------------
% Y-axis DATA
uilabel(uiFig, 'Text', 'Y-axis DATA', 'Position', [220, 350, 150, 20], 'FontWeight', 'bold');
uilabel(uiFig, 'Text', 'MIN:', 'Position', [220, 320, 40, 20]);
yDataMinEdit = uieditfield(uiFig, 'numeric', 'Position', [270, 320, 80, 22], 'Value', yDataMin);
uilabel(uiFig, 'Text', 'MAX:', 'Position', [220, 290, 40, 20]);
yDataMaxEdit = uieditfield(uiFig, 'numeric', 'Position', [270, 290, 80, 22], 'Value', yDataMax);

% Y-axis DISPLAY (auto-calculated defaults)
uilabel(uiFig, 'Text', 'Y-axis Display', 'Position', [220, 250, 150, 20], 'FontWeight', 'bold');
uilabel(uiFig, 'Text', 'MIN:', 'Position', [220, 220, 40, 20]);
yDisplayMinEdit = uieditfield(uiFig, 'numeric', 'Position', [270, 220, 80, 22], 'Value', yDisplayMin);
uilabel(uiFig, 'Text', 'MAX:', 'Position', [220, 190, 40, 20]);
yDisplayMaxEdit = uieditfield(uiFig, 'numeric', 'Position', [270, 190, 80, 22], 'Value', yDisplayMax);
uilabel(uiFig, 'Text', 'STEP:', 'Position', [220, 160, 40, 20]);
yDisplayStepEdit = uieditfield(uiFig, 'numeric', 'Position', [270, 160, 80, 22], 'Value', yDisplayStep);

% Apply button (same callback)
uibutton(uiFig, 'Text', 'Apply', 'Position', [150, 20, 100, 30], ...
    'ButtonPushedFcn', @(btn,event) updateAxes(ax, ...
    xDataMinEdit.Value, xDataMaxEdit.Value, ...
    xDisplayMinEdit.Value, xDisplayMaxEdit.Value, xDisplayStepEdit.Value, ...
    yDataMinEdit.Value, yDataMaxEdit.Value, ...
    yDisplayMinEdit.Value, yDisplayMaxEdit.Value, yDisplayStepEdit.Value));


% ========================================================================
% Visibility Toggle Callback (NEW)
% ========================================================================
function toggleVisibility(chk, lineHandle)
    if chk.Value
        lineHandle.Visible = 'on';
    else
        lineHandle.Visible = 'off';
    end
    refreshdata % Force plot update
end
% ========================================================================
% Callback function (identical to original)
% ========================================================================
function updateAxes(ax, xDataMin, xDataMax, xDispMin, xDispMax, xDispStep, yDataMin, yDataMax, yDispMin, yDispMax, yDispStep)
    if xDataMin >= xDataMax || yDataMin >= yDataMax || xDispMin >= xDispMax || yDispMin >= yDispMax
        errordlg('Invalid input: MIN must be < MAX.', 'Error');
        return;
    end
    ax.XLim = [xDataMin, xDataMax];
    ax.YLim = [yDataMin, yDataMax];
    ax.XTick = xDispMin:xDispStep:xDispMax;
    ax.YTick = yDispMin:yDispStep:yDispMax;
end

% ========================================================================
% Helper function (same as original)
% ========================================================================
function [dispMin, dispMax, dispStep] = calculateDisplaySettings(dataMin, dataMax)
    range = dataMax - dataMin;
    step = 10^floor(log10(range/5));
    step = step * ceil((range/5)/step);
    dispMin = floor(dataMin/step)*step;
    dispMax = ceil(dataMax/step)*step;
    if step < 0.1
        step = 0.1;
    end
    dispStep = step;
end

%% Export figure
exportgraphics(gcf, 'Mean_Abs_Plot.png', 'Resolution', 300);

%%
% Secondary processing: compute -ln(Ax/A0) for each sample
% ========================================================================
% Initialize transformed data array
transformedAbs = nan(size(abs3D));

for k = 1:numDatasets
    for i = 1:numGroups
        % Extract A0 for this group and dataset (first time point)
        A0 = abs3D(1, i, k);
        for j = 1:numTimePoints
            Ax = abs3D(j, i, k);
            transformedAbs(j, i, k) = -log(Ax / A0);
        end
    end
end

% Compute mean and standard deviation of transformed data
meanTransformed = mean(transformedAbs, 3);
stdTransformed = std(transformedAbs, 0, 3);

% Create a new table with Time and transformed means
transformedTable = array2table([Time, meanTransformed], 'VariableNames', ['Time', groupNames]);

% ========================================================================
% Create transformed figure with simplified plot and UI controls
% ========================================================================
transformedFig = figure('Color', 'white', 'Position', [100, 100, 800, 600]);
axTrans = axes(transformedFig);
hold(axTrans, 'on');

% Plot parameters (keep group identification)
colors = parula(numGroups);
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.'};
markers = markers(1:numGroups);

% Plot mean values only (no error bars)
for i = 1:numGroups
    plot(axTrans, Time, meanTransformed(:,i), ...
        'LineStyle', '-', ...
        'Marker', markers{i}, ...
        'Color', colors(i,:), ...
        'MarkerSize', 8, ...
        'LineWidth', 1.5, ...
        'DisplayName', groupNames{i});
end

% Auto-calculate DISPLAY settings for transformed data
[xDisplayMinT, xDisplayMaxT, xDisplayStepT] = calculateDisplaySettings(min(Time), max(Time));
[yDisplayMinT, yDisplayMaxT, yDisplayStepT] = calculateDisplaySettings(min(meanTransformed(:)), max(meanTransformed(:)));

% Set initial axis properties with validation
yMinT = min(meanTransformed(:));
yMaxT = max(meanTransformed(:));
if yMinT == yMaxT
    yMinT = yMinT - 0.1;
    yMaxT = yMaxT + 0.1;
end

set(axTrans, ...
    'FontSize', 12, ...
    'FontName', 'Helvetica', ...
    'LineWidth', 2, ...
    'XColor', 'k', ...
    'YColor', 'k', ...
    'Box', 'on', ...
    'TickDir', 'in', ...
    'XLim', [min(Time), max(Time)], ...
    'YLim', [yDisplayMinT, yDisplayMaxT], ...
    'XTick', xDisplayMinT:xDisplayStepT:xDisplayMaxT, ...
    'YTick', yDisplayMinT:yDisplayStepT:yDisplayMaxT);

xlabel(axTrans, 'Time (min)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(axTrans, '-ln(A_x/A_0)', 'FontSize', 14, 'FontWeight', 'bold');
legend(axTrans, 'Location', 'eastoutside', 'FontSize', 10, 'Interpreter', 'none');
line(axTrans, [min(Time), max(Time)], [0, 0], ... % y=0 dash line
    'LineStyle', '--', ...
    'Color', [0.5 0.5 0.5], ...  % Medium-gray color
    'LineWidth', 2, ...
    'HandleVisibility', 'off');  % Exclude from legend

% ========================================================================
% Create enhanced UI for transformed figure with DATA/DISPLAY controls
% ========================================================================
uiFigTrans = uifigure('Name', 'Transformed Axis Control', 'Position', [300, 100, 400, 500]);

% X-axis controls --------------------------------------------------------
% X-axis DATA
uilabel(uiFigTrans, 'Text', 'X-axis DATA', 'Position', [20, 450, 150, 20], 'FontWeight', 'bold');
uilabel(uiFigTrans, 'Text', 'MIN:', 'Position', [20, 420, 50, 20]);
xDataMinTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [70, 420, 80, 22], 'Value', min(Time));
uilabel(uiFigTrans, 'Text', 'MAX:', 'Position', [20, 390, 50, 20]);
xDataMaxTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [70, 390, 80, 22], 'Value', max(Time));

% X-axis DISPLAY (auto-initialized)
[initXdispMin, initXdispMax, initXdispStep] = calculateDisplaySettings(min(Time), max(Time));
uilabel(uiFigTrans, 'Text', 'X-axis DISPLAY', 'Position', [20, 350, 150, 20], 'FontWeight', 'bold');
uilabel(uiFigTrans, 'Text', 'MIN:', 'Position', [20, 320, 50, 20]);
xDispMinTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [70, 320, 80, 22], 'Value', initXdispMin);
uilabel(uiFigTrans, 'Text', 'MAX:', 'Position', [20, 290, 50, 20]);
xDispMaxTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [70, 290, 80, 22], 'Value', initXdispMax);
uilabel(uiFigTrans, 'Text', 'INTERVAL:', 'Position', [20, 260, 60, 20]);
xDispStepTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [70, 260, 80, 22], 'Value', initXdispStep);

% Y-axis controls --------------------------------------------------------
% Y-axis DATA
yDataMin = min(meanTransformed(:));
yDataMax = max(meanTransformed(:));
uilabel(uiFigTrans, 'Text', 'Y-axis DATA', 'Position', [220, 450, 150, 20], 'FontWeight', 'bold');
uilabel(uiFigTrans, 'Text', 'MIN:', 'Position', [220, 420, 50, 20]);
yDataMinTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [270, 420, 80, 22], 'Value', yDataMin);
uilabel(uiFigTrans, 'Text', 'MAX:', 'Position', [220, 390, 50, 20]);
yDataMaxTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [270, 390, 80, 22], 'Value', yDataMax);

% Y-axis DISPLAY (auto-initialized)
[initYdispMin, initYdispMax, initYdispStep] = calculateDisplaySettings(yDataMin, yDataMax);
uilabel(uiFigTrans, 'Text', 'Y-axis DISPLAY', 'Position', [220, 350, 150, 20], 'FontWeight', 'bold');
uilabel(uiFigTrans, 'Text', 'MIN:', 'Position', [220, 320, 50, 20]);
yDispMinTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [270, 320, 80, 22], 'Value', initYdispMin);
uilabel(uiFigTrans, 'Text', 'MAX:', 'Position', [220, 290, 50, 20]);
yDispMaxTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [270, 290, 80, 22], 'Value', initYdispMax);
uilabel(uiFigTrans, 'Text', 'INTERVAL:', 'Position', [220, 260, 60, 20]);
yDispStepTrans = uieditfield(uiFigTrans, 'numeric', 'Position', [270, 260, 80, 22], 'Value', initYdispStep);

% Apply button
uibutton(uiFigTrans, 'Text', 'Apply Settings', 'Position', [150, 20, 120, 30], ...
    'ButtonPushedFcn', @(btn,event) updateAxesTrans(axTrans, ...
    xDataMinTrans.Value, xDataMaxTrans.Value, ...
    xDispMinTrans.Value, xDispMaxTrans.Value, xDispStepTrans.Value, ...
    yDataMinTrans.Value, yDataMaxTrans.Value, ...
    yDispMinTrans.Value, yDispMaxTrans.Value, yDispStepTrans.Value));

% ========================================================================
% Enhanced callback function for transformed plot
% ========================================================================
function updateAxesTrans(ax, xDataMin, xDataMax, xDispMin, xDispMax, xDispStep,...
                        yDataMin, yDataMax, yDispMin, yDispMax, yDispStep)
    % Validate inputs
    if xDataMin >= xDataMax || yDataMin >= yDataMax ||...
       xDispMin >= xDispMax || yDispMin >= yDispMax
        errordlg('Invalid input: MIN must be < MAX for all fields.', 'Error');
        return;
    end
    
    % Set DATA limits
    ax.XLim = [xDataMin, xDataMax];
    ax.YLim = [yDataMin, yDataMax];
    
    % Set DISPLAY ticks
    ax.XTick = xDispMin:xDispStep:xDispMax;
    ax.YTick = yDispMin:yDispStep:yDispMax;
    
    % Force redraw
    drawnow;
end