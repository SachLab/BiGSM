function [idx] = find_index(cell_array, given_str)
% This is the helper function for loading DREAM3 data, mapping the 
% variable names in the data to index according to the given regulator name

% Iterate over the cell array
for i = 1:numel(cell_array)
    % Compare each string with the given string
    if strcmp(cell_array{i}, given_str)
        idx = i;
        break;
    end
end
end

