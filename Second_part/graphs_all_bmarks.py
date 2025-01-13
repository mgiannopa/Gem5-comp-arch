import re
import matplotlib.pyplot as plt
import os

# Function to parse and extract metrics from a stats file
def parse_metrics(file_path, patterns):
    extracted_data = {}
    with open(file_path, 'r') as file:
        file_content = file.read()
        for metric_name, regex_pattern in patterns.items():
            match = re.search(regex_pattern, file_content)
            if match:
                extracted_data[metric_name] = float(match.group(1))
    return extracted_data

# Function to create output folder if it doesn't exist
def create_output_folder(folder_path):
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

# Function to create and save bar plots
def create_bar_plot(values, title, y_label, x_labels, output_file):
    plt.figure(figsize=(12, 8))
    bars = plt.bar(x_labels, values, color='skyblue')
    plt.title(title)
    plt.ylabel(y_label)
    plt.xlabel("Benchmarks")
    plt.tight_layout(pad=2.0)
    plt.savefig(output_file)
    plt.show()

# Specify regex patterns for metrics to be extracted
metric_patterns = {
    'execution_time': r"sim_seconds\s+([\d.]+)",
    'cpi': r"system\.cpu\.cpi\s+([\d.]+)",
    'l1i_miss_rate': r"system\.cpu\.icache\.overall_miss_rate::total\s+([\d.]+)",
    'l1d_miss_rate': r"system\.cpu\.dcache\.overall_miss_rate::total\s+([\d.]+)",
    'l2_miss_rate': r"system\.l2\.overall_miss_rate::total\s+([\d.]+)"
}

# Specify file paths and associated benchmarks
benchmark_files = {
    'spec_bzip': r'C:\Users\Mathaios\Desktop\spec_results\specbzip\stats.txt',
    'spec_mcf': r'C:\Users\Mathaios\Desktop\spec_results\spechmmer\stats.txt',
    'spec_sjeng': r'C:\Users\Mathaios\Desktop\spec_results\specsjeng\stats.txt',
    'spec_hmmer': r'C:\Users\Mathaios\Desktop\spec_results\specmcf\stats.txt',
    'spec_libm': r'C:\Users\Mathaios\Desktop\spec_results\speclibm\stats.txt'
}

# Process each benchmark file to extract the metrics
results = {}
for benchmark_name, path in benchmark_files.items():
    if os.path.exists(path):
        results[benchmark_name] = parse_metrics(path, metric_patterns)
    else:
        print(f"Error: File not found for {benchmark_name}")

# Create a new folder for the graphs if it doesn't exist
output_folder = r'C:\Users\Mathaios\Desktop\graphs_from_benchmarks'
create_output_folder(output_folder)

# Extract data for plotting
benchmark_names = list(results.keys())
metrics = ['execution_time', 'cpi', 'l1i_miss_rate', 'l1d_miss_rate', 'l2_miss_rate']
metric_titles = ["Execution Time", "CPI", "L1I Cache Miss Rate", "L1D Cache Miss Rate", "L2 Cache Miss Rate"]
metric_y_labels = ["Execution Time (s)", "CPI", "Miss Rate", "Miss Rate", "Miss Rate"]
metric_files = ["execution_times.png", "cpi_values.png", "l1i_miss_rates.png", "l1d_miss_rates.png", "l2_miss_rates.png"]

metric_values = {metric: [results[bm].get(metric, 0) for bm in benchmark_names] for metric in metrics}

# Generate and save plots for each metric
for metric, title, y_label, output_file in zip(metrics, metric_titles, metric_y_labels, metric_files):
    output_path = os.path.join(output_folder, output_file)
    create_bar_plot(metric_values[metric], title, y_label, benchmark_names, output_path)