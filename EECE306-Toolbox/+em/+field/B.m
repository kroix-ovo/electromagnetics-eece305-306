function Bv = B(s, r, mur)
%B Evaluate magnetic flux density in teslas.
%   BV = EM.FIELD.B(S,R,MUR) returns MUR*EM.CONST.MU0()*EM.FIELD.H(S,R)
%   for a current source S and Nx3 Cartesian positions R in meters.
%   MUR is a finite positive scalar relative permeability, default 1.
%
%   Example:
%       s = em.src.lineCurrent(1,@(t) [cos(t) sin(t) 0],[0 2*pi],400);
%       Bv = em.field.B(s,[0 0 0]);
%
%   See also EM.FIELD.H, EM.CONST.MU0.

if nargin < 3 || isempty(mur), mur = 1; end
if ~(isnumeric(mur) && isreal(mur) && isscalar(mur) && isfinite(mur) && mur>0)
    error('em:field:B:InvalidPermeability', ...
        'mur must be a finite positive real scalar.');
end
Bv = mur*em.const.mu0()*em.field.H(s,r);
end
