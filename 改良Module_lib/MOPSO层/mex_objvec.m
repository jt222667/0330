function [obj, detail] = mex_objvec(x, goal, RP_data)
%MEX_OBJVEC 生成多目标优化向量（用于MOPSO）
% 目标统一为最小化：
%   f1 = sig（精度误差）
%   f2 = 1/(w+eps)（可操作度越大越好）
%   f3 = num_modules（模块数越少越好）
%   f4 = num_connect（连接数越少越好）

[~, detail] = mex_ev(x, goal, RP_data);

is_flag_bad = ~isscalar(detail.flag) || detail.flag ~= 0;
is_sig_bad = isempty(detail.sig) || ~all(isfinite(detail.sig(:)));
is_w_bad = isempty(detail.w) || ~all(isfinite(detail.w(:)));
is_num_bad = isempty(detail.num_modules) || ~isfinite(detail.num_modules) || ...
    isempty(detail.num_connect) || ~isfinite(detail.num_connect);

if is_flag_bad || is_sig_bad || is_w_bad || is_num_bad
    obj = [1e9, 1e9, 1e9, 1e9];
    return;
end

% w 可能是向量（例如多个时刻/任务点），统一折算为标量目标
sig_scalar = mean(detail.sig(:));
w_scalar = mean(detail.w(:));
obj = [sig_scalar, 1/(w_scalar + 1e-9), detail.num_modules, detail.num_connect];
end
