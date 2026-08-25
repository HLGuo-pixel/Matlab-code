%% IC50 Analysis Script - Run This Section to Generate Results
% This script will automatically process your workspace variable 'data'

% Check if 'data' exists in the workspace
if exist('data', 'var') == 0
    error('Variable "data" not found in workspace. Please import your data first.');
end

% Verify data structure
if size(data,2) < 2
    error('Data table must have at least 2 columns: concentrations and responses');
end

% Extract data from table
conc = data{:,1};  % Concentration values
responses = data{:,2:end};  % Response data (multiple replicates)

% Remove DMSO (0 concentration) entries
validIdx = conc > 0;
conc = conc(validIdx);
responses = responses(validIdx,:);

% Prepare data for analysis
unique_conc = unique(conc);
num_points = numel(unique_conc);
mean_resp = zeros(num_points, 1);
std_resp = zeros(num_points, 1);

% Preallocate arrays
total_points = size(responses,1) * size(responses,2);
x_all = zeros(total_points, 1);
y_all = zeros(total_points, 1);
point_idx = 1;

% Process each concentration
for i = 1:num_points
    c = unique_conc(i);
    resp_vals = responses(conc == c, :);
    resp_vals = resp_vals(~isnan(resp_vals));
    
    % Store statistics
    mean_resp(i) = mean(resp_vals);
    std_resp(i) = std(resp_vals);
    
    % Store individual points
    num_vals = numel(resp_vals);
    x_all(point_idx:point_idx+num_vals-1) = c;
    y_all(point_idx:point_idx+num_vals-1) = resp_vals;
    point_idx = point_idx + num_vals;
end

% Trim unused space
x_all = x_all(1:point_idx-1);
y_all = y_all(1:point_idx-1);

% Set up 4-parameter logistic model
modelfun = @(p, x) p(1) + (p(2)-p(1)) ./ (1 + (x./p(3)).^p(4));

% Initial parameter estimates
a0 = mean_resp(unique_conc == max(unique_conc));  % Bottom asymptote
 %a0 = 0.8;
b0 = mean_resp(unique_conc == min(unique_conc));  % Top asymptote
c0 = 10^(mean(log10(unique_conc)));               % Geometric mean for IC50
d0 = 1.0;                                         % Hill slope initial guess
beta0 = [a0, b0, c0, d0];

% Define penalty for negative asymptote
penalty = 1e10; % Large penalty value
objfun = @(p) sum((modelfun(p, x_all) - y_all).^2) + ...
          penalty * max(0, -p(1) - 0.1) + ...   % Penalize bottom <0
          penalty * max(0, p(2) - 1.1);   % Penalize top >120%
options = optimset('Display', 'off', 'MaxIter', 1000);
beta = fminsearch(objfun, beta0, options);

% Enforce hard constraints after optimization
beta(1) = max(-0.1, beta(1));      % Force bottom ≥0
beta(2) = min(1.15, beta(2));    % Force top ≤120%


% Extract parameters
a = beta(1);  % Bottom asymptote
b = beta(2);  % Top asymptote
IC50 = beta(3);  % IC50 value
hillSlope = beta(4);  % Hill slope

% Generate fitted curve
x_fit = logspace(log10(min(unique_conc)), log10(max(unique_conc)), 500);
y_fit = modelfun(beta, x_fit);

%% Create figure
figure('Color','white','Position',[100 100 800 600]);
hold on;

% Plot data points with error bars
errorbar(unique_conc, mean_resp*100, std_resp*100, 'ko',...
         'MarkerSize',8, 'MarkerFaceColor','w', 'LineWidth',1.5,...
         'CapSize',12);

% Plot fitted curve
semilogx(x_fit, y_fit*100, 'r-', 'LineWidth',2);

% Format plot
set(gca, 'XScale','log','FontSize',14,'LineWidth',2,...
         'XColor','k','YColor','k','Box','on');
xlabel('Concentration (nM)', 'FontSize',14, 'FontWeight','bold');
ylabel('Relative RLUs% (DMSO as 100%)', 'FontSize',14, 'FontWeight','bold');
title('Dose-Response Curve', 'FontSize',16, 'FontWeight','bold');
grid off;

% Set appropriate axis limits
xlim([min(unique_conc)/2, max(unique_conc)*2]);
ylim([-15 129]);

% Add IC50 annotation
 %text(0.12,0.08,sprintf('IC_{50} = %.2f nM\nHill slope = %.2f', IC50, hillSlope),...
     % 'Units','normalized', 'FontSize',12, 'BackgroundColor','w', 'EdgeColor','k');
text(0.12,0.08,sprintf('IC_{50} = %.2f nM', abs(IC50)),...
    'Units','normalized', 'FontSize',12, 'BackgroundColor','w', 'EdgeColor','k');
% Add legend
legend('Experimental Data ± SD', 'Fitted Curve', 'Location','best');
hold off;

%% Display results in command window
fprintf('\n--- IC50 Analysis Results ---\n');
fprintf('Minimum response: %.4f%%\n', a*100);
fprintf('Maximum response: %.4f%%\n', b*100);
fprintf('IC50: %.4f nM\n', IC50);
fprintf('Hill slope: %.4f\n\n', hillSlope);

%% Save figure automatically
saveas(gcf, 'IC50_Results.png');
fprintf('Figure saved as IC50_Results.png\n');