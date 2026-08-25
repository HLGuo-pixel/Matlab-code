% Convert wide format table to long format
dataTable = stack(Lumidata, Lumidata.Properties.VariableNames(1:end),...
    'NewDataVariableName', 'Signal',...
    'IndexVariableName', 'Sample');

% Calculate statistics
statsTable = groupsummary(dataTable, 'Sample', {'mean', 'std'}, 'Signal');

% Create figure with auto-sizing
fig = figure('Color', 'w', 'Units', 'inches', 'Position', [0 0 6 4 + 0.3*height(statsTable)]);
ax = gca; % Get axis handle
hold on;

% Create bar plot
b = bar(ax, statsTable.mean_Signal,...
    'FaceColor', [0.7 0.7 0.7],...
    'EdgeColor', 'none',...
    'BarWidth', 0.6);

% Add error bars
errorbar(ax, 1:height(statsTable), statsTable.mean_Signal, statsTable.std_Signal,...
    'k.', 'LineWidth', 1, 'CapSize', 15);

% Improved clustered jitter
for i = 1:height(statsTable)
    sampleData = dataTable.Signal(dataTable.Sample == statsTable.Sample(i));
    nPoints = numel(sampleData);
    jitterRange = 0.12;
    x = i + linspace(-jitterRange, jitterRange, nPoints);
    scatter(ax, x, sampleData, 60,...
        'MarkerFaceColor', [0.2 0.6 0.4],...
        'MarkerEdgeColor', 'k',...
        'LineWidth', 0.8,...
        'MarkerFaceAlpha', 0.8);
end

% Customize axes
set(ax,...
    'FontSize', 12,...
    'LineWidth', 2,...
    'FontWeight', 'bold',...
    'XTick', 1:height(statsTable),...
    'XTickLabel', categories(statsTable.Sample),...
    'TickLabelInterpreter', 'none',...
    'Box', 'on',...
    'XAxisLocation', 'bottom',...
    'YColor', 'k',...
    'XColor', 'k');

% Ensure y-label appears on left axis
yyaxis left
ylabel(ax, 'RLUs', 'FontSize',14,'FontWeight','bold','Color','k')
ylim(ax, [0 max(statsTable.mean_Signal + statsTable.std_Signal)*1.2])

% Set RIGHT Y-axis to match LEFT (without switching focus)
ax.YAxis(2).Limits = ax.YAxis(1).Limits;        % Sync limits
ax.YAxis(2).TickValues = ax.YAxis(1).TickValues; % Sync ticks
ax.YAxis(2).Color = 'k';                         % Set color
ax.YAxis(2).TickLabels = {};                     % Hide labels
% Auto-rotate labels if needed
if any(cellfun(@length, categories(statsTable.Sample)) > 12)
    xtickangle(ax, 45)
end

% Force update and ensure visibility
drawnow;
set(fig, 'CurrentAxes', ax); % Explicitly set focus to the main axis

% --- New UI controls in a separate window ---
% Calculate initial Y-axis settings
initialUpper = max(statsTable.mean_Signal + statsTable.std_Signal) * 1.2;
[initialYMin, initialYMax, initialYStep] = calculateDisplaySettings(0, initialUpper);

% Create UI figure for Y-axis control
uiFig = uifigure('Name', 'Y-Axis Control', 'Position', [300, 100, 250, 200]);

% Y-axis Display controls
uilabel(uiFig, 'Text', 'Y-axis Settings', 'Position', [20, 170, 150, 20],...
    'FontWeight', 'bold', 'FontSize', 12);

% Y-Min
uilabel(uiFig, 'Text', 'Min:', 'Position', [20, 140, 40, 20]);
yMinEdit = uieditfield(uiFig, 'numeric',...
    'Position', [70, 140, 80, 22],...
    'Value', initialYMin,...
    'Tag', 'yMinEdit');

% Y-Max
uilabel(uiFig, 'Text', 'Max:', 'Position', [20, 110, 40, 20]);
yMaxEdit = uieditfield(uiFig, 'numeric',...
    'Position', [70, 110, 80, 22],...
    'Value', initialYMax,...
    'Tag', 'yMaxEdit');

% Y-Step
uilabel(uiFig, 'Text', 'Step:', 'Position', [20, 80, 40, 20]);
yStepEdit = uieditfield(uiFig, 'numeric',...
    'Position', [70, 80, 80, 22],...
    'Value', initialYStep,...
    'Tag', 'yStepEdit');

% Apply button
uibutton(uiFig, 'push',...
    'Text', 'Apply',...
    'Position', [70, 20, 100, 30],...
    'ButtonPushedFcn', @(src,event) updateYAxis(ax,...
    yMinEdit.Value, yMaxEdit.Value, yStepEdit.Value));

% Store axis handle in UI figure
setappdata(uiFig, 'mainAxes', ax);

% --- Callback function ---
function updateYAxis(ax, yMin, yMax, yStep)
    % Validate inputs
    if yMin >= yMax || yStep <= 0 || isnan(yMin) || isnan(yMax) || isnan(yStep)
        errordlg('Invalid values: Min < Max and Step > 0 required.', 'Error');
        return;
    end
    
    % Create tick values
    ticks = yMin:yStep:yMax;
    
    % Update LEFT Y-axis
    ax.YAxis(1).Limits = [yMin yMax];   % Set limits
    ax.YAxis(1).TickValues = ticks;      % Set tick positions
    
    % Update RIGHT Y-axis to match left
    ax.YAxis(2).Limits = [yMin yMax];    % Sync limits
    ax.YAxis(2).TickValues = ticks;      % Sync tick positions
    ax.YAxis(2).TickLabels = {};         % Hide labels (keep empty)
end

% --- Helper function (from your example) ---
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