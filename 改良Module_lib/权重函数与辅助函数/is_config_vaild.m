clc;
clear;

%% 参数初始化
RP_data = Module_Lib();

module  = [3 3 2 1 2 3 5 3];
install = [1 1 1 1 1 1 1 1];
align   = [0 0 0 0 0 0 0 0];



[module_out, install_out, align_out, num_modules_physical, is_valid,err] = expand_module_units(module, install, align, RP_data);
err