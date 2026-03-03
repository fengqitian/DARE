function [finalMask, analysis, S_fused, S_dyn, S_sta, refinedMap, binaryMap] = DARE2_framework(frameBuffer, params)
    
    sceneDesc = scenePerception(frameBuffer, params.perception);
    
    % Adaptive Weighting: Fast -> Dyn, Accurate -> Sta
    [W_dyn, W_sta] = adaptiveWeighting(sceneDesc, params.weighting);
    
    
    fprintf('-> Executing Paths... W_dyn: %.2f, W_sta: %.2f\n', W_dyn, W_sta);
    
    % Path Execution
    S_dyn = dynamicFilteringPath_v2(frameBuffer, params.filtering);
    S_sta = lowRankPath_STT_v1(frameBuffer, params.lowrank_admm);
    
    
    % Fusion
    [finalMask, S_fused, refinedMap, binaryMap] = fusionAndRefinement(S_dyn, S_sta, ...
                                    W_dyn, W_sta, params.refinement);

    
    analysis.sceneDesc = sceneDesc;
    analysis.W_dyn = W_dyn;
    analysis.W_sta = W_sta;
    
end