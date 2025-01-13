% Main script to parse metrics and create plots

% Specify regex patterns for metrics to be extracted
metric_patterns = struct(...
    'execution_time', 'sim_seconds\s+([\d.]+)', ...
    'cpi', 'system\.cpu\.cpi\s+([\d.]+)', ...
    'l1i_miss_rate', 'system\.cpu\.icache\.overall_miss_rate::total\s+([\d.]+)', ...
    'l1d_miss_rate', 'system\.cpu\.dcache\.overall_miss_rate::total\s+([\d.]+)', ...
    'l2_miss_rate', 'system\.l2\.overall_miss_rate::total\s+([\d.]+)' ...
);

% Specify file paths and associated benchmarks
benchmark_files = struct(...
    'spec_bzip', 'C:\Users\Mathaios\Desktop\spec_results\specbzip\stats.txt', ...
    'spec_mcf', 'C:\Users\Mathaios\Desktop\spec_results\spechmmer\stats.txt', ...
    'spec_sjeng', 'C:\Users\Mathaios\Desktop\spec_results\specsjeng\stats.txt', ...
    'spec_hmmer', 'C:\Users\Mathaios\Desktop\spec_results\specmcf\stats.txt', ...
    'spec_libm', 'C:\Users\Mathaios\Desktop\spec_results\speclibm\stats.txt' ...
);

% Process each benchmark file to extract the metrics
results = struct();
benchmark_names = fieldnames(benchmark_files);
for i = 1:length(benchmark_names)
    benchmark_name = benchmark_names{i};
    path = benchmark_files.(benchmark_name);
    if isfile(path)
        results.(benchmark_name) = parse_metrics(path, metric_patterns);
    else
        fprintf('Error: File not found for %s\n', benchmark_name);
        results.(benchmark_name) = structfun(@(x) 0, metric_patterns, 'UniformOutput', false);
    end
end

% Create a new folder for the graphs if it doesn't exist
output_folder = 'C:\Users\Mathaios\Desktop\graphs_from_benchmarks';
create_output_folder(output_folder);

% Extract data for plotting
metrics = fieldnames(metric_patterns);
metric_titles = ["Execution Time", "CPI", "L1I Cache Miss Rate", "L1D Cache Miss Rate", "L2 Cache Miss Rate"];
metric_y_labels = ["Execution Time (s)", "CPI", "Miss Rate", "Miss Rate", "Miss Rate"];
metric_files = ["execution_times.png", "cpi_values.png", "l1i_miss_rates.png", "l1d_miss_rates.png", "l2_miss_rates.png"];

% Prepare data for each metric
for i = 1:length(metrics)
    metric = metrics{i};
    values = zeros(1, length(benchmark_names));
    for j = 1:length(benchmark_names)
        benchmark_name = benchmark_names{j};
        values(j) = results.(benchmark_name).(metric);
    end
    % Generate and save plot
    output_path = fullfile(output_folder, metric_files{i});
    create_bar_plot(values, metric_titles(i), metric_y_labels(i), benchmark_names, output_path);
end

% --- Subfunctions below ---
function extracted_data = parse_metrics(file_path, patterns)
    % Read the file content
    file_content = fileread(file_path);
    extracted_data = struct();
    % Extract each metric using the provided regex patterns
    metric_names = fieldnames(patterns);
    for i = 1:length(metric_names)
        metric_name = metric_names{i};
        regex_pattern = patterns.(metric_name);
        match = regexp(file_content, regex_pattern, 'tokens', 'once');
        if ~isempty(match)
            extracted_data.(metric_name) = str2double(match{1});
        else
            extracted_data.(metric_name) = 0; % Default to 0 if not found
        end
    end
end

function create_output_folder(folder_path)
    % Create the output folder if it does not exist
    if ~exist(folder_path, 'dir')
        mkdir(folder_path);
    end
end

function create_bar_plot(values, title_text, y_label, x_labels, output_file)
    % Create and save a bar plot
    figure('Position', [100, 100, 1200, 800]); % Set figure size
    bar(values, 'FaceColor', [0.4, 0.6, 0.8]); % Bar color
    title(title_text, 'FontSize', 14, 'Interpreter', 'none');
    ylabel(y_label, 'FontSize', 12);
    set(gca, 'XTickLabel', x_labels, 'XTick', 1:length(x_labels), ...
        'XTickLabelRotation', 0, 'FontSize', 10);
    grid on;
    saveas(gcf, output_file);
    close;
end
