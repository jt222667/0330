function [obj, detail] = mex_objvec(x, goal, RP_data)
%MEX_OBJVEC 生成多目标优化向量（用于MOPSO）
% 目标统一为最小化：
%   f1 = sig（精度误差）
%   f2 = 1/(w+eps)（可操作度越大越好）
%   f3 = num_modules（模块数越少越好）
%   f4 = num_connect（连接数越少越好）

[~, detail] = mex_ev(x, goal, RP_data);

if detail.flag ~= 0 || ~isfinite(detail.sig) || ~isfinite(detail.w)
    obj = [1e9, 1e9, 1e9, 1e9];
    return;
end

obj = [detail.sig, 1/(detail.w + 1e-9), detail.num_modules, detail.num_connect];
end
