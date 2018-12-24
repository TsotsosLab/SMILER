function process_folder(infolder,outfolder,algorithm_params,infile_endings,outfile_endings)
  % PROCESS_FOLDER calculates the saliency maps for all images in a folder.
  % It copies the folder structure of the input folder.
  %
  % @author B. Schauerte
  % @date   2012

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

  if nargin < 1, infolder = 'example-images'; end
  if nargin < 2, outfolder = 'example-images-saliency'; end
  if nargin < 3, algorithm_params = {[NaN 64],'fft'}; end
  if nargin < 4, infile_endings = {'.png','.jpg','.jpeg','.bmp'}; end
  if nargin < 5, outfile_endings = {'.png'}; end

  mkdir(outfolder);
  
  infiles=getAllFiles(infolder);
  for i=1:numel(infiles)
    infile=infiles{i};
    outfile=strrep(infile,infolder,outfolder);
    
    % check file ending
    valid_file=false;
    infile_ending='';
    for j=1:numel(infile_endings)
      if ~isempty(regexp(infile,sprintf('%s%s',infile_endings{j},'$'), 'once'))
        valid_file=true;
        infile_ending=infile_endings{j};
        break;
      end
    end
    
    % process the image
    if valid_file
      % load the image
      image=imread(infile);
      
      % make it a MxNx3 image
      if size(image,3) == 1
        image=repmat(image,[1 1 3]);
      end
      
      % calculate the saliency map
      saliency_map=spectral_saliency_multichannel(im2double(image),algorithm_params{:});
      
      % create sub-folders if necessary
      [pathstr] = fileparts(outfile);
      if ~exist(pathstr,'dir')
        mkdir(pathstr);
      end
      
      % store the saliency map in the specified formats
      for j=1:numel(outfile_endings)
        outfile=strrep(outfile,infile_ending,outfile_endings{j});
        fprintf('%s -> %s\n',infile,outfile);
        switch outfile_endings{j}
          case {'.png'}
            imwrite(mat2gray(saliency_map),outfile);
            
          otherwise
            assert(false); % unknown file ending/type
        end
      end
    end
  end
end
  
function fileList = getAllFiles(dirName)
  dirData = dir(dirName);
  dirIndex = [dirData.isdir];
  fileList = {dirData(~dirIndex).name}';
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};
  validIndex = ~ismember(subDirs,{'.','..'});

  for iDir = find(validIndex)
    nextDir = fullfile(dirName,subDirs{iDir});
    fileList = [fileList; getAllFiles(nextDir)];
  end
end
