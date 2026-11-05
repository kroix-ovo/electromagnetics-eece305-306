function Hv = H(s, r)
%H Evaluate the Biot-Savart magnetic field of a current source.
%   HV = EM.FIELD.H(S,R) returns Nx3 values in A/m at the finite real
%   Nx3 Cartesian positions R in meters. S.Idl already includes the
%   quadrature weights. Empty observation arrays return zeros(0,3).
%   Points within 1e-12 times the coordinate scale of an element raise
%   an error naming both the observation point and source element.
%
%   Example:
%       s = em.src.lineCurrent(1,@(t) [cos(t) sin(t) 0],[0 2*pi],400);
%       em.field.H(s,[0 0 0])    % approximately [0 0 0.5] A/m
%
%   See also EM.FIELD.E, EM.FIELD.B, EM.SRC.LINECURRENT.

validateCurrentSource(s);
if ~(isnumeric(r) && isreal(r) && ismatrix(r) && size(r,2)==3 ...
        && all(isfinite(r(:))))
    error('em:field:H:InvalidPosition', ...
        'r must be a finite real Nx3 Cartesian position array.');
end
N = size(r,1); M = size(s.pos,1);
Hv = zeros(N,3);
if N==0 || M==0, return; end

% Reuse E's displacement, inverse-cube kernel and observation chunks.
% Only the numerator and the final physical constant differ.
chunkSize = max(1,floor(1e6/M));
scale = max([1;abs(r(:));abs(s.pos(:))]);
singularTol = 1e-12*scale;
for first = 1:chunkSize:N
    last = min(N,first+chunkSize-1);
    nc = last-first+1;
    d = reshape(r(first:last,:),[nc 1 3])-reshape(s.pos,[1 M 3]);
    R2 = sum(d.^2,3);
    [obsLocal,elemIndex] = find(R2<=singularTol^2,1);
    if ~isempty(elemIndex)
        error('em:field:H:Singularity', ...
            ['Observation point %d lies at or too near source element ' ...
             '%d; the magnetic field is singular.'],first+obsLocal-1,elemIndex);
    end
    kernel = 1./(R2.*sqrt(R2));
    % Idl cross (r-pos), written componentwise without replicating Idl.
    Hv(first:last,1) = sum((s.Idl(:,2).'.*d(:,:,3)-s.Idl(:,3).'.*d(:,:,2)).*kernel,2);
    Hv(first:last,2) = sum((s.Idl(:,3).'.*d(:,:,1)-s.Idl(:,1).'.*d(:,:,3)).*kernel,2);
    Hv(first:last,3) = sum((s.Idl(:,1).'.*d(:,:,2)-s.Idl(:,2).'.*d(:,:,1)).*kernel,2);
end
Hv = Hv/(4*pi);
end

function validateCurrentSource(s)
if ~(isstruct(s) && isscalar(s) && isfield(s,'type') && strcmp(s.type,'current'))
    error('em:field:H:InvalidSource','s must be a current source struct.');
end
fields = {'pos','w','Idl'};
for k = 1:numel(fields)
    if ~isfield(s,fields{k})
        error('em:field:H:InvalidSource','s is missing required field %s.',fields{k});
    end
    value = s.(fields{k});
    if ~(isnumeric(value) && isreal(value) && ismatrix(value) && all(isfinite(value(:))))
        error('em:field:H:InvalidSource','s.%s must be a finite real numeric array.',fields{k});
    end
end
M = size(s.pos,1);
if size(s.pos,2)~=3 || ~isequal(size(s.Idl),[M 3]) || ~isequal(size(s.w),[M 1])
    error('em:field:H:InvalidSource', ...
        's.pos and s.Idl must be Mx3; s.w must be Mx1.');
end
end
