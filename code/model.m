close all; clear; clc;

rng(1); % Reproducibility

% Parameters
r = 0.38;
T = 50;

% =========================================================
% DEFINE ALL CASES
% =========================================================
% Order:
% [Resist, Obey, Adapt, Encourage, Reinforce, NegOpp, NegCon, Reject]
%
% AUTHORITATIVE OCTANT MAP (matches new.jpg exactly - do not change one
% without changing the other, and keep the manuscript text in step):
%
%   seg  name                      span (deg)   centre   side   power
%   ---  ------------------------  -----------  -------  -----  -----
%    1   Resist                    180 - 225      202.5   opp    low
%    2   Obey                      225 - 270      247.5   opp    low
%    3   Adapt                     270 - 315      292.5   con    low
%    4   Encourage                 315 - 360      337.5   con    low
%    5   Reinforce                   0 -  45       22.5   con    high
%    6   Negotiate in Opposition    45 -  90       67.5   con    high
%    7   Negotiate in Consensus     90 - 135      112.5   opp    high
%    8   Reject                    135 - 180      157.5   opp    high
%
% Horizontal axis: 0 deg = consensus, 180 deg = opposition.
% Vertical axis:  90 deg = high power, 270 deg = low power.
%
% NAMING CONVENTION for the two Negotiate octants. These are the only
% octants named for the camp the actor is negotiating WITH rather than
% for the actor's own position, and the distinction is easy to misread:
%
%   Negotiate in Opposition (67.5 deg) sits on the CONSENSUS side. It is
%   an actor who seeks the change, has moved away from Reject, and has
%   opened negotiation with the opposing camp.
%
%   Negotiate in Consensus (112.5 deg) sits on the OPPOSITION side. It is
%   the mirror image: an actor opposed to the change who has opened
%   negotiation with the consensus camp.
%
% Both are high-power bridging positions flanking the power pole at
% 90 deg, which is why they are adjacent to each other rather than on
% opposite sides of the circle. This convention is deliberate; do not
% "correct" it by swapping segments 6 and 7. It must be stated
% explicitly in any manuscript, or reviewers will read the labels as
% transposed.

cases = {
    % -----------------------------------------------------
    % Validation Through Scenario Testing (from manuscript)
    % -----------------------------------------------------
    % Fixed: original summed to 110
    % Keeps Reinforce=25 and NegCon=25 as in your text,
    % and keeps the opposition block smaller.
    'Scenario 1: Constitutional Reform',           [5 10 10 10 25 5 25 10];

    % Already fine
    'Scenario 2: Grassroots Democratic Movement',  [8 7 25 25 15 2 15 3];

    % Fixed: original summed to 110
    % Keeps Reinforce=20 and NegCon=20, while making the
    % rejection/opposition side smaller but still present.
    'Scenario 3: Federal Decentralization',        [10 10 15 15 20 5 20 5];

    % -----------------------------------------------------
    % Validation Through Simulation Tests (from manuscript)
    % -----------------------------------------------------
    % Already fine
    'Test 1: Baseline State',                      [12.5 12.5 12.5 12.5 12.5 12.5 12.5 12.5];

    % Fixed: original summed to 120
    % To isolate "power determines direction", mass is shifted upward
    % into Reinforce and NegCon while reducing lower-half support.
    'Test 2: Power Determines Direction',          [15 10 5 5 20 15 20 10];

    % Fixed: original summed to 115
    % To isolate "consensus determines speed", Adapt and Encourage are
    % strengthened while upper-half power categories stay the same.
    'Test 3: Consensus Determines Speed',          [10 5 20 20 10 15 10 10];

    % Already fine
    'Test 4: Combined Power and Consensus',        [5 10 15 25 20 10 10 5];

    % -----------------------------------------------------
    % Empirical Illustration cases
    % -----------------------------------------------------
    'Brexit',                                      [15 10 10 15 10 15 15 10];
    'Arab Spring',                                 [5 5 10 20 25 5 20 10];
    'Corporate Restructuring',                     [10 10 15 15 20 10 10 10];
    'Viral Movement',                              [5 5 15 35 5 5 20 10];
    'Innovation Initiative',                       [5 10 25 25 5 10 10 10];
};

% =========================================================
% LOOP THROUGH CASES
% =========================================================

results = cell(size(cases,1), 7); % name, Net_X, Net_Y, Speed, Angle, ChangeType, Fig2Region

for c = 1:size(cases,1)

    caseName = cases{c,1};
    segmentProportions = cases{c,2};

    disp(['--- ', caseName, ' ---']);

    % Normalize proportions to 100
    segmentProportions = segmentProportions / sum(segmentProportions) * 100;

    % Allocate exactly T individuals
    counts = allocateCounts(T, segmentProportions);

    X = [];
    Y = [];

    for i = 1:8
        % Neutral placement so lower-half actors are not artificially compressed
        pow_bias = 1.0;
        consensusBias = 1.0;

        [xR, yR] = placeIndividuals(pow_bias, consensusBias, r, counts(i), i, 1.0);

        X = [X; xR];
        Y = [Y; yR];
    end

    % Normalize to [-1,1]
    X = 2 * (X - 0.5);
    Y = 2 * (Y - 0.5);

    % Calculate change intensity
    C = calculate_change(X, Y);

    % Exact (closed-form) result. This is what should be reported.
    [net_x, net_y, speed, angle_deg, change_type, fig2_region] = ...
        exact_change(segmentProportions);

    % One stochastic draw, kept only for the scatter plot and as a check.
    [mc_x, mc_y, mc_speed, mc_angle] = get_overall_change(X, Y, C);

    % How reproducible is this direction at this population size?
    sd_deg = direction_stability(segmentProportions, T, r, 300);

    if isnan(angle_deg)
        fprintf('Net_X = %.4f\n', net_x);
        fprintf('Net_Y = %.4f\n', net_y);
        fprintf('Speed = %.4f  (zero-length arrow)\n', speed);
        fprintf('Angle = undefined: even spread cancels exactly\n');
        fprintf('Change Type = %s\n', change_type);
        fprintf('Figure 2 Region = %s\n\n', fig2_region);
    else
        if isnan(sd_deg) || sd_deg > 25
            verdict = 'NOT directionally stable, do not read the bearing';
        else
            verdict = 'directionally stable';
        end
        fprintf('Net_X = %.4f\n', net_x);
        fprintf('Net_Y = %.4f\n', net_y);
        fprintf('Speed = %.4f   (arrow length)\n', speed);
        fprintf('Angle = %.2f degrees   (exact)\n', angle_deg);
        fprintf('  one MC draw gave %.2f deg, speed %.4f\n', mc_angle, mc_speed);
        fprintf('  circular SD over resampled populations = %.0f deg -> %s\n', sd_deg, verdict);
        fprintf('Nearest Change Type = %s\n', change_type);
        fprintf('Figure 2 Region = %s\n\n', fig2_region);
    end

    results{c,1} = caseName;
    results{c,2} = net_x;
    results{c,3} = net_y;
    results{c,4} = speed;
    results{c,5} = angle_deg;
    results{c,6} = change_type;
    results{c,7} = fig2_region;

    % Plot
    figure;
    plot_circumplex_with_change(X, Y, C, 'new.jpg');
    title(caseName, 'Color', 'w');

end

% =========================================================
% OPTIONAL: PRINT SUMMARY TABLE
% =========================================================
disp('================ SUMMARY ================');
for c = 1:size(results,1)
    fprintf('%s | Net_X=%.4f | Net_Y=%.4f | Speed=%.4f | Angle=%.2f | Change=%s | Fig2=%s\n', ...
        results{c,1}, results{c,2}, results{c,3}, results{c,4}, results{c,5}, results{c,6}, results{c,7});
end

%% --- FUNCTIONS ---

function counts = allocateCounts(T, proportions)
    rawCounts = T * proportions / 100;
    counts = floor(rawCounts);
    remainder = T - sum(counts);

    [~, idx] = sort(rawCounts - counts, 'descend');
    counts(idx(1:remainder)) = counts(idx(1:remainder)) + 1;
end

function [xR, yR] = placeIndividuals(powerBias, consensusBias, r, N, seg, clusterSize)
    a = clusterSize * 0.25;
    b = seg * 0.25 - 1;

    th = b * pi - a * pi * rand(N, 1);
    R = r * sqrt(rand(N, 1));

    R1 = min(r, R * consensusBias);
    R2 = min(r, R * powerBias);

    xR = R1 .* cos(th) + 0.5;
    yR = R2 .* sin(th) + 0.5;
end

function C = calculate_change(xR, yR)
    angles_rad = deg2rad(0:45:315);
    C = zeros(size(xR));

    for i = 1:length(xR)
        x = xR(i);
        y = yR(i);

        theta = atan2(y, x);
        if theta < 0
            theta = theta + 2*pi;
        end

        % Find nearest circumplex direction
        d = angle(exp(1i * (theta - angles_rad)));
        [~, idx] = min(abs(d));
        theta_closest = angles_rad(idx);

        magnitude = sqrt(x^2 + y^2);
        delta = abs(angle(exp(1i * (theta_closest - theta))));

        % Intensity only, not direction
        C(i) = magnitude * abs(sin(delta));
    end
end

function [net_x, net_y, speed, angle_deg, change_type, fig2_region] = get_overall_change(xR, yR, C)

    % Theory-aligned weights:
    % power still stronger than consensus, but both contribute to direction
    weight_power = 0.65;
    weight_consensus = 0.35;

    % Component-based aggregation
    norms = sqrt(xR.^2 + yR.^2) + eps;
    ux = xR ./ norms;
    uy = yR ./ norms;

    contrib_x = weight_consensus * ux .* abs(C);
    contrib_y = weight_power * uy .* abs(C);

    raw_x = sum(contrib_x);
    raw_y = sum(contrib_y);

    mag = sqrt(raw_x^2 + raw_y^2);

    % A distribution spread evenly over the eight octants sums to the zero
    % vector exactly, because eight equally weighted directions spaced at
    % 45 deg cancel. Any angle recovered from such a vector is the bearing
    % of accumulated rounding and sampling error, so refuse to report one.
    nullTol = 1e-9 * length(xR);

    if mag <= nullTol
        net_x = 0;
        net_y = 0;
        speed = 0;
        angle_deg = NaN;
        change_type = 'none (zero-length arrow)';
        fig2_region = 'none';
        return;
    end

    net_x = raw_x / mag;
    net_y = raw_y / mag;

    % Angle in degrees, converted to [0, 360)
    angle_deg = atan2d(net_y, net_x);
    if angle_deg < 0
        angle_deg = angle_deg + 360;
    end

    % Speed is the arrow length: mean vector magnitude, amplified by
    % CONSENSUS along the horizontal axis.
    %
    % The term is (1 + net_x), NOT (1 + |net_x|). The absolute value would
    % make opposition amplify speed exactly as much as consensus, which
    % contradicts the model's own definitions: Active Change (low power,
    % high consensus) is collective action that moves the system, whereas
    % Withdrawal (low power, high opposition) is disengagement FROM it.
    % Dropping the bars gives a fully opposed population a speed of zero,
    % which is what Withdrawal means, and makes Proposition 2 literally
    % true: consensus determines the speed of change.
    speed = (mag / length(xR)) * (1 + net_x);

    % Unified 8-category classification.
    % Order corrected to match the outer ring of new.jpg: 225 deg is
    % Withdrawal and 315 deg is Active Change. These two were transposed
    % in the earlier version, which mislabelled every result landing in
    % the lower-left or lower-right diagonal.
    all_angles = [0, 45, 90, 135, 180, 225, 270, 315];
    all_labels = {'Rapid Change','Radical Change','Political Change','Inertia', ...
                  'Status Quo','Withdrawal','Passive Change','Active Change'};

    [change_type, ~] = nearest_category(angle_deg, all_angles, all_labels);

    % Figure 2 region
    if net_x >= 0 && net_y >= 0
        fig2_region = 'Transformation';
    elseif net_x < 0 && net_y >= 0
        fig2_region = 'Stabilization';
    elseif net_x < 0 && net_y < 0
        fig2_region = 'Segregation';
    else
        fig2_region = 'Mobilization';
    end
end

function [net_x, net_y, speed, angle_deg, change_type, fig2_region] = ...
         exact_change(segmentProportions)
% EXACT_CHANGE  Closed-form solution of the aggregation model.
%
% Integrating the per-agent rule over the placement distribution shows that
% each octant contributes a vector along its OWN CENTRE direction, with
% magnitude proportional to that octant's share of the population. So:
%
%     net_x  =  0.35 * SUM_k p_k cos(c_k)
%     net_y  =  0.65 * SUM_k p_k sin(c_k)
%
% up to a common positive scalar kappa = (4r/3)*sqrt(2-sqrt(2))/4 which
% cancels out of the direction. Random placement therefore adds sampling
% noise and nothing else. Use this for reported results; use the Monte
% Carlo path only to draw the agent scatter.

    % centres in model.m argument order:
    % [Resist Obey Adapt Encourage Reinforce NegOpp NegCon Reject]
    % NegOpp is at 67.5 and NegCon at 112.5, per the naming convention
    % documented in the header. Do not swap them.
    centres = [202.5, 247.5, 292.5, 337.5, 22.5, 67.5, 112.5, 157.5];

    p = segmentProportions(:)' / sum(segmentProportions);

    raw_x = 0.35 * sum(p .* cosd(centres));
    raw_y = 0.65 * sum(p .* sind(centres));

    mag = sqrt(raw_x^2 + raw_y^2);

    if mag <= 1e-12
        net_x = 0; net_y = 0; speed = 0; angle_deg = NaN;
        change_type = 'none (zero-length arrow)'; fig2_region = 'none';
        return;
    end

    net_x = raw_x / mag;
    net_y = raw_y / mag;

    angle_deg = atan2d(net_y, net_x);
    if angle_deg < 0
        angle_deg = angle_deg + 360;
    end

    % See the note in get_overall_change: (1 + net_x), not (1 + |net_x|).
    speed = mag * (1 + net_x);

    all_angles = [0, 45, 90, 135, 180, 225, 270, 315];
    all_labels = {'Rapid Change','Radical Change','Political Change','Inertia', ...
                  'Status Quo','Withdrawal','Passive Change','Active Change'};
    [change_type, ~] = nearest_category(angle_deg, all_angles, all_labels);

    if net_x >= 0 && net_y >= 0
        fig2_region = 'Transformation';
    elseif net_x < 0 && net_y >= 0
        fig2_region = 'Stabilization';
    elseif net_x < 0 && net_y < 0
        fig2_region = 'Segregation';
    else
        fig2_region = 'Mobilization';
    end
end

function sd_deg = direction_stability(segmentProportions, T, r, nDraw)
% DIRECTION_STABILITY  Circular SD of the direction over resampled
% populations. A short aggregate vector yields an essentially arbitrary
% bearing; treat a case as readable only when this is below about 25 deg.

    if nargin < 4, nDraw = 500; end
    angles = zeros(nDraw, 1);

    for d = 1:nDraw
        counts = allocateCounts(T, segmentProportions / sum(segmentProportions) * 100);
        X = []; Y = [];
        for i = 1:8
            [xR, yR] = placeIndividuals(1.0, 1.0, r, counts(i), i, 1.0);
            X = [X; xR]; Y = [Y; yR];
        end
        X = 2*(X - 0.5); Y = 2*(Y - 0.5);
        C = calculate_change(X, Y);
        [~, ~, ~, a, ~, ~] = get_overall_change(X, Y, C);
        angles(d) = a;
    end

    angles = angles(~isnan(angles));
    if isempty(angles), sd_deg = NaN; return; end

    Rbar = abs(mean(exp(1i * deg2rad(angles))));
    if Rbar <= 0, sd_deg = 180; else, sd_deg = rad2deg(sqrt(-2*log(Rbar))); end
end

function [label, distance_val] = nearest_category(theta_deg, category_angles, category_labels)
    circular_dists = zeros(size(category_angles));

    for k = 1:length(category_angles)
        d = abs(theta_deg - category_angles(k));
        circular_dists(k) = min(d, 360 - d);
    end

    [distance_val, idx] = min(circular_dists);
    label = category_labels{idx};
end

function plot_circumplex_with_change(xR, yR, C, bg_image)

    hold on;
    axis equal;

    img = imread(bg_image);
    imagesc([-1.2 1.2], [1.2 -1.2], img);
    set(gca, 'YDir', 'normal', 'XColor', 'none', 'YColor', 'none');

    scatter(xR, yR, 100, C, 'filled', 'MarkerEdgeColor', 'k');
    colorbar;

    [net_x, net_y, speed, angle_deg, change_type, fig2_region] = get_overall_change(xR, yR, C);

    % Display-only scaling so arrow is easy to see
    displayScale = 25;
    minArrowLength = 0.18;

    arrow_x = net_x * speed * displayScale;
    arrow_y = net_y * speed * displayScale;

    arrow_len = sqrt(arrow_x^2 + arrow_y^2);

    if arrow_len < minArrowLength && arrow_len > 0
        arrow_x = arrow_x / arrow_len * minArrowLength;
        arrow_y = arrow_y / arrow_len * minArrowLength;
    end

    quiver(0, 0, arrow_x, arrow_y, 0, ...
        'g', 'LineWidth', 4, 'MaxHeadSize', 3);

    % Optional on-plot annotations
    text(-1.15, 1.05, sprintf('Angle = %.1f°', angle_deg), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', 'w');
    text(-1.15, 0.93, sprintf('Change = %s', change_type), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', 'w');
    text(-1.15, 0.81, sprintf('Fig 2 = %s', fig2_region), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', 'w');
    text(-1.15, 0.69, sprintf('Speed = %.3f', speed), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', 'w');

    xlim([-1.2 1.2]);
    ylim([-1.2 1.2]);

    hold off;
end