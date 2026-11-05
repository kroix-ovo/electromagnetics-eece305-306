function S = lab09_studies()
%LAB09_STUDIES Run the Lab 9 experiments without cached results.
%   S = LAB09_STUDIES() supplies the notebook and regression tests with
%   the same loop, finite-wire and uniformly spaced solenoid experiments.
%   Wire h is HALF-length; solenoid h is FULL height, as in the handout.

S = struct();
S.I = 1; S.a = 1;
ring = @(t) [cos(t) sin(t) zeros(size(t))];
S.ring = em.src.lineCurrent(S.I,ring,[0 2*pi],400);
S.z = linspace(0,2,10)';
S.loopH = em.field.H(S.ring,[zeros(10,2) S.z]);
S.loopRef = S.I*S.a^2./(2*(S.a^2+S.z.^2).^1.5);
S.loopError = abs(S.loopH(:,3)-S.loopRef)./S.loopRef;
S.symmetryError = max(max(abs(S.loopH(:,1:2))));
% Absolute transverse tolerance: 1e-12 of the center field scale.
S.symmetryTol = 1e-12*S.I/(2*S.a);

S.wireAspect = [(1:.25:12)';15;20;30;50;100];
S.wireRatio = zeros(size(S.wireAspect));
S.chargeRatio = S.wireRatio;
wire = @(t) [zeros(size(t)) zeros(size(t)) t];
rho = 1; rhoL = 1e-9;
for k = 1:numel(S.wireAspect)
    h = S.wireAspect(k)*rho;
    src = em.src.lineCurrent(S.I,wire,[-h h],800);
    H = em.field.H(src,[rho 0 0]);
    S.wireRatio(k) = H(2)/(S.I/(2*pi*rho));
    src = em.src.lineCharge(rhoL,wire,[-h h],800);
    E = em.field.E(src,[rho 0 0]);
    S.chargeRatio(k) = E(1)/(rhoL/(2*pi*em.const.eps0()*rho));
end
S.wireIndex = find(S.wireRatio>=.99,1);
S.wireThreshold = S.wireAspect(S.wireIndex);
S.wireExact = S.wireAspect./sqrt(1+S.wireAspect.^2);
S.wireExactThreshold = .99/sqrt(1-.99^2);
% Repeat Lab 4's original COARSE full-length grid for a fair comparison.
S.lab4FullAspect = logspace(0,2,15)';
S.lab4Ratio = zeros(size(S.lab4FullAspect));
for k = 1:numel(S.lab4FullAspect)
    L = S.lab4FullAspect(k)*rho;
    src = em.src.lineCharge(rhoL,wire,[-L/2 L/2],800);
    E = em.field.E(src,[rho 0 0]);
    S.lab4Ratio(k) = E(1)/(rhoL/(2*pi*em.const.eps0()*rho));
end
S.lab4Threshold = S.lab4FullAspect(find(S.lab4Ratio>=.99,1));

% Midpoint turn centers give exactly N/h turns per unit length. A small
% fixed turn count at the endpoints would change that density as h grows.
S.turns = 200; S.solenoidRadius = .4;
base = em.src.lineCurrent(S.I,ring,[0 2*pi],64);
base.pos = S.solenoidRadius*base.pos;
base.w = S.solenoidRadius*base.w;
base.Idl = S.solenoidRadius*base.Idl;
S.solenoidAspect = (2:.25:20)';
S.solenoidRatio = zeros(size(S.solenoidAspect));
for k = 1:numel(S.solenoidAspect)
    height = S.solenoidAspect(k)*S.solenoidRadius;
    src = stackLoops(base,height,S.turns);
    H = em.field.H(src,[0 0 0]);
    S.solenoidRatio(k) = H(3)/(S.turns*S.I/height);
end
S.solenoidIndex = find(S.solenoidRatio>=.99,1);
S.solenoidThreshold = S.solenoidAspect(S.solenoidIndex);
S.solenoidExact = S.solenoidAspect./sqrt(S.solenoidAspect.^2+4);
S.solenoidExactThreshold = 2*S.wireExactThreshold;
height = S.solenoidThreshold*S.solenoidRadius;
coarse = stackLoops(base,height,S.turns/2);
H = em.field.H(coarse,[0 0 0]);
S.solenoidCoarseRatio = H(3)/(S.turns/2*S.I/height);

S.profileHeight = 20*S.solenoidRadius;
S.solenoid = stackLoops(base,S.profileHeight,S.turns);
S.axisZ = linspace(-.9*S.profileHeight,.9*S.profileHeight,151)';
S.axisH = em.field.H(S.solenoid,[zeros(size(S.axisZ)) zeros(size(S.axisZ)) S.axisZ]);
S.longH = S.turns*S.I/S.profileHeight;
H = em.field.H(S.solenoid,[0 0 0;0 0 S.profileHeight/2]);
S.centerRatio = H(1,3)/S.longH;
S.mouthRatio = H(2,3)/H(1,3);
end

function s = stackLoops(base,height,N)
z = ((1:N)-.5)*height/N-height/2;
parts = cell(1,N);
for k = 1:N
    parts{k} = base;
    parts{k}.pos(:,3) = z(k);
end
s = em.src.merge(parts{:});
end
