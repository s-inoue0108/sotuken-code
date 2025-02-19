import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ptick
import argparse as ap
import textwrap as tw
import re

def main():
  args = get_args()
  [dfs, is_excited] = get_data(args.filename)
  exec_plot(dfs, args, is_excited)

def get_args():
  parser = ap.ArgumentParser()
  parser.add_argument("filename", type=str, help=tw.dedent("""
    Input file name [plot.txt]
    """))
  parser.add_argument("--state", type=int, default=1, help=tw.dedent("""
    State number
    """))
  parser.add_argument("--save", action="store_true", help=tw.dedent("""
    Whether to save the figure or not
    """))
  parser.add_argument("--y1", type=str, choices=["rot", "osc", "gfac", "angle"], default="rot", help=tw.dedent("""
    Y-axis data type [rot|osc|gfac|angle]
    
    rot:   Rotatory Strength
    osc:   Oscillatior Strength
    gfac:  g-factor
    angle: Angle between ETDM and MTDM
    """))
  
  parser.add_argument("--y2", type=str, choices=["rot", "osc", "gfac", "angle"], help=tw.dedent("""
    Y-axis data type [rot|osc|gfac|angle]
    
    rot:   Rotatory Strength
    osc:   Oscillatior Strength
    gfac:  g-factor
    angle: Angle between ETDM and MTDM
    """))

  args = parser.parse_args()
  return args

def get_data(filename):
  dfs = []
  with open(filename, 'r') as file:
    content = file.read()
    cond = content.split("#")[1]
    is_excited = bool(re.search("Excited State", f'{cond}'))
    blocks = content.split("#")[2:]
    
    for block in blocks:
      block_with_header = block.strip().splitlines()   # タイトルとデータを分割
      data = block_with_header[2:]                     # ヘッダ以降をデータとして処理
      row_list = []
      
      for row in data:
        row_line = [elm.strip() for elm in re.split(r'\s+', row)]
        row_list.append([elm  for elm  in row_line if elm  != ""])

      df = pd.DataFrame(row_list)
      dfs.append(df)

  return [dfs, is_excited]

def selected_data(dfs, ydata):
  [rot, osc, avg_osc, gfac, angle] = dfs
  if ydata == "rot":
    return [rot, avg_osc]
  elif ydata == "osc":
    return [osc, avg_osc]
  elif ydata == "gfac":
    return [gfac, avg_osc]
  elif ydata == "angle":
    return [angle, avg_osc]

def exec_plot(dfs, args, is_excited):
  data = selected_data(dfs, args.y1)

  fig = plt.figure(figsize=(8, 4))
  plt.rcParams['font.family'] = 'Times New Roman'
  plt.rcParams['mathtext.fontset'] = 'cm'
  plt.rcParams["font.size"] = 16
  plt.rcParams["axes.titlesize"] = 20
  plt.rcParams['xtick.labelsize'] = 12
  plt.rcParams['ytick.labelsize'] = 12
  plt.rcParams['axes.labelsize'] = 16
  plt.rcParams['axes.labelpad'] = 12
  plt.rcParams['axes.linewidth'] = 1.0

  plt.rcParams["legend.fancybox"] = False    # 丸角
  plt.rcParams["legend.framealpha"] = 1      # 透明度の指定、0で塗りつぶしなし
  plt.rcParams["legend.edgecolor"] = 'black' # edgeの色を変更
  plt.rcParams["legend.handlelength"] = 1    # 凡例の線の長さを調節
  plt.rcParams["legend.labelspacing"] = 1   # 垂直方向（縦）の距離の各凡例の距離
  plt.rcParams["legend.handletextpad"] = 2  # 凡例の線と文字の距離の長さ
  plt.rcParams["legend.markerscale"] = 2     # 点がある場合のmarker scale

  plt.tight_layout()
  ax = fig.add_subplot(1, 1, 1)
  ax.grid()

  x = [float(x) for x in data[0][0].values]
  y = [float(y) for y in data[0][args.state].values]
  avg_osc = float(data[1][args.state - 1][0])

  def define_ylabel(ax, ydata):
    if ydata == "rot":
      ax.set_ylabel(r"$R$ / $10^{{-40}}\mathrm{erg \cdot esu \cdot cm \cdot Gauss^{-1}}$")
    elif ydata == "osc":
      ax.set_ylabel(r"Oscillatior Strength $f$")
    elif ydata == "gfac":
      if is_excited:
        ax.set_ylabel(r"$g_{\mathrm{lum}}$")
      else:
        ax.set_ylabel(r"$g_{\mathrm{abs}}$")
    elif ydata == "angle":
      ax.set_ylabel(r"Angle $\theta_{\mu m}$ / degree")
  
  def get_legend(ydata):
    if ydata == "rot":
      return r"Rotatory Strength $R$"
    elif ydata == "osc":
      return r"Oscillatior Strength $f$"
    elif ydata == "gfac":
      if is_excited:
        return r"$g_{\mathrm{lum}}$"
      else:
        return r"$g_{\mathrm{abs}}$"
    elif ydata == "angle":
      return r"Angle $\theta_{\mu m}$"
    return ""

  ax.set_title(rf"$\mathrm{{S}}_{args.state}$ ($f_\mathrm{{avg}} = {avg_osc:.4f}$)")
  [p1] = ax.plot(x, y, color="blue", label=get_legend(args.y1))
  ax.scatter(x, y, color="blue")
  ax.set_xlabel(r"Dihedral Angle $\theta$ / degree")

  define_ylabel(ax, args.y1)

  if args.y2:
    ax2 = ax.twinx()
    data2 = selected_data(dfs, args.y2)
    y2 = [float(y) for y in data2[0][args.state].values]
    [p2] = ax2.plot(x, y2, color="green", label=get_legend(args.y2))
    ax2.scatter(x, y2, color="green")

    define_ylabel(ax2, args.y2)

    plots = [p1, p2]
    ax.legend(plots, [p.get_label() for p in plots])

  ax.xaxis.set_major_formatter(ptick.ScalarFormatter(useMathText=True))
  ax.yaxis.set_major_formatter(ptick.ScalarFormatter(useMathText=True))
  ax.ticklabel_format(style='sci', axis='both')

  if bool(args.save):
    if args.y2:
      fig.savefig(f'{args.filename}_{args.state}_{args.y1}_{args.y2}.png', bbox_inches="tight", pad_inches=0.05)
    else:
      fig.savefig(f'{args.filename}_{args.state}_{args.y1}.png', bbox_inches="tight", pad_inches=0.05)

  plt.show()


if __name__ == "__main__":
  main()