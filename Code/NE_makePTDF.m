function PTDF = makePTDF(nbus,ref,bbus,bline)
% Script creating the PTDF matrix
% reference node #ref

% Remove the column and the row corresponding to the reference node
bbus_rcs = [bbus(1:ref-1,1:ref-1) bbus(1:ref-1,ref+1:nbus);
    bbus(ref+1:nbus,1:ref-1) bbus(ref+1:nbus,ref+1:nbus)];

% Calculate the inverse of Bbus
b_inv_prime = inv(bbus_rcs);

% Add the column and the row corresponding to the reference node
b_inv = [b_inv_prime(1:ref-1,1:ref-1) zeros(ref-1,1) b_inv_prime(1:ref-1,ref:nbus-1);
	zeros(1,nbus);
	b_inv_prime(ref:nbus-1,1:ref-1) zeros(nbus-ref,1) b_inv_prime(ref:nbus-1,ref:nbus-1)];

% Calculate the PTDF Matrix
PTDF = bline*b_inv;

end

