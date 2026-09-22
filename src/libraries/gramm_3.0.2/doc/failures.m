% failures.m - Demonstration of gramm input dimension failure scenarios
%
% This file showcases potential issues with different input data orientations
% and dimensions in the gramm library. Each section demonstrates a specific
% failure mode or edge case.
%
% Run each section individually to see the issues.

%% Setup
close all;
clear;

%% FAILURE SCENARIO 1: Wide Matrix + geom_bar - Length Mismatch
% Problem: Wide matrices cause dimension mismatches in geom_bar
fprintf('=== FAILURE SCENARIO 1: Wide Matrix + geom_bar ===\n');

try
    x = [1 2 3];        % 1×3 row vector
    y = [4 5 6; 7 8 9]; % 2×3 matrix
    
    fprintf('Input dimensions:\n');
    fprintf('x: %s\n', mat2str(size(x)));
    fprintf('y: %s\n', mat2str(size(y)));
    
    g = gramm('x', x, 'y', y);
    g.geom_bar();
    
    figure();
    g.draw();
    fprintf('SUCCESS: Unexpectedly worked!\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails because wide matrix y gets converted incorrectly\n');
end

%% FAILURE SCENARIO 2: Mixed Cell Orientations + comb()
% Problem: Mixed row/column vectors in cell arrays cause dimension mismatches
fprintf('\n=== FAILURE SCENARIO 2: Mixed Cell Orientations ===\n');

try
    % Mixed orientations: row vector, column vector, row vector
    x_mixed = {[1 2 3], [4; 5], [6 7]};  
    y_mixed = {[10 11 12], [13; 14], [15 16]};
    
    fprintf('Cell contents orientations:\n');
    for i = 1:length(x_mixed)
        fprintf('x{%d}: %s, y{%d}: %s\n', i, mat2str(size(x_mixed{i})), ...
                i, mat2str(size(y_mixed{i})));
    end
    
    g = gramm('x', x_mixed, 'y', y_mixed);
    g.geom_point();
    
    figure();
    g.draw();
    fprintf('SUCCESS: Unexpectedly worked!\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails due to dimension mismatch in vertcat() within comb()\n');
end

%% FAILURE SCENARIO 3: Square Matrix Orientation Ambiguity
% Problem: Square matrices create ambiguous orientation decisions
fprintf('\n=== FAILURE SCENARIO 3: Square Matrix Ambiguity ===\n');

try
    data_square = [1 2; 3 4];  % 2×2 square matrix
    x_vals = [1 2];            % Corresponding x values
    
    fprintf('Input square matrix:\n');
    disp(data_square);
    fprintf('Expected interpretation: columns as separate series\n');
    fprintf('Actual interpretation: rows as separate series\n');
    
    % This will work but may not give expected results
    g = gramm('x', x_vals, 'y', data_square);
    g.geom_line();
    
    figure();
    g.draw();
    title('Square Matrix: Expected vs Actual Interpretation');
    
    fprintf('WARNING: Plot created but may not match user expectations\n');
    fprintf('Matrix is interpreted row-wise, not column-wise\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

%% FAILURE SCENARIO 4: Tall Matrix + stat_smooth Inconsistency  
% Problem: Different handling between cell and array inputs in stat_smooth
fprintf('\n=== FAILURE SCENARIO 4: stat_smooth Inconsistency ===\n');

try
    % Create tall matrix that gets converted to cells
    x_tall = [1; 2; 3; 4];           % 4×1 column vector
    y_tall = [10 15; 12 17; 14 19; 16 21]; % 4×2 matrix
    
    fprintf('Input dimensions:\n');
    fprintf('x: %s\n', mat2str(size(x_tall)));
    fprintf('y: %s\n', mat2str(size(y_tall)));
    
    g = gramm('x', x_tall, 'y', y_tall);
    g.stat_smooth();
    
    figure();
    g.draw();
    title('Tall Matrix Handling in stat_smooth');
    
    % Compare with equivalent cell input
    x_cell = {[1; 2; 3; 4], [1; 2; 3; 4]};
    y_cell = {[10; 12; 14; 16], [15; 17; 19; 21]};
    
    g2 = gramm('x', x_cell, 'y', y_cell);
    g2.stat_smooth();
    
    figure();
    g2.draw();
    title('Equivalent Cell Input in stat_smooth');
    
    fprintf('SUCCESS: Both plots created but with different internal handling\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

%% FAILURE SCENARIO 5: geom_bar Orientation Forcing Issues
% Problem: geom_bar forces row vectors, may cause issues with some inputs
fprintf('\n=== FAILURE SCENARIO 5: geom_bar Orientation Forcing ===\n');

try
    % Create data that works with other geoms but might have issues with geom_bar
    x_cat = {'A', 'B', 'C', 'D'};  % Categorical x
    y_vals = [10; 20; 15; 25];     % Column vector y
    
    fprintf('Testing geom_bar with categorical x and column vector y\n');
    
    g1 = gramm('x', x_cat, 'y', y_vals);
    g1.geom_bar();
    
    figure();
    g1.draw();
    title('geom_bar: Categorical X + Column Vector Y');
    
    % Compare with geom_point using same data
    g2 = gramm('x', x_cat, 'y', y_vals);
    g2.geom_point();
    
    figure();
    g2.draw();
    title('geom_point: Same Data for Comparison');
    
    fprintf('SUCCESS: Both plots work but internal handling differs\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

%% FAILURE SCENARIO 6: Complex Multi-dimensional Edge Case
% Problem: 3D arrays or complex structures may not be handled properly
fprintf('\n=== FAILURE SCENARIO 6: Complex Multi-dimensional Data ===\n');

try
    % Create 3D array (rare but possible user input)
    data_3d = reshape(1:12, [2, 2, 3]);  % 2×2×3 array
    x_simple = [1 2];
    
    fprintf('Input 3D array dimensions: %s\n', mat2str(size(data_3d)));
    
    g = gramm('x', x_simple, 'y', data_3d);
    g.geom_point();
    
    figure();
    g.draw();
    fprintf('SUCCESS: Unexpectedly handled 3D input!\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('3D arrays are not properly supported\n');
end

%% FAILURE SCENARIO 7: Empty Cells in Mixed Data
% Problem: Empty cells in cell arrays may cause issues
fprintf('\n=== FAILURE SCENARIO 7: Empty Cells in Data ===\n');

try
    % Cell arrays with empty elements
    x_empty = {[1 2], [], [3 4], [5]};
    y_empty = {[10 11], [], [12 13], [14]};
    
    fprintf('Cell arrays with empty elements:\n');
    for i = 1:length(x_empty)
        if isempty(x_empty{i})
            fprintf('x{%d}: empty, y{%d}: empty\n', i, i);
        else
            fprintf('x{%d}: %s, y{%d}: %s\n', i, mat2str(x_empty{i}), ...
                    i, mat2str(y_empty{i}));
        end
    end
    
    g = gramm('x', x_empty, 'y', y_empty);
    g.geom_line();
    
    figure();
    g.draw();
    title('Handling Empty Cells in Line Plot');
    
    fprintf('SUCCESS: Empty cells handled correctly\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

%% FAILURE SCENARIO 8: Very Large Dimension Mismatch
% Problem: Extreme dimension mismatches that might not be caught early
fprintf('\n=== FAILURE SCENARIO 8: Large Dimension Mismatch ===\n');

try
    x_large = 1:100;                    % 1×100
    y_large = reshape(1:200, [2, 100]); % 2×100 matrix
    
    fprintf('Large matrix dimensions:\n');
    fprintf('x: %s\n', mat2str(size(x_large)));
    fprintf('y: %s\n', mat2str(size(y_large)));
    
    g = gramm('x', x_large, 'y', y_large);
    g.stat_bin();
    
    figure();
    g.draw();
    title('Large Matrix with stat_bin');
    
    fprintf('SUCCESS: Large matrices handled\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('Large dimension mismatches cause issues\n');
end

%% FAILURE SCENARIO 9: Inconsistent Cell Array Sizes
% Problem: Cell arrays where elements have very different sizes
fprintf('\n=== FAILURE SCENARIO 9: Inconsistent Cell Sizes ===\n');

try
    % Cell arrays with very different sized elements
    x_inconsistent = {[1], [2 3 4 5], [6 7]};
    y_inconsistent = {[10], [11 12 13 14], [15 16]};
    
    fprintf('Highly inconsistent cell sizes:\n');
    for i = 1:length(x_inconsistent)
        fprintf('x{%d}: length %d, y{%d}: length %d\n', i, length(x_inconsistent{i}), ...
                i, length(y_inconsistent{i}));
    end
    
    g = gramm('x', x_inconsistent, 'y', y_inconsistent);
    g.geom_point();
    
    figure();
    g.draw();
    title('Highly Inconsistent Cell Array Sizes');
    
    fprintf('SUCCESS: Inconsistent sizes handled\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
end

%% FAILURE SCENARIO 10: stat_boxplot with All Outliers
% Problem: When all data points are outliers, whisker calculation fails
fprintf('\n=== FAILURE SCENARIO 10: stat_boxplot All Outliers ===\n');

try
    % Create data where all points are outliers (extreme spread)
    x_extreme = [1, 1, 1, 2, 2, 2];
    y_extreme = [1, 100, 1, 200, 2, 199];  % Very spread out data
    
    fprintf('Creating boxplot with extreme outliers:\n');
    fprintf('Group 1: [1, 100, 1] - all points will be outliers\n');
    fprintf('Group 2: [200, 2, 199] - all points will be outliers\n');
    
    g = gramm('x', x_extreme, 'y', y_extreme);
    g.stat_boxplot();
    
    figure();
    g.draw();
    title('stat_boxplot: All Data Points as Outliers');
    
    fprintf('SUCCESS: Handled extreme outlier case\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails when all data points are classified as outliers\n');
end

%% FAILURE SCENARIO 11: stat_boxplot with Single Data Point
% Problem: IQR becomes zero, causing division by zero in notch calculation
fprintf('\n=== FAILURE SCENARIO 11: stat_boxplot Single Data Point ===\n');

try
    % Single data point per group
    x_single = [1, 2, 3];
    y_single = [10, 20, 30];
    
    fprintf('Single data point per group with notches enabled:\n');
    
    g = gramm('x', x_single, 'y', y_single);
    g.stat_boxplot('notch', true);  % Notches require IQR calculation
    
    figure();
    g.draw();
    title('stat_boxplot: Single Points with Notches');
    
    fprintf('SUCCESS: Single point case handled\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails due to IQR=0 causing division by zero in notch calculation\n');
end

%% FAILURE SCENARIO 12: stat_boxplot with Empty Groups
% Problem: Numerical precision in selection may create empty groups
fprintf('\n=== FAILURE SCENARIO 12: stat_boxplot Empty Groups ===\n');

try
    % Create data with potential numerical precision issues
    x_precision = [1.0000001, 1.0000002, 2.0000001, 2.0000002];
    y_precision = [10, 11, 20, 21];
    
    fprintf('Data with potential numerical precision issues:\n');
    fprintf('x values: [1.0000001, 1.0000002, 2.0000001, 2.0000002]\n');
    fprintf('The 1e-10 threshold in selection may cause problems\n');
    
    g = gramm('x', x_precision, 'y', y_precision);
    g.stat_boxplot();
    
    figure();
    g.draw();
    title('stat_boxplot: Numerical Precision Issues');
    
    fprintf('SUCCESS: Numerical precision handled\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails due to numerical precision in group selection\n');
end

%% FAILURE SCENARIO 13: stat_boxplot with Identical Values
% Problem: All identical values create IQR=0, all points become outliers
fprintf('\n=== FAILURE SCENARIO 13: stat_boxplot Identical Values ===\n');

try
    % All identical values within groups
    x_identical = [1, 1, 1, 2, 2, 2];
    y_identical = [5, 5, 5, 10, 10, 10];  % Identical within each group
    
    fprintf('All values identical within each group:\n');
    fprintf('Group 1: [5, 5, 5], Group 2: [10, 10, 10]\n');
    fprintf('IQR = 0 for both groups\n');
    
    g = gramm('x', x_identical, 'y', y_identical);
    g.stat_boxplot();
    
    figure();
    g.draw();
    title('stat_boxplot: Identical Values per Group');
    
    fprintf('SUCCESS: Identical values handled\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails when IQR=0 causes all points to be outliers\n');
end

%% FAILURE SCENARIO 14: stat_boxplot with Mixed Cell Orientations
% Problem: Outlier array concatenation fails with mixed orientations
fprintf('\n=== FAILURE SCENARIO 14: stat_boxplot Mixed Orientations ===\n');

try
    % Create cell data with mixed orientations that could cause outlier issues
    x_mixed_box = {[1; 1; 1], [2 2 2], [3; 3]};  % Mixed column/row vectors
    y_mixed_box = {[10; 15; 5], [20 25 30], [35; 40]};  % Some outliers expected
    
    fprintf('Mixed orientations in cell arrays for boxplot:\n');
    for i = 1:length(x_mixed_box)
        fprintf('x{%d}: %s, y{%d}: %s\n', i, mat2str(size(x_mixed_box{i})), ...
                i, mat2str(size(y_mixed_box{i})));
    end
    
    g = gramm('x', x_mixed_box, 'y', y_mixed_box);
    g.stat_boxplot();
    
    figure();
    g.draw();
    title('stat_boxplot: Mixed Cell Orientations');
    
    fprintf('SUCCESS: Mixed orientations handled\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails due to dimension mismatch in outlier array building\n');
end

%% FAILURE SCENARIO 15: stat_boxplot with Very Small IQR
% Problem: Floating point precision issues with very small IQR values
fprintf('\n=== FAILURE SCENARIO 15: stat_boxplot Tiny IQR ===\n');

try
    % Data with very small differences (floating point precision issues)
    x_tiny = [1, 1, 1, 1, 1];
    y_tiny = [1.0000000001, 1.0000000002, 1.0000000003, 1.0000000004, 1.0000000005];
    
    fprintf('Data with extremely small differences:\n');
    fprintf('y range: %.15f to %.15f\n', min(y_tiny), max(y_tiny));
    fprintf('This may cause floating point precision issues in IQR calculation\n');
    
    g = gramm('x', x_tiny, 'y', y_tiny);
    g.stat_boxplot();
    
    figure();
    g.draw();
    title('stat_boxplot: Tiny IQR Values');
    
    fprintf('SUCCESS: Tiny IQR handled\n');
    
catch ME
    fprintf('ERROR: %s\n', ME.message);
    fprintf('This fails due to floating point precision in IQR calculations\n');
end

%% SUMMARY
fprintf('\n=== SUMMARY ===\n');
fprintf('This file demonstrates various edge cases and potential failure modes\n');
fprintf('in gramm when handling different input data orientations and dimensions.\n');
fprintf('Key issues identified:\n');
fprintf('1. comb() orientation detection using max() can fail with mixed orientations\n');
fprintf('2. geom_bar forces row vectors which may be inconsistent\n');
fprintf('3. Matrix interpretation (row-wise vs column-wise) may not match expectations\n');
fprintf('4. Different handling between cell and array inputs in stat functions\n');
fprintf('5. Complex multi-dimensional arrays are not well supported\n');
fprintf('6. stat_boxplot outlier handling fails with edge cases (all outliers, IQR=0)\n');
fprintf('7. stat_boxplot numerical precision issues in group selection\n');
fprintf('8. stat_boxplot dimension mismatches in outlier array concatenation\n');
fprintf('\nRecommendations:\n');
fprintf('- Use consistent orientations within cell arrays\n');
fprintf('- Be explicit about matrix interpretation requirements\n');
fprintf('- Avoid datasets with all identical values for boxplots\n');
fprintf('- Be cautious with very small or very large numerical ranges\n');
fprintf('- Test with your specific data dimensions before production use\n');