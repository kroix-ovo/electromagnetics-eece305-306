%% EECE 306 Lab 9. Current Sources and the Biot-Savart Law
% *Team 8.* Thalea Collymore, Kroix Jones, Xavier Moore
%
% This notebook checks current sources against a circular loop, a straight
% wire, and a solenoid. All positions use meters and H uses A/m. The
% experiments below run again each time the notebook is published.

%% Setup and implementation time
% The initial AI-assisted implementation and first loop check took about
% 1.2 minutes of wall-clock time. That number covers the first code pass,
% not the team's working time or the full lab. The distance calculation,
% inverse-cube factor, and batches of observation points came from the
% Lab 3 electric field engine, which needed no changes. H replaces the
% charge numerator with Idl cross displacement and uses 1/(4*pi) at the
% end. Lab 4 had kept only the tangent's length, so its curve function now
% returns the tangent and node weights too; keeping that direction earlier
% would have saved this extra step.
clear; close all;
warning('off','Octave:shadowed-function');
addpath(pwd);
addpath(fullfile(pwd,'tests'));
minutes_for_H = 73/60;
fprintf('Initial AI-assisted implementation/check: %.2f minutes\n',minutes_for_H);
fprintf('GNU Octave %s\n',version);
S9 = lab09_studies();

%% Circular loop and symmetry
% A counterclockwise loop of radius 1 m carries 1 A. Its on-axis field is
% |I*a^2/(2*(a^2+z^2)^(3/2))|, with |I/(2*a)| at the center. The ten relative
% errors below must stay below 1e-6. The transverse components should be
% zero, so their absolute tolerance is 1e-12 times the 0.5 A/m center field.
fprintf(' z (m)    H_z (A/m)    relative error\n');
fprintf('%6.3f    %10.7f     %.3e\n',[S9.z S9.loopH(:,3) S9.loopError].');
fprintf('Center %.9f A/m; expected %.9f A/m\n',S9.loopH(1,3),S9.I/(2*S9.a));
fprintf('Max transverse %.3e A/m; absolute tolerance %.1e A/m\n', ...
    S9.symmetryError,S9.symmetryTol);

%% Finite wire and the Lab 4 comparison
% Here h is the wire's half-length, so its endpoints are -h and h. The
% normalized exact field is (h/rho)/sqrt(1+(h/rho)^2). The finer sweep
% brackets the 99 percent crossing instead of treating one coarse sample
% as an exact threshold.
%
% The electric and magnetic thresholds agree for the same total length
% because their radial integrands have the same distance dependence.
% The refined wire first passes at h/rho = 7.25, or full length/rho = 14.5.
% Lab 4 first passed at 19.31 on its much wider sample spacing. Using the
% same geometry and grid removes that sampling difference; the analytic
% full-length threshold is about 14.04 in both cases.
iw9 = S9.wireIndex;
fprintf('Wire h/rho %.2f -> ratio %.8f\n',S9.wireAspect(iw9-1),S9.wireRatio(iw9-1));
fprintf('Wire h/rho %.2f -> ratio %.8f (first >= 0.99)\n', ...
    S9.wireThreshold,S9.wireRatio(iw9));
fprintf('Analytic half-length crossing %.6f; full-length crossing %.6f\n', ...
    S9.wireExactThreshold,2*S9.wireExactThreshold);
fprintf('Lab 4 original coarse full-length sample: L/rho %.4f\n',S9.lab4Threshold);
fprintf('Max electric/magnetic ratio difference on the same grid: %.3e\n', ...
    max(abs(S9.wireRatio-S9.chargeRatio)));
figure('Position',[100 100 650 260]);
semilogx(S9.wireAspect,S9.wireRatio,'o-', ...
    S9.wireAspect,S9.chargeRatio,'--',S9.wireAspect,S9.wireExact,':');
hold on; plot([1 100],[.99 .99],'k:'); grid on;
xlabel('Half-length h / rho'); ylabel('Finite field / infinite field');
legend('Magnetic wire','Lab 4 charge, same geometry','Closed form','0.99', ...
    'Location','southeast');
title('Wire length is 2h; observation radius rho = 1 m');

%% Solenoid aspect ratio and axial profile
% This model uses 200 loops with turn centers halfway through equal height
% intervals. Its density is then N/h, matching the reference formula.
% A fixed stack of 25 loops at the endpoints changes the turn density and
% leaves large gaps as h grows. The denser model avoids confusing that
% spacing error with the long-solenoid limit.
%
% The first passing height is h/a = 14.25 on a grid spaced by 0.25.
% The continuous-winding formula crosses at about 14.04, inside the same
% bracket. At h/a = 20 the center is close to NI/h, but the field falls
% near either end. The mouth is about half the center field, and the field
% keeps dropping outside the coil.
is9 = S9.solenoidIndex;
fprintf('Solenoid h/a %.2f -> center/(NI/h) %.8f\n', ...
    S9.solenoidAspect(is9-1),S9.solenoidRatio(is9-1));
fprintf('Solenoid h/a %.2f -> center/(NI/h) %.8f (first >= 0.99)\n', ...
    S9.solenoidThreshold,S9.solenoidRatio(is9));
fprintf('Continuous-winding crossing h/a %.6f\n',S9.solenoidExactThreshold);
fprintf('100 vs 200 turns, normalized threshold change %.3e\n', ...
    abs(S9.solenoidCoarseRatio-S9.solenoidRatio(is9)));
fprintf('Profile h/a = 20: center/(NI/h) %.6f; mouth/center %.6f\n', ...
    S9.centerRatio,S9.mouthRatio);
figure('Position',[100 100 650 300]);
subplot(1,2,1);
plot(S9.solenoidAspect,S9.solenoidRatio,'-', ...
    S9.solenoidAspect,S9.solenoidExact,'--');
hold on; plot([2 20],[.99 .99],'k:'); grid on;
xlabel('Full height h / a'); ylabel('Center H_z / (NI/h)');
title('Long-solenoid limit');
subplot(1,2,2);
plot(S9.axisZ/S9.profileHeight,S9.axisH(:,3)/S9.longH,'-');
hold on; plot([-.5 .5],[S9.mouthRatio S9.mouthRatio]*S9.centerRatio,'o');
grid on; xlabel('Axial position z / h'); ylabel('H_z / (NI/h)');
title('Inside and beyond the ends');

%% Reversal, scaling, source types, and timing
% The source stores Idl as an Mx3 vector that already includes the weights.
% H must not multiply by those weights again. B uses the existing mu0
% function and multiplies H by |mu0*mur|. The tests also check a rectangular
% current sheet against its solid-angle result, B scaling, reversed curve
% direction, invalid inputs, and errors at source positions.
p9 = [.3 .2 .5];
ring9 = @(t) [cos(t) sin(t) zeros(size(t))];
H9 = em.field.H(S9.ring,p9);
negative9 = em.src.lineCurrent(-1,ring9,[0 2*pi],400);
double9 = em.src.lineCurrent(2,ring9,[0 2*pi],400);
fprintf('Current reversal residual %.3e A/m\n',norm(em.field.H(negative9,p9)+H9));
fprintf('Double-current residual %.3e A/m\n',norm(em.field.H(double9,p9)-2*H9));
merged9 = em.src.merge(S9.ring,double9);
fprintf('Merged elements %d; expected 800\n',size(merged9.pos,1));
try
    em.src.merge(S9.ring,em.src.pointCharge(1e-9,[0 0 0]));
    error('Lab09:MissingTypeGuard','Mixed source merge did not fail.');
catch err9
    assert(strcmp(err9.identifier,'em:src:merge:TypeMismatch'));
    fprintf('Charge/current merge rejected: %s\n',err9.identifier);
end
j9 = (1:5000)';
pts9 = [5+sin(j9) 5+cos(j9) 5+sin(sqrt(2)*j9)];
tic; Hv9 = em.field.H(S9.ring,pts9); time9 = toc;
assert(isequal(size(Hv9),[5000 3]) && time9<2);
fprintf('5000 observations, 400 elements: %.3f s (limit 2 s)\n',time9);

%% Interpretation and problems encountered
% Lab 3 separated source construction from field evaluation, so the field
% engine did not need to know whether the elements came from a loop or a
% sheet. Lab 4 put geometry and weights in one place, but it needed to keep
% direction as well as length. Keeping those pieces separate made the four
% new functions short and left charge-source behavior unchanged. For the
% next interface, it makes sense to keep useful geometry instead of throwing
% it away just because the first calculation does not need it.
%
% The starter and handout used h differently for the straight wire, so this
% report states both half-length and full length. The starter also did not
% sweep the solenoid aspect ratio, and its sparse end-to-end turn spacing
% did not match N/h closely enough. Two older Lab 6 assertions used MATLAB's
% max(A,[],'all'), which Octave does not accept. Flattening those arrays
% keeps the same checks and tolerances. Lab 6 also used the last warning to
% test potential references; Octave's package warnings could overwrite it,
% so that check now targets the reference warning directly. The provided
% runTests and assertClose functions are unchanged.

%% Full Lab 1 through Lab 9 test output
% These results are produced here, not copied from a previous run.
results9 = runTests();
assert(numel(results9)==9 && all([results9.passed]),'Cumulative regression failed');
