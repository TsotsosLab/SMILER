% You can use this script to simply download the patched version of the
% QTFM library that includes the QDCT/IQDCT as well as to download some
% pre-compiled .mex files.
%
% @author B. Schauerte
% @date   2012,2013

% Copyright 2009-2012 B. Schauerte. All rights reserved.
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

%% download the QTFM with QDCT/IQDCT
choice = questdlg('Do you want to download and install the QTFM toolbox?', ...
	'Yes', ...
	'No');
switch choice
  case 'Yes'
    urlwrite('https://cvhci.anthropomatik.kit.edu/~bschauer/code/qdct-qtfm/qtfm-patched-qdct.zip','qtfm-patched-qdct.zip');
    unzip('qtfm-patched-qdct.zip','.');
  otherwise
end

%% download the QTDC .mex binaries
choice = questdlg('Do you want to download and install the QDCT .mex binaries?', ...
	'Yes', ...
	'No');
switch choice
  case 'Yes'
    urlwrite('https://cvhci.anthropomatik.kit.edu/~bschauer/code/qdct-mex-binaries/mexa64.zip','mexa64.zip');
    urlwrite('https://cvhci.anthropomatik.kit.edu/~bschauer/code/qdct-mex-binaries/mexw64.zip','mexw64.zip');
    unzip('mexa64.zip','qdct_impl/');
    unzip('mexw64.zip','qdct_impl/');
  otherwise
end

%% download and compile RC & LDRC
choice = questdlg('Do you want to download and build (locally biased) region contrast saliency?', ...
	'Yes', ...
	'No');
switch choice
  case 'Yes'
    urlwrite('https://github.com/bschauerte/region_contrast_saliency/archive/master.zip','ldrc.zip');
    unzip('ldrc.zip','region_saliency/');
    opwd = pwd();
    cd('region_saliency/region_contrast_saliency-master');
    build
    cd(opwd);
  otherwise
end