function s = lineCurrent(I, curve, tspan, N, rule)
%LINECURRENT Discretize a directed filament carrying current I in amperes.
%   S = EM.SRC.LINECURRENT(I, CURVE, TSPAN, N, RULE) uses the tangent
%   returned by EM.QUAD.LINE. Positive I follows increasing parameter;
%   negative I reverses the current. RULE defaults to 'midpoint'.
%   S.Idl is Mx3 in A*m and already includes the parameter weights.
%   S.w retains the scalar arc-length weights in meters.
%
%   Example:
%       ring = @(t) [cos(t) sin(t) 0];
%       s = em.src.lineCurrent(1, ring, [0 2*pi], 400);
%
%   See also EM.QUAD.LINE, EM.SRC.SURFCURRENT, EM.FIELD.H.

if nargin < 5 || isempty(rule), rule = 'midpoint'; end
if ~(isnumeric(I) && isreal(I) && isscalar(I) && isfinite(I))
    error('em:src:lineCurrent:InvalidCurrent', ...
        'I must be a finite real scalar in amperes.');
end
[pos,w,tangent,wnode] = em.quad.line(curve,tspan,N,rule);
s = struct('type','current', 'pos',pos, 'w',w, ...
    'Idl',I*tangent.*wnode, 'label','line current');
end
