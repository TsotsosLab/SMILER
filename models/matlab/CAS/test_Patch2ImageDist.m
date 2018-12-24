function test_Patch2ImageDist

P = [2 0 0; 0 1 0; 0 0 1];
I = [1 2 3 0; 4 5 6 0; 7 8 9 0];

D = Patch2ImageDistSlow(P, I);
disp('Slow');
disp(D);

D = Patch2ImageDist(P, I);
disp('Fast');
disp(D);

P = rand(3,3,3)+1;
I = rand(250,250,3)+1;

tic;
D1 = Patch2ImageDistSlow(P, I);
toc;
tic;
for k=1:100
D2 = Patch2ImageDist(P, I);
end
toc;

fprintf('Difference between slow and fast algorithm is : %2.f\n', sum(sum(abs(D1-D2))));