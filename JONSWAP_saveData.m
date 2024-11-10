% 参数初始化
gamma = 3.3;         % 谱峰因子
Hs = 9.6;            % 有义波高
Tp = 15;             % 谱峰周期
nw = 100;            % 频率分段数
f_min = 0.28 / (2 * pi); % 最小频率（Hz）
f_max = 1.27 / (2 * pi); % 最大频率（Hz）

% 初始化频率和谱值数组
f = linspace(f_min, f_max, nw); % 频率以 Hz 为单位
s_f = zeros(1, nw);

% 计算JONSWAP谱值（频率以 Hz 为单位）
for i = 1:nw
    s_f(i) = JONSWAP_Hz(f(i), Hs, Tp, gamma);
end

% 转换为圆频率（rad/s）
omega = 2 * pi * f;       % 将频率（Hz）转换为圆频率（rad/s）
s_omega = s_f / (2 * pi); % 将能量谱从 Hz 转换为 rad/s 单位

% 时间序列
dt = 0.1;                  % 时间步长（秒）
time_series = 0:dt:200;  % 时间序列（秒）

% 波浪生成参数
delta_f = (f_max - f_min) / nw; % 频率增量
a = sqrt(2 * s_f * delta_f);    % 每个频率分量的振幅

% 随机相位
theta = 2 * pi * rand(1, nw);

% 计算波浪时历
wave_height = zeros(1, length(time_series));
for t = 1:length(time_series)
    yeta = 0;
    for i = 1:nw
        yeta = yeta + a(i) * cos(2 * pi * f(i) * time_series(t) + theta(i));
    end
    wave_height(t) = yeta;
end

% 绘图
figure(1);
% 绘制波浪时历曲线
% subplot(3,1,1); % 创建3行1列的子图，第1个子图
plot(time_series, wave_height, 'k-', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Wave Height (m)');
title('Irregular Wave Time Series');
grid on;

figure(2);
% 绘制频谱图 (单位：Hz)
% subplot(3,1,2); % 第2个子图
plot(f, s_f, 'b-', 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Spectral Density (m^2/Hz)');
title('JONSWAP Spectrum (Frequency in Hz)');
grid on;

figure(3);
% 绘制频谱图 (单位：rad/s)
% subplot(3,1,3); % 第3个子图
plot(omega, s_omega, 'r-', 'LineWidth', 1.5);
xlabel('Angular Frequency (rad/s)');
ylabel('Spectral Density (m^2/(rad/s))');
title('JONSWAP Spectrum (Angular Frequency in rad/s)');
grid on;

% 将波浪时历数据保存到 Excel 文件
wave_data = table(time_series', wave_height', 'VariableNames', {'Time_s', 'Wave_Height_m'});
writetable(wave_data, 'Wave_Spectrum_Data.xlsx', 'Sheet', 'Wave_Time_Series');

% 将频谱数据（Hz）保存到 Excel 文件
spectrum_data_Hz = table(f', s_f', 'VariableNames', {'Frequency_Hz', 'Spectral_Density_m2PerHz'});
writetable(spectrum_data_Hz, 'Wave_Spectrum_Data.xlsx', 'Sheet', 'Spectrum_Hz', 'WriteMode', 'overwrite');

% 将频谱数据（rad/s）保存到 Excel 文件
spectrum_data_rad = table(omega', s_omega', 'VariableNames', {'Angular_Frequency_radPerS', 'Spectral_Density_m2PerRadPerS'});
writetable(spectrum_data_rad, 'Wave_Spectrum_Data.xlsx', 'Sheet', 'Spectrum_radPerS', 'WriteMode', 'append');

disp('数据已保存到 Wave_Spectrum_Data.xlsx 文件中。');

% 定义 JONSWAP 计算函数（频率以 Hz 为单位）
function Sf = JONSWAP_Hz(f, Hs, Tp, R)
    pi = 4.0 * atan(1.0);
    fp = 1 / Tp;
    Bj = 0.06238 * (1.094 - 0.01915 * log(R)) / (0.230 + 0.0336 * R - 0.185 / (1.9 + R));
    alpha = Bj * Hs ^ 2 / Tp ^ 4;
    beta = -1.25 / Tp ^ 4;
    if f <= fp
        q = 0.07;
    else
        q = 0.09;
    end
    mu = exp(-(f * Tp - 1.0) ^ 2 / (2.0 * q ^ 2));
    Sf = alpha * f ^ (-5) * exp(beta * f ^ (-4)) * R ^ mu; % 能量谱密度 (m^2/Hz)
end
