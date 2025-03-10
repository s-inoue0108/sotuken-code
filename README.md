# `s-inoue0108/sotuken-code`

卒業研究にあたって作成したスクリプトファイルです。動作確認は以下の環境で行いました。

- GNU Bash 4.4.20 (x86_64-redhat-linux-gnu)
- Perl 5.26.3
- Python 3.6.8
  - Matplotlib 3.0.3
  - Pandas 0.25.3

| 名称                                  | 説明                                                                                                     |
| :------------------------------------ | :------------------------------------------------------------------------------------------------------- |
| [`extract.pl`](/scripts/extract.pl)   | Gaussian 16 のアウトプットファイル（`.out` または `.log`）を処理します。                                 |
| [`enerplot.py`](/scripts/enerplot.py) | GaussView 6 からエクスポートした Relaxed Scan の結果ファイル（`.txt`）を読み込み、プロットを表示します。 |
| [`scanplot.py`](/scripts/scanplot.py) | `extract.pl` によってエクスポートしたファイル（`.plot.txt`）を読み込み、プロットを表示します。           |

## 使用法

### `extract.pl`

```bash
perl extract.pl
```

スクリプト起動後、出力フォーマットは以下から選択できます。

1. `opt` オプションによる構造最適化（`opt=modredundant` オプションによるスキャン計算を含む）の計算結果ファイル（`.out` または `.log`）を読み込み、Scan Coordinate ごとの最適化された座標データについて TD-DFT 計算ファイルを生成します。

2. `td` オプション、または `td opt` オプションによる TD-DFT 計算（`opt=modredundant` オプションによるスキャン計算を含む）の結果ファイル（`.out` または `.log`）を読み込み、Scan Coordinate、および励起状態ごとの振動子強度・旋光強度・*g*値および電気遷移双極子モーメントと磁気遷移双極子モーメントがなす角度 $\theta_{\mu m}$ を記載した `.txt` ファイルを出力します。

なお、*g*値および $\theta_{\mu m}$ は以下の式によって計算されます。

$$g = \frac{4 |\boldsymbol{\mu}| |\boldsymbol{m}| \cos \theta_{\mu m}}{|\boldsymbol{\mu}|^2 + |\boldsymbol{m}|^2}$$

$$\theta_{\mu m} = \mathrm{Arccos} ~ \left( \frac{\mu_x m_x + \mu_y m_y + \mu_z m_z}{|\boldsymbol{\mu}| |\boldsymbol{m}|} \right)$$

ただし $\boldsymbol{\mu} = (\mu_x, \mu_y, \mu_z)$ および $\boldsymbol{m} = (m_x, m_y, m_z)$ は電気遷移双極子モーメントベクトル、および磁気遷移双極子モーメントベクトルで、各成分は TD-DFT 計算による出力値です。

3. `opt` オプションによる構造最適化（`opt=modredundant` オプションによるスキャン計算を含む）の計算結果ファイル（`.out` または `.log`）を読み込み、Scan Coordinate ごとの最適化された座標データを `.xyz` 形式で出力します。

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

## 実行例

L-フェニルアラニン（L-Phenylalanine）による計算例を示します。

### 基底状態

`example/ground_state/` ディレクトリに一連のファイルとサブディレクトリがあります。

**1. 構造最適化計算**

[`phe.com`](/example/ground_state/phe.com) は初期構造ファイルです。`opt=modredundant` オプションにより、ベンジル位の二面角を回転させながら構造最適化を繰り返します。

**2. TD-DFT 計算ファイルの生成**

[`phe.out`](/example/ground_state/phe.out) は構造最適化計算の結果ファイルです。これをもとに、二面角ごとの安定構造を入力にもつ TD-DFT インプットファイルを生成します。

```
$ perl extract.pl
-------------------------------------------------------------------------------------
This is the Gaussian output processor for TD-DFT calculations.
(Press 'Ctrl + C' to exit)
-------------------------------------------------------------------------------------

✔ Select output format [1 to 4]
1) Generate TD-DFT input from [opt|opt-scan] output.
2) Extract Rotatory Strengths from [td-scan|td-opt-scan] output.
3) Extract Coordinates from [opt|opt-scan] output.
4) Display help.
>>
```

`1` 番を選択します。

```
✔ Enter the name of <out> file [opt|opt-scan]
>>
```

`phe.out` を入力します。

計算したい励起状態の数（`nstates`）は任意の自然数を入力、汎関数・基底関数系は選択肢から選択します。ただし LanL2DZ は、ECP も同時に設定されます（`<functional>/genecp`、ECP は LanL2DZ）。

すべての設問に答えると、`phe_tddft/` ディレクトリが出力されます。`phe.***.tddft.com` は、生成された TD-DFT 計算ファイルです。

**3. TD-DFT 計算結果の解析**

[`phe_tddft_outs/`](/example/ground_state/phe_tddft_outs/) は二面角ごとの TD-DFT 計算の結果ファイル（`phe.***.tddft.out`）が詰まったディレクトリです。

```
$ perl extract.pl
-------------------------------------------------------------------------------------
This is the Gaussian output processor for TD-DFT calculations.
(Press 'Ctrl + C' to exit)
-------------------------------------------------------------------------------------

✔ Select output format [1 to 4]
1) Generate TD-DFT input from [opt|opt-scan] output.
2) Extract Rotatory Strengths from [td-scan|td-opt-scan] output.
3) Extract Coordinates from [opt|opt-scan] output.
4) Display help.
>>
```

`2` 番を選択します。

```
✔ Enter the name of [td-scan result <directory>|td-opt-scan result <out>]
>>
```

`phe_tddft_outs/` を入力します。

```
✔ Enter the name of <txt> file [tot_ener.txt]
>>
```

[`phe_tot_ener.txt`](/example/ground_state/phe_tot_ener.txt) を入力します（GaussView 6 で `phe.out` を読み込み、Result -> Scan からポテンシャルエネルギーマップを表示し、右クリック -> Save Data からエクスポートしたものです）。

読み込みに成功すると、[`phe_tddft_outs.plot.txt`](/example/ground_state/phe_tddft_outs.plot.txt) がエクスポートされます。

**4. 可視化**

`phe_tot_ener.txt` を用いて、ポテンシャルエネルギーマップを表示できます。

```bash
python3 enerplot.py /path/to/phe_tot_ener.txt
```

また、`phe_tddft_outs.plot.txt` を用いて、旋光強度や *g* 値のプロットを表示できます。

```bash
python3 scanplot.py /path/to/phe_tddft_outs.plot.txt
```

### 励起状態

`example/excited_state/` ディレクトリに一連のファイルとサブディレクトリがあります。

**1. TD-DFT による構造最適化計算**

[`phe_ex.com`](/example/excited_state/phe_ex.com) は初期構造ファイルです。`opt=modredundant` オプションにより、ベンジル位の二面角を回転させながら構造最適化を繰り返します。また、`td` オプションに基づき、励起状態の構造最適化を行います。

**2. TD-DFT 計算結果の解析**

[`phe_ex.out`](/example/excited_state/phe_ex.out) は二面角ごとの TD-DFT 計算の結果が記載されたアウトプットファイルです。

```
$ perl extract.pl
-------------------------------------------------------------------------------------
This is the Gaussian output processor for TD-DFT calculations.
(Press 'Ctrl + C' to exit)
-------------------------------------------------------------------------------------

✔ Select output format [1 to 4]
1) Generate TD-DFT input from [opt|opt-scan] output.
2) Extract Rotatory Strengths from [td-scan|td-opt-scan] output.
3) Extract Coordinates from [opt|opt-scan] output.
4) Display help.
>>
```

`2` 番を選択します。

```
✔ Enter the name of [td-scan result <directory>|td-opt-scan result <out>]
>>
```

`phe_ex.out` を入力します。

```
✔ Enter the name of <txt> file [tot_ener.txt]
>>
```

[`phe_ex_tot_ener.txt`](/example/excited_state/phe_ex_tot_ener.txt) を入力します（GaussView 6 で `phe_ex.out` を読み込み、Result -> Scan からポテンシャルエネルギーマップを表示し、右クリック -> Save Data からエクスポートしたものです）。

読み込みに成功すると、[`phe_ex.out.plot.txt`](/example/excited_state/phe_ex.out.plot.txt) がエクスポートされます。

**4. 可視化**

`phe_ex_tot_ener.txt` を用いて、ポテンシャルエネルギーマップを表示できます。

```bash
python3 enerplot.py /path/to/phe_ex_tot_ener.txt
```

また、`phe_ex.out.plot.txt` を用いて、旋光強度や *g* 値のプロットを表示できます。

```bash
python3 scanplot.py /path/to/phe_ex.out.plot.txt
```