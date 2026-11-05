% test_lab09.m  Directed currents, Biot-Savart fields and limiting cases.
S9 = lab09_studies();
em.test.assertClose(S9.loopH(:,3),S9.loopRef,1e-6,'loop axis, ten z values');
em.test.assertClose(S9.loopH(1,3),S9.I/(2*S9.a),1e-6,'loop center');
assert(S9.symmetryError<S9.symmetryTol,'axis transverse absolute tolerance');
assert(S9.wireRatio(S9.wireIndex)>=.99 && S9.wireRatio(S9.wireIndex-1)<.99);
assert(S9.solenoidRatio(S9.solenoidIndex)>=.99 && S9.solenoidRatio(S9.solenoidIndex-1)<.99);
em.test.assertClose(S9.wireRatio,S9.chargeRatio,1e-9,'Lab 4 same geometry');
% Check finite wire formula over the sweep, not only the threshold sample.
assert(max(abs(S9.wireRatio-S9.wireExact))<2e-5,'finite wire closed form');
assert(max(abs(S9.solenoidRatio-S9.solenoidExact))<2e-5,'finite solenoid closed form');
assert(abs(S9.solenoidCoarseRatio-S9.solenoidRatio(S9.solenoidIndex))<2e-6, ...
    '100 to 200 turn refinement at threshold');
assert(abs(S9.mouthRatio-.5)<.005,'long solenoid mouth is half the center');

ring9 = @(t) [cos(t) sin(t) zeros(size(t))];
p9 = [.3 .2 .5;-.4 .1 -.2;.2 -.6 .8];
H9 = em.field.H(S9.ring,p9);
neg9 = em.src.lineCurrent(-1,ring9,[0 2*pi],400);
twice9 = em.src.lineCurrent(2,ring9,[0 2*pi],400);
reverse9 = em.src.lineCurrent(1,@(t) ring9(2*pi-t),[0 2*pi],400);
% Absolute componentwise residuals work even when a component is zero.
res9 = em.field.H(neg9,p9)+H9; assert(all(abs(res9(:))<1e-12));
res9 = em.field.H(twice9,p9)-2*H9; assert(all(abs(res9(:))<1e-12));
res9 = em.field.H(reverse9,p9)+H9; assert(all(abs(res9(:))<1e-9));
merged9 = em.src.merge(S9.ring,twice9);
assert(size(merged9.pos,1)==800 && isequal(merged9.Idl,[S9.ring.Idl;twice9.Idl]));
em.test.assertClose(em.field.H(merged9,p9),3*H9,1e-12,'current superposition');
caught9 = false;
try
    em.src.merge(S9.ring,em.src.pointCharge(1e-9,[0 0 0]));
catch ex9
    caught9 = strcmp(ex9.identifier,'em:src:merge:TypeMismatch');
end
assert(caught9,'mixed current and charge must raise the type mismatch error');

% Geometry and node weights remain separate, including all supported rules.
straight9 = @(t) [zeros(size(t)) zeros(size(t)) 2*t];
for rule9 = {'midpoint','trapz','simpson','gauss'}
    [pos9,w9,tan9,wn9] = em.quad.line(straight9,[-1 1],20,rule9{1});
    src9 = em.src.lineCurrent(3,straight9,[-1 1],20,rule9{1});
    assert(isequal(src9.pos,pos9) && isequal(src9.w,w9));
    em.test.assertClose(src9.Idl,3*tan9.*wn9,1e-14,'directed node weights');
    em.test.assertClose(sum(src9.Idl,1),[0 0 12],1e-9,'integrated I dL');
    em.test.assertClose(sum(w9),4,1e-9,'unchanged arc length');
end
% Degenerate tangents give zero current elements, with no 0/0 normalization.
still9 = em.src.lineCurrent(1,@(t) [0 0 0],[0 1],4);
assert(all(still9.Idl(:)==0));
zero9 = em.src.lineCurrent(0,ring9,[0 2*pi],20);
assert(all(all(em.field.H(zero9,p9)==0)));

% Independent surface-current reference: K=[1,0,0] on [-1,1]^2 at z=1.
% H_y = -Omega/(4*pi), Omega = 4*atan(1/sqrt(3)) = 2*pi/3.
sheet9 = @(u,v) [u v 0];
sheetSrc9 = em.src.surfCurrent(@(r) [1 0 0],sheet9,[-1 1],[-1 1],24,24,'gauss');
em.test.assertClose(sum(sheetSrc9.Idl,1),[4 0 0],1e-9,'sheet weighted current');
sheetH9 = em.field.H(sheetSrc9,[0 0 1]);
assert(abs(sheetH9(1))<1e-12 && abs(sheetH9(3))<1e-12);
em.test.assertClose(sheetH9(2),-1/6,1e-8,'rectangular sheet solid angle');
variable9 = em.src.surfCurrent(@(r) [r(:,1) 2*r(:,2) ones(size(r,1),1)], ...
    sheet9,[-1 1],[-1 1],6,8);
em.test.assertClose(variable9.Idl, ...
    [variable9.pos(:,1) 2*variable9.pos(:,2) ones(48,1)].*variable9.w,1e-14,'varying K');
% Idl includes geometry once. Changing bookkeeping w cannot change H.
book9 = sheetSrc9; book9.w = 7*book9.w;
assert(isequal(em.field.H(book9,p9),em.field.H(sheetSrc9,p9)));
em.test.assertClose(em.field.B(S9.ring,p9),em.const.mu0()*H9,1e-14,'default B');
em.test.assertClose(em.field.B(S9.ring,p9,2.5),2.5*em.const.mu0()*H9,1e-14,'relative permeability');
assert(isequal(size(em.field.H(S9.ring,zeros(0,3))),[0 3]));
assert(isequal(size(em.field.B(S9.ring,zeros(0,3))),[0 3]));
empty9 = struct('type','current','pos',zeros(0,3),'w',zeros(0,1),'Idl',zeros(0,3));
assert(isequal(em.field.H(empty9,p9),zeros(size(p9))));

% Reproducible nontrivial observations, without changing the global RNG.
j9 = (1:10000)';
pts9 = [5+sin(j9) 5+cos(j9) 5+sin(sqrt(2)*j9)];
tic; large9 = em.field.H(S9.ring,pts9(1:5000,:)); time5k9 = toc;
assert(isequal(size(large9),[5000 3]) && all(isfinite(large9(:))) && time5k9<2, ...
    '5000-point H must return finite Nx3 in under two seconds');
tic; large10k9 = em.field.H(S9.ring,pts9); time10k9 = toc;
assert(isequal(size(large10k9),[10000 3]) && all(isfinite(large10k9(:))) && time10k9<2, ...
    '10000-point H vectorization');
em.test.assertClose(large9(1:3,:),em.field.H(S9.ring,pts9(1:3,:)),1e-12,'chunk independence');

% Exact and near coincidences identify the offending element and point.
for offset9 = [0 1e-13]
    caught9 = false;
    try
        em.field.H(S9.ring,[p9(1,:);S9.ring.pos(7,:)+[0 0 offset9]]);
    catch ex9
        caught9 = strcmp(ex9.identifier,'em:field:H:Singularity') ...
            && ~isempty(strfind(ex9.message,'element 7')) ...
            && ~isempty(strfind(ex9.message,'point 2'));
    end
    assert(caught9,'singularity must name observation point and source element');
end
bad9 = {@() em.src.lineCurrent([1 2],ring9,[0 1],10), ...
    @() em.src.surfCurrent(1,sheet9,[0 1],[0 1],4,4), ...
    @() em.src.surfCurrent(@(r) [1 2],sheet9,[0 1],[0 1],4,4), ...
    @() em.src.surfCurrent(@(r) [NaN 0 0],sheet9,[0 1],[0 1],4,4), ...
    @() em.field.H(S9.ring,[1 2]),@() em.field.H(S9.ring,[NaN 0 0]), ...
    @() em.field.H(em.src.pointCharge(1,[0 0 0]),p9), ...
    @() em.field.B(S9.ring,p9,[1 2]),@() em.field.B(S9.ring,p9,0)};
for k9 = 1:numel(bad9)
    caught9 = false; try, bad9{k9}(); catch, caught9 = true; end
    assert(caught9,'invalid inputs must raise an error');
end
fprintf('  Lab 9: max loop relative error %.3e; transverse %.3e A/m (tol %.1e)\n', ...
    max(S9.loopError),S9.symmetryError,S9.symmetryTol);
fprintf('  Wire half-length h/rho %.2f; full-length L/rho %.2f; ratio %.8f\n', ...
    S9.wireThreshold,2*S9.wireThreshold,S9.wireRatio(S9.wireIndex));
fprintf('  Solenoid full-height h/a %.2f; ratio %.8f; mouth/center %.6f\n', ...
    S9.solenoidThreshold,S9.solenoidRatio(S9.solenoidIndex),S9.mouthRatio);
fprintf('  H timings: 5000 points %.3f s; 10000 points %.3f s\n',time5k9,time10k9);
fprintf('  Surface current, B scaling, reversal, merge, input and singularity checks passed\n');
fprintf('  test_lab09 checks complete\n');
