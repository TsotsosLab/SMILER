function [featMap] = ExtLocalFeat_intraScale_both_adaptive(image,a,b,way)


image = double(image);

%% Parameters.
[r,c] = size(image);
area_bound = floor(r*b*c*b);
sum_all = sum(image(:));
area_all = r*c;

t_ini = 40;
min_v = min(image(:));
max_v = max(image(:));
if max_v ~= min_v
    if way == 4
        thre = 0.0005*(max_v-min_v)*(max_v-min_v);
    else
        thre = 0.0005*(max_v-min_v);
    end
else
    fprintf('This image is empty.\n');
end
% thre = thre*thre; % Then the L2 can be squared.
% RC = (r*c)^2;
RC=r*c;

%% Initialization.
k = t_ini;

phi = extrFeatMap(image,t_ini,a,area_bound,sum_all,area_all,way);

counter = 1;
distance = 999999.0;
while distance > thre
    %% Calculate the feature map.
    phi_tmp = extrFeatMap(image,k,a,area_bound,sum_all,area_all,way);
    
    %% Judge whether need more random rectangles.
    distance = sqrt(sum(sum(abs(phi_tmp - phi).^2)))/RC;
    
    phi = (phi+phi_tmp)/2;
    k = 2*k;
    
    counter = counter + 1;
end

featMap = phi;

function [phi] = extrFeatMap(image,rt,a,area_bound,sum_all,area_all,way)
% output: the updated feature map after calculating contrast in "rt" random rectangles.
phi = zeros(size(image));
[r,c] = size(image);
counter = 0;

% t3 = tic;
while counter<rt
    x1 = floor(rand()*(r-1))+1;
    y1 = floor(rand()*(c-1))+1;
    
    x2 = floor(rand()*(r-1))+1;
    y2 = floor(rand()*(c-1))+1;
    
    area_2 = (abs(x1-x2)+1)*(abs(y1-y2)+1);
    if(x2 <r && y2 < c && x1 > 0 && y1 > 0) && area_2>area_bound
        
        l1 = x1;
        u1 = y1;
        
        l2 = x2;
        u2 = y2;
        
        if(x1>x2)
            l1 = x2;
            l2 = x1;
        end
        
        if(y1>y2)
            u1 = y2;
            u2 = y1;
        end
        
        sum_2 = sum(sum(image(l1:l2,u1:u2)));
        ml2 = sum_2/area_2;
        ml = (sum_all-sum_2)/(area_all-area_2);
        if way ==1 % max
            phi(l1:l2,u1:u2) = phi(l1:l2,u1:u2) + max(abs((image(l1:l2,u1:u2) - ml)),abs(image(l1:l2,u1:u2)-ml2));
        elseif way==2 % min
            phi(l1:l2,u1:u2) = phi(l1:l2,u1:u2) + min(abs((image(l1:l2,u1:u2) - ml)),abs(image(l1:l2,u1:u2)-ml2));
        elseif way == 3 % add
            phi(l1:l2,u1:u2) = phi(l1:l2,u1:u2) + a*abs((image(l1:l2,u1:u2) - ml))+(1-a)*abs(image(l1:l2,u1:u2)-ml2);
        elseif way==4 % multi
            phi(l1:l2,u1:u2) = phi(l1:l2,u1:u2) + abs((image(l1:l2,u1:u2) - ml)).*abs(image(l1:l2,u1:u2)-ml2);
        end
        counter =counter + 1;
    end
    
end
phi = phi/counter;
