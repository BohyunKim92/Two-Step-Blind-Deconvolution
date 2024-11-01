function z = upc2signal (upc)

% Input: UPC signal, output: binary number describing barcode. 
% upc is a string containing exactly 12 digits
% u is the step signal read: 0 for white, 1 for black
% d is the first derivative of u: dirac functions


% Read first 6 digits: manufacturer's number
for i = 1:6
  if double(upc(i))-48 == 0
    u(1+7*(i-1):7+7*(i-1)) = [0 0 0 1 1 0 1];
  elseif double(upc(i))-48 == 1
    u(1+7*(i-1):7+7*(i-1)) = [0 0 1 1 0 0 1];  
  elseif double(upc(i))-48 == 2
    u(1+7*(i-1):7+7*(i-1)) = [0 0 1 0 0 1 1];  
  elseif double(upc(i))-48 == 3
    u(1+7*(i-1):7+7*(i-1)) = [0 1 1 1 1 0 1];   
  elseif double(upc(i))-48 == 4
    u(1+7*(i-1):7+7*(i-1)) = [0 1 0 0 0 1 1];   
  elseif double(upc(i))-48 == 5
    u(1+7*(i-1):7+7*(i-1)) = [0 1 1 0 0 0 1];   
  elseif double(upc(i))-48 == 6
    u(1+7*(i-1):7+7*(i-1)) = [0 1 0 1 1 1 1];   
  elseif double(upc(i))-48 == 7
    u(1+7*(i-1):7+7*(i-1)) = [0 1 1 1 0 1 1];   
  elseif double(upc(i))-48 == 8
    u(1+7*(i-1):7+7*(i-1)) = [0 1 1 0 1 1 1];
  else        % upc(i) == 9
    u(1+7*(i-1):7+7*(i-1)) = [0 0 0 1 0 1 1]; 
  end          
end

% Insert spacer between manufacturer's and product number: 01010.
u(43:47) = [0 1 0 1 0];

% Read last 6 digits: product number
for i = 7:12
  if double(upc(i))-48 == 0
     u(48+7*(i-7):54+7*(i-7)) = [1 1 1 0 0 1 0];
  elseif double(upc(i))-48 == 1
    u(48+7*(i-7):54+7*(i-7)) = [1 1 0 0 1 1 0];  
  elseif double(upc(i))-48 == 2
    u(48+7*(i-7):54+7*(i-7)) = [1 1 0 1 1 0 0];  
  elseif double(upc(i))-48 == 3
    u(48+7*(i-7):54+7*(i-7)) = [1 0 0 0 0 1 0];         
  elseif double(upc(i))-48 == 4
    u(48+7*(i-7):54+7*(i-7)) = [1 0 1 1 1 0 0];         
  elseif double(upc(i))-48 == 5
    u(48+7*(i-7):54+7*(i-7)) = [1 0 0 1 1 1 0];         
  elseif double(upc(i))-48 == 6
    u(48+7*(i-7):54+7*(i-7)) = [1 0 1 0 0 0 0];         
  elseif double(upc(i))-48 == 7
    u(48+7*(i-7):54+7*(i-7)) = [1 0 0 0 1 0 0];         
  elseif double(upc(i))-48 == 8
    u(48+7*(i-7):54+7*(i-7)) = [1 0 0 1 0 0 0];
  else        % upc(i) == 9
    u(48+7*(i-7):54+7*(i-7)) = [1 1 1 0 1 0 0]; 
  end          
end


z = zeros(1,95);
z(1:3) =[1 0 1];
z(4:end-3)=u;
z(end-2:end) =[1 0 1];
