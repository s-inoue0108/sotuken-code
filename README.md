# `s-inoue0108/sotuken-code`

卒業研究にあたって作成したスクリプトファイルです。動作確認は以下の環境で行いました。

- GNU Bash 4.4.20 (x86_64-redhat-linux-gnu)
- Perl 5.26.3
- Python 3.6.8
  - Matplotlib 3.0.3
  - Pandas 0.25.3

| 名称          | 説明                                                                                                     |
| :------------ | :------------------------------------------------------------------------------------------------------- |
| `extract.pl`  | Gaussian 16 のアウトプットファイル（`.out` または `.log`）を処理します。                                 |
| `enerplot.py` | GaussView 6 からエクスポートした Relaxed Scan の結果ファイル（`.txt`）を読み込み、プロットを表示します。 |
| `scanplot.py` | `extract.pl` によってエクスポートしたファイル（`.plot.txt`）を読み込み、プロットを表示します。           |

## 使用法

### `extract.pl`

```bash
perl extract.pl
```

スクリプト起動後、出力フォーマットは以下から選択できます。

1. `Opt` オプションによる構造最適化（`Opt=ModRedundant` オプションによるスキャン計算を含む）の計算結果ファイル（`.out` または `.log`）を読み込み、Scan Coordinate ごとの最適化された座標データについて TD-DFT 計算ファイルを生成します。

2. `TD` オプション、または `TD Opt` オプションによる TD-DFT 計算（`Opt=ModRedundant` オプションによるスキャン計算を含む）の結果ファイル（`.out` または `.log`）を読み込み、Scan Coordinate、および励起状態ごとの振動子強度・旋光強度・$g$ 値および電気遷移双極子モーメントと磁気遷移双極子モーメントがなす角度 $\theta_{\mu m}$ を記載した `.txt` ファイルを出力します。

なお、$g$ 値および $\theta_{\mu m}$ は以下の式によって計算されます。

$$g = \frac{4 |\boldsymbol{\mu}| |\boldsymbol{m}| \cos \theta_{\mu m}}{|\boldsymbol{\mu}|^2 + |\boldsymbol{m}|^2}$$

$$\theta_{\mu m} = \mathrm{Arccos} ~ \left( \frac{\mu_x m_x + \mu_y m_y + \mu_z m_z}{|\boldsymbol{\mu}| |\boldsymbol{m}|} \right)$$

ただし $\boldsymbol{\mu} = (\mu_x, \mu_y, \mu_z)$ および $\boldsymbol{m} = (m_x, m_y, m_z)$ は電気遷移双極子モーメントベクトル、および磁気遷移双極子モーメントベクトルで、各成分は TD-DFT 計算による出力値です。

3. `Opt` オプションによる構造最適化（`Opt=ModRedundant` オプションによるスキャン計算を含む）の計算結果ファイル（`.out` または `.log`）を読み込み、Scan Coordinate ごとの最適化された座標データを `.xyz` 形式で出力します。

### `enerplot.py`

```bash
python3 enerplot.py [-h|--help] [--save] filename

# または
python enerplot.py [-h|--help] [--save] filename
```

| 引数         | 説明                                 | 備考 |
| :----------- | :----------------------------------- | :--- |
| `-h\|--help` | ヘルプを表示します。                 |      |
| `--save`     | プロットを `.png` 形式で保存します。 |      |
| `filename`   | `.plot.txt` ファイルを指定します。   | 必須 |

> [!warning]
> SSH 接続しながらプロットを表示する場合には、X11 転送等で GUI が使用できる環境が必要となります。

### `scanplot.py`

```bash
python3 scanplot.py [-h|--help] [--state STATE] [--save] [--y1 {rot,osc,gfac,angle}] [--y2 {rot,osc,gfac,angle}] filename

# または
python scanplot.py [-h|--help] [--state STATE] [--save] [--y1 {rot,osc,gfac,angle}] [--y2 {rot,osc,gfac,angle}] filename
```

| 引数                 | 説明                                                                                                                                                                                                                             | 備考                     |
| :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------- |
| `-h\|--help`         | ヘルプを表示します。                                                                                                                                                                                                             |                          |
| `--state STATE`      | プロットを表示する励起状態番号を指定します。`STATE` は任意の整数です。                                                                                                                                                           | デフォルトは `--state 1` |
| `--save`             | プロットを `.png` 形式で保存します。                                                                                                                                                                                             |                          |
| `--y1` および `--y2` | $y$ 軸のデータを指定します。`rot` は旋光強度、`osc` は振動子強度、`gfac` は $g$ 値（基底状態では $g_\mathrm{abs}$、励起状態では $g_\mathrm{lum}$）、`angle` は $\theta_{\mu m}$ です。`--y2` を指定すると2軸プロットとなります。 | デフォルトは `--y1 rot`  |
| `filename`           | `.plot.txt` ファイルを指定します。                                                                                                                                                                                               | 必須                     |

> [!warning]
> SSH 接続しながらプロットを表示する場合には、X11 転送等で GUI が使用できる環境が必要となります。