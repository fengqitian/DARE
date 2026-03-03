clear; clc; close all;



baseInputDir = 'image';         
baseOutputDir = 'results';    
targetSubFolders = {'1'};  



imgType = '*.png';              
bufferSize = 15;                



params.perception.maxDisplacement = 10; 
params.perception.entropySize = 9;


params.weighting.dynamismFactor = 0.5; 
params.weighting.complexityFactor = 0.5;


params.filtering.temporalInterval = 2; 
params.filtering.alpha = 2.0;
params.filtering.imregcorrType = 'similarity'; 
params.filtering.imwarpFillValue = NaN;        


params.lowrank_admm.lambda = 1.7;      
params.lowrank_admm.maxIter = 100; 
params.lowrank_admm.tolerance = 1e-4; 


params.refinement.minArea = 6;        
params.refinement.k_factor = 4.0;     
params.refinement.absSigma = 20; 
params.refinement.absThreshold = 0.1;



if ~exist(baseInputDir, 'dir')
    error('错误：未找到输入根目录 "%s"。', baseInputDir);
end

fprintf('开始处理 %d 个子文件夹...\n', length(targetSubFolders));

for k = 1:length(targetSubFolders)
    subFolderName = targetSubFolders{k};
    
  
    currentInputPath = fullfile(baseInputDir, subFolderName);
    currentOutputPath = fullfile(baseOutputDir, subFolderName);
    
  
    if ~exist(currentInputPath, 'dir')
        warning('跳过：找不到子文件夹 "%s"', currentInputPath);
        continue;
    end
    
    
    if ~exist(currentOutputPath, 'dir')
        mkdir(currentOutputPath);
    end
    
    
    imageFiles = dir(fullfile(currentInputPath, imgType));
    numFrames = length(imageFiles);
    
    if numFrames == 0
        warning('文件夹 "%s" 中没有找到图片。', subFolderName);
        continue;
    end
    
    fprintf('\n=== 正在处理文件夹: %s (共 %d 帧) ===\n', subFolderName, numFrames);
    

    frameBuffer = []; 
    
    
    for t = 1:numFrames
        imgName = imageFiles(t).name;
        fullImgPath = fullfile(currentInputPath, imgName);
        
        
        currentFrame = double(imread(fullImgPath));
        if size(currentFrame, 3) > 1
            currentFrame = rgb2gray(currentFrame);
        end
        
        
        frameBuffer = cat(3, frameBuffer, currentFrame);
        if size(frameBuffer, 3) > bufferSize
            frameBuffer = frameBuffer(:,:,2:end);
        end
        
       
        if size(frameBuffer, 3) == bufferSize
           
            [finalMask, ~] = DARE2_framework(frameBuffer, params);
            
           
            [~, fname, ~] = fileparts(imgName);
            saveName = sprintf('%s_mask.png', fname);
            saveFullPath = fullfile(currentOutputPath, saveName);
            
           
            imwrite(finalMask, saveFullPath);
            
            
            if mod(t, 10) == 0 || t == numFrames
                fprintf('Folder %s: 已处理 %d/%d\n', subFolderName, t, numFrames);
            end
        end
    end
end

fprintf('\n==================================\n');
fprintf('所有文件夹处理完毕。\n');
fprintf('结果已保存在 "%s" 目录下。\n', baseOutputDir);