function [module_out, install_out, align_out, num_modules_physical, is_valid, err] = expand_module_units(module_units, install_units, align_units, RP_data)

num_single = 7;
integrated_modules = RP_data.integrated_modules;
n = numel(module_units);

module_cell = cell(1, n);
install_cell = cell(1, n);
align_cell   = cell(1, n);

num_modules_physical = 0;

for i = 1:n
    unit_id = round(module_units(i));
    unit_install = round(install_units(i));
    unit_align   = round(align_units(i));

    if unit_id <= num_single
        module_cell{i}  = unit_id;
        install_cell{i} = unit_install;
        align_cell{i}   = unit_align;
        num_modules_physical = num_modules_physical + 1;
    else
        idx = unit_id - num_single;

        if idx >= 1 && idx <= numel(integrated_modules)
            unit = integrated_modules{idx};

            module_cell{i}  = unit.module;
            install_cell{i} = unit.install;
            align_cell{i}   = unit.align;

            num_modules_physical = num_modules_physical + numel(unit.module);
        else
            module_cell{i}  = 1;
            install_cell{i} = unit_install;
            align_cell{i}   = unit_align;

            num_modules_physical = num_modules_physical + 1;
        end
    end
end

module_out  = [module_cell{:}];
install_out = [install_cell{:}];
align_out   = [align_cell{:}];

[is_valid, err] = is_valid_expanded_config_debug(module_out, install_out, RP_data);

end


function [is_valid, err] = is_valid_expanded_config_debug(module_var, install_var, RP_data)

% 初始化
is_valid = true;
err = struct('code', 0, 'pos', [], 'msg', '');

if isempty(module_var)
    is_valid = false;
    err.code = 1;
    err.msg = 'module_var 为空';
    return;
end

J = RP_data.J_type(module_var);

%% ===== 1. Revolute数量 =====
numR = sum(J == 'R');
if numR < 6 || numR > 7
    is_valid = false;
    err.code = 2;
    err.msg = sprintf('R关节数量非法: %d (应为6~7)', numR);
    return;
end

%% ===== 2. Link约束 =====
is_link = (J == 'L');

% 首尾
if is_link(1)
    is_valid = false;
    err.code = 3;
    err.pos = 1;
    err.msg = '首位不能是Link';
    return;
end

if is_link(end)
    is_valid = false;
    err.code = 4;
    err.pos = numel(module_var);
    err.msg = '末位不能是Link';
    return;
end

% 连续Link
idx = find(is_link(1:end-1) & is_link(2:end), 1);
if ~isempty(idx)
    is_valid = false;
    err.code = 5;
    err.pos = idx;
    err.msg = sprintf('连续Link出现在位置 %d-%d', idx, idx+1);
    return;
end

%% ===== 3. 二元约束 =====
m1 = module_var(1:end-1);
m2 = module_var(2:end);
i1 = install_var(1:end-1);
i2 = install_var(2:end);

cond = (m1==1 & m2==1);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 6;
    err.pos = idx;
    err.msg = '非法: 1-1 相邻';
    return;
end

cond = (m1==1 & m2==3 & i2==0);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 7;
    err.pos = idx;
    err.msg = '非法: 1-3 且 install(后)=0';
    return;
end

cond = (m1==3 & m2==1 & i1==1);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 8;
    err.pos = idx;
    err.msg = '非法: 3-1 且 install(前)=1';
    return;
end

cond = (m1==3 & m2==3 & i1==1 & i2==0);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 9;
    err.pos = idx;
    err.msg = '非法: 3-3 安装冲突';
    return;
end

%% ===== 4. 三元约束 =====
m1 = module_var(1:end-2);
m2 = module_var(2:end-1);
m3 = module_var(3:end);

i1 = install_var(1:end-2);
i3 = install_var(3:end);

cond = (m1==1 & m2==5 & m3==1);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 10;
    err.pos = idx;
    err.msg = '非法: 1-5-1';
    return;
end

cond = (m1==1 & m2==5 & m3==3 & i3==0);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 11;
    err.pos = idx;
    err.msg = '非法: 1-5-3 且 install(末)=0';
    return;
end

cond = (m1==3 & m2==5 & m3==1 & i1==1);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 12;
    err.pos = idx;
    err.msg = '非法: 3-5-1 且 install(首)=1';
    return;
end

cond = (m1==3 & m2==5 & m3==3 & i1==1 & i3==0);
idx = find(cond,1);
if ~isempty(idx)
    is_valid = false;
    err.code = 13;
    err.pos = idx;
    err.msg = '非法: 3-5-3 安装冲突';
    return;
end

end