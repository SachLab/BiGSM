function [idx] = find_index(cell_array, given_str)
% Iterate over the cell array
for i = 1:numel(cell_array)
    % Compare each string with the given string
    if strcmp(cell_array{i}, given_str)
        idx = i;
        break;
    end
end
end

