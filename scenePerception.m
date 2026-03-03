function sceneDesc = scenePerception(frameBuffer, params)
    
    currentFrame = double(frameBuffer(:,:,end));
    prevFrame = double(frameBuffer(:,:,end-1));

    
    tform = imregcorr(uint8(prevFrame), uint8(currentFrame));
    displacement = sqrt(tform.T(3,1)^2 + tform.T(3,2)^2);
    sceneDesc.D = min(1, displacement / params.maxDisplacement); 

    
    entropyMap = entropyfilt(uint8(frameBuffer(:,:,end)), true(params.entropySize));
    sceneDesc.C = mean(entropyMap(:)) / log2(params.entropySize^2); 

    
    high_thresh = mean(currentFrame(:)) + 2 * std(currentFrame(:));
    bright_mask = currentFrame > high_thresh;
    CC = bwconncomp(bright_mask);
    if CC.NumObjects > 0
        
        sparsity_metric = (1 / CC.NumObjects) * (1 - sum(bright_mask(:))/numel(bright_mask));
        sceneDesc.S = min(1, sparsity_metric * 5);
    else
        sceneDesc.S = 0;
    end
    
    fprintf('Scene Perception -> D: %.2f, C: %.2f, S: %.2f\n', sceneDesc.D, sceneDesc.C, sceneDesc.S);
end