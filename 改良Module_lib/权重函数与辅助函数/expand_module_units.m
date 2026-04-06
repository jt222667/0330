function [module_out, install_out, align_out, num_modules_physical, is_valid] = expand_module_units(module_units, install_units, align_units, RP_data)

module_out = [];
install_out = [];
align_out = [];

num_single = 5;
integrated_modules = RP_data.integrated_modules;

for i = 1:length(module_units)
    unit_id = round(module_units(i));
    unit_install = round(install_units(i));
    unit_align = round(align_units(i));

    if unit_id <= num_single
        module_out(end+1) = unit_id; %#ok<AGROW>
        install_out(end+1) = unit_install; %#ok<AGROW>
        align_out(end+1) = unit_align; %#ok<AGROW>
    else
        idx_integrated = unit_id - num_single;
        if idx_integrated < 1 || idx_integrated > numel(integrated_modules)
            module_out(end+1) = 1; %#ok<AGROW>
            install_out(end+1) = unit_install; %#ok<AGROW>
            align_out(end+1) = unit_align; %#ok<AGROW>
            continue;
        end

        unit = integrated_modules{idx_integrated};
        module_out = [module_out, unit.module]; %#ok<AGROW>
        install_out = [install_out, unit.install]; %#ok<AGROW>
        align_out = [align_out, unit.align]; %#ok<AGROW>
    end
end

num_modules_physical = length(module_units) - numel(find(module_units > num_single));
for i = 1:length(module_units)
    unit_id = round(module_units(i));
    if unit_id > num_single
        idx_integrated = unit_id - num_single;
        if idx_integrated >= 1 && idx_integrated <= numel(integrated_modules)
            num_modules_physical = num_modules_physical + length(integrated_modules{idx_integrated}.module);
        else
            num_modules_physical = num_modules_physical + 1;
        end
    end
end

is_valid = is_valid_expanded_config(module_out, install_out, RP_data);

end

function is_valid = is_valid_expanded_config(module_var, install_var, RP_data)
is_valid = true;

if isempty(module_var)
    is_valid = false;
    return;
end

num_revolute = sum(RP_data.J_type(module_var) == 'R');
if num_revolute < 6 || num_revolute > 7
    is_valid = false;
    return;
end

for i = 1:(length(module_var) - 1)
    if module_var(i) == 1 && module_var(i+1) == 1
        is_valid = false;
        return;
    end

    if module_var(i) == 1 && module_var(i+1) == 3 && install_var(i+1) == 0
        is_valid = false;
        return;
    end

    if module_var(i) == 3 && module_var(i+1) == 1 && install_var(i) == 1
        is_valid = false;
        return;
    end

    if module_var(i) == 3 && module_var(i+1) == 3 && install_var(i) == 1 && install_var(i+1) == 0
        is_valid = false;
        return;
    end
end

for i = 1:(length(module_var) - 2)
    if module_var(i) == 1 && module_var(i+1) == 5 && module_var(i+2) == 1
        is_valid = false;
        return;
    end

    if module_var(i) == 1 && module_var(i+1) == 5 && module_var(i+2) == 3 && install_var(i+2) == 0
        is_valid = false;
        return;
    end

    if module_var(i) == 3 && module_var(i+1) == 5 && module_var(i+2) == 1 && install_var(i) == 1
        is_valid = false;
        return;
    end

    if module_var(i) == 3 && module_var(i+1) == 5 && module_var(i+2) == 3 && install_var(i) == 1 && install_var(i+2) == 0
        is_valid = false;
        return;
    end
end
end
