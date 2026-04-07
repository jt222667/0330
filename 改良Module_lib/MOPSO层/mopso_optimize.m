function result = mopso_optimize(goal, RP_data, nvars, lb, ub, options)
%MOPSO_OPTIMIZE 使用多目标粒子群（MOPSO）进行构型寻优

num_particles = options.SwarmSize;
max_iters = options.MaxIterations;
archive_max = options.ArchiveSize;
inertia = options.InertiaWeight;
c1 = options.C1;
c2 = options.C2;

% 初始化粒子
X = repmat(lb, num_particles, 1) + rand(num_particles, nvars) .* repmat((ub - lb), num_particles, 1);
V = zeros(num_particles, nvars);

PbestX = X;
PbestF = inf(num_particles, 4);

archiveX = zeros(0, nvars);
archiveF = zeros(0, 4);

for iter = 1:max_iters
    F = zeros(num_particles, 4);

    for i = 1:num_particles
        x_eval = sanitize_x(X(i, :), lb, ub);
        [F(i, :), ~] = mex_objvec(x_eval, goal, RP_data);
        X(i, :) = x_eval;

        if dominates(F(i, :), PbestF(i, :))
            PbestX(i, :) = X(i, :);
            PbestF(i, :) = F(i, :);
        elseif ~dominates(PbestF(i, :), F(i, :)) && rand < 0.5
            PbestX(i, :) = X(i, :);
            PbestF(i, :) = F(i, :);
        end
    end

    % 更新外部档案
    archiveX = [archiveX; X]; %#ok<AGROW>
    archiveF = [archiveF; F]; %#ok<AGROW>
    [archiveX, archiveF] = pareto_filter(archiveX, archiveF);

    if size(archiveX, 1) > archive_max
        keep_idx = truncate_by_crowding(archiveF, archive_max);
        archiveX = archiveX(keep_idx, :);
        archiveF = archiveF(keep_idx, :);
    end

    % 领航者选择与速度位置更新
    crowd = crowding_distance(archiveF);
    for i = 1:num_particles
        leader_idx = select_leader(crowd);
        leader = archiveX(leader_idx, :);

        r1 = rand(1, nvars);
        r2 = rand(1, nvars);

        V(i, :) = inertia * V(i, :) ...
            + c1 * r1 .* (PbestX(i, :) - X(i, :)) ...
            + c2 * r2 .* (leader - X(i, :));

        X(i, :) = X(i, :) + V(i, :);
        X(i, :) = min(max(X(i, :), lb), ub);
    end

    fprintf('MOPSO 迭代 %d/%d, Pareto数=%d\n', iter, max_iters, size(archiveX, 1));
end

% 从Pareto解中按权重选择单一推荐解，便于兼容原输出
weights = [RP_data.weight_cfg.lambda_sig, RP_data.weight_cfg.lambda_w, ...
           RP_data.weight_cfg.lambda_num_modules, RP_data.weight_cfg.lambda_num_connect];
[best_idx, best_score] = weighted_pick(archiveF, weights);
best_x = archiveX(best_idx, :);

[~, best_detail] = mex_ev(best_x, goal, RP_data);

result.best_x = best_x;
result.best_score = best_score;
result.best_detail = best_detail;
result.pareto_x = archiveX;
result.pareto_f = archiveF;
end

function x = sanitize_x(x, lb, ub)
x = min(max(x, lb), ub);
x = round(x);
end

function tf = dominates(a, b)
tf = all(a <= b) && any(a < b);
end

function [X, F] = pareto_filter(X, F)
n = size(F, 1);
keep = true(n, 1);
for i = 1:n
    if ~keep(i)
        continue;
    end
    for j = 1:n
        if i == j || ~keep(j)
            continue;
        end
        if dominates(F(j, :), F(i, :))
            keep(i) = false;
            break;
        end
    end
end
X = X(keep, :);
F = F(keep, :);

% 去重（同目标值保留一个）
[~, uniq_idx] = unique(F, 'rows', 'stable');
X = X(uniq_idx, :);
F = F(uniq_idx, :);
end

function d = crowding_distance(F)
n = size(F, 1);
m = size(F, 2);
if n == 0
    d = [];
    return;
elseif n <= 2
    d = inf(n, 1);
    return;
end

d = zeros(n, 1);
for k = 1:m
    [vals, idx] = sort(F(:, k));
    d(idx(1)) = inf;
    d(idx(end)) = inf;

    range_v = vals(end) - vals(1);
    if range_v == 0
        continue;
    end

    for i = 2:n-1
        if ~isinf(d(idx(i)))
            d(idx(i)) = d(idx(i)) + (vals(i+1) - vals(i-1)) / range_v;
        end
    end
end
end

function idx = select_leader(crowd)
if isempty(crowd)
    idx = 1;
    return;
end

finite_mask = isfinite(crowd);
if any(finite_mask)
    prob = crowd;
    prob(~finite_mask) = max(prob(finite_mask));
    prob = prob + 1e-12;
    prob = prob / sum(prob);
    idx = randsample(numel(crowd), 1, true, prob);
else
    idx = randi(numel(crowd));
end
end

function keep_idx = truncate_by_crowding(F, max_num)
crowd = crowding_distance(F);
[~, order] = sort(crowd, 'descend');
keep_idx = order(1:max_num);
end

function [idx, score] = weighted_pick(F, w)
% 将四个目标做min-max归一化后加权求和
fmin = min(F, [], 1);
fmax = max(F, [], 1);
den = fmax - fmin;
den(den == 0) = 1;
Fn = (F - fmin) ./ den;

w = w(:).' / sum(w);
score_all = Fn * w.';
[score, idx] = min(score_all);
end
