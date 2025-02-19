#!/usr/bin/perl

# Extract optimized structures from gaussian output.
# Usage: perl extract.pl

use strict;
use warnings;
use Term::ReadLine;
use File::Spec;
use Math::Trig;

# 元素記号のマップ
my %atoms = (
  1   => 'H',   # 水素 (Hydrogen)
  2   => 'He',  # ヘリウム (Helium)
  3   => 'Li',  # リチウム (Lithium)
  4   => 'Be',  # ベリリウム (Beryllium)
  5   => 'B',   # ホウ素 (Boron)
  6   => 'C',   # 炭素 (Carbon)
  7   => 'N',   # 窒素 (Nitrogen)
  8   => 'O',   # 酸素 (Oxygen)
  9   => 'F',   # フッ素 (Fluorine)
  10  => 'Ne',  # ネオン (Neon)
  11  => 'Na',  # ナトリウム (Sodium)
  12  => 'Mg',  # マグネシウム (Magnesium)
  13  => 'Al',  # アルミニウム (Aluminum)
  14  => 'Si',  # ケイ素 (Silicon)
  15  => 'P',   # リン (Phosphorus)
  16  => 'S',   # 硫黄 (Sulfur)
  17  => 'Cl',  # 塩素 (Chlorine)
  18  => 'Ar',  # アルゴン (Argon)
  19  => 'K',   # カリウム (Potassium)
  20  => 'Ca',  # カルシウム (Calcium)
  21  => 'Sc',  # スカンジウム (Scandium)
  22  => 'Ti',  # チタン (Titanium)
  23  => 'V',   # バナジウム (Vanadium)
  24  => 'Cr',  # クロム (Chromium)
  25  => 'Mn',  # マンガン (Manganese)
  26  => 'Fe',  # 鉄 (Iron)
  27  => 'Co',  # コバルト (Cobalt)
  28  => 'Ni',  # ニッケル (Nickel)
  29  => 'Cu',  # 銅 (Copper)
  30  => 'Zn',  # 亜鉛 (Zinc)
  31  => 'Ga',  # ガリウム (Gallium)
  32  => 'Ge',  # ゲルマニウム (Germanium)
  33  => 'As',  # ヒ素 (Arsenic)
  34  => 'Se',  # セレン (Selenium)
  35  => 'Br',  # 臭素 (Bromine)
  36  => 'Kr',  # クリプトン (Krypton)
  37  => 'Rb',  # ルビジウム (Rubidium)
  38  => 'Sr',  # ストロンチウム (Strontium)
  39  => 'Y',   # イットリウム (Yttrium)
  40  => 'Zr',  # ジルコニウム (Zirconium)
  41  => 'Nb',  # ニオブ (Niobium)
  42  => 'Mo',  # モリブデン (Molybdenum)
  43  => 'Tc',  # テクネチウム (Technetium)
  44  => 'Ru',  # ルテニウム (Ruthenium)
  45  => 'Rh',  # ロジウム (Rhodium)
  46  => 'Pd',  # パラジウム (Palladium)
  47  => 'Ag',  # 銀 (Silver)
  48  => 'Cd',  # カドミウム (Cadmium)
  49  => 'In',  # インジウム (Indium)
  50  => 'Sn',  # スズ (Tin)
  51  => 'Sb',  # アンチモン (Antimony)
  52  => 'Te',  # テルル (Tellurium)
  53  => 'I',   # ヨウ素 (Iodine)
  54  => 'Xe',  # キセノン (Xenon)
  55  => 'Cs',  # セシウム (Cesium)
  56  => 'Ba',  # バリウム (Barium)
  57  => 'La',  # ランタン (Lanthanum)
  58  => 'Ce',  # セリウム (Cerium)
  59  => 'Pr',  # プラセオジム (Praseodymium)
  60  => 'Nd',  # ネオジム (Neodymium)
  61  => 'Pm',  # プロメチウム (Promethium)
  62  => 'Sm',  # サマリウム (Samarium)
  63  => 'Eu',  # ユウロピウム (Europium)
  64  => 'Gd',  # ガドリニウム (Gadolinium)
  65  => 'Tb',  # テルビウム (Terbium)
  66  => 'Dy',  # ジスプロシウム (Dysprosium)
  67  => 'Ho',  # ホルミウム (Holmium)
  68  => 'Er',  # エルビウム (Erbium)
  69  => 'Tm',  # ツリウム (Thulium)
  70  => 'Yb',  # イッテルビウム (Ytterbium)
  71  => 'Lu',  # ルテチウム (Lutetium)
  72  => 'Hf',  # ハフニウム (Hafnium)
  73  => 'Ta',  # タンタル (Tantalum)
  74  => 'W',   # タングステン (Tungsten)
  75  => 'Re',  # レニウム (Rhenium)
  76  => 'Os',  # オスミウム (Osmium)
  77  => 'Ir',  # イリジウム (Iridium)
  78  => 'Pt',  # 白金 (Platinum)
  79  => 'Au',  # 金 (Gold)
  80  => 'Hg',  # 水銀 (Mercury)
  81  => 'Tl',  # タリウム (Thallium)
  82  => 'Pb',  # 鉛 (Lead)
  83  => 'Bi',  # ビスマス (Bismuth)
  84  => 'Po',  # ポロニウム (Polonium)
  85  => 'At',  # アスタチン (Astatine)
  86  => 'Rn',  # ラドン (Radon)
  87  => 'Fr',  # フランシウム (Francium)
  88  => 'Ra',  # ラジウム (Radium)
  89  => 'Ac',  # アクチニウム (Actinium)
  90  => 'Th',  # トリウム (Thorium)
  91  => 'Pa',  # プロトアクチニウム (Protactinium)
  92  => 'U',   # ウラン (Uranium)
  93  => 'Np',  # ネプツニウム (Neptunium)
  94  => 'Pu',  # プルトニウム (Plutonium)
  95  => 'Am',  # アメリシウム (Americium)
  96  => 'Cm',  # キュリウム (Curium)
  97  => 'Bk',  # バークリウム (Berkelium)
  98  => 'Cf',  # カリフォルニウム (Californium)
  99  => 'Es',  # アインスタイニウム (Einsteinium)
  100 => 'Fm',  # フェルミウム (Fermium)
  101 => 'Md',  # メンデレビウム (Mendelevium)
  102 => 'No',  # ノーベリウム (Nobelium)
  103 => 'Lr',  # ローレンシウム (Lawrencium)
  104 => 'Rf',  # レニウム (Rutherfordium)
  105 => 'Db',  # ドブニウム (Dubnium)
  106 => 'Sg',  # シーボーギウム (Seaborgium)
  107 => 'Bh',  # ボーリウム (Bohrium)
  108 => 'Hs',  # ハッシウム (Hassium)
  109 => 'Mt',  # マイトネリウム (Meitnerium)
  110 => 'Ds',  # ダームスタチウム (Darmstadtium)
  111 => 'Rg',  # レントゲニウム (Roentgenium)
  112 => 'Cn',  # コペルニシウム (Copernicium)
  113 => 'Nh',  # ニホニウム (Nihonium)
  114 => 'Fl',  # フレロビウム (Flerovium)
  115 => 'Mc',  # モスコビウム (Moscovium)
  116 => 'Lv',  # リバモリウム (Livermorium)
  117 => 'Ts',  # テネシン (Tennessine)
  118 => 'Og',  # オガネソン (Oganesson)
);

# アウトプットフォーマットのマップ
my %modes = (
  1 => 'tddft',
  2 => 'anl_tddft',
  3 => 'xyz',
  4 => 'help',
);

# 汎関数のマップ
my %functionals = (
  1 => 'b3lyp',
  2 => 'ub3lyp',
  3 => 'cam-b3lyp',
  4 => 'cam-ub3lyp',
);

# 基底関数系のマップ
my %basis_sets = (
  1 => '6-31g(d)',
  2 => '6-31g(d,p)',
  3 => '6-311g(d)',
  4 => '6-311g(d,p)',
);

# ECP のマップ
my %ecps = (
  1 => 'not',
  2 => 'lanl2dz',
  3 => 'def2-svp',
);

# コンソール
print "\e[96m-------------------------------------------------------------------------------------\nThis is the Gaussian output processor for TD-DFT calculations.\n(Press 'Ctrl + C' to exit)\n-------------------------------------------------------------------------------------\e[0m\n";
my $term = Term::ReadLine->new("console");

# 設問と回答のバリデーションルール
my @questions = (
  { i => 0,
    q => "\n\e[92m✔ Select output format [1 to 4]\e[0m\n\e[1m1)\e[0m Generate TD-DFT input from [opt|opt-scan] output.\n\e[1m2)\e[0m Extract Rotatory Strengths from [td-scan|td-opt-scan] output.\n\e[1m3)\e[0m Extract Coordinates from [opt|opt-scan] output.\n\e[1m4)\e[0m Display help.\n>> ", 
    v => sub {
      $_[0] ne '' && exists $modes{$_[0]};
    }
  },
  { i => 1,
    q => "\n\e[92m✔ Enter the name of <out> file [opt|opt-scan]\e[0m\n>> ", 
    v => sub {
      my $file = $_[0];
      return -e $file && -r $file && -f $file && ($file =~ /\.(out|log)$/i);
    }
  },
  { i => 2,
    q => "\n\e[92m✔ Enter the name of [td-scan result <directory>|td-opt-scan result <out>]\e[0m\n>> ", 
    v => sub {
      my $source = $_[0];
      return -e $source && -r $source && (-d $source || (-f $source && ($source =~ /\.(out|log)$/i)));
    }
  },
  { i => 3,
    q => "\n\e[92m✔ Enter the name of <txt> file [tot_ener.txt]\e[0m\n>> ", 
    v => sub {
      my $file = $_[0];
      return -e $file && -r $file && -f $file && ($file =~ /\.(txt)$/i);
    }
  },
  { i => 4,
    q => "\n\e[92m✔ Enter a number of excited states to calculate [>= 1]\e[0m\n>> ", 
    v => sub {
      $_[0] ne '' && $_[0] =~ /^[1-9]+$/;
    }
  },
  { i => 5,
    q => "\n\e[92m✔ Select the functional to use [1 to 4]\e[0m\n\e[1m1)\e[0m B3LYP\n\e[1m2)\e[0m UB3LYP\n\e[1m3)\e[0m CAM-B3LYP\n\e[1m4)\e[0m CAM-UB3LYP\n>> ", 
    v => sub {
      $_[0] ne '' && exists $functionals{$_[0]};
    }
  },
  { i => 6,
    q => "\n\e[92m✔ Select the basis set to use [1 to 4]\e[0m\n\e[1m1)\e[0m 6-31G(d)\n\e[1m2)\e[0m 6-31G(d,p)\n\e[1m3)\e[0m 6-311G(d)\n\e[1m4)\e[0m 6-311G(d,p)\n>> ",
    v => sub {
      $_[0] ne '' && exists $basis_sets{$_[0]};
    } 
  },
  { i => 7,
    q => "\n\e[92m✔ Select the ECP to use, or Not to use [1 to 3]\e[0m\n\e[1m1)\e[0m Not to use\n\e[1m2)\e[0m LanL2DZ\n\e[1m3)\e[0m Def2-SVP\n>> ",
    v => sub {
      $_[0] ne '' && exists $ecps{$_[0]};
    } 
  },
  { i => 8,
    q => "\n\e[92m✔ Enter the atomic symbol which applies ECP [e.g. Pd]\e[0m\n>> ",
    v => sub {
      $_[0] ne ''
    } 
  },
  { i => 9,
    q => "\n\e[92m✔ Enter the atomic symbols which applies basis set, separating space [e.g. C H O]\e[0m\n>> ",
    v => sub {
      $_[0] ne ''
    } 
  },
);

my @inputs;
my $err_msg = "\e[91m[ERROR] Invalid input. Please try again:\e[0m\n";
my $qnum = undef;
my $is_ecp = 1;
my $is_xyz = 0;
my $is_anl_tddft = 0;
my $is_anl_scan_tddft = 0;
my $is_help = 0;

# 設問の分岐処理
TOP: foreach my $question (@questions) {
  my $i = $question->{i};
  my $q = $question->{q};
  my $v = $question->{v};

  if ($is_help == 1) {
    last TOP;
  }

  if ($is_ecp == 0) {
    last TOP;
  }

  # アウトプット形式
  questioner_format($i, $q, $v);

  # ソースファイル名またはディレクトリ
  if (defined $qnum and $i == $qnum) {
    questioner($i, $qnum, $q, $v);

    if ($is_xyz == 1) {
      last TOP;
    }
  }

  # ポテンシャルスキャンの txt ファイル
  if ($i == 3 and $is_anl_tddft == 1) {
    questioner($i, 3, $q, $v);
    last TOP;
  }

  # 励起状態の数
  questioner($i, 4, $q, $v);

  # 汎関数
  questioner($i, 5, $q, $v);

  # 基底関数系
  questioner($i, 6, $q, $v);

  # ECP
  questioner_ecp($i, $q, $v);

  # ECP を適用する重原子
  questioner($i, 8, $q, $v);

  # 基底関数を適用する原子セット
  questioner($i, 9, $q, $v);
}

# 設問ごとの値を保存
my $mode = undef;
my $file = undef;
my $tddft_source = undef;
my $scan_txt = undef;
my $nstat = undef;
my $functional = undef;
my $basis_set = undef;
my $ecp = undef;
my $ecp_atom = undef;
my $basis_set_atoms = undef;

while (my ($index, $value) = each @inputs) {
  if ($index == 0) {
    $mode = $modes{$value};
  } elsif ($index == 1) {
    $file = $value;
  } elsif ($index == 2) {
    $tddft_source = $value;
  } elsif ($index == 3) {
    $scan_txt = $value;
  } elsif ($index == 4) {
    $nstat = $value;
  } elsif ($index == 5) {
    $functional = $functionals{$value};
  } elsif ($index == 6) {
    $basis_set = $basis_sets{$value};
  } elsif ($index == 7) {
    $ecp = $ecps{$value};
  } elsif ($index == 8) {
    $ecp_atom = $value;
  } elsif ($index == 9) {
    $basis_set_atoms = $value;
  }
}

# メインルーチン
if ($mode eq 'anl_tddft' && -d $tddft_source) {
  processor_b($tddft_source, $scan_txt);
} elsif ($mode eq 'anl_tddft' && -f $tddft_source) {
  processor_c($tddft_source, $scan_txt);
} elsif ($mode eq 'help') {
  print "Please wait...\n";
  system("eog ~/tools/extract-usage.png");
} else {
  processor_a($file);
}


# サブルーチン

# 設問ごとの処理
sub questioner {
  my $input;
  my ($i, $j, $q, $v) = @_;
  
  if ($i == $j) {
    $input = $term->readline("$q");

    # validation
    if ($v->($input)) {
      $inputs[$i] = $input;
      return;
    } else {
      print $err_msg;
      questioner($i, $j, $q, $v);
    }
  }
}

# アウトプット形式
sub questioner_format {
  my $input;
  my ($i, $q, $v) = @_;

  if ($i == 0) {
    $input = $term->readline("$q");

    # validation
    if ($v->($input)) {
      $inputs[$i] = $input;

      if ($input == 2) {
        # ソースフォルダ名
        $qnum = 2;
      } else {
        # ソースファイル名
        $qnum = 1;
      }

      # td-dft anl の場合
      if ($input == 2) {
        $is_anl_tddft = 1;
      }

      # xyz フォーマットでのエクスポート
      if ($input == 3) {
        $is_xyz = 1;
      }

      # ヘルプ
      if ($input == 4) {
        $is_help = 1;
      }
    } else {
      print $err_msg;
      questioner_format($i, $q, $v);
    }
  }
}

# ECP
sub questioner_ecp {
  my $input;
  my ($i, $q, $v, $loop) = @_;

  if ($i == 7) {
    $input = $term->readline("$q");

    # validation
    if ($v->($input)) {
      $inputs[$i] = $input;

      if ($input == 1) {
        # ECP を使用しない
        $is_ecp = 0;
      } else {
        # ECP を使用する
        $is_ecp = 1;
      }
    } else {
      print $err_msg;
      questioner_ecp($i, $q, $v);
    }
  }
}

# 座標の処理
sub processed_coordinate {
  my ($coordinate) = @_;

  my $label_droped_coordinate = join("\n", map {
    # 行をスペースで分割
    my @columns = split(/\s+/, $_);
    
    # ラベル列を drop
    splice(@columns, 1, 1);
    
    # 残りのカラムをスペースで再結合
    join(" ", @columns);

  } split(/\n/, $coordinate));

  my $type_droped_coordinate = join("\n", map {
    # 行をスペースで分割
    my @columns = split(/\s+/, $_);
    
    # タイプ列を drop
    splice(@columns, 2, 1);
    
    # 残りのカラムを空白で再結合
    join(" ", @columns);

  } split(/\n/, $label_droped_coordinate));

  my $number_replaced_coordinate = join("\n", map {
    # 行をスペースで分割
    my @columns = split(/\s+/, $_);
    
    # 原子番号を元素記号に置換
    foreach my $row (@columns) {
      if (exists $atoms{$row}) {
        $row = $atoms{$row};
      }
    }
    
    # 残りのカラムをタブで再結合
    join("\t", @columns);

  } split(/\n/, $type_droped_coordinate));

  # 行ごとに分割して処理
  my @lines = split /\n/, $number_replaced_coordinate;

  # 行頭のタブを除去して、再度\nで結合する
  my $cleaned_coordinate = join("\n", map { s/^\t/ /r } @lines);
  
  return $cleaned_coordinate;
}


# TD-DFT インプットの生成
sub gen_tddft {
  my ($file, $coordinate, $count) = @_;

  my $tddft_file = $file;
  my $chk_file = $file;
  my $title = $file;

  $tddft_file =~ s/\.[^.]+$/\.%03d.tddft.com/;
  $chk_file =~ s/\.[^.]+$/\.%03d.tddft.chk/;
  $tddft_file = sprintf($tddft_file, $count);
  $chk_file = sprintf($chk_file, $count);
  $title =~ s/\.[^.]+$/\ | No.$count/;

  my $new_coordinate = processed_coordinate($coordinate);
  
  my $theory_setting;
  my $ecp_setting;

  if ($ecp eq 'not') {
    $theory_setting = "$functional/$basis_set";
    $ecp_setting = '';
  } else {
    $theory_setting = "$functional/genecp";
    $ecp_setting = "$ecp_atom 0\n$ecp\n****\n$basis_set_atoms 0\n$basis_set\n****\n\n$ecp_atom 0\n$ecp\n";
  }

  open my $fh, '>', $tddft_file or die "Can't open file $tddft_file: $!\n";

print $fh <<"EOF";
%chk=$chk_file
# td=(nstat=$nstat) $theory_setting

$title

0 1
$new_coordinate

$ecp_setting

EOF

  close $fh;
}

# TD-DFT 計算ファイル群の処理

# Rotatory Strength を抽出
sub anl_r_str {
  my ($block) = @_;
  my $row = "";

  foreach my $line (split /\n/, $block) {
    # 行をスペースで分割
    my @fields = split /\s+/, $line;

    # Rotatory Strength を取り出す
    my $r_length = $fields[5];
    $row .= "$r_length\t";
  }

  return $row;
}

# Oscillator Strength の算術平均を計算
sub aves_osc_strs {
  my ($all_osc_strs) = @_;
  my $avgs = "";

  # 列数を取得（列数は最初の行の要素数）
  my $cols = @{$all_osc_strs->[0]};

  # 行数を取得（行数は配列の要素数）
  my $rows = @$all_osc_strs;

  # 各列の合計を格納する配列
  my @col_sums = (0) x $cols;

  # 各列の合計を計算
  foreach my $row (@$all_osc_strs) {
    for (my $col = 0; $col < $cols; $col++) {
      $col_sums[$col] += $row->[$col];
    }
  }

  # 各列の平均を計算して表示
  for (my $col = 0; $col < $cols; $col++) {
    my $avg = $col_sums[$col] / $rows;
    $avgs .= "$avg\t";
  }

  return $avgs;
}  

# scan txt からの Scan Coordinate の抽出
sub extract_scan_coordinate {
  my ($scan_txt) = @_;
  my $coordinates = "";

  open my $fh, '<', $scan_txt or die "Can't open file $scan_txt: $!\n";
  while (my $line = <$fh>) {
    if ($line !~ /^#/ && $line =~ /^\s*(\-*[0-9.]+)/) {
      $coordinates .= "$1\n";
    }
  }

  close $fh;
  return $coordinates;
}

# txt 形式への書き込み
sub export_plot_txt {
  my ($dir, $txt) = @_;
  $dir =~ s/\///;

  my $txt_name = "$dir.plot.txt";

  open my $fh, '>', $txt_name or die "Can't open file $txt_name: $!\n";

print $fh <<"EOF";
$txt
EOF

  close $fh;
}

# g-factor の計算
sub get_g_factors {
  my ($etdm_coords, $mtdm_coords, $count_of_states) = @_;

  my @etdm_matrix = ();
  my @mtdm_matrix = ();
  my $g_factors = "";

  foreach my $etdm_coord (@$etdm_coords) {
    my @coords = split(/\n/, $etdm_coord);

    foreach my $row (@coords) {
      my @coord = split(/\s+/, $row);
      my @etdm_coord = ($coord[1], $coord[2], $coord[3], $coord[4]);
      push(@etdm_matrix, \@etdm_coord);
    }
  }

  foreach my $mtdm_coord (@$mtdm_coords) {
    my @coords = split(/\n/, $mtdm_coord);

    foreach my $row (@coords) {
      my @coord = split(/\s+/, $row);
      my @mtdm_coord = ($coord[1], $coord[2], $coord[3], $coord[4]);
      push(@mtdm_matrix, \@mtdm_coord);
    }
  }

  # g-factor を計算
  for my $i (0..$#etdm_matrix) {
    my $etdm_row = $etdm_matrix[$i];
    my $mtdm_row = $mtdm_matrix[$i];

    my $inner_product = 0;
    my $sq_etdm_norm = 0;
    my $sq_mtdm_norm = 0;

    for my $j (1..$#$etdm_row) {
      my $etdm_elm = $etdm_row->[$j];
      my $mtdm_elm = $mtdm_row->[$j];

      $inner_product += $etdm_elm * $mtdm_elm;
      $sq_etdm_norm += $etdm_elm * $etdm_elm;
      $sq_mtdm_norm += $mtdm_elm * $mtdm_elm;
    }

    my $g_factor = 4 * $inner_product / ($sq_etdm_norm + $sq_mtdm_norm);
    my $state_number = @$etdm_row[0];

    if ($state_number == $count_of_states) {
      $g_factors .= "$g_factor\n";
      next;
    }

    $g_factors .= "$g_factor\t";
  }

  return $g_factors;
}

# theta_etdm-mtdm の計算
sub get_theta_etdm_mtdms {
  my ($etdm_coords, $mtdm_coords, $count_of_states) = @_;

  my @etdm_matrix = ();
  my @mtdm_matrix = ();
  my $theta_etdm_mtdms = "";

  foreach my $etdm_coord (@$etdm_coords) {
    my @coords = split(/\n/, $etdm_coord);

    foreach my $row (@coords) {
      my @coord = split(/\s+/, $row);
      my @etdm_coord = ($coord[1], $coord[2], $coord[3], $coord[4]);
      push(@etdm_matrix, \@etdm_coord);
    }
  }

  foreach my $mtdm_coord (@$mtdm_coords) {
    my @coords = split(/\n/, $mtdm_coord);

    foreach my $row (@coords) {
      my @coord = split(/\s+/, $row);
      my @mtdm_coord = ($coord[1], $coord[2], $coord[3], $coord[4]);
      push(@mtdm_matrix, \@mtdm_coord);
    }
  }

  # theta_etdm_mtdm を計算
  for my $i (0..$#etdm_matrix) {
    my $etdm_row = $etdm_matrix[$i];
    my $mtdm_row = $mtdm_matrix[$i];

    my $inner_product = 0;
    my $sq_etdm_norm = 0;
    my $sq_mtdm_norm = 0;

    for my $j (1..$#$etdm_row) {
      my $etdm_elm = $etdm_row->[$j];
      my $mtdm_elm = $mtdm_row->[$j];

      $inner_product += $etdm_elm * $mtdm_elm;
      $sq_etdm_norm += $etdm_elm * $etdm_elm;
      $sq_mtdm_norm += $mtdm_elm * $mtdm_elm;
    }

    my $theta_etdm_mtdm = acos($inner_product / sqrt($sq_etdm_norm + $sq_mtdm_norm)) * 180 / 3.14159265359;
    my $state_number = @$etdm_row[0];

    if ($state_number == $count_of_states) {
      $theta_etdm_mtdms .= "$theta_etdm_mtdm\n";
      next;
    }

    $theta_etdm_mtdms .= "$theta_etdm_mtdm\t";
  }

  return $theta_etdm_mtdms;
}

# XYZ ファイルの生成
sub export_xyz {
  my ($file, $coordinate, $count) = @_;

  my $xyz_file = $file;
  my $title = $file;

  $xyz_file =~ s/\.[^.]+$/\.%03d.xyz/;
  $xyz_file = sprintf($xyz_file, $count);
  $title =~ s/\.[^.]+$/\ | No.$count/;

  my $new_coordinate = processed_coordinate($coordinate);
  my $number_of_atoms = () = $new_coordinate=~ /\n/g;
  $number_of_atoms += 1;

  open my $fh, '>', $xyz_file or die "Can't open file $xyz_file: $!\n";

print $fh <<"EOF";
$number_of_atoms

$title

$new_coordinate

EOF

  close $fh;
}

# プロセッサ A
sub processor_a {
  my ($file) = @_;

  # テンポラリー変数
  my $ln = 0;
  my $is_block = 0;
  my $count = 0;
  my $coordinate = "";
  my $stationary_coordinate;

  # メインルーチン
  open my $fh, '<', $file or die "Can't open file $file: $!\n";
  while (my $line = <$fh>) {
    
    if ($line =~ /Standard orientation/) {
      $ln = $.;
      $is_block = 1;
      print "Standard Orientation Found\n";
    } elsif ($. > $ln + 4 and $is_block == 1) {
      if ($line =~ /-----/) {
        $stationary_coordinate = $coordinate;
        $coordinate = "";
        $ln = $.;
        $is_block = 0;
      } else {
        $coordinate .= "$line";
      }
    } elsif ($line =~ /Optimization completed/) {
      $count++;
      print "\e[92m[💡Optimized Structure Found]\e[0m No.$count\n";
      
      if ($mode eq 'tddft') {
        gen_tddft($file, $stationary_coordinate, $count);
      } elsif ($mode eq 'xyz') {
        export_xyz($file, $stationary_coordinate, $count);
      }
    }
  }
  close $fh;

  my $dir_name = $file;
  my $ext;

  if ($mode eq 'tddft') {
    $ext = 'tddft.com';
  } elsif ($mode eq 'xyz') {
    $ext = 'xyz';
  }

  $dir_name =~ s/\./_/g;
  $dir_name =~ s/_[^_]+$/_$mode/;

  if ($count == 1) {
    my $file_name = $file;
    $file_name =~ s/\.[^.]+$/\.001.$ext/;

    print "\e[96m-------------------------------------------------------------------------------------\nComplete!\n1 file generated.\n\n";
    print "✔ Check generated file:\n% ls $file_name\n";
    print "-------------------------------------------------------------------------------------\e[0m\n";
  } else {
    my $wild_file_name = $file;
    $wild_file_name =~ s/\.[^.]+$/\.*.$ext/;

    system "mkdir $dir_name";
    system "mv $wild_file_name $dir_name/";

    print "\e[96m-------------------------------------------------------------------------------------\nComplete!\n$count files generated.\n\n";
    print "✔ Check generated files:\n% cd $dir_name/\n% ls\n";
    print "-------------------------------------------------------------------------------------\e[0m\n";
  }
}

# プロセッサ B
sub processor_b {
  my ($dir, $scan_txt) = @_;

  my $data = "";
  my $osc_data = "";
  my @all_osc_strs = ();
  my $count_of_states = 0;

  my @etdm_coords = ();
  my @mtdm_coords = ();

  opendir my $dh, $dir or die "Could not open directory '$dir': $!\n";

  # ファイルをソート
  my @entries = grep { !/^\./ } readdir($dh); 
  @entries = sort @entries;

  foreach my $entry (@entries) {
    # ファイルごとのすべての Oscillator Strength
    my @osc_strs = ();

    # ファイルのフルパス
    my $file_path = File::Spec->catfile($dir, $entry);

    # 拡張子が *.tddft.out または *.tddft.log のファイルを処理
    if (-f $file_path && $file_path =~ /\.[0-9]+\.tddft\.(out|log)$/) {

      # ファイルを開く
      open my $fh, '<', $file_path or die "Could not open '$file_path': $!\n";

      # ファイルの内容
      my $content = do { local $/; <$fh> };

      close $fh;

      # Oscillator Strength を抽出
      while ($content =~ /Excited State.*f=(.*?)\s+<S\*\*2>=/g) {
        my $osc_str = $1;
        push @osc_strs, $osc_str;
      }
      
      my $osc_row = join("\t", @osc_strs);
      $osc_data .= "$osc_row\n";
      push @all_osc_strs, \@osc_strs;

      # Rotatory Strength を抽出
      if ($content =~ /.*R\(length\)\n(.+?)\n\s+1\/2/s) {
        my $block = $1;
        my $row = anl_r_str($block);
        $data .= "$row\n";

        my @states = split("\t", $row);
        $count_of_states = @states;
      }

      # ETDM を抽出
      if ($content =~ /.*Osc\.\s*\n(.+?)\n\s+Ground to excited state transition velocity dipole moments/s) {
        my $block = $1;
        push @etdm_coords, $block;
      }

      # MTDM を抽出
      if ($content =~ /.*Z\s*\n(.+?)\n\s+Ground to excited state transition velocity quadrupole moments/s) {
        my $block = $1;
        push @mtdm_coords, $block;
      }

      print "\e[92m[💡Processed Output]\e[0m $entry\n";
    }
  }

  closedir $dh;

  $dir =~ s/\///;

  # Scan Coordinate を抽出
  my $coordinates = extract_scan_coordinate($scan_txt);

  # Oscillator Strength の算術平均を計算
  my $avgs = aves_osc_strs(\@all_osc_strs);

  # g-factor を取得
  my $g_factors = get_g_factors(\@etdm_coords, \@mtdm_coords, $count_of_states);

  # ETDM と MTDM のなす角を取得
  my $theta_etdm_mtdms = get_theta_etdm_mtdms(\@etdm_coords, \@mtdm_coords, $count_of_states);

  # 行ごとに分割してリストに格納
  my @rows = split("\n", $data);
  my @osc_rows = split("\n", $osc_data);
  my @g_factor_rows = split("\n", $g_factors);
  my @theta_etdm_mtdm_rows = split("\n", $theta_etdm_mtdms);
  my @coordinates = split("\n", $coordinates);

  # States
  my $header = join("\t", map { "S$_" } 1..$count_of_states);
  my $txt = "# Optical Values of $dir (Ground State)\n\n# Rotatory Strengths (erg esu cm Gauss^(-1))\nCoordinate\t$header\n";

  # それぞれの行をタブで分割（Rotatory Strength）
  while (my ($index, $row) = each @rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  $txt .= "\n# Oscillator Strength\nCoordinate\t$header\n";

  # それぞれの行をタブで分割（Oscillator Strength）
  while (my ($index, $row) = each @osc_rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  # Oscillator Strength の算術平均を出力
  $txt .= "\n# Average of Oscillator Strength\n$header\n$avgs\n";

  # g-factor を出力
  $txt .= "\n# g-factor\nCoordinate\t$header\n";
  
  # それぞれの行をタブで分割（g-factor）
  while (my ($index, $row) = each @g_factor_rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  # ETDM と MTDM のなす角を出力
  $txt .= "\n# Angle between ETDM and MTDM (degree)\nCoordinate\t$header\n";
  
  # それぞれの行をタブで分割（ETDM と MTDM のなす角）
  while (my ($index, $row) = each @theta_etdm_mtdm_rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  export_plot_txt($dir, $txt);

  print "\e[96m-------------------------------------------------------------------------------------\nComplete!\n1 file generated.\n\n";
  print "✔ Check generated file:\n% ls $dir.plot.txt\n\n";
  print "✔ Preview plot with state number:\n% scanplot $dir.plot.txt --state=<number>\n";
  print "-------------------------------------------------------------------------------------\e[0m\n";
}

# プロセッサ C
sub processor_c {
  my ($file, $scan_txt) = @_;

  # テンポラリー変数
  my $ln = 0;
  my $is_block = 0;
  my $is_r_str_block = 0;
  my $count = 0;

  my $data = "";
  my $osc_data = "";
  my @all_osc_strs = ();
  my @all_tmp_osc_strs = ();
  my $count_of_states = 0;

  my $tmp_osc_str = "";
  my $tmp_osc_strs = "";

  my $tmp_row = "";
  my $tmp_row_block = "";

  my $is_etdm_block = 0;
  my $etdm_block = "";
  my @etdm_coords = ();

  my $is_mtdm_block = 0;
  my $mtdm_block = "";
  my @mtdm_coords = ();

  # メインルーチン
  open my $fh, '<', $file or die "Can't open file $file: $!\n";
  while (my $line = <$fh>) {
    
    if ($line =~ /Standard orientation/) {
      $ln = $.;
      $is_block = 1;
      print "Standard Orientation Found\n";
    } elsif ($is_block == 1 and $line =~ /Maximum Force/) {
      push @all_tmp_osc_strs, "$tmp_osc_strs";
      $tmp_osc_strs = "";
      $is_block = 0;
    } elsif ($. > $ln and $is_block == 1) {
      if ($line =~ /Excited State.*f=(.*?)\s+<S\*\*2>=/) {
        my $tmp_osc_str = $1;
        $tmp_osc_strs .= "\t$tmp_osc_str";
      } 
      if ($line =~ /.*R\(length\)/) {
        $tmp_row = "";
        $tmp_row_block = "";
        $is_r_str_block = 1;
      } elsif ($line =~ /\s*1\/2\[\<0\|del/) {
        $is_r_str_block = 0;
        $tmp_row = anl_r_str($tmp_row_block);
      } elsif ($is_r_str_block == 1) {
        $tmp_row_block .= "$line";
      }
      if ($line =~ /\s*Ground to excited state transition electric dipole moments/) {
        $is_etdm_block = 1;
        $etdm_block = "";
      } elsif ($line =~ /\s*Ground to excited state transition velocity dipole moments/) {
        $is_etdm_block = 0;
      } elsif ($is_etdm_block == 1) {
        if ($line =~ /\s*state/) {
          next;
        }
        $etdm_block .= "$line";
      }
      if ($line =~ /\s*Ground to excited state transition magnetic dipole moments/) {
        $is_mtdm_block = 1;
        $mtdm_block = "";
      } elsif ($line =~ /\s*Ground to excited state transition velocity quadrupole moments/) {
        $is_mtdm_block = 0;
      } elsif ($is_mtdm_block == 1) {
        if ($line =~ /\s*state/) {
          next;
        }
        $mtdm_block .= "$line";
      }
    } elsif ($line =~ /Optimization completed/) {
      $count++;
      $ln = $.;

      print "\e[92m[💡Optimized Structure Found]\e[0m No.$count\n";
      
      if ($mode eq 'anl_tddft') {
        my $osc_row = $all_tmp_osc_strs[-1];
        
        $osc_data .= "$osc_row\n";
        my @osc_strs = split("\t", $osc_row);

        shift(@osc_strs) while $osc_strs[0] eq "";

        push @all_osc_strs, \@osc_strs;
        
        my $row = $tmp_row;
        $data .= "$row\n";

        my @states = split("\t", $row);
        $count_of_states = @states;

        push @etdm_coords, $etdm_block;
        push @mtdm_coords, $mtdm_block;
      }
    } elsif ($line =~ /Normal termination of Gaussian/) {
      $is_block = 0;
    }
  }
  close $fh;

  # Scan Coordinate を抽出
  my $coordinates = extract_scan_coordinate($scan_txt);

  # Oscillator Strength の算術平均を計算
  my $avgs = aves_osc_strs(\@all_osc_strs);

  # g-factor を取得
  my $g_factors = get_g_factors(\@etdm_coords, \@mtdm_coords, $count_of_states);

  # ETDM と MTDM のなす角を取得
  my $theta_etdm_mtdms = get_theta_etdm_mtdms(\@etdm_coords, \@mtdm_coords, $count_of_states);

  # 行ごとに分割してリストに格納
  my @rows = split("\n", $data);
  my @osc_rows = split("\n", $osc_data);
  my @g_factor_rows = split("\n", $g_factors);
  my @theta_etdm_mtdm_rows = split("\n", $theta_etdm_mtdms);
  my @coordinates = split("\n", $coordinates);

  # States
  my $header = join("\t", map { "S$_" } 1..$count_of_states);
  my $txt = "# Optical Values of $file (Excited State)\n\n# Rotatory Strength (erg esu cm Gauss^(-1))\nCoordinate\t$header\n";

  # それぞれの行をタブで分割（Rotatory Strength）
  while (my ($index, $row) = each @rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  $txt .= "\n# Oscillator Strength\nCoordinate\t$header\n";

  # それぞれの行をタブで分割（Oscillator Strength）
  while (my ($index, $row) = each @osc_rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  # Oscillator Strength の算術平均を出力
  $txt .= "\n# Average of Oscillator Strength\n$header\n$avgs\n";

  # g-factor を出力
  $txt .= "\n# g-factor\nCoordinate\t$header\n";
  
  # それぞれの行をタブで分割（g-factor）
  while (my ($index, $row) = each @g_factor_rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  # ETDM と MTDM のなす角を出力
  $txt .= "\n# Angle of ETDM and MTDM (degree)\nCoordinate\t$header\n";
  
  # それぞれの行をタブで分割（ETDM と MTDM のなす角）
  while (my ($index, $row) = each @theta_etdm_mtdm_rows) {   
    # それぞれの列をタブ区切りで出力
    $txt .= "$coordinates[$index]\t$row\n";
  }

  export_plot_txt($file, $txt);

  print "\e[96m-------------------------------------------------------------------------------------\nComplete!\n1 file generated.\n\n";
  print "✔ Check generated file:\n% ls $file.plot.txt\n\n";
  print "✔ Preview plot summary:\n% scanplot $file.plot.txt\n\n";
  print "✔ Preview plot with state number:\n% scanplot $file.plot.txt --state=<number>\n";
  print "-------------------------------------------------------------------------------------\e[0m\n";
}