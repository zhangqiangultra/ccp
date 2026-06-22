% 函数功能：
% 实时血流

clear all
clc
close all

currentPath = pwd;
parentDir = fileparts(fileparts(currentPath));
addpath(fullfile(parentDir, 'function'));
init;
%% 功能设置
imgshowflag = 1;                            %是否显示图像
savedataflag = 0;                           %是否保存数据

%% =====BC 参数=====
bparams.gain = 35;   % 0~100
bparams.drange = 50; % 
cparams.mode =0;   % 0:vel mode ,1:pow mode
cparams.gain = 50.0;%增益
cparams.doSmooth = 1;                          % 是否做平滑
cparams.gaussh = 7;
cparams.sigmah = 3.2;
cparams.gaussl = 5;
cparams.sigmal = 3.8;
cparams.flash_level = 5;                   % 闪烁抑制

%% 基本设置

lasting_time = 300;                         %扫查时长（秒）

prf = 800;                                  % 血流PRF
probe_name = 'L5-10';                       %探头名称
imagedepth = 0.04;                          %成像深度（米）
scanLine = 128;                             %扫描线数量
BF_pt   = 2048;                             %波束合成点数
BF_pt_deci = 1024;                          %降采样后点数
sysrate = 125e6;                            %采样率 支持125M
sos = 1540;                                 %声速
channel = 128;                              %通道
% 发射波形

txwave.pulse_type = 'rect';                 %发射波形：  rect:方波
txwave.pulse_level_type = {'A'};            %电平类型  A或B
txwave.pulse_cw_flag = 0;                   %连续波，1代表连续波
txwave.pulse_voltage = [30];                %发射电压 V
txwave.pulse_num = 2;                       %发射周期，支持1 1.5 ...
txwave.pulse_duration = [0.5,0.5];          %占空比，0.5代表半个周期
txwave.pulse_polarity = [1,-1];             %发射极性，1代表正波形，-1代表负波形
txwave.pulse_frequency = 5e6;               %发射频率 Hz


%  降采样参数, 1不降采样，最大32倍
DownsampleM =3;
%  32阶fir低通滤波器系数，不配置则不使用
FirFilter.Lp_coef = fir1(31, 15/(sysrate/2/1e6), 'low', hamming(32));
% % 数据放大，数值为0-6，0输出原数据，1放大2倍..最大64倍
FirFilter.Lp_amp = 6;
%  32阶带通滤波器系数，不配置则不使用
FirFilter.Bp_coef = fir1(31, [1 15]/(sysrate/DownsampleM/1e6/2), 'bandpass', hamming(32));
% % 数据放大，数值为0-6，0输出原数据，1放大2倍..最大64倍
FirFilter.Bp_amp = 6;

% 模拟增益
atgc_depth  = [0, 0.005, 0.01, 0.02, 0.03, 0.04,0.1];
atgc_value=[-24, -20, -16, -8, -4, 0,0];

% LNA : 支持15dB、18dB、21dB ,默认21dB
afe_value.lna_gain = 21;
% PGA : 支持18dB、21dB、24dB、27dB ,默认18dB
afe_value.pga_gain = 18;
% 抗混叠低通滤波AAF : 支持10MHz、15MHz、20MHz、30MHz、40MHz、50MHz、60MHz,默认30MHz.
% 10MHz下PGA不支持18dB和21dB，15MHz下PGA不支持18dB
afe_value.aaf = 30;
% 输入阻抗 : 支持50Ω、100Ω、 200Ω、 400Ω、。默认50Ω
afe_value.ipt_res = 50;
% 发射变迹
tx_aper.fs_win = { 'rect'};

% 解调参数
postprocess.demo_depth = [0 imagedepth];    %解调深度（与成像深度一致）
postprocess.demo_value = [txwave.pulse_frequency txwave.pulse_frequency];         %解调频率

% fir滤波器阶数、系数、窗函数
postprocess.filterdepth = [0.01 0.02];
postprocess.filtercoef = [0.096 0.096];

postprocess.filtertype = 'cheb';
postprocess.filterorder = 64;
postprocess.filteralpha = 0;
postprocess.Nz_deci = BF_pt_deci;

%% 配置参数
probe =  Probe_para(probe_name);
AcqConfig.Probe = probe;
AcqConfig.Tx.channel = channel;
AcqConfig.Tx.fs = sysrate;
AcqConfig.Tx.sos = sos;
AcqConfig.Tx.prf = prf;

if(exist('FirFilter'))
    AcqConfig.Tx.FirFilter = FirFilter;
end
if(exist('emit_time'))
    AcqConfig.Tx.Emit_time = emit_time;
end

if(exist('stop_time'))
    AcqConfig.Tx.Stop_time = stop_time;
end



AcqConfig.Tx.DownsampleM = DownsampleM;
AcqConfig.Tx.Pulse = txwave;
if(exist('atgc_depth')||exist('atgc_value'))
    AcqConfig.Tx.ATGC.depth = atgc_depth;
    AcqConfig.Tx.ATGC.value = atgc_value;
end
if(exist('afe_value'))
    AcqConfig.Tx.AFE = afe_value;
end
AcqConfig.Tx.fs_win = tx_aper.fs_win;
AcqConfig.Tx.aperture = channel;
%% 采样点数
AcqConfig.Tx.steer = linspace(-15,15,15);
[Rx,Revpt,Revdepth ]= SampleInfo(AcqConfig,imagedepth);
sampt = round(imagedepth/(AcqConfig.Tx.sos/AcqConfig.Tx.fs/2));

AcqConfig.Rx = Rx;
AcqConfig.Rx.Revpt =Revpt;
AcqConfig.Rx.Revdepth = Revdepth;

AcqConfig.Rx.aperture.js_win = hamming(256)';
AcqConfig.Rx.aperture.fn_depth = [0 0.04];
AcqConfig.Rx.aperture.min_Aper = 16;
AcqConfig.Rx.aperture.max_Aper = 128;

AcqConfig.Rx.aperture.fn_value = [1.2 1];
sampt = round(imagedepth/(AcqConfig.Tx.sos/AcqConfig.Rx.fs/2));

revloc.z_num = BF_pt;
revloc.start_z =  AcqConfig.Probe.image_start ;
revloc.step_z =AcqConfig.Tx.sos/AcqConfig.Rx.fs/2*AcqConfig.Rx.Revpt/BF_pt;


revloc.start_x = AcqConfig.Probe.element_pos.x(1);
revloc.step_x = (AcqConfig.Probe.element_pos.x(end)-AcqConfig.Probe.element_pos.x(1))/(scanLine-1);
revloc.x_num = scanLine;

AcqConfig.Rx.post_process_fs = AcqConfig.Tx.sos/revloc.step_z/2;
[pw_tx_angle,prt,prt_rem] = calcAdaptiveUltrafast(AcqConfig);
AcqConfig.Tx.Steering = pw_tx_angle;

[tx_info,scanlist,rx_info]=  Tx_beamform_PlaneWave(pw_tx_angle,AcqConfig,revloc);
AcqConfig.Tx.sequence = tx_info.sequence;
scanlist = CScanList(scanlist,prt,prt_rem);
ScanList = scanlist;

AcqConfig.Rx.sequence = rx_info.sequence;
%平面波成像区域
startx = revloc.start_x;
startz = revloc.start_z;
setpx = revloc.step_x;
setpz = revloc.step_z;

Nx = revloc.x_num;
Nz = revloc.z_num;

x_axis = (0:setpx:(Nx-1) * setpx)+ startx;
z_axis = (0:setpz:(Nz-1) * setpz)+ startz;

AcqConfig.Rx.rev_line.x = x_axis;
AcqConfig.Rx.rev_line.z = z_axis;

[x_grid, z_grid] = meshgrid(x_axis,z_axis);
f_number = 1.5;
x_grid = reshape(x_grid,[Nz*Nx,1]);
z_grid = reshape(z_grid,[Nz*Nx,1]);


f_mask = zeros(Nx*Nz,probe.element_num);
for i = 1:probe.element_num
    f_mask(:,i) = z_grid./abs(x_grid - probe.element_pos.x(i))/2 > f_number;
end
AcqConfig.Rx.apod  = f_mask;

x_grid_all = single(repmat(x_grid,length(ScanList),1));
z_grid_all = single(repmat(z_grid,length(ScanList),1));


bfparams.Nx = Nx;
bfparams.Nz_bf = BF_pt;
bfparams.Nz_deci = BF_pt_deci;
bfparams.Nz = BF_pt;
bfparams.x_axis = x_axis;
bfparams.z_axis = z_axis;
bfparams.x_grid = x_grid;
bfparams.z_grid = z_grid;
bfparams.x_grid_all = x_grid_all;
bfparams.z_grid_all = z_grid_all;
bfparams.scanLine = scanLine;
bfparams.lasting_time = lasting_time;

if savedataflag~=0
    folderPath = uigetdir('', 'Select Folder to Save');
    if folderPath ~= 0
        currentTime = datetime('now');
        currentTime.Format = 'yyyyMMddHHmmss';
        timeStr = char(currentTime);  % 将 datetime 转换为 char 类型的字符串
        fullPath = fullfile(folderPath, timeStr);
        if ~exist(fullPath,'dir')
            mkdir(fullPath);
        end
        disp("数据保存路径为："+fullPath)

    
        [NumsPerFile,File_nums,frameN,prf] = DAQ_RealTime_ColorFlow(AcqConfig,postprocess,scanlist,lasting_time,fullPath,savedataflag,imgshowflag,bfparams,bparams,cparams);

    
        filename_para = strcat(fullPath, '\Param.txt');
        fileID = fopen(filename_para,'w');
        fprintf(fileID, 'frames: %d\n',frameN);
        fprintf(fileID, 'prf: %d\n',prf);
        fprintf(fileID, 'numsPerFile: %d\n',NumsPerFile);
        fprintf(fileID, 'fs: %d\n',AcqConfig.Rx.fs);
        fprintf(fileID, 'sampleNum: %d\n',AcqConfig.Rx.Revpt);
        fprintf(fileID, 'scanLine: %d\n',length(AcqConfig.Rx.rev_line.x));    
        fprintf(fileID, 'imageDepth: %f\n',imagedepth);
        fprintf(fileID, 'steer: ');
        for i = 1:size(pw_tx_angle,2)
            fprintf(fileID, '%f ',pw_tx_angle(i));
        end
        fprintf(fileID, '\n');
        fprintf(fileID, 'focus: %f\n',-1);
        fprintf(fileID, 'start_x step_x start_z step_z: ');
        for i = 1:length(AcqConfig.Rx.rev_line.x)
            fprintf(fileID, '%f ',AcqConfig.Rx.rev_line.x(i),AcqConfig.Rx.sequence{1, 1}.step_x,...
                AcqConfig.Rx.sequence{1, 1}.start_z,AcqConfig.Rx.sequence{1, 1}.step_z);
        end
        fprintf(fileID, '\n');

        fprintf(fileID, 'cstartoffset: ');
        for i = 1:size(AcqConfig.Tx.sequence,2)
            fprintf(fileID, '%f ',AcqConfig.Rx.sequence{1, i}.cstartoffset);
        end
        fclose(fileID);
        disp("参数文件保存路径为："+filename_para)
    
    end

else
    fullPath = [];

    [NumsPerFile,File_nums,frameN,prf] = DAQ_RealTime_ColorFlow(AcqConfig,postprocess,scanlist,lasting_time,fullPath,savedataflag,imgshowflag,bfparams,bparams,cparams);
end



