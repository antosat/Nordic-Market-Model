function B = NE_makeBbus (mpc)
% NE_MAKEBBUS calculate the bus susceptance matrix B for a given system using the Laplacian matrix
%
% B = NE_makeBbus (mpc)
%
% where:
%
% -  "B" is the susceptance matrix of the AC system;
% -  "mpc" is the matpower case;

nbus = mpc.bus(end,1); % Number of lines
nline = length(mpc.branch(:,1)); % Number of lines

M = zeros(nline,nbus);
for i = 1:1:nline
    M( i, mpc.branch(i,1) ) = 1;
    M( i, mpc.branch(i,2) ) = -1;
end
Bp=diag( 1./mpc.branch(:,4) );

B = M' * Bp * M;
