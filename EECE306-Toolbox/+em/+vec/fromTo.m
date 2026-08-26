function d = fromTo(P, Q)
%FROMTO Displacement vector between two points
%   D = EM.VEC.FROMTO(P, Q) returns the Nx3 displacement vector 
%   from point P to point Q
%
%   Example:
%       em.vec.fromTo([1 1 1], [2 3 4]) % returns [1 2 3]
%
%   See also EM.VEC.MAG, EM.VEC.UNIT.

    d = Q - P;
end
