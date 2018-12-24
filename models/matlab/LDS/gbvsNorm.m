function [img_b] = gbvsNorm(img)

if size(img,3)~= 1
    img = rgb2gray(img);
end

h=size(img,1);
w=size(img,2);
scale = 32 / max(w,h);
salmapsize = round( [ h w ] * scale );

ufile = sprintf('%s__m%s__%s.mat',num2str(salmapsize),num2str([]),num2str(2));
ufile(ufile==' ') = '_';
pathroot = 'initcache/';
ufile = fullfile( pathroot , ufile );
if ( exist(ufile, 'file') )
    grframe = load(ufile);
    grframe = grframe.grframe;
else
    grframe = graphsalinit( salmapsize , [] , 2, 2, 2 );
    save(ufile,'grframe');
end

img = double(img);

img = imresize(img,salmapsize);
img_b = graphsalapply( img , grframe, 0.06, 2, 1 ,  .0001 ); % iterate twice.