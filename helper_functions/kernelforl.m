function [k_es,u_es,err,idx] = kernelforl(fc,a,cutlength)

%   Input:
%   fc = blurred barcode
%   a = stretching factor
%
%   Output:
%   k_es = estimated k (blurring kernel)
%   u_es = estimated u
%   err = err tolerance
%   idx = recovered first two digits.

err = 10000;
for i = 0:99
    k = kfind(num2str(i, '%02i'), a, fc,cutlength);
    u = deconvwnr(fc, k, 0.05);
    conre = conv(u,k);
    conre = conre(cutlength+1:end-cutlength);
    e = norm(fc - conre);
     
    if(e < err) 
        k_es = k;
        u_es = u;
        err = e;
        idx = i;
    end
end
end

