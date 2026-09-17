%% EECE 306 Lab 4 notebook. The Quadrature Engine and Continuous Charge Distributions
% *Team 8.* Thalea Collymore, Kroix Jones, Xavier Moore
%
% Fill in every TODO, run |publish('Lab04_notebook.m')| from the toolbox
% root, print the HTML to PDF, three to five pages.

%% Setup
clear; close all;
e0 = em.const.eps0();

%% Geometry before physics
% The sum of the weights must return length, area, and volume with no
% field anywhere in sight.
circ = @(t)[cos(t) sin(t) zeros(size(t))];
[~, wc] = em.quad.line(circ, [0 2*pi], 400);
sph = @(th,ph)[sin(th)*cos(ph) sin(th)*sin(ph) cos(th)];
[~, ws] = em.quad.surf(sph, [0 pi], [0 2*pi], 60, 120);
ball = @(u,v,w)[w*sin(u)*cos(v) w*sin(u)*sin(v) w*cos(u)];
[~, wv] = em.quad.vol(ball, [0 pi], [0 2*pi], [0 1], 30, 60, 30);
sq = @(u,v)[u v 0];
[~, wq] = em.quad.surf(sq, [0 1], [0 1], 20, 20);
fprintf('circle length  %.6f   expect %.6f\n', sum(wc), 2*pi);
fprintf('sphere area    %.6f   expect %.6f\n', sum(ws), 4*pi);
fprintf('ball volume    %.6f   expect %.6f\n', sum(wv), 4*pi/3);
fprintf('square area    %.6f   expect %.6f\n', sum(wq), 1);

%% Observed order of each rule
% Errors are collected in a plain loop, then the standard fitting tool
% reports the observed order. One representative log log plot is shown.
Iex = exp(1) - 1;
Ns = [8 16 32 64 128]';
rules = {'midpoint', 'trapz', 'simpson'};
for k = 1:3
    rule = rules{k};
    errs = zeros(size(Ns));
    for j = 1:numel(Ns)
        [t, w] = em.quad.nodes(0, 1, Ns(j), rule);
        errs(j) = abs(sum(exp(t) .* w) - Iex);
    end
    p = em.test.convergence(@(N) errs(Ns == N), Ns, struct('plot', strcmp(rule,'simpson')));
    fprintf('%-9s observed order p = %.2f\n', rule, p);
end

%% The Gauss rule does not fit the same mold
for N = [2 4 8 16]
    [t, w] = em.quad.nodes(0, 1, N, 'gauss');
    fprintf('gauss N = %2d   error = %.3e\n', N, abs(sum(exp(t) .* w) - Iex));
end
% An N-point Gauss rule is exact for every polynomial through degree
% 2N - 1, so a smooth nonpolynomial integrand can converge faster than
% any single fixed power of N. Its errors therefore do not follow one
% straight line on a log-log plot and eventually reach floating-point
% precision, so a fitted slope is not a meaningful fixed order.

%% Finite line against the infinite line formula
d = 1;
Lod = logspace(0, 2, 15)';
ratio = zeros(size(Lod));
for k = 1:numel(Lod)
    L = Lod(k) * d;
    lineC = @(t)[zeros(size(t)) zeros(size(t)) t];
    sl = em.src.lineCharge(1e-9, lineC, [-L/2 L/2], 800);
    Ef = em.field.E(sl, [d 0 0]);
    ratio(k) = Ef(1) / (1e-9 / (2*pi*e0*d));
end
figure; semilogx(Lod, ratio, 'o-'); grid on
xlabel('L / d'); ylabel('E finite over E infinite')
title('Finite line approaching the infinite line')
iAbove = find(ratio > 0.99, 1);
fprintf('ratio first exceeds 0.99 at L/d about %.1f\n', Lod(iAbove));

%% Disk against the infinite sheet formula
h = 1;
aoh = logspace(0, 2.1, 14)';
ratioD = zeros(size(aoh));
for k = 1:numel(aoh)
    a = aoh(k) * h;
    disk = @(u,v)[u.*cos(v) u.*sin(v) zeros(size(u))];
    sd = em.src.surfCharge(1e-9, disk, [0 a], [0 2*pi], 80, 80);
    Ed = em.field.E(sd, [0 0 h]);
    ratioD(k) = Ed(3) / (1e-9 / (2*e0));
end
figure; semilogx(aoh, ratioD, 'o-'); grid on
xlabel('a / h'); ylabel('E disk over E sheet')
title('Disk approaching the infinite sheet')
iA = find(ratioD > 0.99, 1);
fprintf('ratio first exceeds 0.99 at a/h about %.1f\n', aoh(iA));

%% A nonuniform density through the same constructor
lineC = @(t)[zeros(size(t)) zeros(size(t)) t];
sn = em.src.lineCharge(@(r) r(:,3), lineC, [-1 1], 400);
fprintf('net charge of rho(z) = z on [-1, 1] = %.3e C  (expect 0)\n', sum(sn.q .* sn.w));

%% Interpretation
% The measured midpoint and trapezoid orders are near two, while Simpson's
% order is near four, which verifies the node and weight construction. On
% the sampled grids, the line first exceeds 0.99 at L/d about 19.3, while
% the disk first exceeds 0.99 at a/h about 59.8, so the disk approaches
% its infinite limit much more slowly. The supplied closed form places the
% exact disk threshold near a/h = 100, so the earlier numerical crossing
% also shows that the fixed 80-point radial grid becomes under-resolved as
% the disk grows. In the Lab 7 and Lab 8 numerical solvers, an unexpectedly
% low measured order would be an early sign of an incorrectly handled
% boundary or an off-by-one error in node placement.

%% Problems encountered
% The starter study uses even values of N for Simpson's rule even though
% the composite 1/3 rule normally requires an odd number of nodes. We kept
% exactly N nodes by applying Simpson's 3/8 rule on the final three
% subintervals for even N, then verified that the combined rule retains
% fourth-order convergence.

%% Full test suite
runTests
