function test_Patch2ImageDistSpeed

P = rand(7,7,3)+1;
I = rand(250,250,3)+1;

tic;
D1 = Patch2ImageDistSlow(P, I);
toc;
tic;
for k=1:200
D2 = Patch2ImageDist(P, I);
end
toc;

fprintf('Difference between slow and fast algorithm is : %2.f\n', sum(sum(abs(D1-D2))));