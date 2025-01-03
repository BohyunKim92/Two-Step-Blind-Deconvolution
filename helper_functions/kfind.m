function [ nextk ] = kfind(u_2,a,fc,cutlength)
%this function will help us find all the estimation k for the for two digit
% data we guessed.
% fp has to be part of fc for first two digits
u = shortupc2signal(u_2); % barcode of first 2 digit.
% we set threshold and it is changeable
threshold = 0.0001;





%% process below is to find stretched matrix A
%cutoff can be changed to fix dimention
cutoff = ceil(2*a);

%x = -cutoff:cutoff; 
fp = fc(1+cutlength:17*a-cutlength);

%lamda = lamda_c(fp);
lamda = 1/0.05;

% stretchedu is the stretched version of u0 
su=kron(eye(17),ones(a,1));
stretchedu = su*u';
n = length(stretchedu);

% prepare A and fc for interpretation


U = convmtx(stretchedu,2*cutlength+1);
A = U(2*cutlength+1:end-2*cutlength,:);


%% f
dt = 1/norm(A'*A);


%Deblur the data
thisk = zeros(2*cutlength+1,1);

nextk = min(1, max(0, thisk + dt*(-A'*(A*thisk-fp)-(lamda*thisk))));
D = [eye(size(thisk,1)) zeros(size(thisk,1),1)] - [zeros(size(thisk,1),1) eye(size(thisk,1))];
D = D(1:end-1,1:end-1);
L = D'*D;


rep = 0;
thresh = norm(nextk - thisk)/norm(thisk);
while (thresh > threshold) && (rep < 10^5);
    rep = rep + 1;
    thisk = nextk;
    nextk = min(1, max(0, thisk + dt*(-A'*(A*thisk-fp)-(lamda*L*thisk))));
    thresh = norm(nextk - thisk)/norm(thisk);
    if(mod(rep,10000) == 0)
        disp(thresh);
    end
end
end

