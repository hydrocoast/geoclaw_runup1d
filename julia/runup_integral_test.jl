# ##############################################################################
# Julia言語による津波遡上の決定論的計算例（初期条件プロット付き）
#
# 概要:
# Synolakis (1987) の解析解に基づき、孤立波の遡上過程を計算します。
# このバージョンでは、遡上高の時間変化のプロットに加え、
# 計算の初期条件である海底地形と初期波形を可視化するプロットを追加します。
#
# 必要なパッケージ:
# - QuadGK: 高精度の数値積分
# - SpecialFunctions: ベッセル関数など
# - CairoMakie: プロット
#
# インストール方法 (Julia REPLで実行):
# using Pkg
# Pkg.add()
# ##############################################################################

using QuadGK
using SpecialFunctions
using CairoMakie
using LaTeXStrings
using Printf

# --------------------------------------------------------------------------
# 1. 物理パラメータの設定
# --------------------------------------------------------------------------
println("Setting up physical parameters...")

# 基本パラメータ
const g = 9.81          # 重力加速度 (m/s^2)
h0 = 100.0        # 沖合の一定水深 (m)
slope = 1/10     # 海岸の勾配 (無次元)
H = 1.0          # 沖合の孤立波の波高 (m)
X1 = (h0 / slope)*1.50   # t=0 における孤立波の初期位置 (m)

# 派生パラメータ
X0 = h0 / slope                               # 斜面の麓の位置 (m)
X0_nd = X0 / h0                       # = cotβ（無次元）
X1_nd = X1 / h0                       # 初期中心の無次元位置
#c_wave = sqrt(g * (h0 + H))                   # 孤立波の波速 (m/s)
c = sqrt(g * h0)                             # 基準波速 (m/s)
const γ_soliton = sqrt(3 * H / (4 * h0^3))    # 孤立波の形状パラメータ （1/m）
const α_synolakis = π / (2 * γ_soliton * h0)        # a = π/(2 κ d)（無次元）

tmax_soliton = 1/c * (X1 + X0 - (0.366/γ_soliton))  # 孤立波が斜面に到達するまでの時間 (s)
R = h0 * 2.831* sqrt(1/slope) *  (H/h0)^(5/4)     # Synolakis (1987) の最大遡上高予測 (m)

# パラメータを辞書にまとめる
params = Dict(
    :h0 => h0,
    :slope => slope,
    :H => H,
    :X0 => X0,            # 物理座標（主に図のために残す）
    :X1 => X1,            # 物理座標（主に図のために残す）
    :X0_nd => X0_nd,      # 無次元 X0
    :X1_nd => X1_nd,      # 無次元 X1
    #:c_wave => c_wave,
    :γ_soliton => γ_soliton,
    :α_synolakis => α_synolakis
)


# --------------------------------------------------------------------------
# 2. 遡上積分および初期条件の関数定義
# --------------------------------------------------------------------------

# 遡上積分の被積分関数
function runup_integrand(k::Float64, t::Float64, p::Dict)
    if k == 0.0
        return 0.0 + 0.0im
    end
    # 無次元時間と無次元位相
    t_nd = t * sqrt(g / p[:h0])                    # c=1 に対応
    phase = p[:X1_nd] - p[:X0_nd] - t_nd  # 位相の符号を修正（2024-06-20）
    csch_term = 1.0 / sinh(k * p[:α_synolakis])    # a, k は無次元
    numerator = k * csch_term * exp(im * k * phase)
    denominator = besselj0(2 * k * p[:X0_nd]) - im * besselj1(2 * k * p[:X0_nd])
    return numerator / denominator
end

# 指定された時刻 t における遡上高 R(t) を計算する関数
function calculate_runup(t::Float64, p::Dict)
    integral_val, err = quadgk(k -> runup_integrand(k, t, p), -Inf, Inf, rtol=1e-8)
    # η(t) = d * [ (4/(3π)) ∫ … dk ]  （式(3.3)）
    runup_height = p[:h0] * (4/(3π)) * real(integral_val)    

    # Kmax ~ O(1/a) で指数減衰を活かす（Synolakis 3.3 の収束議論に対応）
    #fac  = 60.0                       # 40–80 の範囲で収束確認用に調整可
    #Kmax = fac / p[:α_synolakis]      # a = π/(2y)（無次元）→ Kmax は無次元

    #integral_pos, err = quadgk(k -> real(runup_integrand(k, t, p)),
    #                           0.0, Kmax; rtol=1e-7, atol=1e-10, maxevals=10^7)
    #integral_val = 2.0 * integral_pos
    #runup_height = p[:h0] * (4/(3π)) * integral_val    

    return runup_height
end

# 初期波形（孤立波）を計算する関数
function initial_wave_profile(x::Float64, p::Dict)
    return p[:H] * sech(p[:γ_soliton] * (x - p[:X1]))^2
end

# 海底地形を計算する関数
function bathymetry_profile(x::Float64, p::Dict)
    if x >= p[:X0]
        return -p[:h0]  # 沖合の一定水深
    else
        return -p[:slope] * x # 一定勾配の斜面
    end
end


# --------------------------------------------------------------------------
# 3. 計算の実行
# --------------------------------------------------------------------------
println("Starting runup calculation over time...")

# 計算する時間範囲とステップ
t_start = 0.0
t_end = round(tmax_soliton * 2.0, sigdigits=2)  # 孤立波が斜面に到達してから十分な時間まで
t_steps = 201
t_vec = range(t_start, t_end, length=t_steps)

# 各時刻での遡上高を格納する配列
R_vec = zeros(t_steps)

# 各時刻で遡上高を計算
for (i, t) in enumerate(t_vec)
    print("\rCalculating for t = $(round(t, digits=2)) s... ($(i)/$(t_steps))")
    R_vec[i] = calculate_runup(t, params)
end

println("\nCalculation finished. Plotting results...")

# --------------------------------------------------------------------------
# 4. プロットの作成
# --------------------------------------------------------------------------
fig = Figure(; size = (800, 800)) # 2つのプロットを縦に並べるために高さを確保

# --- 上段：初期条件のプロット ---
ax_setup = Axis(fig[1, 1],
    title = "Initial Condition (t = 0 s)",
    xlabel = "Offshore Distance x (m)",
    ylabel = "Elevation z (m)",
    xlabelsize = 16,
    ylabelsize = 16,
    titlesize = 18
)

x_domain = range(-0.1*X0, 2.0*X0, length=501)
# 初期水面形
water_surface = [x > 0.0 ? initial_wave_profile(x, params) : NaN for x in x_domain]
#water_surface = [initial_wave_profile(x, params) for x in x_domain]
# 海底地形
seabed = [bathymetry_profile(x, params) for x in x_domain]

lines!(ax_setup, x_domain, water_surface, color=:blue, linewidth=2, label="Initial wave η(x,0)")
# 海底を塗りつぶして表現
band!(ax_setup, x_domain, -h0, seabed, color=(:brown, 0.3), label="Seabed")
# 静水面
hlines!(ax_setup, [0.0], color = :gray, linestyle = :dash, label = "Still Water Level")

# 凡例を追加
axislegend(ax_setup, position = :lb)
ylims!(ax_setup, -1.1*h0, 0.1*h0) # y軸の表示範囲を調整

# --- 下段：遡上高の時系列プロット ---
ax_runup = Axis(fig[2, 1],
    title = "Tsunami runup on a plane slope (Synolakis, 1987)",
    xlabel = "Time (s)",
    ylabel = "Elevation at shoreline (m)",
    xlabelsize = 16,
    ylabelsize = 16,
    titlesize = 18
)

lines!(ax_runup, t_vec, R_vec, color = :blue, linewidth = 2, label = "Runup R(t)")
hlines!(ax_runup, [0.0], color = :black, linestyle = :dash, label = "Still Water Level")

# 最大遡上高をプロット上に表示
max_runup, max_idx = findmax(R_vec)
scatter!(ax_runup, [t_vec[max_idx]], [max_runup], color = :red, marker = :star5, markersize = 15)
text!(ax_runup, t_vec[max_idx], max_runup,
    text = " Max elevation: $(round(max_runup, sigdigits=3)) m",
    align = (:left, :bottom),
    color = :red,
    fontsize = 14
)
axislegend(ax_runup, position = :lt)

# プロットを保存
figname = @sprintf("tsunami_runup_Synolakis1987_cot%03d.png", round(Int, 1/params[:slope]))
save(figname, fig)

println("Plot saved as $figname")
display(fig)
