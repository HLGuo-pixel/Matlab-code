%% Data Layout Transfer – Column "list" with Partial Block Support
% Assumes a variable named 'list' exists in the workspace.

% ---------- Settings ----------
outputFile = 'special_tables.xlsx';

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
% ... [Data Validation & numericList conversion remains the same] ...
numericList = numericList(:);
numericList = rmmissing(numericList);
numElements = length(numericList);

% ---------- Layout Logic ----------
rowVals     = 8;       
blockRows   = 5;       
blockCols   = 10;      
blockSize   = rowVals + (blockRows * blockCols); 

% Calculate total sheets needed (rounding up to include the remainder)
numSheets = ceil(numElements / blockSize);
fprintf('Total elements: %d. Creating %d sheets.\n', numElements, numSheets);

for blk = 1:numSheets
    idxStart = (blk-1)*blockSize + 1;
    % Ensure we don't exceed the bounds of the list
    idxEnd   = min(blk*blockSize, numElements);
    currentData = numericList(idxStart:idxEnd);
    
    % --- Handle C1:J1 (Header) ---
    % Take up to the first 8 elements
    headerLength = min(length(currentData), rowVals);
    headerRow = currentData(1:headerLength)';
    
    % --- Handle A2:J6 (Block) ---
    if length(currentData) > rowVals
        blockDataRaw = currentData(rowVals+1 : end);
        
        % If the remainder is a partial block, pad it with NaNs so reshape works
        requiredBlockSize = blockRows * blockCols;
        if length(blockDataRaw) < requiredBlockSize
            padding = NaN(requiredBlockSize - length(blockDataRaw), 1);
            blockDataRaw = [blockDataRaw; padding];
        end
        
        blockMatrix = reshape(blockDataRaw, blockCols, blockRows)';
    else
        % If there wasn't even enough data to start the block, leave it empty
        blockMatrix = [];
    end
    
    % --- Write to Excel ---
    sheetName = sprintf('Table_%02d', blk);
    
    % Write row to C1:J1
    if ~isempty(headerRow)
        writematrix(headerRow, outputFile, 'Sheet', sheetName, 'Range', 'C1');
    end
    
    % Write block to A2:J6
    if ~isempty(blockMatrix)
        writematrix(blockMatrix, outputFile, 'Sheet', sheetName, 'Range', 'A2');
    end
    
    fprintf('Processed Sheet %d ("%s") with %d elements.\n', blk, sheetName, length(currentData));
end

fprintf('Done. All data including remainders saved to %s\n', outputFile);