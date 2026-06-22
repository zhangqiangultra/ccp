function init

if libisloaded('DAQ_SDK')
    try
        calllib('DAQ_SDK', 'stop_sample'); 
        calllib('DAQ_SDK', 'close_SDK');  
    catch
    end
    unloadlibrary('DAQ_SDK');
end

if libisloaded('US_GPU_FOUCSWAVE')
    unloadlibrary('US_GPU_FOUCSWAVE');
end
if libisloaded('US_GPU')
    unloadlibrary('US_GPU');
end
if libisloaded('US_APP')
    unloadlibrary('US_APP');
end
try
    calllib('US_ACQ_ALG_SDK', 'stop_sample');
    calllib('US_ACQ_ALG_SDK', 'close_SDK');
catch
end


if libisloaded('US_ACQ_ALG_SDK')
    unloadlibrary('US_ACQ_ALG_SDK');
    disp('US_ACQ_ALG_SDK 库已卸载');
end
close all force;
fclose('all');
clear all;      
clear global;   
clear mex;     
clear classes; 

try
    g = gpuDevice();
    reset(g);
catch
    disp('GPU 重置跳过或未找到支持的 GPU');
end

try daqreset; catch; end   
try instrreset; catch; end  

clc;
disp('=======================================');
disp('环境初始化完成！');
disp('=======================================');
end