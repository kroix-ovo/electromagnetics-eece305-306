function s = surfCurrent(K, surface, uspan, vspan, Nu, Nv, rule)
%SURFCURRENT Discretize a surface current density K in A/m.
%   S = EM.SRC.SURFCURRENT(K, SURFACE, USPAN, VSPAN, NU, NV, RULE)
%   evaluates K at the Cartesian quadrature positions. K must be a
%   function handle returning a finite real 1x3 vector per position;
%   vectorized Mx3 output is also supported. RULE defaults to 'midpoint'.
%   S.w contains area weights in m^2. S.Idl = K.*S.w is Mx3 in A*m,
%   so field evaluation must not multiply by S.w again.
%
%   Example:
%       sheet = @(u,v) [u v 0];
%       s = em.src.surfCurrent(@(r) [1 0 0],sheet,[-1 1],[-1 1],20,20);
%
%   See also EM.QUAD.SURF, EM.SRC.LINECURRENT, EM.FIELD.H.

if nargin < 7 || isempty(rule), rule = 'midpoint'; end
if ~isa(K,'function_handle')
    error('em:src:surfCurrent:InvalidDensity', ...
        'K must be a function handle returning current density in A/m.');
end
[pos,w] = em.quad.surf(surface,uspan,vspan,Nu,Nv,rule);
M = size(pos,1);
try
    density = K(pos);
catch
    density = [];
end
if ~(isnumeric(density) && isreal(density) && isequal(size(density),[M 3]))
    density = zeros(M,3);
    for k = 1:M
        value = K(pos(k,:));
        if ~(isnumeric(value) && isreal(value) && isequal(size(value),[1 3]) ...
                && all(isfinite(value)))
            error('em:src:surfCurrent:InvalidDensityOutput', ...
                'K(pos) must return a finite real 1x3 vector per position.');
        end
        density(k,:) = value;
    end
end
if any(~isfinite(density(:)))
    error('em:src:surfCurrent:InvalidDensityOutput', ...
        'K(pos) must return finite real current density vectors.');
end
s = struct('type','current', 'pos',pos, 'w',w, ...
    'Idl',density.*w, 'label','surface current');
end
