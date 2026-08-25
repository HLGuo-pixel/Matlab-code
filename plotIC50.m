function [IC50, hillSlope, params] = plotIC50(data, compoundName, unit)
% PLOTIC50 Processes IC50 data and generates dose-response curve
%   [IC50, hillSlope] = plotIC50(dataTable, compoundName, unit)
%   Inputs:
%       dataTable     - Table containing concentration and response data
%       compoundName  - Name of compound for plot title
%       unit          - Concentration unit (e.g., 'nM', 'μM')
%   Outputs:
%       IC50          - Calculated IC50 value
%       hillSlope     - Hill slope parameter
%       params        - Full parameter set from curve fitting

% Extract concentration and response data
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

% Preallocate arrays for all data points
total_points = size(responses,1) * size(responses,2);
x_all = zeros(total_points, 1);
y_all = zeros(total_points, 1);
point_idx = 1;  % Index tracker for filling arrays

% Process each concentration
for i = 1:num_points
    c = unique_conc(i);
    % Get all responses for this concentration
    resp_vals = responses(conc == c, :);
    resp_vals = resp_vals(~isnan(resp_vals));
    
    % Store mean and std
    mean_resp(i) = mean(resp_vals);
    std_resp(i) = std(resp_vals);
    
    % Store individual points
    num_vals = numel(resp_vals);
    x_all(point_idx:point_idx+num_vals-1) = c;
    y_all(point_idx:point_idx+num_vals-1) = resp_vals;
    point_idx = point_idx + num_vals;
end

% Trim unused preallocated space
x_all = x_all(1:point_idx-1);
y_all = y_all(1:point_idx-1);

% Set up 4-parameter logistic model
modelfun = @(p, x) p(1) + (p(2)-p(1)) ./ (1 + (x./p(3)).^p(4));

% Initial parameter estimates
a0 = mean_resp(unique_conc == max(unique_conc));  % Bottom asymptote
b0 = mean_resp(unique_conc == min(unique_conc));  % Top asymptote
c0 = 10^(mean(log10(unique_conc)));               % Geometric mean for IC50
d0 = 1.0;                                         % Hill slope initial guess
beta0 = [a0, b0, c0, d0];

% Perform nonlinear regression
opts = statset('Display','off','MaxIter',1000);
beta = nlinfit(x_all, y_all, modelfun, beta0, opts);

% Extract parameters
a = beta(1);  % Bottom asymptote
b = beta(2);  % Top asymptote
IC50 = beta(3);  % IC50 value
hillSlope = beta(4);  % Hill slope
params = beta;

% Generate fitted curve
x_fit = logspace(log10(min(unique_conc)), log10(max(unique_conc)), 500);
y_fit = modelfun(beta, x_fit);

% Create figure
figure('Color','white','Position',[100 100 800 600]);
hold on;

% Plot data points with error bars
errorbar(unique_conc, mean_resp*100, std_resp*100, 'ko',...
         'MarkerSize',8, 'MarkerFaceColor','w', 'LineWidth',1.5,...
         'CapSize',12);

% Plot fitted curve
semilogx(x_fit, y_fit*100, 'r-', 'LineWidth',2);

% Format plot
set(gca, 'XScale','log','FontSize',12,'LineWidth',1.5,...
         'XColor','k','YColor','k','Box','on');
xlabel(['Concentration (', unit, ')'], 'FontSize',14, 'FontWeight','bold');
ylabel('Relative RLUs% (DMSO as 100%)', 'FontSize',14, 'FontWeight','bold');
title(['Dose-Response Curve: ', compoundName], 'FontSize',16, 'FontWeight','bold');
grid on;

% Set appropriate axis limits
xlim([min(unique_conc)/2, max(unique_conc)*2]);
ylim([0 max(mean_resp)*100*1.2]);

% Add IC50 annotation
text(0.05, 0.25, sprintf('IC_{50} = %.2f %s\nHill slope = %.2f', IC50, unit, hillSlope),...
     'Units','normalized', 'FontSize',12, 'BackgroundColor','w', 'EdgeColor','k');

% Add legend
legend('Experimental Data ± SD', 'Fitted Curve', 'Location','best');

% Ensure proper layout
hold off;

% Display results
fprintf('\n--- IC50 Results for %s ---\n', compoundName);
fprintf('Minimum response: %.4f%%\n', a*100);
fprintf('Maximum response: %.4f%%\n', b*100);
fprintf('IC50: %.4f %s\n', IC50, unit);
fprintf('Hill slope: %.4f\n\n', hillSlope);
end