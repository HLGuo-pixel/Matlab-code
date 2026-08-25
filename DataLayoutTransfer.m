%% Data Layout Transfer – Column "list" to Special Tables
% Assumes a variable named 'list' exists in the workspace.
% Each sheet will contain:
%   - 8 elements as a 1×8 row in C1:J1
%   - 50 elements as a 5×10 block in A2:J6

% ---------- Settings ----------
outputFile = 'special_tables.xlsx';   % Output Excel file name
% ------------------------------

% Validate input
if ~exist('list', 'var')
    error('Variable "list" not found in workspace. Please load or define it first.');
end

% Convert input to a numeric column vector
if istable(list)
    dataMatrix = table2array(list);
    if size(dataMatrix, 2) > 1
        warning('Table has %d columns. Using only the first column.', size(dataMatrix,2));
        numericList = dataMatrix(:, 1);
    else
        numericList = dataMatrix;
    end
elseif isnumeric(list)
    numericList = list;
elseif iscell(list)
    numericList = cell2mat(list);
else
    error('Unsupported data type for "list". Must be numeric, cell, or table.');
end

numericList = numericList(:);
numericList = rmmissing(numericList);

numElements = length(numericList);
fprintf('Processed list contains %d numeric elements.\n', numElements);

% ---------- Layout Logic ----------
rowVals     = 8;       % Number of values for C1:J1
blockRows   = 5;       % Rows in A2:J6
blockCols   = 10;      % Columns in A2:J6
blockSize   = rowVals + (blockRows * blockCols); % 58 total

numFullBlocks = floor(numElements / blockSize);
remainder = mod(numElements, blockSize);

fprintf('Block size = %d cells. Creating %d full tables', blockSize, numFullBlocks);
if remainder > 0
    fprintf(' (last %d elements will be ignored).\n', remainder);
else
    fprintf('.\n');
end

% Process each full block
for blk = 1:numFullBlocks
    % Extract block data
    idxStart = (blk-1)*blockSize + 1;
    idxEnd   = blk*blockSize;
    blockData = numericList(idxStart:idxEnd);
    
    % 1. Extract the first 8 elements for the 1x8 header (C1:J1)
    % Transpose to make it a row vector
    headerRow = blockData(1:rowVals)'; 
    
    % 2. Extract the next 50 elements for the 5x10 block (A2:J6)
    blockData2D = blockData(rowVals+1 : end);
    
    % To fill A2:J6 row-by-row (first 10 values in A2:J2, etc.):
    % Reshape to (columns x rows) and then transpose.
    blockMatrix = reshape(blockData2D, blockCols, blockRows)';
    
    % Write to Excel
    sheetName = sprintf('Table_%02d', blk);
    
    % Write 1x8 row to C1:J1
    writematrix(headerRow, outputFile, 'Sheet', sheetName, 'Range', 'C1');
    
    % Write 5x10 block to A2:J6
    writematrix(blockMatrix, outputFile, 'Sheet', sheetName, 'Range', 'A2');
    
    fprintf('Written Table %d to sheet "%s".\n', blk, sheetName);
end

fprintf('Done. Output saved to %s\n', outputFile);