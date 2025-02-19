import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ptick
import argparse as ap
import re
from io import StringIO

# make parser
parser = ap.ArgumentParser()

# add arguments
parser.add_argument("filename", type=str)
parser.add_argument("--save", action="store_true")

args = parser.parse_args()

# 1列目のタブの削除
with open(args.filename, 'r') as f:
    lines = [re.sub(r'^\s+', '', line) for line in f]

data = ''.join(lines)

df = pd.read_csv(StringIO(data), comment='#', header=None, sep='\s+', names=['Coordinate', 'Energy'], encoding="utf-8", engine="python")

plt.rcParams['font.family'] = 'Times New Roman'
plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams["font.size"] = 16
plt.rcParams["axes.titlesize"] = 20
plt.rcParams['xtick.labelsize'] = 12
plt.rcParams['ytick.labelsize'] = 12
plt.rcParams['axes.labelsize'] = 16
plt.rcParams['axes.labelpad'] = 12
plt.rcParams['axes.linewidth'] = 1.0

fig = plt.figure(figsize=(8, 4))
ax = fig.add_subplot(1, 1, 1)
ax.grid()

ax.xaxis.set_major_formatter(ptick.ScalarFormatter(useMathText=True))
ax.yaxis.set_major_formatter(ptick.ScalarFormatter(useMathText=True))
ax.ticklabel_format(style='sci', axis='both')

ax.plot(df["Coordinate"], df["Energy"], color="red")
ax.scatter(df["Coordinate"], df["Energy"], color="red")
ax.set_xlabel(r"Dihedral Angle $\theta$ / degree")
ax.set_ylabel(r"Total Energy / hartree")

plt.tight_layout()

if args.save:
    fig.savefig(f'{args.filename}.png', bbox_inches="tight", pad_inches=0.05)

plt.show()
