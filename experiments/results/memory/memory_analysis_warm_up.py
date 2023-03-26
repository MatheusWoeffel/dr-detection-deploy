import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys

def get_metric_to_analyze_label(metric_to_analyze):
    if metric_to_analyze == 'fullLatency':
        return 'Latência Total'
    else:
        return 'Tempo de predição'


model_name = sys.argv[1]
metric_to_analyze = sys.argv[2]

memory_1gb = pd.read_csv(f"./warm-up-{model_name}-1gb.csv")
memory_2gb= pd.read_csv(f"./warm-up-{model_name}-2gb.csv")
memory_3gb = pd.read_csv(f"./warm-up-{model_name}-3gb.csv")



combined_data = [memory_1gb[metric_to_analyze], memory_2gb[metric_to_analyze] , memory_3gb[metric_to_analyze]]

fig, ax = plt.subplots(figsize=(14, 7))

# Creating plot
bp = plt.boxplot(combined_data, showfliers=False)

m1 = np.asarray(combined_data).mean(axis=1)
st1 = np.asarray(combined_data).std(axis=1)

for i, line in enumerate(bp['medians']):
    x, y = line.get_xydata()[1]
    text = ' μ={:.2f}\n σ={:.2f}'.format(m1[i], st1[i])
    ax.annotate(text, xy=(x, y))

plt.ylabel(f'{get_metric_to_analyze_label(metric_to_analyze)} (s)')
plt.xlabel('Tamanho de memória utilizado')
plt.xticks([1, 2, 3], ('1 GB', '2 GB', '3 GB'))

plt.savefig(f'warm-up-{model_name}-{metric_to_analyze}.eps', bbox_inches='tight', format="eps")
# show plot
plt.show()