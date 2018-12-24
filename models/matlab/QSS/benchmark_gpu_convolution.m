% A simple spectral saliency benchmark on the GPU.
%
% Question: At which resolution may it become beneficial to switch from a
%           CPU to a GPU implementation?
%
% Notes:
% - This is very simple code to check whether it makes sense to use the GPU
%   or not. Of course a specialized implementation may be faster
% - You can optionally exclude the memory transfer from the basic benchmark
% - Since the DCT code in principle relies on the FFT, the most costly
%   functions are equivalent and thus this code is more or less
%   representative for PFT/SW as well
%
% @author B. Schauerte
% @date 2012

% Copyright 2012 B. Schauerte. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%    1. Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%
%    2. Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the
%       distribution.
%
% THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR
% IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
% OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation
% are those of the authors and should not be interpreted as representing
% official policies, either expressed or implied, of B. Schauerte.

%%
if exist('gpu_idct2','file')
  gpu_idct2_func=@gpu_idct2;
else
  gpu_idct2_func=@idct2; % see error check below
end

%%
% A simple test to find a possible problem/bug
try
  foo=gpu_idct2_func(gpuArray(rand(64,64)));
catch err
  if strcmp(err.identifier,'MATLAB:UnableToConvert')
    fprintf(['You need to patch Matlab''s idct function. I.e., you need\n' ...
      'to change this:\n' ...
      '  %% Re-order elements of each column according to equations (5.93) and\n' ...
      '  %% (5.94) in Jain\n' ...
      '  a = zeros(n,m);\n' ...
      '  a(1:2:n,:) = y(1:n/2,:);\n' ...
      '  a(2:2:n,:) = y(n:-1:n/2+1,:);\n' ...
      'to:\n' ...
      '  %% Re-order elements of each column according to equations (5.93) and\n' ...
      '  %% (5.94) in Jain\n' ...
      '  a = parallel.gpu.GPUArray.zeros(n,m);\n' ...
      '  a(1:2:n,:) = y(1:n/2,:);\n' ...
      '  a(2:2:n,:) = y(n:-1:n/2+1,:);\n' ...
      'Unfortunately, since this is copyrighted code by Mathworks, I\n' ...
      'can not include an already patched version with the package.\n' ...
      'You best save the patched file as ''gpu_idct'' and also create\n' ...
      'a patched ''gpu_idct2'' that calls ''gpu_idct''.\n' ...
      ]);
    assert(false);
  else
    rethrow(err);
  end
end

%%
% Print information about the GPU
gdev=gpuDevice();
fprintf('Using %s as GPU ...\n', gdev.Name);

%%
% Number of benchmark runs to get more stable results
num_runs=10;

% incorporate the memory transfer in the benchmark?
benchmark_with_gpu_memory_in=false;
benchmark_with_gpu_memory_out=false;

%resolutions=[128,128;256,256;512,512;1024,1024];
resolutions=[64,48;128,96;256,192;320,240;640,480;1280,960;1600,1200];
times=zeros(size(resolutions,1),2);
for r=1:num_runs
  for i=1:size(resolutions,1)
    in=rand(resolutions(i,:));
    
    % memory transfer
    in_cpu=in;
    tic; in_gpu=gpuArray(in); t_gpu_transfer_in=toc;
    
    % pre-allocate the memory
    dct_gpu=parallel.gpu.GPUArray.zeros(size(in,1),size(in,2));
    sign_dct_gpu=parallel.gpu.GPUArray.zeros(size(in,1),size(in,2));
    idct_sign_dct_gpu=parallel.gpu.GPUArray.zeros(size(in,1),size(in,2));
    dct_cpu=zeros(size(in,1),size(in,2));
    sign_dct_cpu=zeros(size(in,1),size(in,2));
    idct_sign_dct_cpu=zeros(size(in,1),size(in,2));
    
    total_t_cpu=0;
    total_t_gpu=0;
    
    tic; dct_cpu=dct2(in_cpu); t_cpu=toc;
    tic; dct_gpu=dct2(in_gpu); t_gpu=toc;
    fprintf('OP=DCT2: size=[%4d %4d] GPU=%f CPU=%f\n',resolutions(i,1),resolutions(i,2),t_gpu,t_cpu);
    total_t_cpu=total_t_cpu+t_cpu; total_t_gpu=total_t_gpu+t_gpu;
    
    tic; sign_dct_cpu=sign(dct_cpu); t_cpu=toc;
    tic; sign_dct_gpu=sign(dct_gpu); t_gpu=toc;
    fprintf('OP=SIGN: size=[%4d %4d] GPU=%f CPU=%f\n',resolutions(i,1),resolutions(i,2),t_gpu,t_cpu);
    total_t_cpu=total_t_cpu+t_cpu; total_t_gpu=total_t_gpu+t_gpu;
    
    tic; idct_sign_dct_cpu=idct2(sign_dct_cpu).^2; t_cpu=toc;
    tic; idct_sign_dct_gpu=gpu_idct2_func(sign_dct_gpu).^2; t_gpu=toc;
    fprintf('OP=DCTI: size=[%4d %4d] GPU=%f CPU=%f\n',resolutions(i,1),resolutions(i,2),t_gpu,t_cpu);
    total_t_cpu=total_t_cpu+t_cpu; total_t_gpu=total_t_gpu+t_gpu;
    
    % @note: we don't do filtering here (but you can add it, if you wish)
    
    tic; out_gpu=gather(idct_sign_dct_gpu); t_gpu_transfer_out=toc;
    
    if benchmark_with_gpu_memory_in, total_t_gpu = total_t_gpu + t_gpu_transfer_in; end
    if benchmark_with_gpu_memory_out, total_t_gpu = total_t_gpu + t_gpu_transfer_out; end
    
    times(i,:) = times(i,:) + [total_t_cpu total_t_gpu];
  end
end

%%
figure
bar(times);
%plot(times);
xlabel('resolution');
ylabel('time');
xticklabels=[];
for i=1:size(resolutions,1)
  xticklabels=vertcat(xticklabels,sprintf('[%4d %4d]',resolutions(i,1),resolutions(i,2)));
end
set(gca,'XTickLabel',xticklabels)
legend('CPU','GPU');


% %%
% figure
% subplot(1,2,1); imshow(mat2gray(idct_sign_dct_cpu)); colormap('jet');
% subplot(1,2,2); imshow(mat2gray(gather(idct_sign_dct_gpu))); colormap('jet');