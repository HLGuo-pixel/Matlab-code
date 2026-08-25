% Change name "Thiolreactiveassay" to your data name!
Time = ThiolreactiveassayS1{:, 1};              % Time (min) - X-axis
AbsData = ThiolreactiveassayS1{:, 2:end};       % Absorbance - Y-axis
groupNames = ThiolreactiveassayS1.Properties.VariableNames(2:end); % Group names

% Automatically detect dimensions
numGroups = size(AbsData, 2);    % Number of groups (columns 2:end)
numTimePoints = size(AbsData, 1);% Number of time points (rows)

% Create main figure for the plot
mainFig = figure('Color', 'white', 'Position', [100, 100, 800, 600]);
ax = axes(mainFig);
hold(ax, 'on');

% Generate dynamic colors and markers
colors = parula(numGroups);      % Colormap adjusts to number of groups
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x', '.', '_', '|'}; % Extended list
markers = markers(1:numGroups);  % Use first 'numGroups' markers (repeats if needed)

% Plot each group dynamically
for i = 1:numGroups
    plot(ax, Time, AbsData(:, i), ...
        'LineStyle', '-', ...
        'Marker', markers{i}, ...
        'Color', colors(i, :), ...
        'MarkerSize', 8, ...
        'LineWidth', 1.5, ...
        'DisplayName', groupNames{i});
end

% ========================================================================
% Auto-calculate DISPLAY settings based on data
% ========================================================================
% Function to calculate "nice" display limits and steps
function [dispMin, dispMax, dispStep] = calculateDisplaySettings(dataMin, dataMax)
    range = dataMax - dataMin;
    
    % Calculate step size (round to nearest 0.1, 1, 10, etc.)
    step = 10^floor(log10(range/5)); % Target ~5-10 ticks
    step = step * ceil((range/5)/step); 
    
    % Adjust min/max to "nice" values
    dispMin = floor(dataMin/step)*step;
    dispMax = ceil(dataMax/step)*step;
    
    % Ensure step is not too small/large
    if step < 0.1
        step = 0.1; % Minimum step for readability
    end
    dispStep = step;
end

% X-axis display settings
[xDisplayMin, xDisplayMax, xDisplayStep] = calculateDisplaySettings(min(Time), max(Time));

% Y-axis display settings
[yDisplayMin, yDisplayMax, yDisplayStep] = calculateDisplaySettings(min(AbsData(:)), max(AbsData(:)));

% Initialize DATA limits (actual axis range)
xDataMin = min(Time);
xDataMax = max(Time);
yDataMin = min(AbsData(:));
yDataMax = max(AbsData(:));

% ========================================================================
% Customize axes
% ========================================================================
set(ax, ...
    'FontSize', 12, ...
    'FontName', 'Helvetica', ...
    'LineWidth', 2, ...
    'XColor', 'k', ...
    'YColor', 'k', ...
    'Box', 'on', ...
    'TickDir', 'in', ...
    'XLim', [xDataMin, xDataMax], ...    % Actual data range
    'YLim', [yDataMin, yDataMax], ...
    'XTick', xDisplayMin:xDisplayStep:xDisplayMax, ... % Auto display labels
    'YTick', yDisplayMin:yDisplayStep:yDisplayMax);

xlabel(ax, 'Time (min)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel(ax, 'Absorbance (Abs)', 'FontSize', 14, 'FontWeight', 'bold');

% Add legend
legend(ax, 'Location', 'eastoutside', 'FontSize', 10, 'Interpreter', 'none');

% ========================================================================
% Create UI with auto-populated display settings
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

% Apply button
uibutton(uiFig, 'Text', 'Apply', 'Position', [150, 20, 100, 30], ...
    'ButtonPushedFcn', @(btn,event) updateAxes(ax, ...
    xDataMinEdit.Value, xDataMaxEdit.Value, ...
    xDisplayMinEdit.Value, xDisplayMaxEdit.Value, xDisplayStepEdit.Value, ...
    yDataMinEdit.Value, yDataMaxEdit.Value, ...
    yDisplayMinEdit.Value, yDisplayMaxEdit.Value, yDisplayStepEdit.Value));

% ========================================================================
% Callback function
% ========================================================================
function updateAxes(ax, xDataMin, xDataMax, xDispMin, xDispMax, xDispStep, yDataMin, yDataMax, yDispMin, yDispMax, yDispStep)
    % Validate inputs
    if xDataMin >= xDataMax || yDataMin >= yDataMax || xDispMin >= xDispMax || yDispMin >= yDispMax
        errordlg('Invalid input: MIN must be < MAX.', 'Error');
        return;
    end
    
    % Update DATA limits (axis range)
    ax.XLim = [xDataMin, xDataMax];
    ax.YLim = [yDataMin, yDataMax];
    
    % Update DISPLAY ticks (labels)
    ax.XTick = xDispMin:xDispStep:xDispMax;
    ax.YTick = yDispMin:yDispStep:yDispMax;
end

%% Output
% Save as high-resolution PNG/PDF
exportgraphics(gcf, 'Time_vs_Abs_Plot.png', 'Resolution', 300);
% exportgraphics(gcf, 'Time_vs_Abs_Plot.pdf', 'ContentType', 'vector');