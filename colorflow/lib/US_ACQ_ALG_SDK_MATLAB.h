/*
 * US_ACQ_ALG_SDK_MATLAB.h - MATLAB loadlibrary / calllib header
 *
 * Ship with US_ACQ_ALG_SDK.dll. Keep in sync with src/daq/DAQ_SDK.h.
 * Differences vs DAQ_SDK.h:
 *   - DAQParameter uses typedef struct { ... } DAQParameter for MATLAB.
 *   - initializeULMGPU trailing flags use int (0/1) instead of bool.
 */

#pragma once
#include <stdint.h>

#ifdef US_ACQ_ALG_SDK_EXPORTS
#define US_ACQ_ALG_SDK_API __declspec(dllexport)
#else
#define US_ACQ_ALG_SDK_API __declspec(dllimport)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#pragma pack(push, 1)
typedef struct DAQParameter
{
    int frame_num_in_callback;
    int OpticalPort;
    int ADC_fs;
    int DownSampleM;
    int sample_num;
    int sensor_num;
    unsigned short trigger_mode;
    unsigned short trigger_fs;
    unsigned short trigger_delay;
    unsigned short voltageA;
    unsigned short voltageB;
    unsigned short voltageC;
    unsigned short voltageD;
    unsigned short voltageE;
    unsigned short voltageF;
    unsigned int FilterLPByPass;
    unsigned int FilterLPShiftBit;
    unsigned int FilterBPByPass;
    unsigned int FilterBPShiftBit;
    unsigned int ECG_SAMPLE_EN;
    unsigned int Encoder_Scan_En;
} DAQParameter;
#pragma pack(pop)

US_ACQ_ALG_SDK_API void open_SDK();
US_ACQ_ALG_SDK_API int setDAQ(DAQParameter param);
US_ACQ_ALG_SDK_API int start_sample();
US_ACQ_ALG_SDK_API int SetIsSave(int isSave, const char* directoryName);
US_ACQ_ALG_SDK_API int getOneFrameData(int8_t** data);
US_ACQ_ALG_SDK_API int getOneRFData(float* data, int* frameid, uint32_t* width, uint32_t* height);
US_ACQ_ALG_SDK_API int stop_sample();
US_ACQ_ALG_SDK_API int close_SDK();

US_ACQ_ALG_SDK_API void set_afe_reg(int addr, int val);
US_ACQ_ALG_SDK_API void set_tx_registers(uint32_t addr, uint32_t val);
US_ACQ_ALG_SDK_API void set_tx_arg(int tx_index, int inner_index, uint32_t addr, uint32_t val);
US_ACQ_ALG_SDK_API void set_tvg_arg(int tvg_val_us, int tvg_val_pact, int tvg_attenuation_time);
US_ACQ_ALG_SDK_API void set_prt_arg(int mode_type, int scanlenth, uint32_t triggerdelay, uint32_t scantime, uint32_t repeatNum);
US_ACQ_ALG_SDK_API void set_sync_pulse_width_arg(uint8_t index, uint8_t value);
US_ACQ_ALG_SDK_API void set_sync_trigger_delay_arg(uint8_t index, uint16_t value);
US_ACQ_ALG_SDK_API void set_sync_status(uint8_t mux, uint8_t bank);
US_ACQ_ALG_SDK_API void set_scanHead(int frame, int sln, int mode_type, int pack_size, int beam, int pulse_type, int frame_end, int frame_start, int scan_len);
US_ACQ_ALG_SDK_API void set_afe_mode(int mode_num, int mode_id, int profile_id, int line_num, int line_start_id);
US_ACQ_ALG_SDK_API void set_afe_profile(int profile_num, int profile_id, int val[], int vallen);
US_ACQ_ALG_SDK_API void set_afe_filter(int filter_num, int filter_id, int val0, int val1, int val2, int val3, int val4, int val5, int val6, int val7);
US_ACQ_ALG_SDK_API void set_LPCoef(int index, uint32_t value);
US_ACQ_ALG_SDK_API void set_BPCoef(int index, uint32_t value);
US_ACQ_ALG_SDK_API void set_device_en(uint8_t CMUT_BIAS, uint8_t P_D3V3_EN, uint8_t P_PRE_EN);

/* GPU session is a DLL singleton; any initialize* replaces the previous session. */

US_ACQ_ALG_SDK_API int initializeBeamformingGPU(
    const char* wave_type,
    int Demod_AFE_Dynamic,
    int image_count,
    int FH,
    int rx_num,
    int Channel,
    int RxChannel,
    int element_num,
    float element_pitch,
    int sample_num,
    int bf_sample_num,
    int BeamN,
    int ValidBeamN,
    float sos,
    float fs,
    float B_fs,
    float focus_depth,
    float Js_Min_Aper,
    float Js_Max_Aper,
    float Js_Max_Fn,
    float Js_Min_Fn,
    float Js_Fn_depth,
    float Js_fn_setp,
    float Js_Fn_value,
    float* allBeamN, int allBeamN_size,
    float* allValidBeamN, int allValidBeamN_size,
    float* allBeamNIndex, int allBeamNIndex_size,
    float* allbfframeIndex, int allbfframeIndex_size,
    float* allBFtype, int allBFtype_size,
    float* allfsfocus, int allfsfocus_size,
    float* allfslinex, int allfslinex_size,
    float* allfslinez, int allfslinez_size,
    float* Steering, int Steering_size,
    float* plae_wave_steer, int plae_wave_steer_size,
    float* beamx, int beamx_size,
    float* beamz, int beamz_size,
    float* cstartoffset, int cstartoffset_size,
    float* Jswin, int Jswin_size,
    float* udm_L, int udm_L_size,
    float* fs_focus,
    int fs_focus_size,
    float* channel_map, int channel_map_size,
    float* element_pos_xz, int element_pos_xz_size,
    float Demod_MaxPoint,
    float blackholethre,
    float ImageStart,
    float UI_depth,
    float* Demodulate_FreDepth,
    float* Demodulate_FreValue,
    float* Demod_FilterDepth,
    float* Demod_FilterCutoff,
    const char* Demodulate_FilterType,
    int Demod_OrderFactor,
    float wininfo_alpha,
    int dr_input,
    int dr_output,
    int dr_drange,
    int axialGain_size,
    float* axialGain,
    float xuanniuGain);  /* UI 旋钮增益 0~100，同 enumBmodeParamSetGain；非 dB */

US_ACQ_ALG_SDK_API int initializespectralGPU(
    int prf,
    int numperfile,
    int buffer_num,
    int fft_period,
    int lag,
    float t_axis_span,
    int t_idx,
    int t_buffer_idx,
    const char* probe_type,
    int Demod_AFE_Dynamic,
    int rx_num,
    int Channel,
    int RxChannel,
    int element_num,
    float element_pitch,
    int adc_head,
    int bf_sample_num,
    int BeamN,
    float sos,
    float fs,
    float fc,
    float focus_depth,
    float Js_Min_Aper,
    float Js_Max_Aper,
    float Js_Max_Fn,
    float Js_Min_Fn,
    float Js_Fn_depth,
    float Js_fn_setp,
    float Js_Fn_value,
    float Fsweep_step,
    float Fsweep_start,
    float Fsweep_end,
    float Roi_start,
    float* plae_wave_steer, int plae_wave_steer_size,
    float* beamx, int beamx_size,
    float* beamz, int beamz_size,
    float* cstartoffset, int cstartoffset_size,
    float* Jswin, int Jswin_size,
    float* udm_L, int udm_L_size,
    float* fs_focus, int fs_focus_size,
    float* channel_map, int channel_map_size,
    float* element_pos_xz, int element_pos_xz_size,
    float* filter_coef, int filter_size,
    float* rx_apod, int rx_apod_size,
    float* rx_delay, int rx_delay_size,
    float* tx_delay, int tx_delay_size,
    float* x_loc_all, float* z_loc_all, int loc_num,
    float* iir_b, float* iir_a, float* iir_zi, int iir_order);

US_ACQ_ALG_SDK_API int initializeAllGPU(
    const char* probe_type,
    int Demod_AFE_Dynamic,
    int rx_num,
    int Channel,
    int RxChannel,
    int element_num,
    float element_pitch,
    int adc_head,
    int bf_sample_num,
    int BeamN,
    float sos,
    float fs,
    float focus_depth,
    float Js_Min_Aper,
    float Js_Max_Aper,
    float Js_Max_Fn,
    float Js_Min_Fn,
    float Js_Fn_depth,
    float Js_fn_setp,
    float Js_Fn_value,
    float Fsweep_step,
    float Fsweep_start,
    float Fsweep_end,
    float Roi_start,
    float* plae_wave_steer, int plae_wave_steer_size,
    float* beamx, int beamx_size,
    float* beamz, int beamz_size,
    float* cstartoffset, int cstartoffset_size,
    float* Jswin, int Jswin_size,
    float* udm_L, int udm_L_size,
    float* fs_focus, int fs_focus_size,
    float* channel_map, int channel_map_size,
    float* element_pos_xz, int element_pos_xz_size,
    int ValidBeamN,
    int rx_line_size,
    float* rx_line,
    float SmoothCoef,
    float UI_FrameRate,
    float B_fs,
    int Demod_MaxPoint,
    float ImageStart,
    float UI_depth,
    int dr_input,
    int dr_output,
    int dr_drange,
    int axialGain_size,
    float* axialGain,
    float xuanniuGain,
    int spa_smoothcoef_size,
    float* spa_smoothcoef,
    float* Demodulate_FreDepth,
    float* Demodulate_FreValue,
    const char* Demodulate_FilterType,
    float blackholethre,
    float decifs,
    float* Demod_FilterDepth,
    float* Demod_FilterCutoff,
    int Demod_OrderFactor,
    float wininfo_alpha);

US_ACQ_ALG_SDK_API int initializeULMGPU(
    int numberOfParticles,
    int res,
    int SVD_cutoff_min,
    int SVD_cutoff_max,
    int max_linking_distance,
    int min_length,
    int fwhm_x,
    int fwhm_z,
    int max_gap_closing,
    int Nz,
    int Nx,
    int NbFrames,
    float scalez,
    float scalex,
    float scalet,
    float CutoffFreq_min,
    float CutoffFreq_max,
    float framerate,
    int flag_vel_norm,
    int flag_vel_z);

US_ACQ_ALG_SDK_API int initializeAllGPU_Test(void);

#pragma pack(push, 8)
typedef struct ColorFlowInitParam {
    int mode;        // 0=velocity imaging, 1=power imaging
    int roi_height;
    int roi_width;
    int roi_height_offset;
    int roi_width_offset;
    int roi_packsize;
    float user_gain;
    int doSmooth;
    int gaussh;
    float sigmah;
    int gaussl;
    float sigmal;
    int flash_level;
} ColorFlowInitParam;
#pragma pack(pop)

US_ACQ_ALG_SDK_API int openColorFlow(int height, int width, int height_offset, int width_offset);
US_ACQ_ALG_SDK_API int openColorFlowEx(const ColorFlowInitParam* param);
US_ACQ_ALG_SDK_API int closeColorFlow(void);
US_ACQ_ALG_SDK_API void setPwIqCompareDump(int enable, const char* dir);
US_ACQ_ALG_SDK_API int processDataBeamformingGPU(int8_t* input, int size, float* output, uint32_t* width, uint32_t* height);
US_ACQ_ALG_SDK_API int processDataMidProcessGPU(float* input, int noLine, int modetype, float* output);
US_ACQ_ALG_SDK_API int processSpectralDataBeamformingandPostGPU(
    int8_t* input,
    int size,
    float* output_b,
    float* output_sd,
    int bag_idx);
US_ACQ_ALG_SDK_API int processBeamformingAndPostGPU(
    int8_t* input,
    int size,
    uint8_t* output,
    int* imagesize);
US_ACQ_ALG_SDK_API int processULMGPU(float* input_1, float* input_2, float* output, int step);
US_ACQ_ALG_SDK_API void releaseGPU(void);

#ifdef __cplusplus
}
#endif
